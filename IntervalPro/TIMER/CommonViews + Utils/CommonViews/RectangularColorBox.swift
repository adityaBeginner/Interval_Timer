//
//  RectangularColorBox.swift
//  TIMER
//
//  Created by Aditya Maroo on 15/10/24.
//

import SwiftUI

struct RectangularColorBox: View {
    @State var isNaviagteColorSelecting: Bool = false
    @Binding var colorHexString:String
    @Binding var colorOpacity:Double
    
    var colorObject: ColorObject?
    
    var body: some View {
        ZStack{
            Rectangle()
                .fill(Color(hex: colorHexString).opacity(colorOpacity))
                .frame(width: 48, height: 24)
                .cornerRadius(6)
                .onTapGesture {
                    isNaviagteColorSelecting = true
                }
                .overlay{
                    if AppComman.shared.has95PercentBlackRatio(color: Color(hex: colorHexString)) || AppComman.shared.has95PercentWhiteRatio(color: Color(hex: colorHexString)) {
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color(uiColor: .footerBackgroundColor), lineWidth: 0.7)
                            .frame(width: 50, height: 25)
                    }
                }
            NavigationLink(isActive: $isNaviagteColorSelecting) {
                if isNaviagteColorSelecting{
                    ColorSelectingView(colorHexString: $colorHexString, colorOpacity: $colorOpacity, previousNavigation: $isNaviagteColorSelecting, colorObject:  colorObject)
                }
            } label: {
                EmptyView()
            }
            .hidden()

        }
    }
}

#Preview {
    RectangularColorBox(colorHexString: .constant(""), colorOpacity: .constant(1))
}
