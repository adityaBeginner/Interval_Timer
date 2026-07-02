//
//  CircluarSettingToggleBtn.swift
//  TIMER
//
//  Created by Aditya Maroo on 23/08/24.
//

import SwiftUI

struct CircularSettingToggleBtn: View {
    var isTextToSpeech: Bool = false
    var settingName: String = ""
    @Binding var isBtnStateChange: Bool
   
    var body: some View {
        HStack{
            TextLabelRegularFont(stringData: settingName)
//            Color.white
            Spacer()
            Image(isBtnStateChange ? !isTextToSpeech ?.stateBtnTrue :.stateBtnFalse : .stateBtnFalse)
        }
        .frame(height: 24)
    }
}


