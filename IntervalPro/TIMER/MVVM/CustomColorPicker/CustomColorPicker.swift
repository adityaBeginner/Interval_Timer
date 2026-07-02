//
//  CustomColorPicker.swift
//  TIMER
//
//  Created by Aditya Maroo on 05/09/24.
//

import SwiftUI

struct CustomColorPicker: View {
     //MARK: - State properties
    @State var geomertrySizeOfShades: CGSize?
    @State var selectedPosition: CGPoint = CGPoint(x: UIScreen.main.bounds.size.width - 40, y: 8)
    @State var selectRGBColor: Color = .red
    @State var selectedColor: Color = .red
    @Binding var hexCode: String
    @Binding var opacityNumber: Double
    @State var tintNumber: Double = 1.0
    @State var tintColor: Color = .red
    @State var opacityPosition: CGPoint = CGPoint(x: UIScreen.main.bounds.size.width - 48, y: 13)
    @State var finalColor: Color = .red
    @State var selectRGBColorPosition = CGPoint(x: 16, y: 12)
    
     //MARK: - State object view model
    @StateObject var viewModel = CustomColorPickerVM()
    
    var colorObject:ColorObject?
    
    //CallBack Data
    var dismisscallBackData: (()-> Void)?
    
    var body: some View {
        ZStack{
            Color.background
                .ignoresSafeArea()
            setup()
                .onAppear{
                    ///
                    ///Fetching Color Object data to display
                    ///
                    guard let colorObject else{debugPrint("ColorObject is nil while assigning color-parameters in CustomColorPicker"); return}
                    selectedPosition = CGPoint(x: colorObject.colorShadesX, y: colorObject.colorShadesY)
                    selectRGBColorPosition = CGPoint(x: colorObject.colorRgbX, y: colorObject.colorRgbY)
                    opacityPosition = CGPoint(x: colorObject.colorOpacityX, y: colorObject.colorOpacityY)
                    finalColor = Color(hex: colorObject.colorHexCode ?? hexCode).opacity(colorObject.alphaValue)
                    selectedColor = Color(hex: colorObject.colorHexCode ?? "").opacity(colorObject.alphaValue)
                    selectRGBColor = Color(hex: colorObject.colorHexCode ?? "")
                    
                }
                .onDisappear {
                    CoreDataManager.shared.saveContext()
                }
        }
    }
}


