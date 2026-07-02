//
//  CustomColorPickerVM.swift
//  TIMER
//
//  Created by Aditya Maroo on 05/09/24.
//

import Foundation
import SwiftUI

struct ColorAdding: Identifiable{
    var id: UUID = UUID()
    var alphaValue: Double
    var colorHexCode: String
    var colorOpacityY: Double
    var colorOpacityX: Double
    var colorRgbX: Double
    var colorRgbY: Double
    var colorShadesX: Double
    var colorShadesY: Double
}



class CustomColorPickerVM: ObservableObject{
//    @Published var colorItemData: ColorAdding = ColorAdding(alphaValue: 1.0, colorHexCode: "#EB5757", colorOpacityY: 13, colorOpacityX: UIScreen.main.bounds.size.width - 48, colorRgbX: 16, colorRgbY: 12, colorShadesX: UIScreen.main.bounds.size.width - 40, colorShadesY: 8)
    
     //MARK: - RGB Gradient colour
    @Published var colorArray : [Color] = [Color(hexString: "#FF0000"), // Red
    Color(hexString: "#FFA800"), // Orange
    Color(hexString: "#FFFF00"), // Yellow
    Color(hexString: "#00FF00"), // Green
    Color(hexString: "#00FFFF"), // Cyan
    Color(hexString: "#0000FF"), // Blue
    Color(hexString: "#FF00FF"), // Magenta
    Color(hexString: "#FF0000")  // Red
                                           ]
    
     //MARK: - Defaults colour hexCode
    @Published var defaultColorArray: [ColorModel] = [
        ColorModel(color: Color(hexString: "#8B1414")),
        ColorModel(color: Color(hex: "#FA4C4C")),
        ColorModel(color:  Color(hex: "#FAE84C")),
        ColorModel(color:  Color(hex: "#148B76")),
        ColorModel(color:  Color(hex: "#49148B")),
        ColorModel(color:  Color(hex: "#FA4CAA")),
        ColorModel(color:  Color(hex: "#DBDBDB")),
        ColorModel(color:  Color(hex: "#4CFAD0")),
        ColorModel(color:Color(hex: "#1886EC")),
        ColorModel(color: Color(hex: "#000000"))
    ]
    
     //MARK: - Saving or Adding colour through color picker
    @Published var addingColour: [ColorAdding] = []
    @Published var isScrollGuestureOff: Bool = false
   @Published var previousColorData: String = ""
    
    //Appear new text field on tap
    @Published var isHiddentextFieldAppear: Bool = false
    
     //MARK: - init for fetching data when screen appears
    init() {
        fetchingColorData()
    }
    
    
     //MARK: - Database function
    
    func fetchingColorData(){
        var colorData = ColorPickerStoryRepository.shared.fetchItems()
        addingColour.removeAll()
        var newColorData = colorData.filter{$0.colorChoice}
        newColorData.sort{$0.indexValue < $1.indexValue}
        for colrData in newColorData{
            addingColour.append(ColorAdding(alphaValue: colrData.alphaValue, colorHexCode: colrData.colorHexCode!, colorOpacityY: colrData.colorOpacityY, colorOpacityX: colrData.colorOpacityX, colorRgbX: colrData.colorRgbX, colorRgbY: colrData.colorRgbY, colorShadesX: colrData.colorShadesX, colorShadesY: colrData.colorShadesY))
        }
    }
    
    func updateColorData() {
         var colorData = ColorPickerStoryRepository.shared.fetchItems()
        
        if !addingColour.isEmpty {
            addingColour.removeFirst()
        }
        
        var newColorData = colorData.filter { $0.colorChoice }
        newColorData.sort { $0.indexValue < $1.indexValue }
        
        if !newColorData.isEmpty {
            CoreDataManager.shared.deleteNSManagedObject(object: newColorData.first ?? ColorObject())
        }
        
        for index in 0..<min(addingColour.count, newColorData.count) {
            newColorData[index].indexValue = Int64(index)
        }
        
        CoreDataManager.shared.saveContext()
    }
  
    
     //MARK: - Color Conversion for Rgb Color
    func getColor(at position: CGFloat) -> Color {
            // Define gradient stops
            let stops: [(color: Color, location: CGFloat)] = [
                (color: colorArray[0], location: 0),
                (color: colorArray[1], location: 0.13),
                (color: colorArray[2], location: 0.22),
                (color: colorArray[3], location: 0.34),
                (color: colorArray[4], location: 0.50),
                (color: colorArray[5], location: 0.66),
                (color: colorArray[6], location: 0.82),
                (color: colorArray[7], location: 1)
            ]
            
            // Find the two closest stops based on the position
            var lowerStop = stops[0]
            var upperStop = stops[stops.count - 1]
            
            for i in 0..<stops.count - 1 {
                if position >= stops[i].location && position <= stops[i + 1].location {
                    lowerStop = stops[i]
                    upperStop = stops[i + 1]
                    break
                }
            }
            
            // Calculate the normalized distance between the two stops
            let range = upperStop.location - lowerStop.location
            let normalizedPosition = (position - lowerStop.location) / range
            
            // Interpolate between the two colors
            return interpolateColor(from: lowerStop.color, to: upperStop.color, fraction: normalizedPosition)
        }
        
        // Helper function to interpolate between two colors
        private func interpolateColor(from start: Color, to end: Color, fraction: CGFloat) -> Color {
            let startComponents = start.getComponent()
            let endComponents = end.getComponent()
            
            let red = startComponents.red + fraction * (endComponents.red - startComponents.red)
            let green = startComponents.green + fraction * (endComponents.green - startComponents.green)
            let blue = startComponents.blue + fraction * (endComponents.blue - startComponents.blue)
            
            return Color(red: red, green: green, blue: blue)
        }
}
extension Color {
    func getComponent() -> (red: CGFloat, green: CGFloat, blue: CGFloat, opacity: CGFloat) {
            let uiColor = UIColor(self)
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0
            
            uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            
            return (red, green, blue, alpha)
        }
    
    init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
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
