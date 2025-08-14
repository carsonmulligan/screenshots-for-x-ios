# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

ScreenshotsForX is an iOS application for creating stylized screenshots suitable for sharing on X (formerly Twitter). The app uses SwiftUI and targets iOS 17.6+.

## Build and Development Commands

```bash
# Build for simulator
xcodebuild -scheme ScreenshotsForX -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 15' build

# Build for device (replace <device-id> with actual device ID)
xcodebuild -scheme ScreenshotsForX -configuration Debug -destination 'platform=iOS,id=<device-id>' build

# Open in Xcode
open ScreenshotsForX.xcodeproj

# Archive for distribution
xcodebuild -scheme ScreenshotsForX -configuration Release archive -archivePath ./build/ScreenshotsForX.xcarchive

# Clean build folder
xcodebuild -scheme ScreenshotsForX clean
```

## Architecture

### Core Architecture Pattern
The app follows a simplified MVVM pattern with SwiftUI:
- **State Management**: Uses `@State` properties in ContentView for reactive UI updates
- **View Composition**: Modular `@ViewBuilder` functions for reusable UI components
- **Background Options**: Strategy pattern using `BackgroundOption` enum with computed views

### Key Components

1. **ContentView.swift** (Main application logic):
   - Contains all UI and business logic in a single view structure
   - Manages image selection, styling, and export functionality
   - Uses `ImageSaver` class for photo library operations
   - Implements corner radius calculations with iOS-style continuous corners support

2. **Background System**:
   - `BackgroundOption` enum defines 8 background styles (4 gradients, 4 solid colors)
   - Each option returns a computed SwiftUI view
   - Backgrounds are displayed in a horizontal scroll view selector

3. **Export System**:
   - `exportContent()` creates the final composed view
   - `exportImageOverlay()` applies styling to the selected image
   - `exportImage()` renders at 2000x2000px using `ImageRenderer`
   - `ImageSaver` handles UIKit photo library integration

### State Properties
Key state variables in ContentView:
- `selectedItem`: PhotosPickerItem for image selection
- `selectedImage`: Loaded UIImage from picker
- `cornerRadius`: Corner radius value (0-100)
- `imageScale`: Image scaling factor (0.3-1.0)
- `selectedBackground`: Current BackgroundOption
- `isIOSStyle`: Toggle for continuous vs circular corners
- `isExporting`: Export operation state

### Corner Radius Implementation
The app dynamically calculates corner radius based on:
- Image dimensions and scale
- iOS-style continuous corners (when enabled)
- Standard circular corners (default)
- Formula: `min(imageWidth, imageHeight) * scale * (cornerRadius / 100) * 0.5`

## Development Notes

### When modifying UI:
- All UI code is in ContentView.swift
- Use existing `@ViewBuilder` pattern for new UI components
- Maintain consistent spacing and styling with existing elements

### When adding features:
- Add new background options to `BackgroundOption` enum
- Follow existing pattern for computed view properties
- Update background selector view to include new options

### Photo Library Integration:
- App uses `PHPhotoLibrary` for saving images
- Permissions handled via entitlements file
- Error handling implemented in `ImageSaver` class

### Image Processing:
- Export resolution fixed at 2000x2000px
- Uses `ImageRenderer` for high-quality output
- Corner radius and scaling applied via SwiftUI modifiers