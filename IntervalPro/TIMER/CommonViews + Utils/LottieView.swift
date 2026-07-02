//
//  LottieView.swift
//  WifiDemo
//
//  Created by Aditya Maroo on 15/11/24.
//
//
import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    var filename: String
    var loopMode: LottieLoopMode = .playOnce

    private let animationView = LottieAnimationView()

    func makeUIView(context: UIViewRepresentableContext<LottieView>) -> UIView {
        let view = UIView(frame: .zero)
        
        // Configure the Lottie animation view
        animationView.animation = LottieAnimation.named(filename)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = loopMode

        // Start playing the animation immediately
        animationView.play()
        
        // Add the animation view to the container view
        view.addSubview(animationView)
        
        // Set up constraints to make the animation view fit the container view
        animationView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
        
        return view
    }

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<LottieView>) {
        // No update code needed for static animation
    }
}

