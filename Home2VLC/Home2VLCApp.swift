//
//  Home2VLCApp.swift
//  Home2VLC
//
//  Created by Nathan Dykstra on 2025-10-11.
//

import SwiftUI

@main
struct Home2VLCApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    handleDeepLink(url)
                }
        }
    }
    
    private func handleDeepLink(_ url: URL) {
        // Post notification to ContentView to handle the URL
        NotificationCenter.default.post(
            name: NSNotification.Name("HandleDeepLink"),
            object: url
        )
    }
}
