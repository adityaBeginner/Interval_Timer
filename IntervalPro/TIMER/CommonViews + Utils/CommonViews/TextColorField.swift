//
//  TextColorField.swift
//  TIMER
//
//  Created by Aditya Maroo on 06/09/24.
//

//
//  SwiftUIView.swift
//  TIMER
//
//  Created by Aditya Maroo on 16/08/24.
//

import SwiftUI

struct TextColorField: View {
    var txtPlaceHolder: String
    var isColorBoxHidden: Bool = false
    @State var isNaviagteColorPicker: Bool = false
    var isNavigationOn: Bool = false
    @Binding var colorHexString:String
    @Binding var colorOpacity:Double
    @Binding var previousNavigation: Bool
    var colorObject:ColorObject?
    @Binding var isNewTextFieldAppear: Bool
    @State var hiddenColorString: String = ""
    @State var isRedLine : Bool = false
    @FocusState private var isTextFieldFocus: Bool
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) private var isPresented
    //Empty call back for changing shades and color
    var selectedColorCallBack: (()-> Void)?
    
    var body: some View {
        ZStack{
            VStack(spacing: 17){
                HStack{
                    TextLabelLightFont(stringData: txtPlaceHolder, fontSize: .TSIZE_14)
                    Spacer()
                }
                .frame(height: 17)
                VStack(spacing: 8)
                {
                    HStack{
                        ZStack{
//                            if !isNewTextFieldAppear{
//                                TextField(txtPlaceHolder, text: $colorHexString)
//                                    .font(.system(size: TSize.TSIZE_16.rawValue, weight: Font.Weight.medium))
//                                    .foregroundStyle(Color(uiColor: .headerTitleColerSet))
//                                //                                .onChange(of: colorHexString, perform: {value in
//                                //                                isNewTextFieldAppear = false
//                                //                                })
//                                    .disabled(true)
//                                
//                            }
                            //For wirting hex Code
                            
                            TextField(colorHexString.isEmpty ? txtPlaceHolder : "", text: $colorHexString)
                                .font(.system(size: TSize.TSIZE_16.rawValue, weight: Font.Weight.medium))
                                .foregroundStyle(Color(uiColor: .headerTitleColerSet))
                                .onChange(of: colorHexString, perform: {value in
                                    if isTextFieldFocus{
//                                    if value != colorHexString{
                                        if value.count == 6 && value.first != "#"  {
                                            var newValue = "#"
                                            newValue.append(value)
                                            if AppComman.shared.colorInputValiadateCheck(colorString: newValue){
                                                colorHexString = newValue
                                                selectedColorCallBack?()
                                                isNewTextFieldAppear = false
                                                dismissKeyboard()
                                            }
                                            else{
                                                isRedLine = true
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 1 , execute: {
                                                    isNewTextFieldAppear = false
                                                    isRedLine = false
                                                    hiddenColorString = ""
                                                    dismissKeyboard()
                                                })
                                            }
                                        }
                                        else if value.count == 7 && value.first == "#"{
                                            if AppComman.shared.colorInputValiadateCheck(colorString: value){
                                                colorHexString = value
                                                selectedColorCallBack?()
                                                isNewTextFieldAppear = false
                                                dismissKeyboard()
                                            }
                                            else{
                                                isRedLine = true
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 1 , execute: {
                                                    isNewTextFieldAppear = false
                                                    isRedLine = false
                                                    hiddenColorString = ""
                                                    dismissKeyboard()
                                                })
                                            }
                                            //                                        }
                                        }
                                    }
                                })
                                .focused($isTextFieldFocus)
//                                .onChange(of: isTextFieldFocus) { newValue in
//                                    if newValue{
//                                        if hiddenColorString.isEmpty{
//                                            hiddenColorString = colorHexString
//                                        }
//                                        isNewTextFieldAppear = true
//                                    }
//                                }
//                                .onTapGesture {
//                                    isNewTextFieldAppear = true
//                                    hiddenColorString = colorHexString
//                                }
                            
                        }
                        
                        if !isColorBoxHidden{
                            Spacer()
                            Rectangle()
                                .fill(Color(hex: colorHexString).opacity(colorOpacity))
                                .frame(width: 48, height: 24)
                                .cornerRadius(6)
                                .overlay{
                                    if AppComman.shared.has95PercentBlackRatio(color: Color(hex: colorHexString)) || AppComman.shared.has95PercentWhiteRatio(color: Color(hex: colorHexString)) {
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(Color(uiColor: .orange),lineWidth: 1)
                                    }
                                }
                                .onTapGesture {
                                    if isNavigationOn{
                                        isNaviagteColorPicker = true
                                    }
                                }
                        }
                    }
                    HStack{
                        Color(uiColor: isRedLine ? .red : .borderLine)
                    }
                    .frame(height: 1)
                    
                }
            }
            
            .frame(height: 61)
            //        .padding(.horizontal, 16)
            
            NavigationLink(isActive: $isNaviagteColorPicker) {
                if isNaviagteColorPicker{
                    CustomColorPicker(hexCode: $colorHexString, opacityNumber: $colorOpacity, colorObject: colorObject, dismisscallBackData: {
                       previousNavigation = false
                    })
                }
            } label: {
                EmptyView()
            }
            .hidden()
            
            
        }
    }
    
}


