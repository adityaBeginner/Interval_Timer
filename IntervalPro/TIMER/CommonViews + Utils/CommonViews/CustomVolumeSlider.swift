import SwiftUI

struct CustomVolumeSlider: View {
    @Binding var volumeLevel: Float
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Full slider background
                RoundedRectangle(cornerRadius: 1)
                    .fill(.volumeSliderMaxTint) // Replace with .volumeSliderMaxTint
                    .frame(height: 2)
                
                // Filled slider based on volumeLevel
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color(.defaultFolderTimerReactionColor)) // Replace with .volume
                    .frame(width: CGFloat(volumeLevel) * geometry.size.width, height: 2)
                
                // Thumb at the end of the filled slider
                Circle()
                    .fill(.volume) // Replace with .volume
                    .frame(width: 16, height: 16)
                    .padding(.all, 10)
                    .offset(x: CGFloat(volumeLevel) * geometry.size.width - 16) // Offset to center thumb
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let newVolume = min(max(0, value.location.x / geometry.size.width), 1)
                                self.volumeLevel = Float(newVolume)
                            }
                    )
            }
        }
        .frame(height: 16) // Ensures enough space for the thumb
    }
}

#Preview {
    CustomVolumeSlider(volumeLevel: .constant(0.4))
}
