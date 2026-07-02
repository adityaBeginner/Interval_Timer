//
//  CustomFooterShape.swift
//  TIMER
//
//  Created by Aditya Maroo on 07/10/24.
//

import Foundation
import SwiftUI

struct CustomFooterShape: Shape {
        func path(in rect: CGRect)-> Path{
            var path = Path()

                   // Start point on the bottom left
                   path.move(to: CGPoint(x: 0, y: rect.height))
                   
                   // Draw a straight line to the start of the curve
                   path.addLine(to: CGPoint(x: 0, y: rect.height * 0.6))
                   
                   // Add a small curve at the top
                   let controlPoint = CGPoint(x: rect.width / 2, y: rect.height * 0.3) // Control point for the curve
                   let endPoint = CGPoint(x: rect.width, y: rect.height * 0.6) // End point of the curve
                   path.addQuadCurve(to: endPoint, control: controlPoint)
                   
                   // Draw a straight line down to the bottom right
                   path.addLine(to: CGPoint(x: rect.width, y: rect.height))
                   
                   // Close the path to form the shape
                   path.closeSubpath()
            return path
        }
}

#Preview {
    CustomFooterShape()
        .fill(Color(uiColor: .footerBackgroundColor))
        .frame(width: 36, height: 40)
}
