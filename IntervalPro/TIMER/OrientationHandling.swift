//
//  OrientationHandling.swift
//  TIMER
//
//  Created by Aditya Maroo on 30/08/24.
//

import SwiftUI
import Foundation

struct CustomModifierDeviceRotation: ViewModifier{
    let action: (UIDeviceOrientation) -> Void
    
    func body(content: Content)-> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)){ _ in
                
                action(UIDevice.current.orientation)
            }
    }
}

extension View{
    func onRotateDevice(perform action: @escaping (UIDeviceOrientation)-> Void)-> some View{
        self.modifier(CustomModifierDeviceRotation(action: action))
    }
}
