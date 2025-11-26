import SwiftUI
import AVFoundation

struct PlayerView: View {
    @ObservedObject var audio: AudioManager
    let startIndex: Int
    @Environment(\.dismiss) private var dismiss
    @State private var rotation: Double = 0
    @State private var rotationTimer: Timer?
    
    // Focus state for buttons
    @FocusState private var focusedButton: FocusedButton?
    
    // Focus identifiers
    enum FocusedButton: Hashable {
        case back
        case playPause
        case previous
        case next
        case repeatButton
        case shuffle
    }
    
    // MARK: - Subviews
    
    private var topBar: some View {
        HStack {
            Button(action: { dismiss() }) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.subheadline)
                    Text("Back")
                        .font(.subheadline)
                }
                .padding(8)
                .background(focusedButton == .some(.back) ? Color.blue.opacity(0.2) : Color.clear)
                .cornerRadius(6)
            }
            .buttonStyle(PlainButtonStyle())
            .focused($focusedButton, equals: .back)
            
            Spacer()
        }
        .padding(.top, 10)
        .padding(.horizontal, 20)
    }
    
    private var albumArt: some View {
        VStack {
            Image(audio.albumArt[audio.currentIndex])
                .resizable()
                .scaledToFill()
                .frame(width: 300, height: 300)  // Reduced from 400x400
                .clipShape(Circle())
                .shadow(radius: 8)  // Slightly reduced shadow
                .rotationEffect(.degrees(audio.isPlaying ? rotation : 0))
        }
        .padding(.vertical, 5)  // Reduced vertical padding
        .onAppear {
            startRotationTimer()
        }
        .onDisappear {
            stopRotationTimer()
        }
    }
    
    private var songInfo: some View {
        VStack(spacing: 2) {
            Text(audio.currentSong.name)
                .font(.headline)
                .fontWeight(.medium)
                .lineLimit(1)
                .padding(.horizontal, 20)
            
            Text("Artist Name")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(.bottom, 5)
    }
    
    private var progressView: some View {
        VStack(spacing: 2) {
            ProgressView(value: audio.progress)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .scaleEffect(x: 1, y: 1.5, anchor: .center)
                .padding(.horizontal, 40)
            
            HStack {
                Text(formatTime(audio.player?.currentTime ?? 0))
                    .font(.caption2)
                Spacer()
                Text("-\(formatTime((audio.player?.duration ?? 0) - (audio.player?.currentTime ?? 0)))")
                    .font(.caption2)
            }
            .foregroundColor(.gray)
            .padding(.horizontal, 40)
        }
        .padding(.bottom, 20)
    }
    
    private var playbackControls: some View {
        VStack(spacing: 0) {
            // Audio visualizer - full width
            AudioVisualizer(audio: audio)
                .frame(maxWidth: .infinity, minHeight: 50, maxHeight: 60)
                .padding(.vertical, 10)
                .padding(.horizontal, 20)  // Add some horizontal padding
            
            // Main playback controls
            PlaybackControlsView(
                audio: audio,
                rotation: $rotation
            )
            .padding(.top, 5)
            
            // Bottom row with shuffle and repeat buttons
            HStack(spacing: 40) {
                // Shuffle button (left side)
                Button(action: { /* Implement shuffle functionality */ }) {
                    Image(systemName: "shuffle")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(.gray)
                        .frame(width: 50, height: 40)
                        .background(focusedButton == .some(.shuffle) ? Color.blue.opacity(0.2) : Color.clear)
                        .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
                .focused($focusedButton, equals: .shuffle)
                
                Spacer()
                
                // Repeat button (right side)
                Button(action: { audio.repeatOn.toggle() }) {
                    Image(systemName: "repeat")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(audio.repeatOn ? .blue : .gray)
                        .frame(width: 50, height: 40)
                        .background(focusedButton == .some(.repeatButton) ? Color.blue.opacity(0.2) : Color.clear)
                        .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
                .focused($focusedButton, equals: .repeatButton)
            }
            .padding(.horizontal, 50)
            .padding(.bottom, 20)
        }
        .background(Color.black.opacity(0.9))
        .edgesIgnoringSafeArea(.bottom)
    }
    
    // Additional controls have been moved to playbackControls
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Main content area with scroll view
            ScrollView {
                VStack(spacing: 15) {  // Reduced spacing between elements
                    // Top bar with back button
                    topBar
                        .padding(.top, 10)
                    
                    // Album art with reduced size
                    albumArt
                        .padding(.top, 5)  // Reduced top padding
                    
                    // Song info
                    songInfo
                        .padding(.top, 5)  // Reduced top padding
                    
                    // Progress view
                    progressView
                        .padding(.top, 5)  // Reduced top padding
                    
                    // Add space at the bottom for controls
                    // This ensures content isn't hidden behind the fixed controls
                    Color.clear
                        .frame(height: 180)  // Increased to account for the larger control area
                }
                .padding(.horizontal, 30)  // Reduced side padding
                .padding(.bottom, 20)  // Add some bottom padding
            }
            .edgesIgnoringSafeArea(.bottom)
            
            // Fixed controls at the bottom
            playbackControls
                .zIndex(1)  // Ensure controls stay above the scroll view
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            audio.selectSong(at: startIndex)
            // Set initial focus on the play/pause button
            DispatchQueue.main.async {
                self.focusedButton = .playPause
            }
        }
        .onMoveCommand { direction in
            guard let current = focusedButton else {
                focusedButton = .playPause
                return
            }
            
            switch (current, direction) {
                // Navigation from play/pause button
                case (.playPause, .up):
                    focusedButton = .back
                case (.playPause, .down):
                    focusedButton = .repeatButton
                case (.playPause, .left):
                    focusedButton = .previous
                case (.playPause, .right):
                    focusedButton = .next
                    
                // Navigation from back button
                case (.back, .down):
                    focusedButton = .playPause
                case (.back, .left):
                    focusedButton = .playPause
                case (.back, .right):
                    focusedButton = .playPause
                    
                // Navigation from repeat button
                case (.repeatButton, .up):
                    focusedButton = .playPause
                case (.repeatButton, .left):
                    focusedButton = .shuffle
                case (.repeatButton, .right):
                    focusedButton = .shuffle
                    
                // Navigation from previous button
                case (.previous, .right):
                    focusedButton = .playPause
                case (.previous, .up):
                    focusedButton = .back
                case (.previous, .down):
                    focusedButton = .repeatButton
                    
                // Navigation from next button
                case (.next, .left):
                    focusedButton = .playPause
                case (.next, .up):
                    focusedButton = .back
                case (.next, .down):
                    focusedButton = .repeatButton
                    
                // Navigation from shuffle
                case (.shuffle, .left):
                    focusedButton = .repeatButton
                case (.shuffle, .right):
                    focusedButton = .repeatButton
                case (.shuffle, .up):
                    focusedButton = .playPause
                    
                default:
                    break
            }
        }
        .onPlayPauseCommand {
            audio.playPause()
        }
        .onExitCommand {
            dismiss()
        }
    }
    
    // MARK: - Helper Methods
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func startRotationTimer() {
        rotationTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            if audio.isPlaying {
                withAnimation(.linear(duration: 0.05)) {
                    rotation += 1.8
                    if rotation >= 360 {
                        rotation = 0
                    }
                }
            }
        }
    }
    
    private func stopRotationTimer() {
        rotationTimer?.invalidate()
        rotationTimer = nil
    }


// Preview
}

// Preview
struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerView(audio: AudioManager(), startIndex: 0)
    }
}
