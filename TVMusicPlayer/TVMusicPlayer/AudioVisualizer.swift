import SwiftUI
import Combine

struct AudioVisualizer: View {
    @ObservedObject var audio: AudioManager
    private let barCount = 32  // Increased number of bars for better coverage
    private let barSpacing: CGFloat = 2  // Reduced spacing between bars
    
    var body: some View {
        GeometryReader { geometry in
            let availableWidth = geometry.size.width - (CGFloat(barCount - 1) * barSpacing)
            let barWidth = max(2, availableWidth / CGFloat(barCount))
            
            HStack(alignment: .bottom, spacing: barSpacing) {
                ForEach(0..<barCount, id: \.self) { index in
                    VisualizerBar(audio: audio, index: index, totalBars: barCount)
                        .frame(width: barWidth)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 50, alignment: .bottom)
        }
        .frame(height: 50)
    }
}

struct VisualizerBar: View {
    @ObservedObject var audio: AudioManager
    let index: Int
    let totalBars: Int
    
    @State private var scale: CGFloat = 0.1
    private let animation = Animation.spring(response: 0.2, dampingFraction: 0.5)
    
    var body: some View {
        GeometryReader { geometry in
            let maxHeight = geometry.size.height * 0.8
            let height = max(4, maxHeight * scale)  // Ensure minimum height for visibility
            
            LinearGradient(gradient: Gradient(colors: [.blue, .purple]),
                           startPoint: .top,
                           endPoint: .bottom)
            .mask(
                RoundedRectangle(cornerRadius: 1.5)
                    .frame(height: height)
            )
            .frame(maxWidth: .infinity, maxHeight: height, alignment: .bottom)
            .animation(animation, value: scale)
        }
        .onReceive(audio.$currentAmplitude) { amplitude in
            // Calculate a position-based scale factor (bars in the middle are more sensitive)
            let positionFactor = 1.0 - (abs(CGFloat(index) / CGFloat(totalBars - 1) - 0.5) * 0.8)
            
            // Add some randomness to make it more dynamic
            let randomFactor = CGFloat.random(in: 0.8...1.2)
            
            // Calculate the new scale with position and random factors
            let newScale = min(1.0, CGFloat(amplitude) * positionFactor * randomFactor * 2.0)
            
            // Ensure the scale never goes below a minimum value
            self.scale = max(0.1, newScale)
        }
        }
    }
    
    // MARK: - Preview
    struct AudioVisualizer_Previews: PreviewProvider {
        static var previews: some View {
            let audio = AudioManager()
            
            // Create a preview with a fixed width
            let preview = AudioVisualizer(audio: audio)
                .frame(width: 300)
                .previewLayout(.sizeThatFits)
                .padding()
                .background(Color.black)
            
            // Return the preview with a fixed width
            return preview
                .frame(width: 300)
                .onAppear {
                    // Simple animation to demonstrate the visualizer
                    withAnimation(Animation.easeInOut(duration: 0.5).repeatForever()) {
                        audio.currentAmplitude = 0.8
                    }
                }
        }
    }
