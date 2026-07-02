//
//  ComEditHeaderView.swift
//  TIMER
//
//  Created by Aditya Maroo on 14/08/24.
//

import SwiftUI

struct ComEditHeaderView: View {
    //MARK: -
    //MARK: PROPERTIES
    @Environment(\.dismiss) private var dismiss
    
    @Binding var viewState: WorkoutViewState
    @Binding var headerTitleTxt: String
    
    @State var isMoveable:Bool = false
    @State var isSettingButtonTouch: Bool = false
    @State var showHideDeleteSettingBtn: Bool = false
    @State var hideUnhide: Bool = false
    
    var selectedItem: [Item] = []
    var settingScreen: SettingScreen = .AppSetting
    var isBackBtnHidden: Bool = true
    
    ///CALLBACK
    var callBackDeleteData: (()-> Void)?
    var callBackCopyData: (()-> Void)?
    var callBackPasteData: (()-> Void)?
    var callBackCutData: (()-> Void)?
    var callBackShareData: (()-> Void)?

    
    var body: some View {
        ZStack{
            VStack(spacing: 0){
                HStack {
                    if !isBackBtnHidden{
                        Button(action: {
                            dismiss()
                            
                        }){  Image(.navigationbackBtn)
                                .renderingMode(/*@START_MENU_TOKEN@*/.template/*@END_MENU_TOKEN@*/)
                                .foregroundStyle(.headerTitleColerSet)
                        }
                        .padding(.trailing, 24)
                        
                    }
                    TextLabelMeduimFont(stringData: headerTitleTxt, fontSize: AppComman.shared.handlingDeviceSizeFont())
                        .lineLimit(1)
                    Spacer()
                    HStack(spacing: viewState == .Edit ? 40 : 0){
                            if hideUnhide{
                                HStack(spacing: viewState == .Edit ? isMoveable ? 40 : 20 : 0){
                                    Button(action: {
                                        if !selectedItem.isEmpty{
                                            hapticON()
                                            callBackCutData?()
                                        }
                                    }){
                                        Image("IconCut")
                                            .resizable()
                                            .renderingMode(.template)
                                            .foregroundStyle(.headerTitleColerSet)
                                            .scaledToFit()
                                            .frame(width: 16, height: 15.98)
                                    }
                                    
                                    Button(action: {
                                        //                            if !selectedItem.isEmpty{
                                        hapticON()
                                        callBackCopyData?()
                                        //                            }
                                    }){
                                        Image("IconCopy")
                                            .resizable()
                                            .renderingMode(.template)
                                            .foregroundStyle(.headerTitleColerSet)
                                            .scaledToFit()
                                            .frame(width: 16, height: 17.3)
                                    }
                                    Button(action: {
                                        //                            if !selectedItem.isEmpty{
                                        hapticON()
                                        callBackPasteData?()
                                        //                            }
                                    }){
                                        Image("IconPaste")
                                            .resizable()
                                            .renderingMode(.template)
                                            .foregroundStyle(.headerTitleColerSet)
                                            .scaledToFit()
                                            .frame(width: 16, height: 17.3)
                                    }
                                    
                                    Button(action: {
                                        if !selectedItem.isEmpty{
                                            hapticON()
                                            callBackShareData?()
                                        }
                                    }){
                                        Image("IconShare")
                                            .resizable()
                                            .renderingMode(.template)
                                            .foregroundStyle(.headerTitleColerSet)
                                            .scaledToFit()
                                            .frame(width: 16, height: 17.3)
                                    }
                                }
                                .offset(x: viewState == .Edit ? isMoveable ? 0 : 10 : 20)
                                
                                
                            }
                                Button(action: {
                                    if showHideDeleteSettingBtn{
                                        if !selectedItem.isEmpty{
                                            hapticON()
                                            callBackDeleteData?()
                                        }
                                    }
                                    else{
                                        if settingScreen == .AppSetting{
                                            isSettingButtonTouch = true
                                        }
                                    }
                                }){
                                    if showHideDeleteSettingBtn{
                                        Image("IconDelete")
                                            .resizable()
                                            .renderingMode(.template)
                                            .foregroundStyle(.headerTitleColerSet)
                                            .scaledToFit()
                                            .frame(width: 16, height: 17.3)
                                    }
                                    else{
                                        Image("SettingIcon")
                                            .resizable()
                                            .renderingMode(.template)
                                            .foregroundStyle(.headerTitleColerSet)
                                            .scaledToFit()
                                            .frame(width: 16, height: 17.75)
                                            .rotationEffect(Angle(degrees: viewState == .Edit ? -75 : 75))
                                    }
                                }
                            
                    }
                }
                .onChange(of: viewState, perform: { value in
                    if value == . Edit{
                        withAnimation(){
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                                hideUnhide = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15){
                                isMoveable = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.23){
                                showHideDeleteSettingBtn = true
                            }
                        }
                    }
                    else if value == .Normal{
                        withAnimation(){
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                                isMoveable = false
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                                hideUnhide = false
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25){
                                showHideDeleteSettingBtn = false
                            }
                        }
                    }
                })
                //            .frame(height: 48)
                .padding(.horizontal, 16)
                
                HStack{
                    Color(uiColor: .footerBackgroundColor)
                }
                .frame(height: 1)
                .padding(.top, 24)
                .padding(.horizontal, 16
                )
            }
            .onDisappear{
                DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                    withAnimation(.easeInOut){
                        self.isMoveable = false
                    }
                })
            }
            
            NavigationLink(isActive: $isSettingButtonTouch) {
                AppSettingView()
            } label: {
               EmptyView()
            }
            .hidden()
        }
            
    }
}

#Preview {
    ComEditHeaderView(viewState: .constant(.Edit), headerTitleTxt: .constant("Workout"))
}
