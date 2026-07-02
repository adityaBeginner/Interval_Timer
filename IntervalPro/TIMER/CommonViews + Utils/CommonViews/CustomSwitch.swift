//
//  CustomSwitch.swift
//  TIMER
//
//  Created by Aditya Maroo on 04/09/24.
//

import SwiftUI

struct CustomSwitch: View {
    @Binding var isSwitchTap: Bool 
    var body: some View {
        ZStack{
            Capsule()
                .fill(Color(uiColor: isSwitchTap ? .footerBackgroundColor : .switchBackgroundColor))
                .frame(width: 48, height: 24)
            
            Circle()
                .fill(Color(uiColor: .switchCircleBackgroundColor))
                .frame(width: 16, height: 16)
                .offset(x: isSwitchTap ? 12 : -12)
                
        }
    }
}

#Preview {
    CustomSwitch(isSwitchTap: .constant(true))
}
