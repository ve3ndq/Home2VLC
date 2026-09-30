import Combine
import Foundation
import TVVLCKit
import UIKit

enum PlaybackMode: String, CaseIterable, Identifiable {
    case externalVLC
    case embeddedVLC

    var id: String { rawValue }
    var title: String {
        switch self {
        case .externalVLC: return "External VLC app"
        case .embeddedVLC: return "In-app player (TVVLCKit)"
        }
    }

    static func selected(in defaults: UserDefaults = .standard) -> PlaybackMode {
        PlaybackMode(rawValue: defaults.string(forKey: "playbackMode") ?? "") ?? .externalVLC
    }
}

@MainActor
final class PlaybackController: NSObject, ObservableObject, VLCMediaPlayerDelegate {
    static let shared = PlaybackController()

    @Published var isPresented = false
    @Published private(set) var status = ""
    @Published private(set) var isPlaying = false
    @Published private(set) var errorMessage: String?

    let videoView = UIView()
    private var player: VLCMediaPlayer?
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        super.init()
        videoView.backgroundColor = .black
    }

    static func mediaURL(from value: String) -> URL? {
        guard let url = URL(string: value.trimmingCharacters(in: .whitespacesAndNewlines)),
              let scheme = url.scheme?.lowercased(),
              ["http", "https", "rtsp", "rtmp", "ftp", "udp", "rtp"].contains(scheme),
              let host = url.host, !host.isEmpty else { return nil }
        return url
    }

    /// Completion confirms request acceptance/app handoff, not successful decoding.
    func playURL(_ value: String, completion: @escaping (Bool) -> Void) {
        switch PlaybackMode.selected(in: defaults) {
        case .externalVLC:
            stop()
            VLCLauncher.shared.playURL(value, completion: completion)
        case .embeddedVLC:
            guard let url = Self.mediaURL(from: value) else {
                completion(false)
                return
            }
            // Retire the old delegate before stopping, so old events cannot update new playback.
            releasePlayer()
            errorMessage = nil
            status = "Opening stream…"
            isPlaying = false
            let newPlayer = VLCMediaPlayer()
            newPlayer.delegate = self
            newPlayer.drawable = videoView
            newPlayer.media = VLCMedia(url: url)
            player = newPlayer
            isPresented = true
            newPlayer.play()
            completion(true)
        }
    }

    func togglePause() {
        guard let player else { return }
        if player.isPlaying { player.pause() } else { player.play() }
    }

    func stop() {
        releasePlayer()
        isPlaying = false
        isPresented = false
        status = "Stopped"
        errorMessage = nil
    }

    private func releasePlayer() {
        player?.delegate = nil
        player?.stop()
        player?.drawable = nil
        player = nil
    }

    nonisolated func mediaPlayerStateChanged(_ notification: Notification) {
        // VLCKit callbacks may arrive outside Swift's main actor.
        guard let source = notification.object as? VLCMediaPlayer else { return }
        Task { @MainActor [weak self] in
            guard let self, source === self.player else { return }
            self.isPlaying = source.isPlaying
            switch source.state {
            case .opening: self.status = "Opening stream…"
            case .buffering: self.status = "Buffering…"
            case .playing: self.status = "Playing"
            case .paused: self.status = "Paused"
            case .stopped: self.status = "Stopped"
            case .ended: self.status = "Playback ended"
            case .error:
                self.status = "Playback failed"
                self.errorMessage = "Unable to play this stream. Check the URL, network connection, and media format."
            default: break
            }
        }
    }
}
