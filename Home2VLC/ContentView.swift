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

            if let errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
                    .font(.footnote)
            }

            Spacer()
        }
        .padding()
        .onAppear {
            LocalHTTPServer.shared.start(on: 8080)
            DispatchQueue.main.async {
                let ip = self.localIPv4Address() ?? "<unknown>"
                self.serverStatus = "Server running on \(ip):\(LocalHTTPServer.shared.port)"
            }
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

        VLCLauncher.shared.playURL(trimmed, title: nil) { success in
            if !success {
                DispatchQueue.main.async {
                    self.errorMessage = "Could not open URL in VLC or any supported app."
                }
            }
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
