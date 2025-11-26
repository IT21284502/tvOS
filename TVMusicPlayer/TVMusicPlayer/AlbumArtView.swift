import SwiftUI

struct AlbumArtView: View {
    let imageName: String
    @Binding var rotation: Double
    var isPlaying: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 250, height: 250)
            
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 200, height: 200)
                .clipShape(Circle())
                .rotationEffect(.degrees(rotation))
        }
        .onAppear(perform: setupRotationAnimation)
        .onChange(of: isPlaying) { isPlaying in
            updateRotationAnimation(isPlaying: isPlaying)
        }
        .padding(.vertical, 10)
    }
    
    private func setupRotationAnimation() {
        withAnimation(Animation.linear(duration: 60).repeatForever(autoreverses: false)) {
            rotation = 360
        }
    }
    
    private func updateRotationAnimation(isPlaying: Bool) {
        if isPlaying {
            withAnimation(Animation.linear(duration: 60).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        } else {
            withAnimation {
                rotation = 0
            }
        }
    }
}

struct AlbumArtView_Previews: PreviewProvider {
    static var previews: some View {
        AlbumArtView(imageName: "album1", rotation: .constant(0), isPlaying: true)
    }
}