extension CustomColorPicker{
    @ViewBuilder
    func setup()-> some View{
        VStack(spacing: 32){
            ComHeaderView(titleHeader: .constant("Select Colour"), isBackBtnHidden: false, isSettingBtnHidden: true,shouldDismissOnBackButton: false,callback: {
              dismisscallBackData?()
            })
                .padding(.horizontal, 16)
            contentData()
            footerContent()
                .padding(.top, -8)
//            footerContent()
         }
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarHidden(true)
    }
    @ViewBuilder
    func contentData()-> some View{
        ScrollView{
            VStack(spacing : 44){
                TextColorField(txtPlaceHolder: "Hex", isColorBoxHidden: false, colorHexString: $hexCode, colorOpacity: $opacityNumber, previousNavigation: .constant(false), colorObject: colorObject, isNewTextFieldAppear: $viewModel.isHiddentextFieldAppear, selectedColorCallBack: {
                    selectedColor = Color(hex: hexCode)
                    finalColor = Color(hex: hexCode).opacity(opacityNumber)
                    selectRGBColor = Color(hex: hexCode)
                    colorObject?.colorHexCode = hexCode
                    colorObject?.alphaValue = opacityNumber
                })
                
                VStack(spacing: 32){
                    ///
                    ///Shades of color Sub view components
                    ///In this geometry reader is used to find the size of the componets and position of shade of componets
                    ///Drag Guesture is used to find the drag location in side shade components
                    ///Geometry reader helps the drag point to be inside the components
                    ///
                    GeometryReader{geometry in
                        ZStack{
                            //Two linear gradient is used to make this shade effect
                            //Color used the shade color or pick color, white and black co0lor with different opacity
                            // Implemeted in gradient according to figma style
                            LinearGradient(colors: [Color(hex: "#FFFFFF"), selectRGBColor], startPoint: .leading
                                           , endPoint: .trailing)
                            LinearGradient(
                                gradient: Gradient(stops: [
                                    Gradient.Stop(color: Color(hex: "#000000").opacity(0), location: 0),
                                    Gradient.Stop(color: Color(hex: "#000000").opacity(0.29), location: 0.29),
                                    Gradient.Stop(color: Color(hex: "#000000"), location: 1)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        disableTextField()
                                       shadeOfSingleColor(geometry: geometry, value: value)
                                    }
                            )
                            Circle()
                                .fill(selectedColor == .red ? selectedColor : finalColor)
                                .frame(width: 40, height: 40)
                                .overlay(Circle().stroke(Color.white, lineWidth: 3))
                                .position(selectedPosition)
                                .shadow(color: Color.black.opacity(0.25), radius: 4, x: 0, y: 4)
                                .gesture(
                                    DragGesture(minimumDistance: 0)
                                        .onChanged { value in
                                            disableTextField()
                                            shadeOfSingleColor(geometry: geometry, value: value)
                                        }
                                )
                        }
                    }
                    .frame(height: screenDeviceHeight * 0.2661)
                    .padding(.horizontal, -4)
                    ///
                    /// RGB color Sub view components
                    ///In this geometry reader is used to find the size of the componets and position of shade of componets
                    ///Drag Guesture is used to find the drag location in side shade components
                    ///Geometry reader helps the drag point to be inside the components
                    ///
                    GeometryReader{geometry in
                        ZStack{
                            /// * color is used to in linear gradient to make rgb or color picker
                            /// * Color are placed according to point or location in double type
                            ///  In this componets is movavble in x direction
                            RoundedRectangle(cornerRadius: 24)
                                .fill(LinearGradient(
                                    gradient: Gradient(stops: [
                                        Gradient.Stop(color: viewModel.colorArray[0], location: 0),
                                        Gradient.Stop(color: viewModel.colorArray[1], location: 0.13),
                                        Gradient.Stop(color: viewModel.colorArray[2], location: 0.22),
                                        Gradient.Stop(color: viewModel.colorArray[3], location: 0.34),
                                        Gradient.Stop(color: viewModel.colorArray[4], location: 0.50),
                                        Gradient.Stop(color: viewModel.colorArray[5], location: 0.66),
                                        Gradient.Stop(color: viewModel.colorArray[6], location: 0.82),
                                        Gradient.Stop(color: viewModel.colorArray[7], location: 1)
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                                .frame(height: 24)
                                .gesture(
                                    DragGesture(minimumDistance: 0)
                                        .onChanged{ value in
                                            disableTextField()
                                            shadeOfMultiColor(geometry: geometry, value: value)
                                        }
                                )
                            Circle()
                                .fill(selectRGBColor)
                                .frame(width: 40, height: 40)
                                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                                .position(selectRGBColorPosition)
                                .shadow(color: Color.black.opacity(0.25), radius: 4, x: 0, y: 4)
                                .gesture(
                                    DragGesture(minimumDistance: 0)
                                        .onChanged{ value in
                                            disableTextField()
                                            shadeOfMultiColor(geometry: geometry, value: value)
                                        }
                                )
                            
                        }
                    }
                    ///
                    /// opacity value Sub view components
                    ///In this geometry reader is used to find the size of the componets and position of opacity  of componets
                    ///Drag Guesture is used to find the drag location in side shade components
                    ///Geometry reader helps the drag point to be inside the components
                    ///
                    GeometryReader{geometry in
                        ZStack{
                            /// * color chnages according to final color which will be shade color or rgb color
                            ///  In this componets is movavble in x direction
                            RoundedRectangle(cornerRadius: 24)
                                .fill(
                                    LinearGradient(colors: [.white, selectedColor], startPoint: .leading
                                                   , endPoint: .trailing)
                                )
                                .frame(height: 24)
//                                .background{
//                                    Image(.customColorPickerOpacityBackground)
//                                        .resizable()
//                                        .scaledToFill()
//                                }
                                .overlay{
                                    RoundedRectangle(cornerRadius: 24)
                                        .stroke(.black.opacity(0.2))
                                }
                                .gesture(
                                    DragGesture(minimumDistance: 0)
                                        .onChanged{ value in
                                            disableTextField()
                                            colorOpacityValue(geometry: geometry, value: value)
                                        }
                                )
                            Circle()
                                .fill(selectedColor == .red ? selectedColor : finalColor)
                                .frame(width: 40, height: 40)
                                .overlay(Circle().stroke(Color.white, lineWidth: 3))
                                .position(opacityPosition)
                                .shadow(color: Color.black.opacity(0.25), radius: 4, x: 0, y: 4)
                                .gesture(
                                    DragGesture(minimumDistance: 0)
                                        .onChanged{ value in
                                            disableTextField()
                                            colorOpacityValue(geometry: geometry, value: value)
                                        }
                                )
                        }
                        .padding(.top, 11)
                    }
                }
                addColour()
                defaultColor()
            }
            .padding(.horizontal, 16)
        }
        .disabled(viewModel.isScrollGuestureOff)
    }
    ///
    ///Add color componets
    ///Using grid we distribute the color
    ///We have added coredatamange to save the color in device
    ///
    @ViewBuilder
    func addColour()-> some View{
        VStack(alignment: .leading,spacing: 16){
            HStack{
                TextView(fontName: .TMEDIUM, fontsSize: .TSIZE_16, fontColor: .headerTitleColerSet, textTitle: "Your Colours")
                    .padding(.horizontal, 5)
                Spacer()
            }
            // Size of circular shape color componets
            let itemWidth: CGFloat = 40
                let totalSpacing: CGFloat = 48 // Horizontal padding
                let screenWidth = UIScreen.main.bounds.size.width
                let calculatedSpacing = (screenWidth - (5 * itemWidth) - totalSpacing) / 4

                let gridColumns: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: calculatedSpacing), count: 5)
            
            LazyVGrid(columns: gridColumns, spacing: 16){
                Button {
                            // storring color in local array to show at present color
                    if viewModel.previousColorData != hexCode{
                        viewModel.addingColour.append(ColorAdding(alphaValue: opacityNumber, colorHexCode: hexCode, colorOpacityY: opacityPosition.y, colorOpacityX: opacityPosition.x, colorRgbX: selectRGBColorPosition.x, colorRgbY: selectRGBColorPosition.y, colorShadesX: selectedPosition.x, colorShadesY: selectedPosition.y))
                        ColorPickerStoryRepository.shared.addColorDataBase(colorHexCode: hexCode, alphaValue: opacityNumber, colorOpacityY: opacityPosition.y, colorOpacityX: opacityPosition.x, colorRgbX: selectRGBColorPosition.x, colorRgbY: selectRGBColorPosition.y, colorShadesX: selectedPosition.x, colorShadesY: selectedPosition.y, indexValue: Int64(viewModel.addingColour.count))
                        if viewModel.addingColour.count == 10{
                            viewModel.updateColorData()
                        }
                        viewModel.previousColorData = hexCode
                    }
                    }
                label: {
                    Image(.dottedCircle)
                        .overlay{
                            Image(.addColorPlusBtn)
                        }
                }
            
                    ForEach(viewModel.addingColour) { colorValue in
                        if viewModel.addingColour.count < 10 {
                            Button(action: {
                                selectedPosition = CGPoint(x: colorValue.colorShadesX, y: colorValue.colorShadesY)
                                selectRGBColorPosition = CGPoint(x: colorValue.colorRgbX, y: colorValue.colorRgbY)
                                opacityPosition = CGPoint(x: colorValue.colorOpacityX, y: colorValue.colorOpacityY)
                                selectRGBColor = Color(hex: colorValue.colorHexCode)
                                selectedColor = Color(hex: colorValue.colorHexCode).opacity(colorValue.alphaValue)
                                finalColor = Color(hex: colorValue.colorHexCode).opacity(colorValue.alphaValue)
                                
                                /// Storing values in the colorValue of the timer
                                self.colorObject?.colorHexCode = colorValue.colorHexCode
                                self.colorObject?.alphaValue = colorValue.alphaValue
                                self.colorObject?.colorOpacityX = colorValue.colorOpacityX
                                self.colorObject?.colorOpacityY = colorValue.colorOpacityY
                                self.colorObject?.colorRgbX = colorValue.colorRgbX
                                self.colorObject?.colorRgbY = colorValue.colorRgbY
                                self.colorObject?.colorShadesX = colorValue.colorShadesX
                                self.colorObject?.colorShadesY = colorValue.colorShadesY
                                
                                /// Displaying the color in the text field
                                hexCode = colorValue.colorHexCode
                                opacityNumber = colorValue.alphaValue
                            }) {
                                /// Circular button filled with color
                                Circle()
                                    .fill(Color(hex: colorValue.colorHexCode).opacity(colorValue.alphaValue))
                                    .frame(width: 40, height: 40)
                            }
                        }
                    
                }
            }
            
           
        }
        .padding(.top, 12)
        .padding(.horizontal, 8)
    }
    ///
    ///Default color componets
    ///made through lazyV grid
    ///
    @ViewBuilder
    func defaultColor()-> some View{
        let itemWidth: CGFloat = 40
            let totalSpacing: CGFloat = 48 // Horizontal padding
            let screenWidth = UIScreen.main.bounds.size.width
            let calculatedSpacing = (screenWidth - (5 * itemWidth) - totalSpacing) / 4

            let gridColumns: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: calculatedSpacing), count: 5)
        VStack(spacing: 16){
            HStack{
                TextView(fontName: .TMEDIUM, fontsSize: .TSIZE_16, fontColor: .headerTitleColerSet, textTitle: "Default Colours")
                    .padding(.horizontal, 5)
                Spacer()
            }
            LazyVGrid(columns: gridColumns, spacing: 16){
                ForEach(0..<viewModel.defaultColorArray.count , id: \.self) { index in
                    Button(action: {
                        selectRGBColor = viewModel.defaultColorArray[index].color ?? Color(.white)
                        selectedColor = viewModel.defaultColorArray[index].color ?? Color(.white)
                        finalColor = viewModel.defaultColorArray[index].color ?? Color(.white)
                        hexCode = viewModel.defaultColorArray[index].color?.toHex() ?? ""
                        opacityNumber = 1
                        
                        colorObject?.colorHexCode = viewModel.defaultColorArray[index].color?.toHex() ?? ""
                        colorObject?.alphaValue = 1
                    })
                    {
                        Circle()
                            .fill(viewModel.defaultColorArray[index].color ?? Color(.white))  // Use the color property from ColorModel
                            .frame(width: 40, height: 40)
                    }
                }
            }
        }
        
        .padding(.horizontal, 8)
        .padding(.top, -4)
    }
    @ViewBuilder
    func footerContent()->some View{
        let height = NotchHandling.shared.adjustFooterHeight()
        HStack{
            Color(uiColor: .footerBackgroundColor)
        }
        .frame(height: 8)
    }
 //MARK: - Shades of color function
    ///
    ///Taking parameter x and y and size of componets
    ///First linear gradient contains color and white colr
    ///through interpolation method we will red, green and blue content in that color
    ///again repeat for black gradient with first interpolation color
    ///this will be final shade collor
    ///and the color will be return
    ///
    func calculateColorAtPoint(x: CGFloat, y: CGFloat, in size: CGSize) -> Color {
        let horizontalFraction = x / size.width
        let verticalFraction = y / size.height
        
        // Interpolating between white and red horizontally
        let horizontalColor = interpolateColor(start: .white, end: selectRGBColor, fraction: horizontalFraction)
        // Interpolating between black and the horizontal color vertically
        let finalColor = interpolateColor(start: horizontalColor, end: .black, fraction: verticalFraction)
        
        return finalColor
    }
    
    // Helper function to interpolate between two colors
    func interpolateColor(start: Color, end: Color, fraction: CGFloat) -> Color {
        let startComponents = start.getComponents()
        let endComponents = end.getComponents()
        
        let r = startComponents.red + fraction * (endComponents.red - startComponents.red)
        let g = startComponents.green + fraction * (endComponents.green - startComponents.green)
        let b = startComponents.blue + fraction * (endComponents.blue - startComponents.blue)
        
        return Color(red: r, green: g, blue: b)
    }
    
}


extension Color {
    ///
    ///rgb content in a color is find throught this method
    ///using rgb float value (256,256,256)
    ///
    func getComponents() -> (red: CGFloat, green: CGFloat, blue: CGFloat, opacity: CGFloat) {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return (red, green, blue, alpha)
    }
    ///
    ///color converted to hex string
    ///
    func toHex() -> String {
        let components = self.getComponents()
        return String(
            format: "#%02lX%02lX%02lX",
            lroundf(Float(components.red * 255)),
            lroundf(Float(components.green * 255)),
            lroundf(Float(components.blue * 255))
        )
    }
    
