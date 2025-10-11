import SwiftUI

struct SettingsView: View {
    @AppStorage("webserverEnabled") private var webserverEnabled: Bool = true
    @AppStorage("webserverPort") private var webserverPort: Int = 8080
    @AppStorage("historyCount") private var historyCount: Int = 10
    @AppStorage("autoPlayDeepLinks") private var autoPlayDeepLinks: Bool = true
    @AppStorage("showNetworkStatus") private var showNetworkStatus: Bool = true
    @AppStorage("hapticFeedback") private var hapticFeedback: Bool = true
    @AppStorage("confirmClearHistory") private var confirmClearHistory: Bool = true
    @AppStorage("autoCollapseHistory") private var autoCollapseHistory: Bool = false
    @AppStorage("defaultURLScheme") private var defaultURLScheme: String = "http://"
    
    @State private var showingClearHistoryAlert = false
    @State private var tempPort: String = ""
    @State private var tempHistoryCount: String = ""
    
    var onSettingsChanged: () -> Void
    var onClearHistory: () -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section("Web Server") {
                    Toggle("Enable Web Server", isOn: $webserverEnabled)
                        .onChange(of: webserverEnabled) { _ in
                            onSettingsChanged()
                        }
                    
                    HStack {
                        Text("Port")
                        Spacer()
                        TextField("Port", text: $tempPort)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                            .onSubmit {
                                updatePort()
                            }
                    }
                    .disabled(!webserverEnabled)
                    
                    if webserverEnabled {
                        Text("Server accessible at port \(webserverPort)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Section("History") {
                    HStack {
                        Text("Max History Items")
                        Spacer()
                        TextField("Count", text: $tempHistoryCount)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 60)
                            .onSubmit {
                                updateHistoryCount()
                            }
                    }
                    
                    Toggle("Auto-collapse History", isOn: $autoCollapseHistory)
                    
                    Toggle("Confirm Before Clearing", isOn: $confirmClearHistory)
                    
                    Button("Clear History") {
                        if confirmClearHistory {
                            showingClearHistoryAlert = true
                        } else {
                            clearHistory()
                        }
                    }
                    .foregroundStyle(.red)
                }
                
                Section("Playback") {
                    Toggle("Auto-play Deep Links", isOn: $autoPlayDeepLinks)
                    
                    Picker("Default URL Scheme", selection: $defaultURLScheme) {
                        Text("http://").tag("http://")
                        Text("https://").tag("https://")
                        Text("rtsp://").tag("rtsp://")
                        Text("ftp://").tag("ftp://")
                    }
                }
                
                Section("Interface") {
                    Toggle("Show Network Status", isOn: $showNetworkStatus)
                        .onChange(of: showNetworkStatus) { _ in
                            onSettingsChanged()
                        }
                    
                    #if os(iOS)
                    Toggle("Haptic Feedback", isOn: $hapticFeedback)
                    #endif
                }
                
                Section("Information") {
                    HStack {
                        Text("App Version")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("Build Number")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("Bundle ID")
                        Spacer()
                        Text(Bundle.main.bundleIdentifier ?? "Unknown")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Section("About") {
                    Link("GitHub Repository", destination: URL(string: "https://github.com/ve3ndq/Home2VLC")!)
                    
                    HStack {
                        Text("Developer")
                        Spacer()
                        Text("Nathan Dykstra")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
        }
        .onAppear {
            tempPort = String(webserverPort)
            tempHistoryCount = String(historyCount)
        }
        .alert("Clear History", isPresented: $showingClearHistoryAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Clear", role: .destructive) {
                clearHistory()
            }
        } message: {
            Text("This will permanently delete all URL history. This action cannot be undone.")
        }
    }
    
    private func updatePort() {
        if let port = Int(tempPort), port >= 1024, port <= 65535 {
            webserverPort = port
            onSettingsChanged()
        } else {
            tempPort = String(webserverPort)
        }
    }
    
    private func updateHistoryCount() {
        if let count = Int(tempHistoryCount), count >= 1, count <= 50 {
            historyCount = count
        } else {
            tempHistoryCount = String(historyCount)
        }
    }
    
    private func clearHistory() {
        onClearHistory()
    }
}

#Preview {
    SettingsView(
        onSettingsChanged: {},
        onClearHistory: {}
    )
}