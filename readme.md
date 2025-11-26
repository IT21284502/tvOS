# TV Music Player (tvOS)

A simple, clean, and functional music player built for tvOS using SwiftUI.  
This project demonstrates playlist navigation, audio playback, focus-based interactions, and smooth user experience on the Apple TV platform.

---

## Overview

TV Music Player is a lightweight prototype designed to show how a basic media player can be built for tvOS.  
It focuses on clarity, simplicity, and easy navigation using the native tvOS focus system.

### Key Capabilities
- Browse a list of audio tracks
- Select a track to begin playback
- Control playback (Play, Pause, Next, Previous)
- View real-time playback progress
- Toggle Repeat mode
- Navigate using the Apple TV Remote or keyboard
- Return to the playlist at any time

---

## Features

### Playlist Screen
- Displays all available tracks
- Uses native tvOS focus navigation
- Highlighted items shift smoothly as the user navigates
- Selecting a track opens the Player screen

### Player Screen
- Shows the currently playing track name
- Provides playback controls:
  - Play
  - Pause
  - Next
  - Previous
  - Repeat toggle
- Includes a real-time progress bar
- Offers a Back button to return to the Playlist screen

### Audio Handling
- Built using `AVAudioPlayer`
- Timer-based progress updates for accurate tracking
- Clean synchronization between UI state and audio engine
- Handles transitions between tracks smoothly

---

## Technical Details

### Technologies Used
- **Language:** Swift  
- **UI Framework:** SwiftUI  
- **Audio Framework:** AVFoundation  
- **Platform:** tvOS  

### Architecture Notes
- Follows a simple and readable SwiftUI structure
- Maintains playback state using `ObservableObject`
- Uses a single audio player instance for consistency
- Separates playlist data from UI logic for easier maintenance

---

## Project Purpose

This project is designed for:
- Developers learning tvOS UI patterns
- Students working on coursework or demonstrations
- Beginners experimenting with audio playback on Apple platforms
- Anyone creating a minimal starting point for a media-based tvOS app

The goal is to provide a clean, understandable foundation that can be extended into a more complex media application.

---

## How to Run the Project

1. Open the project in Xcode (version compatible with tvOS target).
2. Select the Apple TV simulator or a physical device.
3. Build and run the project.
4. Use the remote (or arrow keys) to navigate and control playback.

---

## Future Improvements (Optional Ideas)
- Support for playlists loaded from external files
- UI animations for transitions and focus changes
- Album artwork display
- Shuffle mode
- Background audio support
- Integration with MediaPlayer framework

