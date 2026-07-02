//
//  SessionTextField.swift
//  TIMER
//
//  Created by Aditya Maroo on 12/11/24.
//

import SwiftUI

struct SessionTextField: View {
    var txtPlaceHolder: String
    var textFieldPlaceHolder: String = ""
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
                        .foregroundColor(AppDefaults.shared.hundredthMilliSeconds ? .clear : .textFontChild)
                        .background(alignment: .leading, content: {
                            if AppDefaults.shared.hundredthMilliSeconds{
                                SessionMilliSecondsAttributeTxt(timeString: stringData, fontColor: .textFontChild, fontSize: .TSIZE_16)
                            }
                        })
                        .frame(maxWidth: .infinity)
                        .focused($textFieldState)
                        .onChange(of: stringData){newValue in
                            AppDefaults.shared.hundredthMilliSeconds ? reformatAsTimeMinMilliSeconds(newValue) :
                        reformatAsTimeMin(newValue)
                        }
                   
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
        .onAppear{stringData = AppComman.shared.handlingHoursMilliseconds(timeString: stringData)}
        .frame(height: 61)
    }
        
}

#Preview {
    TextFieldView(txtPlaceHolder: "Time Creation", stringData: .constant("Aditya maroo"))
}

extension SessionTextField{
    public func reformatAsTimeMin(_ value: String) {
        let timeSeparator = ":"
           var cleanString = value.replacingOccurrences(of: timeSeparator, with: "")
           
// Handle empty input
//           if cleanString.isEmpty {
//               minData = "00:00"
//               return
//           }
           
           var minutesText = ""
           var secondsText = ""
           var hourText = ""
           
           switch cleanString.count {
           case 1:
               // If only one digit, treat as 00:00:0X
               hourText = "00"
               minutesText = "00"
               secondsText = "0\(cleanString)"
               
           case 2:
               // If two digits, treat as 00:00:XX
               hourText = "00"
               minutesText = "00"
               secondsText = cleanString
               
           case 3:
               // If three digits, treat as 00:0X:XX
               hourText = "00"
               minutesText = "0\(cleanString.prefix(1))"
               secondsText = String(cleanString.suffix(2))
               
           case 4:
               //if Four Digit Text Field,treat as 00:XX:XX
               hourText = "00"
               minutesText = String(cleanString.prefix(2))
               secondsText = String(cleanString.suffix(2))
               
           case 5:
               // If Five Digit Text Field,treat as 00:XX:XX
               hourText = "0\(cleanString.prefix(1))"
               cleanString.removeFirst()
               minutesText = String(cleanString.prefix(2))
               secondsText = String(cleanString.suffix(2))
               
           default:
               // If four or more digits, remove the first digit to fit MM:SS format
               if cleanString.prefix(1) == "0"{
                   cleanString = String(cleanString.suffix(6))
                   hourText = String(cleanString.prefix(2))
                   minutesText = String(cleanString.dropFirst(2).prefix(2))
                   secondsText = String(cleanString.suffix(2))
               }
               else{
                   cleanString = String(cleanString.prefix(6))
                   hourText = String(cleanString.prefix(2))
                   minutesText = String(cleanString.dropFirst(2).prefix(2))
                   secondsText = String(cleanString.suffix(2))
               }
           }
           
           // Update the formatted time
        if cleanString.count > 0 {
            stringData = "\(hourText)\(timeSeparator)\(minutesText)\(timeSeparator)\(secondsText)"
        }
           
           // Remove unnecessary leading zeros if the user backspaces
        if cleanString == "0" || cleanString == "00" || cleanString == "000" || cleanString == "0000" || cleanString == "00000" {
            
            switch cleanString.count {
            case 1:
                // If only one digit, treat as 0
                cleanString = "0"
                
            case 2:
                // If two digits, treat as 00
                cleanString = "00"
                
            case 3:
                // If three digits, treat as 00:0
                cleanString = "00:0"
                
            case 4:
                //if Four Digit Text Field,treat as 00:00
                cleanString = "00:00"
                
            case 5:
                // If Five Digit Text Field,treat as 00:00:0
                cleanString = "00:00:0"
                
            default:
                // If four or more digits, remove the first digit to fit MM:SS format
             cleanString = ""
            }
              
               stringData = cleanString
           }
       }
    
    public func reformatAsTimeMinMilliSeconds(_ value: String) {
        let timeSeparator = ":"
        var cleanString = value.replacingOccurrences(of: timeSeparator, with: "")
        
        var hourText = ""
        var minutesText = ""
        var secondsText = ""
        var milliText = ""
        
        switch cleanString.count {
        case 1:
            hourText = "00"
            minutesText = "00"
            secondsText = "00"
            milliText = "0\(cleanString)"
        case 2:
            hourText = "00"
            minutesText = "00"
            secondsText = "00"
            milliText = cleanString
        case 3:
            hourText = "00"
            minutesText = "00"
            secondsText = "0\(cleanString.prefix(1))"
            milliText = String(cleanString.suffix(2))
        case 4:
            hourText = "00"
            minutesText = "00"
            secondsText = String(cleanString.prefix(2))
            milliText = String(cleanString.suffix(2))
        case 5:
            hourText = "00"
            minutesText = "0\(cleanString.prefix(1))"
            secondsText = String(cleanString.dropFirst().prefix(2))
            milliText = String(cleanString.suffix(2))
        case 6:
            hourText = "00"
            minutesText = String(cleanString.prefix(2))
            secondsText = String(cleanString.dropFirst(2).prefix(2))
            milliText = String(cleanString.suffix(2))
        case 7:
            hourText = "0\(String(cleanString.prefix(1)))"
            minutesText = String(cleanString.dropFirst(1).prefix(2))
            secondsText = String(cleanString.dropFirst(3).prefix(2))
            milliText =  String(cleanString.suffix(2))
     
        default:
            if cleanString.prefix(1) == "0"{
                cleanString = String(cleanString.suffix(8))
                hourText = String(cleanString.prefix(2))
                minutesText = String(cleanString.dropFirst(2).prefix(2))
                secondsText = String(cleanString.dropFirst(4).prefix(2))
                milliText = String(cleanString.suffix(2))
            }
            else{
                cleanString = String(cleanString.prefix(8))
                hourText = String(cleanString.prefix(2))
                minutesText = String(cleanString.dropFirst(2).prefix(2))
                secondsText = String(cleanString.dropFirst(4).prefix(2))
                milliText = String(cleanString.suffix(2))
            }
        }
        
        if cleanString.count > 0 {
            stringData = "\(hourText)\(timeSeparator)\(minutesText)\(timeSeparator)\(secondsText)\(timeSeparator)\(milliText)"
        }
        
        if cleanString == "0" || cleanString == "00" || cleanString == "000" || cleanString == "0000" || cleanString == "00000" || cleanString == "000000" || cleanString == "0000000"{
            switch cleanString.count {
            case 1:
                cleanString = "0"
            case 2:
                cleanString = "00"
            case 3:
                cleanString = "00:0"
            case 4:
                cleanString = "00:00"
            case 5:
                cleanString = "00:00:0"
            case 6:
                cleanString = "00:00:00"
            case 7:
                cleanString = "00:00:00:0"
            default:
                cleanString = ""
            }
            stringData = cleanString
        }
    }

}
