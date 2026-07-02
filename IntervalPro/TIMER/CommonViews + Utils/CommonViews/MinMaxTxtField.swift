//
//  MinMaxTxtField.swift
//  TIMER
//
//  Created by Aditya Maroo on 21/08/24.
//

import SwiftUI

struct MinMaxTxtField: View {
    var txtPlaceHolder: String = "88:88:88"

    @Binding var minData: String
    @Binding var maxData: String
    var firstSettingLblName: String = "Total Rounds"
     @State private var isFormatting: Bool = false
    @State private var lastFormattedValue: String = ""
    //Focuse state
    @FocusState private var isTextFieldFocused: Bool
    
    var secondSettingLblName: String = "Rounds"
    var textFieldType: TextFieldType?
    @Binding var isSwitchOn: Bool
    // Call Back for appearing pop screen
    var callBackData: ((TextFieldType, MinMaxTime)-> Void)?
    var body: some View {
      settingUp()
            .onAppear{
               handlingMilliseconds()
            }
    }
}

#Preview {
    MinMaxTxtField(minData: .constant("88:88:88"), maxData: .constant("88:88:88"), isSwitchOn: .constant(false))
}
extension MinMaxTxtField{
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
            TextLabelLightFont(stringData: firstSettingLblName)
        Spacer()
            TextLabelLightFont(stringData: secondSettingLblName)
        }
        .frame(height: 17)
    }
    @ViewBuilder
    func endContent()-> some View{
        HStack(spacing: 0){
            
            VStack(spacing: 8)
            {
                    HStack(spacing: 33){
                        VStack(alignment: .leading, spacing: 4){
                            textFieldChild(txtPlaceHolder: AppDefaults.shared.hundredthMilliSeconds ? "MM:SS:ms" : "MM:SS" , bindStringData: $minData)
                                .onChange(of: minData){newValue in
                                    AppDefaults.shared.hundredthMilliSeconds ? reformatAsTimeMinForMilliseconds(newValue) : reformatAsTimeMin(newValue)
                                }
                            if isSwitchOn{
                                TextLabelRegularFont(stringData: "Min", fontSize: .TSIZE_14)
                                    .foregroundStyle(Color(uiColor: .headerTitleColerSet))
                            }
                            }
                        if isSwitchOn{
                            VStack(alignment: .leading, spacing: 4){
                                textFieldChild(txtPlaceHolder: AppDefaults.shared.hundredthMilliSeconds ? "MM:SS:ms" : "MM:SS", bindStringData: $maxData)
                                    .onChange(of: maxData, perform: AppDefaults.shared.hundredthMilliSeconds ? reformatAsTimeMaxForMilliseconds : reformatAsTimeMax)
                                TextLabelRegularFont(stringData: "Max", fontSize: .TSIZE_14)
                                    .foregroundStyle(Color(uiColor: .headerTitleColerSet))
                            }
                            
                        }
                        Spacer()
                        }

                HStack{
                    Color(uiColor: isTextFieldFocused ? .footerBackgroundColor : .borderLine )
                }
                .frame(height: 1)
                
            }
            Spacer()
           CustomSwitch(isSwitchTap: $isSwitchOn)
                .onTapGesture{
                    withAnimation(.linear.delay(0.15)){
                        isSwitchOn.toggle()
                        }
                    let generator = UIImpactFeedbackGenerator(style: .light)
                               generator.impactOccurred()
                        
                }
                .padding(.top, -8)
        }
    }
}
 //MARK: - Creating function for adding":"
extension MinMaxTxtField{
    
