import SwiftUI

struct PlaybackControlsView: View {
    @ObservedObject var audio: AudioManager
    @Binding var rotation: Double
    
    // FocusState properties for each button
    @FocusState private var previousFocus: Bool
    @FocusState private var playPauseFocus: Bool
    @FocusState private var nextFocus: Bool
    
    var body: some View {
        HStack(spacing: 20) {
            // Previous button
            Button(action: handlePrevious) {
                Image(systemName: "backward.fill")
                    .font(.system(size: 20))
                    .frame(width: 50, height: 50)
                    .background(previousFocus ? Color.blue.opacity(0.2) : Color.clear)
                    .clipShape(Circle())
            }
            .buttonStyle(PlainButtonStyle())
            .focused($previousFocus)
            
            Spacer()
            
            // Play/Pause button
            Button(action: handlePlayPause) {
                Image(systemName: audio.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 60))
                    .frame(width: 70, height: 70)
                    .background(playPauseFocus ? Color.blue.opacity(0.2) : Color.clear)
                    .clipShape(Circle())
            }
            .buttonStyle(PlainButtonStyle())
            .focused($playPauseFocus)
            
            Spacer()
            
            // Next button
            Button(action: handleNext) {
                Image(systemName: "forward.fill")
                    .font(.system(size: 20))
                    .frame(width: 50, height: 50)
                    .background(nextFocus ? Color.blue.opacity(0.2) : Color.clear)
                    .clipShape(Circle())
            }
            .buttonStyle(PlainButtonStyle())
            .focused($nextFocus)
        }
        .padding(.horizontal, 30)
        .padding(.bottom, 20)
    }
    
    private func handlePlayPause() {
        audio.playPause()
        if !audio.isPlaying {
            withAnimation {
                rotation = 0
            }
        }
    }
    
    private func handleNext() {
        audio.next()
        resetRotation()
    }
    
    private func handlePrevious() {
        audio.previous()
        resetRotation()
    }
    
    private func resetRotation() {
        rotation = 0
        if audio.isPlaying {
            withAnimation(Animation.linear(duration: 20).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

struct PlaybackControlsView_Previews: PreviewProvider {
    static var previews: some View {
        @State var rotation: Double = 0
        
        return PlaybackControlsView(
            audio: AudioManager(),
            rotation: $rotation
        )
    }
}
