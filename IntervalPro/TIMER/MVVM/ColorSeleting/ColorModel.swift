//
//  ColorModel.swift
//  TIMER
//
//  Created by Aditya Maroo on 21/08/24.
//

import Foundation
import SwiftUI
import Combine

struct ColorModel{
    
    var color: Color?
    var colorHexCode: String?
    var isSelected: Bool = false
    
    
}
class ColorGridVM: ObservableObject{
    @Published var colorHexCode: String = "#000000"
    @Published var colorOpacity: Double = 1.0
    
    //Appear new text field on tap
    @Published var isHiddentextFieldAppear: Bool = false
    
    
    
//    @Published var colorItemData: ColorAdding = ColorAdding(alphaValue: 1.0, colorHexCode: "#EB5757", colorOpacityY: 13, colorOpacityX: UIScreen.main.bounds.size.width - 48, colorRgbX: 16, colorRgbY: 12, colorShadesX: UIScreen.main.bounds.size.width - 40, colorShadesY: 8)
     //MARK: - func for callback type
//    func addingColorData()-> ColorAdding{
//        let colorData = ColorAdding(alphaValue: colorOpacity, colorHexCode: colorHexCode)
//        return colorData
//    }
    
    @Published var defaultColorArray: [ColorModel] = [
        ColorModel(color: Color(hex: "#8B1414")),
        ColorModel(color: Color(hex: "#FA4C4C")),
        ColorModel(color:  Color(hex: "#FAE84C")),
        ColorModel(color:  Color(hex: "#148B76")),
        ColorModel(color:  Color(hex: "#49148B")),
        ColorModel(color:  Color(hex: "#FA4CAA")),
        ColorModel(color:  Color(hex: "#DBDBDB")),
        ColorModel(color:  Color(hex: "#4CFAD0")),
        ColorModel(color:Color(hex: "#1886EC")),
        ColorModel(color: Color(hex: "#202020"))
    ]
    
    //Disable Text field on Color Tap
    func disableHideTextField(){
        dismissKeyboard()
        isHiddentextFieldAppear = false
    }
    
        
    }



extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        
        let r, g, b, a: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (r, g, b, a) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17, 255)
        case 6: // RGB (24-bit)
            (r, g, b, a) = (int >> 16, int >> 8 & 0xFF, int & 0xFF, 255)
        case 8: // ARGB (32-bit)
            (r, g, b, a) = (int >> 24 & 0xFF, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b, a) = (1, 1, 1, 1) // Default color is white
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}


