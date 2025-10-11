import Foundation
import Network
import os.log
import UIKit

final class LocalHTTPServer {
    static let shared = LocalHTTPServer()

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "LocalHTTPServer", category: "HTTP")
    private var listener: NWListener?
    private let queue = DispatchQueue(label: "LocalHTTPServer.queue")
    private(set) var port: UInt16 = 8080

    private init() {}

    func start(on port: UInt16 = 8080) {
        queue.async { [weak self] in
            guard let self = self else { return }
            if self.listener != nil { return }
            self.port = port
            do {
                let params = NWParameters.tcp
                self.listener = try NWListener(using: params, on: NWEndpoint.Port(rawValue: port)!)
                self.listener?.newConnectionHandler = { [weak self] connection in
                    self?.handle(connection: connection)
                }
                self.listener?.stateUpdateHandler = { [weak self] state in
                    self?.logger.debug("Listener state: \(String(describing: state))")
                }
                self.listener?.start(queue: self.queue)
                self.logger.info("HTTP server started on port \(self.port)")
            } catch {
                self.logger.error("Failed to start listener: \(error.localizedDescription)")
            }
        }
    }

    func stop() {
        queue.async { [weak self] in
            self?.listener?.cancel()
            self?.listener = nil
            self?.logger.info("HTTP server stopped")
        }
    }

    private func handle(connection: NWConnection) {
        connection.stateUpdateHandler = { [weak self] state in
            switch state {
            case .ready:
                self?.receive(on: connection)
            case .failed(let error):
                self?.logger.error("Connection failed: \(error.localizedDescription)")
                connection.cancel()
            case .cancelled:
                break
            default:
                break
            }
        }
        connection.start(queue: queue)
    }

    private func receive(on connection: NWConnection, accumulated: Data = Data()) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 64 * 1024) { [weak self] content, _, isComplete, error in
            guard let self = self else { return }
            if let error = error {
                self.logger.error("Receive error: \(error.localizedDescription)")
                connection.cancel()
                return
            }
            var data = accumulated
            if let content = content { data.append(content) }

            // Try to parse a full HTTP request (simple, not streaming)
            if let request = HTTPRequestParser.parse(from: data) {
                self.process(request: request, on: connection)
                return
            }

            if isComplete {
                // Could not parse, respond 400
                self.sendResponse(status: 400, body: "Bad Request", on: connection)
                return
            }

            // Keep receiving until we can parse
            self.receive(on: connection, accumulated: data)
        }
    }

    private func process(request: HTTPRequest, on connection: NWConnection) {
        if request.method == "POST" && request.path == "/play" {
            let contentType = request.headers["content-type"]?.lowercased() ?? ""
            var urlParam: String?
            if contentType.contains("application/x-www-form-urlencoded") {
                let bodyString = String(data: request.body, encoding: .utf8) ?? ""
                let params = Self.parseFormURLEncoded(bodyString)
                urlParam = params["url"]
            } else {
                sendResponse(status: 400, body: "Unsupported Content-Type", on: connection)
                return
            }

            guard let urlParam, !urlParam.isEmpty else {
                sendResponse(status: 400, body: "Missing 'url' parameter", on: connection)
                return
            }

            VLCLauncher.shared.playURL(urlParam, title: nil) { success in
                let status = success ? 200 : 502
                let body = success ? "OK" : "Failed to open URL"
                self.sendResponse(status: status, body: body, on: connection)
            }
        } else {
            sendResponse(status: 404, body: "Not Found", on: connection)
        }
    }

    private func sendResponse(status: Int, body: String, on connection: NWConnection) {
        let bodyData = body.data(using: .utf8) ?? Data()
        let response = "HTTP/1.1 \(status) \(Self.reasonPhrase(for: status))\r\nContent-Type: text/plain; charset=utf-8\r\nContent-Length: \(bodyData.count)\r\nConnection: close\r\n\r\n".data(using: .utf8)! + bodyData
        connection.send(content: response, completion: .contentProcessed { _ in
            connection.cancel()
        })
    }

    private static func reasonPhrase(for status: Int) -> String {
        switch status {
        case 200: return "OK"
        case 400: return "Bad Request"
        case 404: return "Not Found"
        case 502: return "Bad Gateway"
        default: return "Status"
        }
    }

    private static func parseFormURLEncoded(_ s: String) -> [String: String] {
        var result: [String: String] = [:]
        for pair in s.split(separator: "&") {
            let parts = pair.split(separator: "=", maxSplits: 1).map(String.init)
            guard parts.count == 2 else { continue }
            let key = parts[0].replacingOccurrences(of: "+", with: " ").removingPercentEncoding ?? parts[0]
            let value = parts[1].replacingOccurrences(of: "+", with: " ").removingPercentEncoding ?? parts[1]
            result[key] = value
        }
        return result
    }
}

// Simple HTTP request representation and parser for our limited needs
private struct HTTPRequest {
    let method: String
    let path: String
    let headers: [String: String]
    let body: Data
}

private enum HTTPRequestParser {
    static func parse(from data: Data) -> HTTPRequest? {
        guard let s = String(data: data, encoding: .utf8) else { return nil }
        // Separate headers and body
        guard let headerRange = s.range(of: "\r\n\r\n") else { return nil }
        let headerPart = String(s[..<headerRange.lowerBound])
        let bodyPart = String(s[headerRange.upperBound...])

        let lines = headerPart.split(separator: "\r\n", omittingEmptySubsequences: false).map(String.init)
        guard let requestLine = lines.first else { return nil }
        let comps = requestLine.split(separator: " ")
        guard comps.count >= 2 else { return nil }
        let method = String(comps[0])
        let path = String(comps[1])

        var headers: [String: String] = [:]
        for line in lines.dropFirst() {
            if let sep = line.firstIndex(of: ":") {
                let name = line[..<sep].trimmingCharacters(in: .whitespaces).lowercased()
                let value = line[line.index(after: sep)...].trimmingCharacters(in: .whitespaces)
                headers[name] = value
            }
        }

        // If Content-Length is present, ensure we have full body
        if let cl = headers["content-length"], let expected = Int(cl) {
            if bodyPart.utf8.count < expected { return nil }
            let bodyData = Data(bodyPart.utf8.prefix(expected))
            return HTTPRequest(method: method, path: path, headers: headers, body: bodyData)
        } else {
            // No content-length; treat remaining as body
            return HTTPRequest(method: method, path: path, headers: headers, body: Data(bodyPart.utf8))
        }
    }
}
