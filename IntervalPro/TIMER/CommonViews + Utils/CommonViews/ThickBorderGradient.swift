//
//  ThickBorderGradient.swift
//  TIMER
//
//  Created by Aditya Maroo on 20/08/24.
//

import SwiftUI

struct ThickBorderGradient: View {
    var body: some View {
        HStack{
            LinearGradient(colors: [Color(uiColor: .thickBorderGradientFirst), Color(uiColor: .thickBorderGradientSecond), Color(uiColor: .thickBorderGradientThird)], startPoint: .top, endPoint: .bottom)
        }
        .frame(height: 8)
        .padding(.horizontal, -16)
    }
}

#Preview {
    ThickBorderGradient()
}
