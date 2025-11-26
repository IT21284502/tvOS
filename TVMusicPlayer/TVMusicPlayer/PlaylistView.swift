import SwiftUI

struct PlaylistView: View {
    @StateObject var audio = AudioManager()
    @State private var selectedIndex: Int? = nil
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {  // Reduced spacing from 40 to 20
                Text("Playlist")
                    .font(.largeTitle)
                    .padding(.top, 20)  // Reduced top padding from 40 to 20
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Add some top padding to the first item
                        Color.clear.frame(height: 10)  // Add space at the top of the scroll view
                        
                        ForEach(Array(audio.songs.enumerated()), id: \.offset) { index, song in
                            PlaylistSongRow(
                                song: song,
                                index: index,
                                isSelected: selectedIndex == index,
                                onSelect: {
                                    selectedIndex = index
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 60)
                }
                .frame(maxWidth: .infinity)
                
                Spacer()
            }
            .navigationDestination(isPresented: Binding<Bool>(
                get: { selectedIndex != nil },
                set: { if !$0 { selectedIndex = nil } }
            )) {
                if let index = selectedIndex {
                    PlayerView(audio: audio, startIndex: index)
                }
            }
        }
    }
}

// MARK: - Song Row Component
struct PlaylistSongRow: View {
    let song: AudioManager.Song
    let index: Int
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            songRowContent
        }
        .buttonStyle(CardButtonStyle())
    }
    
    private var songRowContent: some View {
        HStack {
            Text(song.name)
                .font(.title2)
                .foregroundColor(.primary)
            
            Spacer()
            
            if isSelected {
                Image(systemName: "play.fill")
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .frame(maxWidth: 600, minHeight: 60)
        .background(songRowBackground)
        .overlay(songRowBorder)
    }
    
    private var songRowBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(isSelected ? Color.blue.opacity(0.2) : Color.gray.opacity(0.3))
    }
    
    private var songRowBorder: some View {
        RoundedRectangle(cornerRadius: 12)
            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
    }
}

// Custom button style for better focus handling on tvOS
struct CardButtonStyle: ButtonStyle {
    @Environment(\.isFocused) private var isFocused
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
            .background(
                ZStack {
                    // Focus ring
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isFocused ? Color.blue : Color.clear, lineWidth: 4)
                        .padding(-4)
                    
                    // Background
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.clear)
                }
            )
            .focusable(true)
    }
}

