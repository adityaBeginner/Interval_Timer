//
//  ComHeaderView.swift
//  TIMER
//
//  Created by Aditya Maroo on 14/08/24.
//

import SwiftUI

struct ComHeaderView: View {
   
    @Binding var titleHeader: String
    var childHeader: String = "888/888"
    var audioSettingData: Settings?
    
    //MARK: -
    //MARK: STATE PROPERTIES
    @State var isSettingButtonTouch: Bool = false
    @State var isAudioSettingButtonTouch: Bool = false
    
    //MARK: -
    //MARK: PROPERTIES
    var isBackBtnHidden: Bool = true
    var isLabelHidden: Bool = true
    var isPopScreen: Bool = false
    var isSettingBtnHidden: Bool = false
    var settingScreen: SettingScreen = .AppSetting
    var shouldDismissOnBackButton:Bool = true
    ///
    ///ON CLICK BACK BUTTON
    ///
    var callback:(() -> Void)?
    
    //MARK: -
    //MARK: PROPERTIES
    @Environment(\.dismiss) private var dismiss
   
    
    
    var body: some View{
        ZStack{
            VStack(spacing: 24){
                HStack(spacing: 0) {
                    if !isBackBtnHidden{
                        Button(action: {
                            ///
                            /// IF NO VALIDATION ERRORS ARE REQUIRED
                            /// DISMISS/POP CURRENT VIEW
                            ///
                            if shouldDismissOnBackButton{
                                callback?()
                                dismiss()
                            }else{
                                callback?()
                            }
                            
                        }){  Image(.navigationbackBtn)
                                .renderingMode(/*@START_MENU_TOKEN@*/.template/*@END_MENU_TOKEN@*/)
                                .foregroundStyle(.headerTitleColerSet)
                        }
                        .padding(.trailing, 24)
                      
                    }
                    TextLabelMeduimFont(stringData: titleHeader, fontSize: AppComman.shared.handlingDeviceSizeFont())
                        .minimumScaleFactor(0.8)
                        .lineLimit(1)
//                        .minimumScaleFactor(0.6)
                        
//                    TextView(fontName: .TMEDIUM, fontsSize: .TSIZE_40, fontColor: .headerTitleColerSet, frameHeight: 48, textTitle: titleHeader)
                    if !isLabelHidden{
                        TextLabelRegularFont(stringData: childHeader)
                            .padding(.top, 15)
                            .padding(.leading, 10)
                    }
                    Spacer()
                    if !isSettingBtnHidden{
                        Button(action: {
                            if settingScreen == .AppSetting{
                                isSettingButtonTouch = true
                            }
                            else if settingScreen == .AudioSetting{
                                isAudioSettingButtonTouch = true
                            }
                        }, label: {
                            
                            Image("SettingIcon")
                                .resizable()
                                .renderingMode(.template)
                                .foregroundStyle(.headerTitleColerSet)
                                .scaledToFit()
                                .frame(width: 16, height: 17.75)
                        })
                    }
                }
                HStack{
                    Color(uiColor: .footerBackgroundColor)
                }
                .frame(height: 1)
                
            }
            
//            .background(.green)
            NavigationLink(isActive: $isSettingButtonTouch) {
                AppSettingView()
            } label: {
               EmptyView()
            }
            .hidden()
            NavigationLink(isActive: $isAudioSettingButtonTouch) {
                if isAudioSettingButtonTouch{
                    TimerSettingView(audioSetting: audioSettingData)
                }
            } label: {
                EmptyView()
            }
            .hidden()
        }
//         .frame(height: 75)
    }
}

#Preview {
    ComHeaderView(titleHeader: .constant("Header File"))
}
