//
//  SettingAddingRounds.swift
//  TIMER
//
//  Created by Aditya Maroo on 20/08/24.
//

import SwiftUI

struct SettingAddingRounds: View {
    var settingName: String = "No of rounds"
    @Binding var rounds: Int64
    var body: some View {
        HStack{
            TextLabelRegularFont(stringData: settingName)
            Spacer()
            
            HStack(spacing: 0){
                Button(action: {
                    hapticON()
                    rounds = rounds > 1 ? rounds - 1 : 1
                })
                {
                    Image(.minusBtn)
                        .padding(.all, 20)
                }
                .frame(width: 48, height: 48)
                
                TextLabelRegularFont(stringData: "\(rounds)")
             
                
                Button(action:{
                    hapticON()
                    rounds += 1
                })
                {
                    Image(.plusBtn)
                        .padding(.all, 20)
                }
                .frame(width: 48, height: 48)
                
            }
            .padding(.trailing, -16)
        }
//        .frame(height: 24)
//        .padding(.horizontal, 16)
    }
}

#Preview {
    SettingAddingRounds( rounds: .constant(0) )
}
