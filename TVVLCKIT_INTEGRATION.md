# TVVLCKit integration

## Dependency

- Official production binary: TVVLCKit 3.7.2.
- Archive: https://download.videolan.org/cocoapods/prod/TVVLCKit-3.7.2-3e42ae47-79128878.tar.xz
- SHA-256: `fa264c2eb17d648669d9d12b51e76e5b6769828354517d09b340387b30825f58`.
- Install with `bash scripts/setup-tvvlckit.sh` before opening/building the project.
- The XCFramework has tvOS arm64 device and arm64/x86_64 simulator slices.
- The inspected device binary is dynamically linked. Xcode links and embeds the
  selected framework slice, signing on copy for signed device builds.
- No library code was modified. The 3.7.2 release is pinned deliberately rather
  than depending on the moving 4.0 nightly Swift package.

## Playback behavior

`PlaybackController` routes all entry points using the persisted `playbackMode`
preference. The default preserves external VLC behavior. Embedded playback uses
one shared video surface and replaces the media player for each new request,
retiring old delegates to ignore obsolete state callbacks. Stop/dismiss releases
the player. UI and player operations run on the main actor.

Embedded requests accept HTTP, HTTPS, RTSP, RTMP, FTP, UDP, and RTP URLs with a host.
Acceptance is not a guarantee that a particular codec/transport plays successfully.
URLs are passed to VLCMedia without wrapping them in another URL scheme.
The current `/play` API keeps its response codes; `200` confirms acceptance, not
decoding or audible/visible playback. The pre-existing server/parser security
findings in CODEX_HANDOFF.md remain separate work.

## Licensing before distribution

Settings includes an Open Source Licenses screen and the archive's LGPL 2.1 text.
This is development integration, not a determination of release compliance.
Before a commercial/App Store release:

1. Obtain and archive corresponding sources for this exact binary, including
   VLCKit, libVLC, bundled dependencies, patches, and compilation scripts. The
   archive filename identifies revisions `3e42ae47` and `79128878`; verify the
   complete provenance with VideoLAN. The current generic source link is not a
   substitute for a corresponding-source distribution.
2. Inventory bundled third-party license/copyright notices and add them to the
   in-app notices/source distribution as required.
3. Establish an LGPL section 6 relinking/replacement route compatible with the
   actual packaging, signing, distribution, and app EULA. Dynamic linking alone
   is not proof that this requirement is satisfied.
4. Have the release plan reviewed for licensing compliance.

Upstream source: https://code.videolan.org/videolan/VLCKit

## Physical Apple TV verification

- Choose embedded mode, play representative HLS, HTTP MPEG-TS, and RTSP streams.
- Send a second POST while playing and confirm the new stream replaces the old.
- Verify pause/resume, Siri Remote play/pause, Back/Menu, Stop & Close, and focus.
- Test invalid/unreachable media and confirm an error is displayed.
- Switch back to external mode and verify the existing VLC app launch.
- Verify signed/percent-escaped URLs and confirm preference survives relaunch.
- Confirm server recovery after app foregrounding and document suspension limits.

Physical-device playback and signing are not verified by simulator compilation.

## Verification performed

- Debug simulator build (arm64 and x86_64): passed with Xcode 26.1.1.
- Release arm64 tvOS device build with signing disabled: passed.
- Four Swift Testing regression tests passed on tvOS 26.1 Simulator: preference
  persistence/fallback, signed URL preservation, invalid URL rejection, and actual
  VLC player request replacement/stop cleanup using a closed localhost port.
- Remaining build warnings are existing deprecated `onChange` calls and Xcode's
  skipped App Intents metadata extraction.
- No deployment, physical Apple TV interaction, or real stream decoding test.
