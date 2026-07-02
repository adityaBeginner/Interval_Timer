//
//  MessageView.swift
//  TIMER
//
//  Created by Aditya Maroo on 21/08/24.
//

import SwiftUI

struct MessageView: View {
    
    //MARK: -
    //MARK: STATE PROPERTIES
    @StateObject var viewModel = MessageViewVM()
    @Environment(\.presentationMode) var isPresented
    var isEdited: Bool = false
    var messageData: MessageItems?
    
    //CallBack
    var scrollToBottomCallBack: (()-> Void)?
  
        var body: some View {
            ZStack{
                Color.background
                    .ignoresSafeArea()
                settingUp()
                    .navigationBarHidden(true)
                    .onTapGesture {
                        dismissKeyboard()
                        viewModel.changeDelayValueOnDissmiss()
                    }
                    .onAppear{
                        viewModel.messageItem = messageData
                        if isEdited{
                            viewModel.messageName = messageData?.messageName ?? ""
                            viewModel.delay = messageData?.delay ?? ""
                            viewModel.delay = AppComman.shared.handlingMilliseconds(timeString: viewModel.delay)
                        }
                    }
            }
    }
}

#Preview {
    MessageView()
}
extension MessageView{
    
    @ViewBuilder
    func settingUp()-> some View{
        
        ZStack{
            VStack(spacing: 0){
                ComHeaderView(titleHeader: .constant("Message"), isBackBtnHidden: false, isSettingBtnHidden: true, shouldDismissOnBackButton: false){
                    if viewModel.validateMessageInput(){
                        viewModel.changeDelayValueOnDissmiss()
                        viewModel.updateMessage()
                        isPresented.wrappedValue.dismiss()
                        scrollToBottomCallBack?()
                    }
                    else{
                        viewModel.deleteMessage()
                        isPresented.wrappedValue.dismiss()
                    }
                }
                .padding(.horizontal, 16)
                middleContent()
                    .padding(.top, 32)
                
                endFooter()
                
            }
            .edgesIgnoringSafeArea(.bottom)
        
//            if viewModel.shouldShowValidationError{
//                AlertTextPopScreen(alertHeader: "Error: Missing Fields",alertDescription: viewModel.validationErrorMessage, alertCancelText: "Cancel", alertOkText: "Delete Message & Back", okayCallBack: {
//                    viewModel.shouldShowValidationError = false
//                }, cancelCallBack: {
//                    viewModel.deleteMessage()
//                    isPresented.wrappedValue.dismiss()
//                })
//            }
        }
    }
    
    @ViewBuilder
    func middleContent()-> some View{
        
        ScrollView{
            VStack(spacing: 24){
                TextFieldView(txtPlaceHolder: "Name",  textFieldPlaceHolder: "Name" ,stringData: $viewModel.messageName)
                    .textInputAutocapitalization(.sentences)
               
                delayTxtField()
                endMessageShowing()
                    .padding(.top, 8)
            }
            .padding(.horizontal, 16)
        }
    }
    @ViewBuilder
    func endMessageShowing()-> some View{
        
        TextLabelLightFont(stringData: "Messages will show on screen for a maximum of 10 seconds. They can be used to give motivation and further instructions etc.\n\nThe delay time is the amount of time into the ongoing call at which the message will appear. ")
        .multilineTextAlignment(.leading)
    }
    @ViewBuilder
    func endFooter()->some View{
        let height = NotchHandling.shared.adjustFooterHeight()
        HStack{
            Color(uiColor: .footerBackgroundColor)
        }
        .frame(height: height)
    }
    
    ///
    ///Messsage delay Text Fiedl
    ///
    @ViewBuilder
    func delayTxtField()-> some View{
        TextFieldView(txtPlaceHolder: "Delay", textFieldPlaceHolder: AppDefaults.shared.hundredthMilliSeconds ? "MM:SS:ms" : "MM:SS", isMessageDelay: true, stringData: $viewModel.delay)
            .keyboardType(.numberPad)
            .onChange(of: viewModel.delay, perform: AppDefaults.shared.hundredthMilliSeconds ? viewModel.reformatAsTimeMinForMilliseconds : viewModel.reformatAsTimeMin)
    }
        
}

