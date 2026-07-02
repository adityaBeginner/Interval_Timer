//
//  HandlingNotchDevice.swift
//  TIMER
//
//  Created by Aditya Maroo on 21/08/24.
//

import Foundation
import SwiftUI
final class NotchHandling{
    static let shared = NotchHandling()
    func adjustFooterHeight() -> CGFloat{
    
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                     let window = windowScene.windows.first else {
                  let footerHeight = 8.0 // Fallback to default
                   return footerHeight
               }
        let bottomSafeAreaInset = window.safeAreaInsets.bottom
            // Assuming iPhone 15 Pro has a larger bottom safe area inset
            if bottomSafeAreaInset > 20 {
                let footerHeight = 30.0
                return CGFloat(footerHeight)
                
                // Adjust footer height based on device
            } else {
               let  footerHeight = 8.0 
                return CGFloat(footerHeight)
                // Default footer height for iPhone SE3 and similar devices
            }
        }
    
}
