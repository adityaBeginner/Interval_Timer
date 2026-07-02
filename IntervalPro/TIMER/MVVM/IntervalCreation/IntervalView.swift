//
//  IntervalView.swift
//  TIMER
//
//  Created by Aditya Maroo on 20/08/24.
//

import SwiftUI

struct IntervalView: View {
    //MARK: - View Model Object
    @StateObject var viewModel = IntervalCreationVM()
   //MARK: - State Variable properties
    @State var isMessageClick: Bool = false

    ///handling navigation stick to previous screen
    var isEdited: Bool = false
    var intervalItem: IntervalItem?
    var totalInterval: Int?
    var indexNumber: Int = 0
    
    //Call Back
    var scrollBackCallBack: (()-> Void)?
    
    @Environment(\.presentationMode) var isPresented
    
    var body: some View {
        ZStack{
            Color.background
                .ignoresSafeArea()
            VStack(spacing: 0){
                
                headerContent()
                    .padding(.horizontal, 16)
                ScrollViewReader{scrollViewProxy in
                    List{
                        Section{
                            VStack(spacing: 0){
                                TextFieldView(txtPlaceHolder: "Name", textFieldPlaceHolder: "Name" , stringData: $viewModel.intervalName)
                                    .textInputAutocapitalization(.words)
                                    .padding(.top, 32)
                                
                                MinMaxTxtField(minData: $viewModel.intervalDurationMinTime, maxData: $viewModel.intervalDurationMaxTime, firstSettingLblName: "Interval Duration", secondSettingLblName: "Random",textFieldType: .IntervalDuration, isSwitchOn: $viewModel.intervalDurationRandom)
                                    .padding(.top, 34)
                                
                                ThickBorderGradient()
                                    .padding(.top, 34)
                                
                                SettingColorLabel(colorObject: viewModel.intervalItem?.colorObject, settingName: "Colour", colorOpacity: $viewModel.coloropacity, colorHex: $viewModel.intervalColour){
                                    viewModel.colorNavigate = true
                                }
                                .padding(.top, 24)
                                
                                ThickBorderGradient()
                                    .padding(.top, 24)
                                
                                LabelSettingSwitch(settingName: "Halfway Alert", isSwitchOn: $viewModel.intervalHalfWayAlert)
                                    .padding(.top, 24)
                                
                                ThickBorderGradient()
                                    .padding(.top, 24)
                                HStack{
                                    Text("Messages")
                                        .font(.custom(TFonts.TREGULAR.rawValue, size: TSize.TSIZE_16.rawValue))
                                    Spacer()
                                }
                                //                    .padding(.horizontal, 16)
                                .padding(.top, 24)
                                
                                
                                if $viewModel.intervalMessage.count > 0{
                                    Line()
                                        .stroke(style: .init(dash: [3]))
                                    //                        .accentColor(Color(uiColor: .lineDottedColor))
                                        .foregroundColor(Color(uiColor: .lineDottedColor))
                                        .frame(height: 1)
                                        .padding(.top, 24)
                                        .padding(.bottom, 0)
                                }
                            }
                        }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .listRowInsets(.init(top: 0, leading: 16, bottom: 0, trailing: 16))
                        .id("Section1")
                        //                            .padding(.horizontal, 16)
                        .onTapGesture {
                                    dismissKeyboard()
                                    viewModel.changingValueBreakField(textFieldType: .IntervalDuration)
                                }

                        Section{
                            ForEach(viewModel.intervalMessage){intervalMessage in
                                MessageCartCell(messageItem: intervalMessage, callBackAddMessage: {messageItem in
                                    viewModel.isFooterEdit = true
                                    viewModel.selectedMessages.append(messageItem)
                                },
                                                callBackRemoveMessage: { messageItem in
                                    viewModel.removeSelectedItem(messageItem: messageItem)
                                    if viewModel.selectedMessages.isEmpty{
                                        viewModel.isFooterEdit = false
                                    }
                                }
                                )
                                .offset(x: viewModel.slideListAnimation ? intervalMessage.isSelected ? -400 : 0 : 0 )
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    viewModel.isMessageEdit = true
                                    viewModel.messageData = intervalMessage
                                    isMessageClick = true
                                }.listRowSeparator(.hidden)
                                    .listRowInsets(.init(top: 24, leading: 16, bottom: 0, trailing: 16))
                                    .listRowBackground(Color.clear)
                                    .id(intervalMessage.id)
                            }
                            .onMove { indices, newOffset in
                                viewModel.indexUpdate(indices: indices, newOffset: newOffset, items: intervalItem ?? IntervalItem())
                            }
                            .onDelete(perform: {indexSet in
                                viewModel.deleteSingleMessage(indexSet: indexSet)
                            })
                           
                            VStack(spacing: 0){
                                addMessageBtn()
                                    .padding(.top, 24)
                                Color.clear.frame(height: 1)
                                    .padding(.bottom, 24)
                            }
                            .id("AddMessageButtonId")
                            .onTapGesture {
                                        dismissKeyboard()
                                        viewModel.changingValueBreakField(textFieldType: .IntervalDuration)
                                    }

                        }
                        .onChange(of: viewModel.isScrollDown, perform: {newValue in
                            if newValue{
                                // Scroll to the last item's ID
                                
                                withAnimation(.smooth){
                                    scrollViewProxy.scrollTo("AddMessageButtonId", anchor: .bottom)
                                }
                            }
                            viewModel.isScrollDown = false
                            
                        })
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .listRowInsets(.init(top: 0, leading: 16, bottom: 0, trailing: 16))
                        .id("Section2")
                    }
                    .listStyle(.plain)
                    .buttonStyle(PlainButtonStyle())
                    .listRowSpacing(0)
                }
                
                
            
            EditFooterView(isCheckBoxChecked: viewModel.isFooterEdit, callBackDeleteData: {
                if !viewModel.selectedMessages.isEmpty{
                    viewModel.alertHeader = "DELETE THIS SELECTION"
                    viewModel.validationMessage = "Are you sure you want to permanently\ndelete the selected item(s)?"
                    viewModel.isDeletePop = true
                    viewModel.blurEffectPresent = true
                }
                /// Delete functionality and animation Handling
                
                
            }, callBackCopyData: {
                /// Copy Data Handling footer call back
                //                    if !viewModel.selectedMessages.isEmpty{
                EditOperations.copyEntity(selectedItems: viewModel.selectedMessages, entityType: .timerMessage)
//                viewModel.selectedMessages.removeAll()
//                viewModel.changeValueSelected()
//                viewModel.stateChange = .Normal
                //                    }
                
            }, callBackPasteData: {
                if EditOperations.editEntityType == .timerMessage{
                    debugPrint("View Model interval message count",viewModel.intervalItem?.messageItems?.count)
                    EditOperations.pasteMessageInTimerInterval(inObject: viewModel.intervalItem)
                    runWithDelay(delay: 0.5) {
                        viewModel.intervalMessage = viewModel.intervalItem?.messageItems?.allObjects as? [MessageItems] ?? []
                        viewModel.intervalMessage.sort{$0.indexValue < $1.indexValue}
                        viewModel.isFooterEdit = false
                        viewModel.isScrollDown = true
                        viewModel.selectedMessages.removeAll()
                        viewModel.changeValueSelected()
//                        viewModel.stateChange = .Normal
                    }
                    
                }
            }, callBackCutData: {
                /// Cut Call Back Functionality
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100), execute: {
                    withAnimation(.smooth){
                        viewModel.slideListAnimation = true
                    }
                })
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000)){
                    withAnimation{
                        EditOperations.cutEntity(selectedItems: viewModel.selectedMessages, entityType: .timerMessage)
                        viewModel.intervalMessage = cutChangeMessageIndex(selectedMessage: viewModel.selectedMessages, totalMessage: viewModel.intervalMessage)
                        viewModel.selectedMessages.removeAll()
                        viewModel.slideListAnimation = false
                        viewModel.changeValueSelected()
                    }
                }
            })
        }
        .blur(radius: viewModel.blurEffectPresent ? 12 : 0)
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarHidden(true)
        .onAppear{
            if EditOperations.editEntityType == .timerMessage{
                viewModel.isFooterEdit = true
            }
            viewModel.intervalItem = viewModel.intervalItem == nil ? intervalItem : viewModel.intervalItem
            debugPrint("View Model Message Count",viewModel.intervalItem?.messageItems?.count)
            viewModel.intervalMessage = (viewModel.intervalItem?.messageItems?.allObjects as? [MessageItems]) ?? []
            viewModel.delayFilter()
//            viewModel.intervalMessage.sort{ $0.indexValue < $1.indexValue}
            if isEdited{
                guard let intervalItem = intervalItem else {debugPrint("intervalItem is nil while setting data on Edit"); return}
                viewModel.intervalName = viewModel.intervalName != "" ? viewModel.intervalName : intervalItem.intervalName ?? ""
                viewModel.intervalDurationRandom = viewModel.intervalDurationRandom != (intervalItem.intervalDuration?.random ?? false) ? viewModel.intervalDurationRandom : (intervalItem.intervalDuration?.random ?? false)
                viewModel.intervalDurationMaxTime = intervalItem.intervalDuration?.max ?? ""
                viewModel.intervalDurationMinTime = intervalItem.intervalDuration?.min ?? ""
                viewModel.intervalDurationRandom = intervalItem.intervalDuration?.random ?? false
                viewModel.intervalHalfWayAlert = intervalItem.halfWayAlert
                //                        viewModel.intervalMessage = (intervalItem.messageItems?.allObjects as? [MessageItems]) ?? []
                //                    viewModel.intervalMessage.sort{$0.indexValue < $1.indexValue}
                viewModel.intervalColour = intervalItem.colorObject?.colorHexCode ?? ""
                viewModel.coloropacity = intervalItem.colorObject?.alphaValue ?? 1
                
            }else{
                if viewModel.colorObject == nil{
                    viewModel.createColorObject()
                }
            }
        }
        
        NavigationLink(isActive: $isMessageClick) {
            if isMessageClick{
                if viewModel.isMessageEdit{
                    ///for updating data in color and navigation
                    MessageView(isEdited: true, messageData: viewModel.messageData)
                }else{
                    
                    MessageView(messageData: viewModel.messageData,scrollToBottomCallBack: {
                        runWithDelay(delay: 0.5){
                            viewModel.isScrollDown = true
                        }
                    })
                }
            }
        } label: {
            EmptyView()
        }
        .hidden()
        
        ///
        /// SHOW VALIDATION ERROR POPUP IF ANY TEXT INPUT FIELD IS BLANK
        ///
        //            if viewModel.shouldShowValidationError{
        //                AlertTextPopScreen(alertHeader: viewModel.alertHeader, alertDescription: viewModel.validationMessage, alertCancelText: "CANCEL", alertOkText: "CHOOSE NEW FILE",textDescriptionDot: viewModel.textDescriptionBox
        //                                 ,okayCallBack: {
        //                    viewModel.shouldShowValidationError = false
        //                    viewModel.deleteIntervalItem(intervalItem: intervalItem)
        //                    isPresented.wrappedValue.dismiss()
        //
        //                }, cancelCallBack: {
        //                    viewModel.shouldShowValidationError = false
        //                } )
        //            }
        ///Alert delete pop
            if viewModel.isDeletePop{
                AlertTextPopScreen(alertHeader: viewModel.alertHeader, alertDescription: viewModel.validationMessage, alertCancelText: "NO, GO BACK", alertOkText: "YES, DELETE", okayCallBack: {
                    viewModel.isDeletePop = false
                    viewModel.blurEffectPresent = false
                    /// Delete functionality and animation Handling
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100), execute: {
                        withAnimation(.smooth){
                            viewModel.slideListAnimation = true
                        }
                    })
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000)){
                        withAnimation{
                            
                            viewModel.changeValueSelected()
                            viewModel.slideListAnimation = false
                            viewModel.deleteSelectedMessages()
                            viewModel.selectedMessages.removeAll()
                            viewModel.isFooterEdit = false
                        }
                    }
                    
                },
                                   cancelCallBack: {
                    viewModel.isDeletePop = false
                    viewModel.blurEffectPresent = false
                }
                )
                
                
                
                .onTapGesture {
                    dismissKeyboard()
                    viewModel.changingValueBreakField(textFieldType: .IntervalDuration)
                }
                .onChange(of: isMessageClick, perform: { newValue in
                    if newValue{
                        viewModel.addOrUpdateInterval()
                    }
                })
                .onChange(of: viewModel.colorNavigate, perform: {newValue in
                    if newValue{
                        viewModel.addOrUpdateInterval()
                    }
                    viewModel.colorNavigate = false
                })
            }
    }
    }
}

extension IntervalView{
    
    @ViewBuilder
    func headerContent()-> some View{
        ComHeaderView(titleHeader: .constant("Interval"), childHeader: "\((intervalItem?.indexValue ?? 887) + 1)/\(totalInterval ?? 888)",isBackBtnHidden: false, isLabelHidden: false, isSettingBtnHidden: true, shouldDismissOnBackButton: false){
            if viewModel.validateInputs(){
                viewModel.addOrUpdateInterval()
                isPresented.wrappedValue.dismiss()
            }
            else{
                viewModel.deleteIntervalItem(intervalItem: viewModel.intervalItem ?? IntervalItem())
                isPresented.wrappedValue.dismiss()
            }
            scrollBackCallBack?()
        }
    }
    
    @ViewBuilder
    func addMessageBtn()-> some View{
        HStack{
            Button(action: {
                viewModel.createMessageObject()
                isMessageClick = true
                viewModel.isMessageEdit = false
            }){
                HStack{
                    Image(.iconAddInterval)
                        .renderingMode(/*@START_MENU_TOKEN@*/.template/*@END_MENU_TOKEN@*/)
                        .foregroundStyle(.headerTitleColerSet)
                    TextLabelRegularFont(stringData: "Add Message")
                       
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    IntervalView()
}
