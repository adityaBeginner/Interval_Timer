import SwiftUI

struct ScrollTextView: View {
    var stringData: String = ""
    var fontColor: Color = .white
    var isLandScape: Bool = false
    
    @State private var offset: CGFloat = 0
    @State private var currentText: String = ""
    @State private var isScrolling: Bool = false
    
    var body: some View {
        let containerWidth = isLandScape ? (screenDeviceHeight * 0.62) - 42 : screenDeviceWidth - 42
        let textWidth = calculateTextWidth(for: stringData, font: .systemFont(ofSize: screenDeviceWidth * 0.093))
        let shouldScroll = textWidth > containerWidth
        
        if shouldScroll {
            ScrollView(.horizontal, showsIndicators: false) {
                TextLabelRegularFont(
                    stringData: stringData,
                    fontColor: fontColor,
                    customFontSize: screenDeviceWidth * 0.093,
                    isCustomFont: true
                )
                .fixedSize()
                .offset(x: offset)
            }
            .disabled(true)
            .frame(height: screenDeviceWidth * 0.12)
            .clipped() // Important: clip the content to prevent overflow
            // Use stringData as the key to force complete view recreation
            .id("scroll_\(stringData)" + (isLandScape ? "Landscape" : ""))
            .onAppear {
                debugPrint("On Appear is working....")
                handleTextChange()
            }
            .onChange(of: stringData) { newValue in
                debugPrint("On Change is working....")
                handleTextChange()
            }
           
            
        } else {
            TextLabelRegularFont(
                stringData: stringData,
                fontColor: fontColor,
                customFontSize: screenDeviceWidth * 0.093,
                isCustomFont: true
            )
            .multilineTextAlignment(.center)
            .frame(height: screenDeviceWidth * 0.12)
            .onAppear{
                debugPrint("Else condition is working")
            }
        }
    }
}

#Preview {
    ScrollTextView()
}

extension ScrollTextView {
    private func handleTextChange() {
        debugPrint("Handling text change: \(stringData)")
        
        // Immediately stop any existing animation
        withAnimation(.none) {
            offset = 0
            isScrolling = false
        }
        
        // Update current text tracking
        currentText = stringData
        
        // Calculate dimensions for current text
        let textWidth = calculateTextWidth(for: stringData, font: .systemFont(ofSize: screenDeviceWidth * 0.093))
        let containerWidth = isLandScape ? (screenDeviceHeight * 0.62) - 42 : screenDeviceWidth - 42
        
        // Only proceed if text needs scrolling
        guard textWidth > containerWidth else { return }
        
        // Start scrolling after ensuring the view has settled
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Double-check that the text hasn't changed again during the delay
            guard self.currentText == self.stringData else {
                debugPrint("Text changed during delay, aborting scroll")
                return
            }
            
            self.startScrollingAnimation(textWidth: textWidth, containerWidth: containerWidth)
        }
    }
    
    private func startScrollingAnimation(textWidth: CGFloat, containerWidth: CGFloat) {
        debugPrint("Starting scroll animation for: \(stringData)")
        
        isScrolling = true
        let targetOffset = -(textWidth + containerWidth * 0.2) // Add small buffer
        
        withAnimation(.linear(duration: 15).repeatForever(autoreverses: false)) {
            offset = targetOffset
        }
        
        debugPrint("Target offset: \(targetOffset)")
    }
    
    private func calculateTextWidth(for text: String, font: UIFont) -> CGFloat {
        let attributes = [NSAttributedString.Key.font: font]
        return (text as NSString).size(withAttributes: attributes).width
    }
}
