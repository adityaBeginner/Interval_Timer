//
//  SettingColorLabel.swift
//  TIMER
//
//  Created by Aditya Maroo on 16/08/24.
//

import SwiftUI

struct SettingColorLabel: View {
    
    //MARK: -
    //MARK: PROPERTIES
    var colorObject:ColorObject?
    var settingName: String
    @Binding var colorOpacity: Double
    @Binding var colorHex:String
    @State var isColor: Bool = false
    
     //MARK: - callBack
    var saveItemData: (()-> Void)?
    
    var body: some View {
        ZStack{
            HStack{
                TextLabelRegularFont(stringData: settingName)
                    
                Spacer()
                
                Rectangle()
                    .fill(Color(hex: colorHex).opacity(colorOpacity))
                    .frame(width: 48, height: 24)
                    .cornerRadius(6)
                    .onTapGesture {
                        saveItemData?()
                        isColor = true
                        colorObject?.colorHexCode = colorHex
                        colorObject?.alphaValue = 1
                    }
                    .overlay{
                        if AppComman.shared.has95PercentBlackRatio(color: Color(hex: colorHex)) || AppComman.shared.has95PercentWhiteRatio(color: Color(hex: colorHex)) {
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color(uiColor: .footerBackgroundColor), lineWidth: 0.7)
                                .frame(width: 50, height: 25)
                        }
                    }
            }
            .frame(height: 24)
            //        .padding(.horizontal, 16)
            NavigationLink(isActive: $isColor) {
                if isColor{
                    ColorSelectingView(colorHexString: $colorHex,colorOpacity: $colorOpacity, previousNavigation: $isColor, colorObject: colorObject)
                }
            } label: {
                EmptyView()
            }
            .hidden()
        }
    }
}
