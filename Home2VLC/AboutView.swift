import SwiftUI

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // App Icon and Title
                VStack(spacing: 16) {
                    Image(systemName: "tv.and.mediabox")
                        .font(.system(size: 80))
                        .foregroundStyle(.blue)
                    
                    VStack(spacing: 4) {
                        Text("Home2VLC")
                            .font(.largeTitle)
                            .bold()
                        
                        Text("Stream media to VLC with ease")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.top, 20)
                
                // App Information
                VStack(alignment: .leading, spacing: 16) {
                    Text("About")
                        .font(.title2)
                        .bold()
                        .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        InfoRow(label: "Version", value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                        InfoRow(label: "Build", value: Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1")
                        InfoRow(label: "Bundle ID", value: Bundle.main.bundleIdentifier ?? "Unknown")
                        InfoRow(label: "Platform", value: "iOS/tvOS")
                        InfoRow(label: "Framework", value: "SwiftUI")
                    }
                    .padding()
                    #if os(iOS)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    #else
                    .background(Color.gray.opacity(0.15))
                    #endif
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                
                // Features
                VStack(alignment: .leading, spacing: 16) {
                    Text("Features")
                        .font(.title2)
                        .bold()
                        .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        FeatureRow(icon: "play.rectangle.fill", title: "Stream to VLC", description: "Send any media URL directly to VLC for playback")
                        FeatureRow(icon: "network", title: "Web Server", description: "Control remotely via HTTP API on customizable port")
                        FeatureRow(icon: "clock.arrow.circlepath", title: "URL History", description: "Keep track of recently played media URLs")
                        FeatureRow(icon: "link", title: "Deep Links", description: "Launch and play media via home2vlc:// URL scheme")
                        FeatureRow(icon: "gear", title: "Customizable", description: "Adjust settings for your perfect streaming experience")
                        FeatureRow(icon: "appletvremote.gen4", title: "tvOS Ready", description: "Optimized for Apple TV remote control navigation")
                    }
                    .padding()
                    #if os(iOS)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    #else
                    .background(Color.gray.opacity(0.15))
                    #endif
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                
                // Usage Examples
                VStack(alignment: .leading, spacing: 16) {
                    Text("Usage Examples")
                        .font(.title2)
                        .bold()
                        .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        UsageExample(title: "Manual Entry", description: "Type or paste any media URL into the app")
                        UsageExample(title: "HTTP API", description: "POST to http://device-ip:8080/play with url parameter")
                        UsageExample(title: "Deep Link", description: "Open home2vlc://play?url=your-media-url")
                        UsageExample(title: "Home Assistant", description: "Integrate with smart home automations")
                    }
                    .padding()
                    #if os(iOS)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    #else
                    .background(Color.gray.opacity(0.15))
                    #endif
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                
                // Developer and Links
                VStack(alignment: .leading, spacing: 16) {
                    Text("Developer")
                        .font(.title2)
                        .bold()
                        .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .foregroundStyle(.blue)
                                .font(.title2)
                            VStack(alignment: .leading) {
                                Text("Nathan Dykstra")
                                    .font(.headline)
                                Text("Software Developer")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                        
                        Link(destination: URL(string: "https://github.com/ve3ndq/Home2VLC")!) {
                            HStack {
                                Image(systemName: "link.circle.fill")
                                    .foregroundStyle(.blue)
                                Text("GitHub Repository")
                                    .foregroundStyle(.blue)
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .foregroundStyle(.blue)
                                    .font(.caption)
                            }
                        }
                        
                        HStack {
                            Image(systemName: "doc.text.fill")
                                .foregroundStyle(.green)
                            Text("MIT License")
                            Spacer()
                            Text("Open Source")
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
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                
                // Requirements
                VStack(alignment: .leading, spacing: 16) {
                    Text("Requirements")
                        .font(.title2)
                        .bold()
                        .padding(.horizontal)
                    
                    VStack(spacing: 8) {
                        RequirementRow(icon: "tv.fill", title: "Apple TV 4K or Apple TV HD")
                        RequirementRow(icon: "iphone", title: "iOS 15.0+ / tvOS 15.0+")
                        RequirementRow(icon: "play.rectangle.fill", title: "VLC Media Player installed")
                        RequirementRow(icon: "wifi", title: "Network connection for HTTP API")
                    }
                    .padding()
                    #if os(iOS)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    #else
                    .background(Color.gray.opacity(0.15))
                    #endif
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                
                // Footer
                VStack(spacing: 8) {
                    Text("Made with ❤️ for the Home Automation Community")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Text("© 2025 Nathan Dykstra")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("About")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.primary)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
                .font(.system(.body, design: .monospaced))
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.blue)
                .font(.title2)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
    }
}

struct UsageExample: View {
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(.blue)
                .frame(width: 8, height: 8)
                .padding(.top, 6)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
    }
}

struct RequirementRow: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.green)
                .font(.title3)
                .frame(width: 20)
            
            Text(title)
                .font(.subheadline)
            
            Spacer()
        }
    }
}

#Preview {
    NavigationView {
        AboutView()
    }
}