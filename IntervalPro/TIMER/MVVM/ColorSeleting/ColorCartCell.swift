//
//  ColorCartCell.swift
//  TIMER
//
//  Created by Aditya Maroo on 21/08/24.
//

import SwiftUI

struct ColorCartCell: View {
    @Binding var colorHex: String
    
    var colorModel:ColorModel
    var colorObject:ColorObject?
    
    //callBackData
    var dismissKeyBoardCallBack: (()-> Void)?
    
    var body: some View {
        ZStack(alignment: .bottomTrailing){
            Rectangle()
                .fill(colorModel.color ?? Color(.white))
                .frame(height: screenDeviceHeight * 0.144)
            Button(action: {
                colorHex = (colorModel.color?.toHex())!
            }){
                if colorHex == colorModel.color?.toHex(){
                    Image(bestButtonColor(for: colorModel.color ?? Color.white) ? .iconUnSelectedTick : .iconSelectedColourTick)
                }
            }
            .padding()
            
        }
       
//        .edgesIgnoringSafeArea(.bottom)
        .onTapGesture {
            colorHex = colorModel.color?.toHex() ??  "#000000"
            colorObject?.colorHexCode = colorHex
            CoreDataManager.shared.saveContext()
            dismissKeyBoardCallBack?()
        }
        
    }
}
 //MARK: - For color white and black contrast

extension ColorCartCell{
    func luminance(for color: Color) -> Double {
        func luminanceComponent(_ component: Double) -> Double {
            return component <= 0.03928 ? component / 12.92 : pow((component + 0.055) / 1.055, 2.4)
        }
        
        let uiColor = UIColor(color)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: nil)
        
        return 0.2126 * luminanceComponent(Double(red)) +
               0.7152 * luminanceComponent(Double(green)) +
               0.0722 * luminanceComponent(Double(blue))
    }

    // Function to calculate contrast ratio between two luminances
    func contrastRatio(luminance1: Double, luminance2: Double) -> Double {
        return (max(luminance1, luminance2) + 0.05) / (min(luminance1, luminance2) + 0.05)
    }

    // Function to choose white or black button color based on background
    func bestButtonColor(for backgroundColor: Color) -> Bool {
        // Luminance for black and white
//        let luminanceWhite = 1.0
//        let luminanceBlack = 0.0
        
        // Calculate the luminance for the background
        let backgroundLuminance = luminance(for: backgroundColor)
        
        //Threshold Value
        let thresholdValue: Double = 0.5
        
        // Calculate contrast with black and white
//        let contrastWithWhite = contrastRatio(luminance1: luminanceWhite, luminance2: backgroundLuminance)
//        let contrastWithBlack = contrastRatio(luminance1: luminanceBlack, luminance2: backgroundLuminance)
        
        // Return the color with better contrast
        return backgroundLuminance < thresholdValue ? true : false
    }

}

