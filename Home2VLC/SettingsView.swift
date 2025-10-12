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
    @State private var showAboutView = false
    
    var onSettingsChanged: () -> Void
    var onClearHistory: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack {
                    Text("Settings")
                        .font(.largeTitle)
                        .bold()
                    Spacer()
                }
                .padding(.bottom, 10)
                
                // Web Server Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Web Server")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    Toggle("Enable Web Server", isOn: $webserverEnabled)
                        .onChange(of: webserverEnabled) { _ in
                            onSettingsChanged()
                        }
                        #if os(tvOS)
                        .focusEffectDisabled()
                        #endif
                    
                    HStack {
                        Text("Port")
                        Spacer()
                        TextField("Port", text: $tempPort)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 140)
                            #if os(iOS)
                            .textFieldStyle(.roundedBorder)
                            #else
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(6)
                            .focusEffectDisabled()
                            #endif
                            .onSubmit {
                                updatePort()
                            }
                            .disabled(!webserverEnabled)
                    }
                    
                    if webserverEnabled {
                        Text("Server accessible at port \(webserverPort)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
                #if os(iOS)
                .background(Color(UIColor.secondarySystemGroupedBackground))
                #else
                .background(Color.gray.opacity(0.15))
                #endif
                .cornerRadius(10)
                
                // History Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("History")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    HStack {
                        Text("Max History Items")
                        Spacer()
                        TextField("Count", text: $tempHistoryCount)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 140)
                            #if os(iOS)
                            .textFieldStyle(.roundedBorder)
                            #else
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(6)
                            .focusEffectDisabled()
                            #endif
                            .onSubmit {
                                updateHistoryCount()
                            }
                    }
                    
                    Toggle("Auto-collapse History", isOn: $autoCollapseHistory)
                        #if os(tvOS)
                        .focusEffectDisabled()
                        #endif
                    
                    Toggle("Confirm Before Clearing", isOn: $confirmClearHistory)
                        #if os(tvOS)
                        .focusEffectDisabled()
                        #endif
                    
                    Button("Clear History") {
                        if confirmClearHistory {
                            showingClearHistoryAlert = true
                        } else {
                            clearHistory()
                        }
                    }
                    .foregroundStyle(.red)
                    #if os(tvOS)
                    .focusEffectDisabled()
                    #endif
                }
                .padding()
                #if os(iOS)
                .background(Color(UIColor.secondarySystemGroupedBackground))
                #else
                .background(Color.gray.opacity(0.15))
                #endif
                .cornerRadius(10)
                
                // Playback Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Playback")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    Toggle("Auto-play Deep Links", isOn: $autoPlayDeepLinks)
                        #if os(tvOS)
                        .focusEffectDisabled()
                        #endif
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Default URL Scheme")
                        HStack {
                            ForEach(["http://", "https://", "rtsp://", "ftp://"], id: \.self) { scheme in
                                Button(scheme) {
                                    defaultURLScheme = scheme
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                #if os(iOS)
                                .background(defaultURLScheme == scheme ? Color.accentColor : Color(UIColor.tertiarySystemFill))
                                #else
                                .background(defaultURLScheme == scheme ? Color.accentColor : Color.gray.opacity(0.2))
                                #endif
                                .foregroundStyle(defaultURLScheme == scheme ? .white : .primary)
                                .cornerRadius(6)
                                #if os(tvOS)
                                .focusEffectDisabled()
                                #endif
                            }
                        }
                    }
                }
                .padding()
                #if os(iOS)
                .background(Color(UIColor.secondarySystemGroupedBackground))
                #else
                .background(Color.gray.opacity(0.15))
                #endif
                .cornerRadius(10)
                
                // Interface Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Interface")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    Toggle("Show Network Status", isOn: $showNetworkStatus)
                        .onChange(of: showNetworkStatus) { _ in
                            onSettingsChanged()
                        }
                        #if os(tvOS)
                        .focusEffectDisabled()
                        #endif
                    
                    #if os(iOS)
                    Toggle("Haptic Feedback", isOn: $hapticFeedback)
                    #endif
                }
                .padding()
                #if os(iOS)
                .background(Color(UIColor.secondarySystemGroupedBackground))
                #else
                .background(Color.gray.opacity(0.15))
                #endif
                .cornerRadius(10)
                
                // Information Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Information")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
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
                .padding()
                #if os(iOS)
                .background(Color(UIColor.secondarySystemGroupedBackground))
                #else
                .background(Color.gray.opacity(0.15))
                #endif
                .cornerRadius(10)
                
                // About Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("About")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    Button(action: { showAboutView = true }) {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundStyle(.blue)
                            Text("About Home2VLC")
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                                .font(.caption)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Link(destination: URL(string: "https://github.com/ve3ndq/Home2VLC")!) {
                        HStack {
                            Image(systemName: "link")
                                .foregroundStyle(.blue)
                            Text("GitHub Repository")
                                .foregroundStyle(.blue)
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .foregroundStyle(.blue)
                                .font(.caption)
                        }
                    }
                    #if os(tvOS)
                    .focusEffectDisabled()
                    #endif
                    
                    HStack {
                        Image(systemName: "person.circle")
                            .foregroundStyle(.secondary)
                        Text("Developer")
                        Spacer()
                        Text("Nathan Dykstra")
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
                #if os(iOS)
                .background(Color(UIColor.secondarySystemGroupedBackground))
                #else
                .background(Color.gray.opacity(0.15))
                #endif
                .cornerRadius(10)
            }
            .padding()
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
        .sheet(isPresented: $showAboutView) {
            NavigationView {
                AboutView()
                    #if os(iOS)
                    .navigationBarTitleDisplayMode(.large)
                    #endif
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                showAboutView = false
                            }
                        }
                    }
            }
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
