//
//  SwiftUIView.swift
//  TIMER
//
//  Created by Aditya Maroo on 16/08/24.
//

import SwiftUI

struct TextFieldView: View {
    var txtPlaceHolder: String
    var textFieldPlaceHolder: String = ""
    var isMessageDelay: Bool = false
    var isColorBoxHidden: Bool = true
    @Binding var stringData: String
    @FocusState private var textFieldState: Bool
   
    var body: some View {
        VStack(spacing: 17){
            HStack{
                TextLabelLightFont(stringData: txtPlaceHolder)
                Spacer()
            }
            .frame(height: 17)
            VStack(spacing: 8)
            {
                HStack{
                    TextField(textFieldPlaceHolder, text: $stringData)
                        .font(.system(size: 16, weight: Font.Weight.medium))
                        .foregroundColor((AppDefaults.shared.hundredthMilliSeconds && isMessageDelay) ? .clear : .textFontChild)
                        .background(alignment: .leading, content: {
                            if AppDefaults.shared.hundredthMilliSeconds && isMessageDelay{
                                MilliSecondsAttributeTxt(timeString: stringData, fontColor: .textFontChild, fontSize: .TSIZE_16)
                            }
                        })
                        .frame(maxWidth: .infinity)
                        .focused($textFieldState)
                   
                    if !isColorBoxHidden{
                        Spacer()
                        Rectangle()
                            .fill(.black)
                            .frame(width: 48, height: 24)
                            .cornerRadius(6)
                    }
                }
                HStack{
                    Color(uiColor: textFieldState ? .footerBackgroundColor : .borderLine)
                }
                .frame(height: 1)
                
            }
        }
    
        .frame(height: 61)
    }
        
}

#Preview {
    TextFieldView(txtPlaceHolder: "Time Creation", stringData: .constant("Aditya maroo"))
}