    /// Generates a tinted version of the base color by interpolating towards white.
        /// - Parameters:
        ///   - baseColor: The base color as a `Color` object.
        ///   - tintFactor: A `CGFloat` in the range `0.0` to `1.0` (0 = no tint, 1 = fully white).
        /// - Returns: The tinted color as a `Color` object.
        static func tintColor(baseColor: Color, tintFactor: CGFloat) -> Color {
            // Ensure tint factor is within 0 to 1
            let clampedTintFactor = min(max(tintFactor, 0), 1)
            
            // Extract RGB components from the base color
            let baseUIColor = UIColor(baseColor)
            let baseComponents = baseUIColor.cgColor.components ?? [0, 0, 0, 1] // Default to black
            let r = baseComponents[0]
            let g = baseComponents[1]
            let b = baseComponents[2]

            // Interpolate RGB channels towards white
            let tintedR = r * (1 - clampedTintFactor) + 1 * clampedTintFactor
            let tintedG = g * (1 - clampedTintFactor) + 1 * clampedTintFactor
            let tintedB = b * (1 - clampedTintFactor) + 1 * clampedTintFactor

            return Color(red: tintedR, green: tintedG, blue: tintedB)
        }
        
        /// Generates a tinted version of the base color by interpolating towards white using a hex color string.
        /// - Parameters:
        ///   - baseColorHex: A string representation of the base color in hexadecimal format (e.g., `"#FF5733"` or `"FF5733"`).
        ///   - tintFactor: A `CGFloat` in the range `0.0` to `1.0`.
        /// - Returns: The tinted color as a `Color` object.
        static func tintColor(baseColorHex: String, tintFactor: CGFloat) -> Color {
            // Convert hex string to a Color
            func hexToColor(hex: String) -> Color? {
                var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
                if hexSanitized.hasPrefix("#") {
                    hexSanitized.removeFirst()
                }

                guard hexSanitized.count == 6, let rgbValue = UInt64(hexSanitized, radix: 16) else {
                    debugPrint("Invalid Hex Code: \(hexSanitized)")
                    return nil
                }

                let r = Double((rgbValue >> 16) & 0xFF) / 255
                let g = Double((rgbValue >> 8) & 0xFF) / 255
                let b = Double(rgbValue & 0xFF) / 255

                return Color(red: r, green: g, blue: b)
            }

            guard let baseColor = hexToColor(hex: baseColorHex) else {
                return Color.white // Fallback to white for invalid hex input
            }

            return tintColor(baseColor: baseColor, tintFactor: tintFactor)
        }
    
    
}

