//
//  TimerInputPopAlert.swift
//  TIMER
//
//  Created by Aditya Maroo on 26/09/24.
//

import SwiftUI
enum TextFieldShift: Hashable{
    case HourTextField
    case MinuteTextField
    case SecondsTextField
}

struct TimerInputPopAlert: View {
    @State var hoursText: String = ""
    @State var minText: String = ""
    @State var secondsText: String = ""
    @State var alertMissingField: Bool = false
    @State var timeData: String = ""
    @FocusState var focusField: TextFieldShift?
    var dataCallbackString: ((String)-> Void)?
    var dataGoback: (()-> Void)?
    var body: some View {
        ZStack{
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            setup()
                .frame(width: UIScreen.main.bounds.size.width * 0.80)
                .padding(.all, 24)
                .background{
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.white)
                }
        }
    }
}
 //MARK: - Extension for sub componenets View

extension TimerInputPopAlert{
    ///
    ///contains all sub Views and  components
    ///
    @ViewBuilder
    func setup()-> some View{
        VStack(spacing: 32){
            topHeadingContent()
            if alertMissingField{
                alertContent()
            }
            middleTextFieldContent()
            buttonComponents()
        }
    }
    ///
    ///Header  View component
    ///
    @ViewBuilder
    func topHeadingContent()-> some View{
        HStack{
            TextLabelBoldFont(stringData: "Set Time", fontColor: Color(uiColor: .timerWorkoutColor), fontSize: .TSIZE_20)
            Spacer()
        }
    }
    ///
    ///Alert placeHolder view
    ///
    @ViewBuilder
    func alertContent()-> some View{
        HStack{
            TextLabelRegularFont(stringData: "You cannot save time without value", fontColor: .wrongTextFieldAlert, fontSize: .TSIZE_14)
            Spacer()
            Image(.popAlertIcon)
        }
    }
    ///
    ///Hour,min,ss text field components
    ///
    @ViewBuilder
    func middleTextFieldContent()-> some View{
        HStack(spacing: 0){
            
            childMiddleContent(placeHolder: "HH", textData: $hoursText, label: "Hrs", focuseState: .HourTextField, nextState: .MinuteTextField)
                .onChange(of: hoursText, perform: validationHours)
            Spacer()
            childMiddleContent(placeHolder: "MM", textData: $minText, label: "Min", focuseState: .MinuteTextField, nextState: .SecondsTextField)
                .onChange(of: minText, perform: validationMinutes)
            Spacer()
            childMiddleContent(placeHolder: "SS", textData: $secondsText, label: "Sec", focuseState: .SecondsTextField, nextState: nil)
                .onChange(of: secondsText, perform: validationSeconds)
        }
    }
    
    ///
    ///Middle Sub Conrtent
    ///
    @ViewBuilder
    func childMiddleContent(placeHolder: String, textData: Binding<String>, label: String, focuseState: TextFieldShift, nextState: TextFieldShift?)->some View{
        HStack(spacing: 0){
            VStack(spacing: 0){
                TextField(placeHolder, text: textData)
                    .font(.custom(TFonts.TREGULAR.rawValue, size: TSize.TSIZE_16.rawValue))
                    .multilineTextAlignment(.center)
                    .keyboardType(.numberPad)
                    .focused($focusField, equals: focuseState)
                    .onSubmit {
                        focusField = nextState
                    }
                    .frame(maxWidth: .infinity)
                Color(.footerBackgroundColor)
                    .frame(height: 1)
                  
                    
            }
            TextLabelMeduimFont(stringData: label, fontColor: .headerTitleColerSet, fontSize: .TSIZE_16)
        }
    }
    ///
    ///Button Componets
    ///
      @ViewBuilder
    func buttonComponents()-> some View{
        HStack{
            Button(action: {
                dataGoback?()
            })
            {
                TextLabelBoldFont(stringData: "Go Back", fontColor: Color(uiColor: .cancelSkipBtnColor), fontSize: .TSIZE_20)
            }
            Spacer()
            Button(action: {
                if overalTimerValidation()
                {
                    dataCallbackString?(hoursText + ":" + minText + ":" + secondsText)
                }
                else{
                    alertMissingField = true
                }

            })
            {
                TextLabelBoldFont(stringData: "Ok", fontColor: Color(uiColor: .footerBackgroundColor), fontSize: .TSIZE_20)
            }
        }
    }
}
 //MARK: - Validation for hh,mm,ss
extension TimerInputPopAlert{
    public func validationHours(_ value: String){
        let hour = value.prefix(2)
        hoursText = String(hour)
        alertMissingField = false
        if value.count == 2{
            focusField = .MinuteTextField
        }
    }
    public func validationMinutes(_ value: String){
        if hoursText.count == 1 {
            hoursText = "0" + hoursText
        }
            let minute = value.prefix(1)
        let secondDigitMinute = value.prefix(2)
            if Int(minute) ?? 0 < 6{
                    minText = String(secondDigitMinute)
            }
            else{
                minText = String("0" + minute)
            }
        alertMissingField = false
        if value.count == 2{
            focusField = .SecondsTextField
        }
        if value.count == 0{
            focusField = .HourTextField
        }
     
    }
    public func validationSeconds(_ value: String){
        if minText.count == 1{
            minText = String("0" + minText)
        }
        let second = value.prefix(1)
       let secondDigitSecond = value.prefix(2)
        if Int(second) ?? 0 < 6{
            secondsText = String(secondDigitSecond)
        }
        else{
            secondsText = String("0" + second)
        }
        if value.count == 0{
            focusField = .MinuteTextField
        }
        alertMissingField = false
    }
    func overalTimerValidation()-> Bool{
        changeTextTime()
        guard (hoursText.trimmingCharacters(in: .whitespaces) != "" && hoursText != "00") || (minText.trimmingCharacters(in: .whitespaces) != "" && minText != "00") || (secondsText.trimmingCharacters(in: .whitespaces) != "" && secondsText != "00")else{
            return false
        }
        guard stringDataCheck() else{
            return false
        }
     
        return true
    }
    func changeTextTime(){
        if secondsText.count == 1{
            secondsText = String("0" + secondsText)
        }
         if hoursText.count == 1{
            hoursText = "0" + hoursText
        }
         if minText.count == 1{
            minText = "0" + minText
        }
         if hoursText.count == 0{
            hoursText = "00"
        }
         if minText.count == 0{
            minText = "00"
        }
        if secondsText.count == 0{
            secondsText = "00"
        }
    }
    ///
    ///Checking or validating Data should be well formated in int structure
    ///
    func stringDataCheck()-> Bool{
        guard (Int(hoursText) != nil) else{
            return false
        }
        guard (Int(minText) != nil) else{
            return false
        }
        guard (Int(secondsText) != nil) else{
            return false
        }
       return true
    }
}

#Preview {
    TimerInputPopAlert()
}