    public func reformatAsTimeMin(_ value: String) {
        let timeSeparator = ":"
           var cleanString = value.replacingOccurrences(of: timeSeparator, with: "")
//        if cleanString.count == 6{
//            cleanString.removeLast(2)
//        }
           
// Handle empty input
//           if cleanString.isEmpty {
//               minData = "00:00"
//               return
//           }
           
           var minutesText = ""
           var secondsText = ""
           
           switch cleanString.count {
           case 1:
               // If only one digit, treat as 00:0X
               
               minutesText = "00"
               secondsText = "0\(cleanString)"
               
           case 2:
               // If two digits, treat as 00:XX
               minutesText = "00"
               secondsText = cleanString
               
           case 3:
               // If three digits, treat as 0X:XX
               minutesText = "0\(cleanString.prefix(1))"
               secondsText = String(cleanString.suffix(2))
               
           default:
               // If four or more digits, remove the first digit to fit MM:SS format
               if cleanString.prefix(1) == "0"{
                   cleanString = String(cleanString.suffix(4))
                   minutesText = String(cleanString.prefix(2))
                   secondsText = String(cleanString.suffix(2))
               }
               else{
                   cleanString = String(cleanString.prefix(4))
                   minutesText = String(cleanString.prefix(2))
                   secondsText = String(cleanString.suffix(2))
               }
           }
           
           // Update the formatted time
        if cleanString.count > 0 {
            minData = "\(minutesText)\(timeSeparator)\(secondsText)"
        }
           
           // Remove unnecessary leading zeros if the user backspaces
           if cleanString == "0" || cleanString == "00" || cleanString == "000" {
               if cleanString.count == 3{
                   cleanString = "00:0"
                 
               }
               else if cleanString.count == 2{
                   cleanString = "00"
               }
               else if cleanString.count == 1{
                   cleanString = "0"
               }
               else{
                   cleanString = ""
               }
               minData = cleanString
           }
       }
    
    
    public func reformatAsTimeMax(_ value: String) {
        let timeSeparator = ":"
           var cleanString = value.replacingOccurrences(of: timeSeparator, with: "")
//        if cleanString.count == 6{
//            cleanString.removeLast(2)
//        }
// Handle empty input
//           if cleanString.isEmpty {
//               minData = "00:00"
//               return
//           }
           
           var minutesText = ""
           var secondsText = ""
           
           switch cleanString.count {
           case 1:
               // If only one digit, treat as 00:0X
               
               minutesText = "00"
               secondsText = "0\(cleanString)"
               
           case 2:
               // If two digits, treat as 00:XX
               minutesText = "00"
               secondsText = cleanString
               
           case 3:
               // If three digits, treat as 0X:XX
               minutesText = "0\(cleanString.prefix(1))"
               secondsText = String(cleanString.suffix(2))
               
           default:
               // If four or more digits, remove the first digit to fit MM:SS format
               if cleanString.prefix(1) == "0"{
                   cleanString = String(cleanString.suffix(4))
                   minutesText = String(cleanString.prefix(2))
                   secondsText = String(cleanString.suffix(2))
               }
               else{
                   cleanString = String(cleanString.prefix(4))
                   minutesText = String(cleanString.prefix(2))
                   secondsText = String(cleanString.suffix(2))
               }
           }
           
           // Update the formatted time
        if cleanString.count > 0 {
            maxData = "\(minutesText)\(timeSeparator)\(secondsText)"
        }
           
           // Remove unnecessary leading zeros if the user backspaces
           if cleanString == "0" || cleanString == "00" || cleanString == "000" {
               if cleanString.count == 3{
                   cleanString = "00:0"
                 
               }
               else if cleanString.count == 2{
                   cleanString = "00"
               }
               else if cleanString.count == 1{
                   cleanString = "0"
               }
               else{
                   cleanString = ""
               }
               maxData = cleanString
           }
    }
    
