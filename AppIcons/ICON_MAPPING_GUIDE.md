# App Icon Mapping Guide

This guide shows where each generated icon should be placed in your Xcode project's Assets.xcassets.

## Generated Icons

All icons have been generated from `Home2VLC.png` and are located in the `AppIcons/` directory.

## iOS App Icons Mapping

### App Icon Image Set (iOS)
Located in: `Assets.xcassets/App Icon & Top Shelf Image.brandassets/App Icon.imagestack/`

**Back Layer** (`Back.imagestacklayer/Content.imageset/`):
- `iOS-AppStore-1024pt-1x.png` → Content.imageset (1024x1024)

**Middle Layer** (`Middle.imagestacklayer/Content.imageset/`):
- Use the same: `iOS-AppStore-1024pt-1x.png` → Content.imageset (1024x1024)

**Front Layer** (`Front.imagestacklayer/Content.imageset/`):
- Use the same: `iOS-AppStore-1024pt-1x.png` → Content.imageset (1024x1024)

### App Store Icon
- `iOS-AppStore-1024pt-1x.png` → App Icon - App Store.imagestack/Back.imagestacklayer/Content.imageset/
- `iOS-AppStore-1024pt-1x.png` → App Icon - App Store.imagestack/Middle.imagestacklayer/Content.imageset/
- `iOS-AppStore-1024pt-1x.png` → App Icon - App Store.imagestack/Front.imagestacklayer/Content.imageset/

## tvOS Top Shelf Images Mapping

### Top Shelf Image
Located in: `Assets.xcassets/App Icon & Top Shelf Image.brandassets/Top Shelf Image.imageset/`
- `tvOS-TopShelf-400x240-1x.png` → 1x slot (400x240)
- `tvOS-TopShelf-800x480-2x.png` → 2x slot (800x480)

### Top Shelf Image Wide
Located in: `Assets.xcassets/App Icon & Top Shelf Image.brandassets/Top Shelf Image Wide.imageset/`
- `tvOS-TopShelfWide-1920x720-1x.png` → 1x slot (1920x720)
- `tvOS-TopShelfWide-3840x1440-2x.png` → 2x slot (3840x1440)

## Standard iOS Icon Sizes (for additional use)

These icons can be used if you need to create additional icon sets or for other purposes:

### Settings Icons (29pt)
- `iOS-29pt-1x.png` (29x29) - iPhone Settings 1x
- `iOS-29pt-2x.png` (58x58) - iPhone Settings 2x
- `iOS-29pt-3x.png` (87x87) - iPhone Settings 3x

### Spotlight Icons (40pt)
- `iOS-40pt-1x.png` (40x40) - iPad Spotlight 1x
- `iOS-40pt-2x.png` (80x80) - iPhone/iPad Spotlight 2x
- `iOS-40pt-3x.png` (120x120) - iPhone Spotlight 3x

### Notification Icons (20pt)
- `iOS-20pt-1x.png` (20x20) - iPad Notification 1x
- `iOS-20pt-2x.png` (40x40) - iPhone/iPad Notification 2x
- `iOS-20pt-3x.png` (60x60) - iPhone Notification 3x

### App Icons (60pt - iPhone)
- `iOS-60pt-2x.png` (120x120) - iPhone App Icon 2x
- `iOS-60pt-3x.png` (180x180) - iPhone App Icon 3x

### iPad App Icons (76pt)
- `iPad-76pt-1x.png` (76x76) - iPad App Icon 1x
- `iPad-76pt-2x.png` (152x152) - iPad App Icon 2x

### iPad Pro App Icon (83.5pt)
- `iPad-83.5pt-2x.png` (167x167) - iPad Pro App Icon 2x

## How to Add Icons in Xcode

1. Open your project in Xcode
2. Navigate to `Assets.xcassets`
3. Find the appropriate image set
4. Drag and drop the corresponding icon from the `AppIcons/` folder
5. Ensure the icon appears in the correct size slot (1x, 2x, 3x)

## tvOS Specific Notes

- tvOS uses layered images (imagestack) with Back, Middle, and Front layers
- The system creates a parallax effect using these layers
- For a simple icon, you can use the same image for all three layers
- Top Shelf images are shown when your app is featured on the tvOS home screen

## Icon Requirements

- All icons are PNG format
- No transparency (alpha channel) - iOS will add rounded corners automatically
- Square aspect ratio for app icons
- Specific aspect ratios for Top Shelf images (as generated)

Generated on: $(date)