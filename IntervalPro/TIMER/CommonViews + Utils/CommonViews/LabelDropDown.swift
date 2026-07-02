//
//  LabelDropDown.swift
//  TIMER
//
//  Created by Aditya Maroo on 16/08/24.
//

import SwiftUI

struct LabelDropDown: View {
    var txtDropDown: String
    var settingName: String
    //audio Data
    var audioSettingData: Settings?
    @State var isSoundSetting: Bool = false
    
     //MARK: - Call back
    var callBackSoundNavigate: (()-> Void)?
    
    var body: some View {
        ZStack{
            HStack{
               TextLabelRegularFont(stringData: settingName)
                Spacer()
                Button(action: {
                    callBackSoundNavigate?()
                    isSoundSetting = true
                })
                {
                    TextLabelLightFont(stringData: txtDropDown)
                }
                
            }
            .frame(height: 24)
            //        .padding(.horizontal, 16)
            NavigationLink(isActive: $isSoundSetting) {
                if isSoundSetting{
                    TimerSettingView(audioSetting: audioSettingData)
                }
            } label: {
                EmptyView()
            }
            .hidden()
        }
    }
}

#Preview {
    LabelDropDown(txtDropDown: "Defaults Beeps", settingName: "Setting")
}
