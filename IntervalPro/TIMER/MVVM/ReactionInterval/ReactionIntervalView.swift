//
//  ReactionIntervalView.swift
//  TIMER
//
//  Created by Aditya Maroo on 21/08/24.
//

import SwiftUI

struct ReactionIntervalView: View {
     //MARK: - View Model object
    @StateObject var viewModel = ReactionIntervalVM()
    //MARK: - local properties
    var intervalItemData: IntervalItem?
    var isEditedState: Bool = false
    var totalInterval: Int?
    
    @Environment(\.presentationMode) var isPresented
    var scrollBackCallBack: (()-> Void)?
     //MARK: - Main Content view
    var body: some View {
        ZStack{
            Color.background
                .ignoresSafeArea()
            settingUp()
                .onTapGesture {
                    dismissKeyboard()
                }
                .onChange(of: viewModel.colorNavigate, perform: {newValue in
                    if newValue{
                        viewModel.addOrUpdateIntervalItem()
                    }
                    viewModel.colorNavigate = false
                })
                .navigationBarHidden(true)
                .onAppear{
                    /// Showing the data of intervalItem on appear
                    viewModel.intervalItem = intervalItemData
                    if isEditedState{
                        guard let intervalItemData else{return}
                        viewModel.intervalName = intervalItemData.intervalName ?? ""
                        viewModel.maximumNumberOfCall = intervalItemData.intervalCall?.maxNumber ?? 0
                        viewModel.random = intervalItemData.intervalCall?.random ?? false
                        viewModel.colorHex = viewModel.intervalItem?.colorObject?.colorHexCode ?? "000000"
                        viewModel.colourOpacity = viewModel.intervalItem?.colorObject?.alphaValue ?? 1
                    }else{
                        viewModel.addOrUpdateColorObject()
                    }
                }
            //        if viewModel.shouldShowAlert{
            //            AlertTextPopScreen(alertHeader: viewModel.alertHeader, alertDescription: viewModel.alertMessage, alertCancelText: "Cancel" ,alertOkText: "Okay", okayCallBack: {
            //                viewModel.shouldShowAlert = false
            //                viewModel.deleteInterval()
            //                isPresented.wrappedValue.dismiss()
            //            },cancelCallBack: {
            //                viewModel.shouldShowAlert = false
            //            })
            //        }
        }
    }
}

#Preview {
    ReactionIntervalView()
}
 //MARK: - Extenion for child and sub view
extension ReactionIntervalView{
    //All sub views are combined
    @ViewBuilder
    func settingUp()-> some View{
        VStack(spacing: 0){
            ComHeaderView(titleHeader: .constant("Interval"), childHeader: "\((intervalItemData?.indexValue ?? 887) + 1)/\(totalInterval ?? 888)", isBackBtnHidden: false, isLabelHidden: false, isSettingBtnHidden: true, shouldDismissOnBackButton: false){
                    if viewModel.validateInputs(){
                        viewModel.addOrUpdateIntervalItem()
                        isPresented.wrappedValue.dismiss()
                    }else{
                        viewModel.deleteInterval()
                        isPresented.wrappedValue.dismiss()
                    }
               scrollBackCallBack?()
            }
            .padding(.horizontal, 16)
            
            middleContent()
            footerContent()
        }
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarBackButtonHidden()
    }
    //Name and other field componets
    @ViewBuilder
    func middleContent()-> some View{
        ScrollView{
            VStack(spacing: 24){
                VStack(spacing: 34){
                    TextFieldView(txtPlaceHolder: "Name", stringData: $viewModel.intervalName)
                        .textInputAutocapitalization(.words)
                    
                    MaxNumberOfCalls(firstSettingLblName: "Max Number of Calls",minData: $viewModel.maximumNumberOfCall , isSwitchOn: $viewModel.random)
                }
                ThickBorderGradient()
                SettingColorLabel(colorObject: viewModel.intervalItem?.colorObject, settingName: "Colour", colorOpacity: $viewModel.colourOpacity, colorHex: $viewModel.colorHex){
                    viewModel.colorNavigate = true
                }
                ThickBorderGradient()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 32)
        }
    }
    // Footer Content view
    @ViewBuilder
    func footerContent()-> some View{
        let height = NotchHandling.shared.adjustFooterHeight()
        HStack{
            Color(uiColor: .footerBackgroundColor)
        }
        .frame(height: height)
        
    }
}
