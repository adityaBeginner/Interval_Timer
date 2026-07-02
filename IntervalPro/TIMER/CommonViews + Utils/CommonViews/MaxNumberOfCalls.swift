//
//  MaxNumberOfCalls.swift
//  TIMER
//
//  Created by Aditya Maroo on 11/09/24.
//

import SwiftUI

struct MaxNumberOfCalls: View {
     var firstSettingLblName = ""
    @Binding var minData: Int32
    var txtPlaceHolder = ""
    @Binding var isSwitchOn: Bool
    
    //Focus State variable for text field
    @FocusState private var istextFieldFocus: Bool
    var body: some View {
       setUp()
    }
}

#Preview {
    MaxNumberOfCalls( minData: .constant(0), isSwitchOn: .constant(false))
}

extension MaxNumberOfCalls{
    @ViewBuilder
    func setUp()-> some View{
        VStack(spacing: 17){
            HStack(spacing: 0){
                TextLabelLightFont(stringData: firstSettingLblName, fontSize: .TSIZE_14)
                Spacer()
            }
            HStack{
                VStack(spacing: 8){
                    TextField(txtPlaceHolder, value: $minData, formatter: NumberFormatter())
                        .font(.custom(TFonts.TMEDIUM.rawValue, size: TSize.TSIZE_16.rawValue))
                        .foregroundStyle(Color(uiColor: .headerTitleColerSet))
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/ )
                        .focused($istextFieldFocus)
                        .keyboardType(.numberPad)
                    
                    HStack{
                        Color(uiColor: istextFieldFocus ?  .footerBackgroundColor : .borderLine)
                    }
                    .frame(height: 1)
                }
                CustomSwitch(isSwitchTap: $isSwitchOn)
                     .onTapGesture{                         withAnimation(.linear.delay(0.15)){
                             isSwitchOn.toggle()
                             }
                         let generator = UIImpactFeedbackGenerator(style: .light)
                                    generator.impactOccurred()
                     }
                     .padding(.top, -8)
            }
        }
    }
}
