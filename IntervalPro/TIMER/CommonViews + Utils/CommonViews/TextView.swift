//
//  TextView.swift
//  TIMER
//
//  Created by Aditya Maroo on 04/09/24.
//

import SwiftUI

struct TextView: View {
    var fontName: TFonts = .TREGULAR
    var fontsSize: TSize = .TSIZE_16
    var fontColor: UIColor = .timerWorkoutColor
    var frameHeight: CGFloat?
    var frameWidth: CGFloat?
    var multiLineAlignment: TextAlignment?
    var textTitle: String = ""
    var alignment:Alignment = .center
    var paddingHorizontal: CGFloat = 0
    
    
    
    var body: some View {
        Text(textTitle)
            .font(.custom(fontName.rawValue, size: fontsSize.rawValue))
            .foregroundStyle(Color(uiColor: fontColor))
            .frame(width: frameWidth, height:  frameHeight,alignment: alignment)
            .multilineTextAlignment(multiLineAlignment ?? .center)
            .padding(.horizontal, paddingHorizontal)
        
    }
}

#Preview {
    TextView()
}