   //For Max Min Milli Seonds
    public func reformatAsTimeMinForMilliseconds(_ value: String) {
        let timeSeparator = ":"
        var cleanString = value.replacingOccurrences(of: timeSeparator, with: "")
        
        var minutesText = ""
        var secondsText = ""
        var milliSecondsText = ""

//        let length = cleanString.count
    
        switch cleanString.count {
        case 1:
            minutesText = "00"
            secondsText = "00"
            milliSecondsText = "0\(cleanString)"
            
        case 2:
            minutesText = "00"
            secondsText = "00"
            milliSecondsText = cleanString
            
        case 3:
            minutesText = "00"
            secondsText = "0\(cleanString.prefix(1))"
            milliSecondsText = String(cleanString.suffix(2))
            
        case 4:
            minutesText = "00"
            secondsText = String(cleanString.prefix(2))
            milliSecondsText = String(cleanString.suffix(2))
            
        case 5:
            minutesText = "0\(cleanString.prefix(1))"
            secondsText = String(cleanString.dropFirst(1).prefix(2))
            milliSecondsText = String(cleanString.suffix(2))
            
        default:
            if cleanString.prefix(1) == "0"{
                cleanString = String(cleanString.suffix(6))
                minutesText = String(cleanString.prefix(2))
                secondsText = String(cleanString.dropFirst(2).prefix(2))
                milliSecondsText = String(cleanString.suffix(2))
            }
            else{
                cleanString = String(cleanString.prefix(6))
                minutesText = String(cleanString.prefix(2))
                secondsText = String(cleanString.dropFirst(2).prefix(2))
                milliSecondsText = String(cleanString.suffix(2))
            }
        }

        // Final formatted result
        if cleanString.count > 0{
            minData = "\(minutesText)\(timeSeparator)\(secondsText)\(timeSeparator)\(milliSecondsText)"
        }

        // Handle if only zero is typed
        if cleanString == "0" || cleanString == "00" || cleanString == "000" || cleanString == "0000" || cleanString == "00000" {
            if cleanString.count == 5{
                cleanString = "00:00:0"
            }
            else if cleanString.count == 4{
                cleanString = "00:00"
            }
            else if cleanString.count == 3{
                cleanString = "00:0"
              
            }
            else if cleanString.count == 2{
                cleanString = "00"
            }
            else if cleanString.count == 1{
                cleanString = "0"
            }
            else{
                cleanString = ""
            }
            minData = cleanString
        }
    }

    public func reformatAsTimeMaxForMilliseconds(_ value: String) {
        let timeSeparator = ":"
        var cleanString = value.replacingOccurrences(of: timeSeparator, with: "")
        
        var minutesText = ""
        var secondsText = ""
        var milliSecondsText = ""

        switch cleanString.count {
        case 1:
            minutesText = "00"
            secondsText = "00"
            milliSecondsText = "0\(cleanString)"
            
        case 2:
            minutesText = "00"
            secondsText = "00"
            milliSecondsText = cleanString
            
        case 3:
            minutesText = "00"
            secondsText = "0\(cleanString.prefix(1))"
            milliSecondsText = String(cleanString.suffix(2))
            
        case 4:
            minutesText = "00"
            secondsText = String(cleanString.prefix(2))
            milliSecondsText = String(cleanString.suffix(2))
            
        case 5:
            minutesText = "0\(cleanString.prefix(1))"
            secondsText = String(cleanString.dropFirst(1).prefix(2))
            milliSecondsText = String(cleanString.suffix(2))
            
        default:
            if cleanString.prefix(1) == "0" {
                cleanString = String(cleanString.suffix(6))
                minutesText = String(cleanString.prefix(2))
                secondsText = String(cleanString.dropFirst(2).prefix(2))
                milliSecondsText = String(cleanString.suffix(2))
            } else {
                cleanString = String(cleanString.prefix(6))
                minutesText = String(cleanString.prefix(2))
                secondsText = String(cleanString.dropFirst(2).prefix(2))
                milliSecondsText = String(cleanString.suffix(2))
            }
        }

        // Final formatted result
        if cleanString.count > 0 {
            maxData = "\(minutesText)\(timeSeparator)\(secondsText)\(timeSeparator)\(milliSecondsText)"
        }

        // Handle if only zero is typed
        if cleanString == "0" || cleanString == "00" || cleanString == "000" || cleanString == "0000" || cleanString == "00000" {
            if cleanString.count == 5 {
                cleanString = "00:00:0"
            } else if cleanString.count == 4 {
                cleanString = "00:00"
            } else if cleanString.count == 3 {
                cleanString = "00:0"
            } else if cleanString.count == 2 {
                cleanString = "00"
            } else if cleanString.count == 1 {
                cleanString = "0"
            } else {
                cleanString = ""
            }
            maxData = cleanString
        }
    }

