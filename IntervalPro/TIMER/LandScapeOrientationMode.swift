//
//  LandScapeOrientationMode.swift
//  TIMER
//
//  Created by Aditya Maroo on 08/11/24.
//

import SwiftUI
import UIKit


class LandscapeHostingController<Content: View>: UIHostingController<Content> {
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override init(rootView: Content) {
        super.init(rootView: rootView)
        // Set the device orientation to landscape when this view controller appears
        UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        // Restore the orientation to portrait when leaving this view controller
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
    }
}


struct LandscapeView<Content: View>: UIViewControllerRepresentable {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    func makeUIViewController(context: Context) -> LandscapeHostingController<Content> {
        return LandscapeHostingController(rootView: content)
    }

    func updateUIViewController(_ uiViewController: LandscapeHostingController<Content>, context: Context) {
        // Ensure the orientation is set correctly when updating the view
        UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
    }
}