 //MARK: - For Custon logic Func
extension CustomColorPicker{
    func disableTextField(){
        viewModel.isHiddentextFieldAppear = false
        dismissKeyboard()
    }
    
    ///
    ///Shades of same Color func or 1st color components
    ///
    func shadeOfSingleColor(geometry: GeometryProxy, value: DragGesture.Value){
        
        let x = min(max(value.location.x, 0), geometry.size.width)
        let y = min(max(value.location.y, 0), geometry.size.height)
        selectedPosition = CGPoint(x: x, y: y)
        geomertrySizeOfShades = geometry.size
        ///calculating the color throught coordinates and size of components
        selectedColor = calculateColorAtPoint(x: x, y: y, in: geometry.size)
        finalColor = Color.tintColor(baseColor: selectedColor.opacity(opacityNumber), tintFactor: (1.0 - tintNumber)) 
        hexCode = selectedColor.toHex()
        
        //updated color object
        colorObject?.colorShadesX = selectedPosition.x
        colorObject?.colorShadesY = selectedPosition.y
        colorObject?.colorHexCode = hexCode
    }
    
    ///
    ///Shades of Multi Color func or 2nd color components
    ///
    func shadeOfMultiColor(geometry: GeometryProxy, value: DragGesture.Value){
        
        //selectedPosition = CGPoint(x: UIScreen.main.bounds.size.width - 48, y: 16)
        let x = min(max(value.location.x, 8), geometry.size.width - 8)
        let y = min(max(value.location.y, 12), geometry.size.height +  3)
        selectRGBColorPosition = CGPoint(x: x, y: y)
        //Getting color through x coordinates and width or xand width  ratio
        // It is movable in x direction
        selectRGBColor = viewModel.getColor(at: x / geometry.size.width)
        selectedColor = selectRGBColor
        // After `finding rgb` the color shades previous location is used to find
        //updated rgb color shade
        selectedColor = calculateColorAtPoint(x: selectedPosition.x , y: selectedPosition.y, in: geomertrySizeOfShades ?? CGSize(width:  UIScreen.main.bounds.size.width - 32, height: 248))
        
        finalColor = selectedColor.opacity(opacityNumber)
        hexCode = selectedColor.toHex()
        
        //UPDATED COLOR OBJECT HERE
        colorObject?.colorRgbX = selectRGBColorPosition.x
        colorObject?.colorRgbY = selectRGBColorPosition.y
        colorObject?.colorHexCode = hexCode
    }
    
    ///
    ///Color Opacity handling or 3rd Components
    ///
    func colorOpacityValue(geometry: GeometryProxy, value: DragGesture.Value){
        let x = min(max(value.location.x, 16), geometry.size.width - 16)
        let y = min(max(value.location.y, 12), geometry.size.height +  3)
        opacityPosition = CGPoint(x: x, y: y)
        /// opacity is find through ration of location point x and width of componets
        tintNumber = (x - 16) / (geometry.size.width - 32)
        tintColor = Color.tintColor(baseColor: selectedColor, tintFactor: (1.0 - tintNumber))
        finalColor = tintColor.opacity(opacityNumber)
        
        hexCode = finalColor.toHex()
        //COLOR OBJECT UPDATED HERE
        colorObject?.colorOpacityX = opacityPosition.x
        colorObject?.colorOpacityY = opacityPosition.y
        colorObject?.colorHexCode = hexCode
        colorObject?.alphaValue = opacityNumber
        
    }
}


//Preview Screen
#Preview {
    CustomColorPicker(hexCode: .constant("#000000"), opacityNumber: .constant(1))
}
