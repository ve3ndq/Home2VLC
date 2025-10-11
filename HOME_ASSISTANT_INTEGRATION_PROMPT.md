# Home Assistant Integration Prompt for Home2VLC

Copy and paste this prompt to VSCode Copilot to create a Home Assistant integration for your Home2VLC app:

---

**AI PROMPT FOR VSCODE COPILOT:**

```
Create a complete Home Assistant integration for controlling a Home2VLC tvOS app. The integration should:

REQUIREMENTS:
1. Send HTTP POST requests to the Home2VLC app running on Apple TV
2. Support both manual IP configuration and automatic discovery
3. Include proper error handling and status feedback
4. Work with Home Assistant automations, scripts, and services
5. Support multiple Apple TV devices running Home2VLC

API DETAILS:
- HTTP Endpoint: POST http://[APPLE_TV_IP]:8080/play
- Content-Type: application/x-www-form-urlencoded
- Payload: url=<STREAM_URL>
- Success Response: 200 OK with "OK" body
- Error Responses: 400 (Bad Request), 502 (Bad Gateway)

INTEGRATION FEATURES NEEDED:
1. Custom component with domain 'home2vlc'
2. Configuration via config flow (UI setup)
3. Device discovery via network scanning
4. Service: home2vlc.play_url with parameters:
   - entity_id (target device)
   - url (stream URL to play)
   - title (optional display name)
5. Device status tracking (online/offline)
6. Proper async/await patterns for HTTP requests
7. Integration with Home Assistant device registry

EXAMPLE USAGE IN AUTOMATIONS:
```yaml
automation:
  - alias: "Play Stream on Apple TV"
    trigger:
      platform: state
      entity_id: input_boolean.start_stream
      to: 'on'
    action:
      service: home2vlc.play_url
      data:
        entity_id: home2vlc.living_room_apple_tv
        url: "http://example.com/stream.m3u8"
        title: "Live Stream"
```

FOLDER STRUCTURE:
- custom_components/home2vlc/__init__.py
- custom_components/home2vlc/manifest.json  
- custom_components/home2vlc/config_flow.py
- custom_components/home2vlc/const.py
- custom_components/home2vlc/device.py (or coordinator.py)

Include proper Home Assistant integration patterns:
- ConfigEntry handling
- Device info with identifiers
- Proper logging with _LOGGER
- Version compatibility
- Requirements in manifest.json
- Translation files if needed

Generate a complete, production-ready Home Assistant custom component that follows Home Assistant development best practices.
```

---

This prompt will help VSCode Copilot generate a complete Home Assistant integration that can discover and control your Home2VLC app via HTTP API calls, making it easy to integrate with your home automation setup.