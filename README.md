# Home2VLC

A SwiftUI iOS/tvOS app that allows you to easily send media URLs to VLC or other video players. The app provides both a user interface for manual URL entry and an HTTP API for remote control.

## Features

- 📱 Simple SwiftUI interface for entering media URLs
- 🌐 Built-in HTTP server for remote API access
- 🎥 Automatic VLC integration with fallback support
- 📺 Support for multiple streaming protocols (HTTP, HTTPS, RTSP, etc.)
- 🔄 Fallback to other video players if VLC is not available
- 📡 Network interface detection and status display

## Supported URL Schemes

The app supports various media URL formats:
- HTTP/HTTPS streams
- RTSP streams
- Direct video file URLs
- Any URL scheme supported by VLC or compatible video players

## Installation

1. Clone this repository
2. Open `Home2VLC.xcodeproj` in Xcode
3. Build and run on your iOS or tvOS device

## Usage

### Manual URL Entry

1. Launch the app
2. Enter a media URL in the text field
3. Tap "Open in VLC" to launch the stream

### HTTP API

The app automatically starts a local HTTP server that you can use to send URLs remotely.

#### Send URL via API

Use the following curl command to send a URL to the app:

```bash
curl -X POST http://[DEVICE_IP]:8080/play \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "url=http://example.com/stream.m3u8"
```

Replace `[DEVICE_IP]` with your device's IP address (displayed in the app).

#### Example Commands

Send an HTTP stream:
```bash
curl -X POST http://192.168.1.100:8080/play \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "url=http://sample.com:80/user/password/stream.ts"
```

Send an RTSP stream:
```bash
curl -X POST http://192.168.1.100:8080/play \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "url=rtsp://example.com:554/live/stream"
```

## API Response

The API returns:
- `200 OK` - URL successfully opened in video player
- `400 Bad Request` - Missing or invalid URL parameter
- `502 Bad Gateway` - Failed to open URL in any compatible app

## Requirements

- iOS 14.0+ or tvOS 14.0+
- Xcode 12.0+
- Swift 5.3+

## VLC Integration

The app attempts to open URLs in the following order:
1. VLC for Mobile (if installed)
2. VLC-X (alternative VLC app)
3. System default app for the URL scheme

## Network Requirements

- The device must be connected to a local network for the HTTP API to function
- Port 8080 must be available on the device
- Firewall settings may need to be configured to allow incoming connections

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built with SwiftUI
- Uses Apple's Network framework for HTTP server functionality
- Designed for seamless VLC integration