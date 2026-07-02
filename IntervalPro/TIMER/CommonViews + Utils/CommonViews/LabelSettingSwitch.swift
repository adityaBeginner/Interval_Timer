//
//  LabelSettingSwitch.swift
//  TIMER
//
//  Created by Aditya Maroo on 16/08/24.
//

import SwiftUI
import AudioUnit

struct LabelSettingSwitch: View {
    var settingName: String
    @Binding var isSwitchOn: Bool
    var isDarkBtnSwitch: Bool = false
    @EnvironmentObject var darkMode: AppEnvironment
    
    //call back
    var disableEnableCallback: (()-> Void)?
  
    
    var body: some View {
        HStack{
            TextLabelRegularFont(stringData: settingName)
            Spacer()
            
           CustomSwitch(isSwitchTap: $isSwitchOn)
                .onTapGesture{
                    withAnimation(.easeInOut(duration: 0.15)){
                        isSwitchOn.toggle()
                        disableEnableCallback?()
                        if isDarkBtnSwitch{
                            if isSwitchOn{
                                darkMode.isDarkMode = isSwitchOn
                            }
                            else{
                                darkMode.isDarkMode = isSwitchOn
                            }
                        }
                    }
                    let generator = UIImpactFeedbackGenerator(style: .light)
                               generator.impactOccurred()
                        
                }
        }
        .frame(height: 24)
//        .padding(.horizontal, 16)
    }
}

#Preview {
    LabelSettingSwitch(settingName: "Setting Name", isSwitchOn: .constant(false))
}
