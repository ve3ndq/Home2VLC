//
//  Home2VLCTests.swift
//  Home2VLCTests
//
//  Created by Nathan Dykstra on 2025-10-11.
//

import Testing
import Foundation
@testable import Home2VLC

struct Home2VLCTests {

    @Test @MainActor func playerPreferenceDefaultsAndPersists() throws {
        let suite = "Home2VLC-tests-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        #expect(PlaybackMode.selected(in: defaults) == .externalVLC)
        defaults.set(PlaybackMode.embeddedVLC.rawValue, forKey: "playbackMode")
        #expect(PlaybackMode.selected(in: defaults) == .embeddedVLC)
        defaults.set("unknown-future-mode", forKey: "playbackMode")
        #expect(PlaybackMode.selected(in: defaults) == .externalVLC)
    }

    @Test @MainActor func signedMediaURLIsPreserved() throws {
        let signed = "https://example.com/live.ts?token=a%2Fb%2B%25&expires=123&name=hello+world#track"
        let url = try #require(PlaybackController.mediaURL(from: " \(signed)\n"))
        #expect(url.absoluteString == signed)
    }

    @Test @MainActor func rejectsNonMediaURLs() {
        for value in ["", "example.com/video.mp4", "https://", "file:///private/file", "home2vlc://play", "javascript:alert(1)"] {
            #expect(PlaybackController.mediaURL(from: value) == nil)
        }
        #expect(PlaybackController.mediaURL(from: "rtsp://example.com:554/live") != nil)
    }

    @Test @MainActor func embeddedPlaybackAcceptsReplacementAndStops() throws {
        let suite = "Home2VLC-playback-tests-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        defaults.set(PlaybackMode.embeddedVLC.rawValue, forKey: "playbackMode")
        let playback = PlaybackController(defaults: defaults)
        defer { playback.stop() }
        var accepted = false
        // Local closed port: exercises the library without external media or credentials.
        playback.playURL("http://127.0.0.1:9/first.mp4") { accepted = $0 }
        #expect(accepted)
        #expect(playback.isPresented)
        playback.playURL("http://127.0.0.1:9/second.mp4") { accepted = $0 }
        #expect(accepted)
        #expect(playback.isPresented)
        playback.stop()
        #expect(!playback.isPresented)
        #expect(!playback.isPlaying)
        playback.playURL("file:///private/file") { accepted = $0 }
        #expect(!accepted)
        #expect(!playback.isPresented)
    }
}
