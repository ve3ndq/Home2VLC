//
//  ContentView.swift
//  Home2VLC
//
//  Created by Nathan Dykstra on 2025-10-11.
//



import SwiftUI
import SystemConfiguration

struct ContentView: View {
    @State private var urlString: String = "http://sample.com:80/<user>/<password>/stream.ts"
    @State private var errorMessage: String?
    @State private var serverStatus: String = ""
    @State private var urlHistory: [String] = []
    @State private var showHistory: Bool = false
    
    private let maxHistoryItems = 10

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Open Stream in VLC")
                .font(.title2)
                .bold()

            HStack(spacing: 8) {
                Circle()
                    .fill(serverStatus.isEmpty ? .gray : .green)
                    .frame(width: 10, height: 10)
                Text(serverStatus.isEmpty ? "Server starting…" : serverStatus)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            TextField("Enter media URL (http, https, rtsp, etc.)", text: $urlString)
#if os(iOS)
                .textFieldStyle(.roundedBorder)
#else
                // Fallback style for platforms where .roundedBorder is unavailable (e.g., tvOS)
                .textFieldStyle(.plain)
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(.quaternary)
                )
#endif
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                #if os(iOS)
                .keyboardType(.URL)
                #endif

            Button(action: openInVLC) {
                HStack {
                    Image(systemName: "play.rectangle.fill")
                    Text("Open in VLC")
                        .bold()
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!canOpen)

            // History toggle button
            if !urlHistory.isEmpty {
                Button(action: { showHistory.toggle() }) {
                    HStack {
                        Image(systemName: showHistory ? "chevron.up" : "chevron.down")
                        Text("URL History (\(urlHistory.count))")
                        Spacer()
                    }
                    .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }

            // URL History List
            if showHistory && !urlHistory.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Recent URLs:")
                        .font(.headline)
                        .padding(.top, 8)
                    
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 6) {
                            ForEach(Array(urlHistory.enumerated()), id: \.offset) { index, url in
                                Button(action: { selectHistoryURL(url) }) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        HStack {
                                            Image(systemName: index < 3 ? "wifi" : "clock.arrow.circlepath")
                                                .foregroundStyle(.secondary)
                                                .font(.caption)
                                            Text("\(index + 1).")
                                                .foregroundStyle(.secondary)
                                                .font(.caption)
                                            Spacer()
                                            if index < 3 {
                                                Text("API")
                                                    .font(.caption2)
                                                    .foregroundStyle(.blue)
                                                    .padding(.horizontal, 4)
                                                    .padding(.vertical, 1)
                                                    .background(
                                                        RoundedRectangle(cornerRadius: 3)
                                                            .fill(.blue.opacity(0.1))
                                                    )
                                            }
                                        }
                                        Text(url)
                                            .font(.system(.body, design: .monospaced))
                                            .foregroundStyle(.primary)
                                            .multilineTextAlignment(.leading)
                                            .lineLimit(2)
                                    }
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(.quaternary)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .frame(maxHeight: 200)
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }

            if let errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
                    .font(.footnote)
            }

            Spacer()
        }
        .padding()
        .animation(.easeInOut(duration: 0.3), value: showHistory)
        .onAppear {
            LocalHTTPServer.shared.start(on: 8080)
            
            // Set up callback to receive URLs from web server
            LocalHTTPServer.shared.onURLReceived = { [self] url in
                self.addToHistory(url)
            }
            
            DispatchQueue.main.async {
                let ip = self.localIPv4Address() ?? "<unknown>"
                self.serverStatus = "Server running on \(ip):\(LocalHTTPServer.shared.port)"
            }
            loadURLHistory()
        }
    }

    private var canOpen: Bool {
        guard let url = URL(string: urlString.trimmingCharacters(in: .whitespacesAndNewlines)), !urlString.isEmpty else { return false }
        // Require at least a scheme and host/path
        return url.scheme != nil
    }

    private func openInVLC() {
        errorMessage = nil
        let trimmed = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            errorMessage = "Please enter a valid URL."
            return
        }

        // Add to history before attempting to play
        addToHistory(trimmed)

        VLCLauncher.shared.playURL(trimmed, title: nil) { success in
            if !success {
                DispatchQueue.main.async {
                    self.errorMessage = "Could not open URL in VLC or any supported app."
                }
            }
        }
    }
    
    private func selectHistoryURL(_ url: String) {
        urlString = url
        openInVLC()
    }
    
    private func addToHistory(_ url: String) {
        // Remove if already exists to avoid duplicates
        urlHistory.removeAll { $0 == url }
        
        // Add to beginning
        urlHistory.insert(url, at: 0)
        
        // Keep only the most recent items
        if urlHistory.count > maxHistoryItems {
            urlHistory = Array(urlHistory.prefix(maxHistoryItems))
        }
        
        // Save to UserDefaults
        saveURLHistory()
    }
    
    private func saveURLHistory() {
        UserDefaults.standard.set(urlHistory, forKey: "Home2VLC_URLHistory")
    }
    
    private func loadURLHistory() {
        if let savedHistory = UserDefaults.standard.array(forKey: "Home2VLC_URLHistory") as? [String] {
            urlHistory = Array(savedHistory.prefix(maxHistoryItems))
        }
    }

    private func localIPv4Address() -> String? {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>? = nil
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                defer { ptr = ptr?.pointee.ifa_next }
                guard let interface = ptr?.pointee else { continue }
                let addrFamily = interface.ifa_addr.pointee.sa_family
                if addrFamily == UInt8(AF_INET) { // IPv4 only
                    let name = String(cString: interface.ifa_name)
                    // Prefer Wi-Fi/Ethernet-like interfaces
                    if name.hasPrefix("en") || name.hasPrefix("enp") || name.hasPrefix("eth") || name.hasPrefix("wl") {
                        var addr = interface.ifa_addr.pointee
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        let result = getnameinfo(&addr, socklen_t(interface.ifa_addr.pointee.sa_len), &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST)
                        if result == 0 {
                            address = String(cString: hostname)
                            break
                        }
                    }
                }
            }
            freeifaddrs(ifaddr)
        }
        return address
    }
}

#Preview {
    ContentView()
}
