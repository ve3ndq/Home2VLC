import SwiftUI
import UIKit

private struct VLCVideoSurface: UIViewRepresentable {
    let videoView: UIView

    func makeUIView(context: Context) -> UIView { videoView }
    func updateUIView(_ uiView: UIView, context: Context) {}
}

struct EmbeddedPlayerView: View {
    @ObservedObject var playback: PlaybackController

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.ignoresSafeArea()
            VLCVideoSurface(videoView: playback.videoView)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                if let error = playback.errorMessage {
                    Text(error).foregroundStyle(.white).multilineTextAlignment(.center)
                }
                HStack(spacing: 24) {
                    Text(playback.status).foregroundStyle(.white)
                    Spacer()
                    Button(playback.isPlaying ? "Pause" : "Play") {
                        playback.togglePause()
                    }
                    .disabled(playback.errorMessage != nil)
                    Button("Stop & Close") { playback.stop() }
                }
            }
            .padding(32)
            .background(.black.opacity(0.75))
        }
        .onPlayPauseCommand { playback.togglePause() }
        .onExitCommand { playback.stop() }
    }
}