    ///
    ///Handling 6 digit and 8 min max data according to milliseconds'
    ///
    func handlingMilliseconds() {
        let shouldAppendMilliseconds = AppDefaults.shared.hundredthMilliSeconds
        let targetCount = shouldAppendMilliseconds ? 5 : 8
        let suffix = shouldAppendMilliseconds ? ":00" : ""

        if minData.count == targetCount {
            if shouldAppendMilliseconds {
                minData.append(suffix)
            } else {
                minData.removeLast(2)
            }
        }
        
        if maxData.count == targetCount {
            if shouldAppendMilliseconds {
                maxData.append(suffix)
            } else {
                maxData.removeLast(2)
            }
        }
    }

}

extension MinMaxTxtField{
    ///
    ///child Componets of Label text
    ///
    @ViewBuilder
    func labelTextComponent(placeHolderData: String)-> some View{
      
        TextLabelMeduimFont(stringData: placeHolderData, fontColor: placeHolderData == "HH:MM:SS" ? Color.headerTitleColerSet.opacity(0.3) : Color(uiColor: .headerTitleColerSet), fontSize: .TSIZE_16)
           
    }
    ///
    ///Child Componets  of text field
    ///
    @ViewBuilder
    func textFieldChild(txtPlaceHolder: String, bindStringData: Binding<String>)-> some View{
        TextField(txtPlaceHolder, text: bindStringData)
            .font(.system(size: 16, weight: Font.Weight.medium))
            .focused($isTextFieldFocused)
            .frame(maxWidth: .infinity)
            .keyboardType(.numberPad)
            .foregroundColor(AppDefaults.shared.hundredthMilliSeconds ? .clear : .textFontChild)
            .background(alignment: .leading, content: {
                if AppDefaults.shared.hundredthMilliSeconds{
                    MilliSecondsAttributeTxt(timeString: bindStringData.wrappedValue, fontColor: .textFontChild, fontSize: .TSIZE_16)
                }
            })
    }
  
    ///this code code will be return on callint this function
}


//public func reformatAsTimeMin(_ value: String) {
//let timeSeparator = ":"
//let cleanString = value.replacingOccurrences(of: timeSeparator, with: "")
//
//if cleanString.count >= 3 {
//    let minuteString = String(cleanString.prefix(2))
//  var secondsString = String(cleanString.dropFirst(2).prefix(2))
//  if Int(secondsString.prefix(1)) ?? 0 < 6{
//      minData = minuteString + timeSeparator + secondsString
//  }
//  else{
//      secondsString = "0" + secondsString.suffix(1)
//      minData = minuteString + timeSeparator + secondsString
//  }
//} else {
//    minData = cleanString
//}
//}
//public func reformatAsTimeMax(_ value: String) {
//let timeSeparator = ":"
//let cleanString = value.replacingOccurrences(of: timeSeparator, with: "")
//
//if cleanString.count >= 3 {
//    let minuteString = String(cleanString.prefix(2))
//  var secondsString = String(cleanString.dropFirst(2).prefix(2))
//  if Int(secondsString.prefix(1)) ?? 0 < 6{
//      maxData = minuteString + timeSeparator + secondsString
//  }
//  else{
//      secondsString = "0" + secondsString.suffix(1)
//      maxData = minuteString + timeSeparator + secondsString
//  }
//} else {
//    maxData = cleanString
//}
//}
//
