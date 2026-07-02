//
//  SettingIntervalTxtSwith.swift
//  TIMER
//
//  Created by Aditya Maroo on 20/08/24.
//

import SwiftUI

struct SettingIntervalTxtSwitch: View {
    var txtPlaceHolder: String = ""
    @Binding var stringData: String
   
    var firstSettingLblName: String = "Total Rounds"
    
    var secondSettingLblName: String = "Rounds"
  
    
    @State var isSwitchOn: Bool = false
    
    var body: some View {
        settingUp()
    }
}

#Preview {
    SettingIntervalTxtSwitch(stringData: .constant("88.88.88"))
}

extension SettingIntervalTxtSwitch{
    @ViewBuilder
    func settingUp()-> some View{
        
        VStack(spacing: 19){
            topContent()
            endContent()
        }
//        .padding(.horizontal, 16)
    }
    @ViewBuilder
    func topContent()->some View{
        
        HStack(spacing: 0){
            Text(firstSettingLblName)
                .font(.custom(TFonts.TLIGHT.rawValue, size: TSize.TSIZE_14.rawValue))
                .foregroundStyle(Color(uiColor: .headerTitleColerSet))
        Spacer()
            Text(secondSettingLblName)
                .font(.custom(TFonts.TLIGHT.rawValue, size: TSize.TSIZE_14.rawValue))
                .foregroundStyle(Color(uiColor: .headerTitleColerSet))
        }
        .frame(height: 17)
    }
    @ViewBuilder
    func endContent()-> some View{
        HStack(spacing: 0){
            
            VStack(spacing: 8)
            {
                
                    HStack{
                        TextField(txtPlaceHolder, text: $stringData)
                            .font(.custom(TFonts.TMEDIUM.rawValue, size: TSize.TSIZE_16.rawValue))
                            .foregroundStyle(Color(uiColor: .headerTitleColerSet))
                    
                }
                HStack{
                    Color(uiColor: .borderLine)
                }
                .frame(height: 1)
                
            }
            Spacer()
           CustomSwitch(isSwitchTap: $isSwitchOn)
                .onTapGesture{
                    
                    withAnimation(.linear(duration: 0.15)){
                        isSwitchOn.toggle()
                    }
                    let generator = UIImpactFeedbackGenerator(style: .light)
                               generator.impactOccurred()
                        
                }
                .padding(.top, -8)
        }
    }
}

