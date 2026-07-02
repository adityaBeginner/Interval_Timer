//
//  AppSettingView.swift
//  TIMER
//
//  Created by Aditya Maroo on 23/08/24.
//

import SwiftUI
import UIKit
struct AppSettingView: View {
    
    // Inject ViewModel using @StateObject to observe changes
    @StateObject private var viewModel = AppSettingViewModel()
    @EnvironmentObject var darkMode: AppEnvironment
    var body: some View {
        ZStack{
            Color.background
                .ignoresSafeArea()
            settingUp()
//                .onAppear{
//                    let outputVolume = AVAudioSession.sharedInstance().outputVolume
//                    viewModel.volumeNumber = outputVolume
//                }
                .navigationBarBackButtonHidden()
            
            NavigationLink(isActive: $viewModel.isHelpNavigation) {
                if viewModel.isHelpNavigation{
                    HelpWebViewController()
                }
            } label: {
                EmptyView()
            }
            .hidden()
            NavigationLink(isActive: $viewModel.isNaviagteSubscription) {
                if viewModel.isNaviagteSubscription{
                    PurchaseView()
                }
            } label: {
                EmptyView()
            }
            .hidden()

        }
    }
}

#Preview {
    AppSettingView()
}

// MARK: - Extension for View Builder

extension AppSettingView {
    
    @ViewBuilder
    func settingUp() -> some View {
        VStack(spacing: 32) {
            ComHeaderView(titleHeader: .constant("Settings"), isBackBtnHidden: false, isSettingBtnHidden: true)
                .padding(.horizontal, 16)
            bodyContent()
            footerContent()
        }
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarHidden(true)
    }
    
    @ViewBuilder
    func bodyContent() -> some View {
        ScrollView {
            VStack(spacing: 24) {
                volumeContent()
                ThickBorderGradient()
                timerContent()
                ThickBorderGradient()
                LabelSettingSwitch(settingName: "Dark Mode", isSwitchOn: $darkMode.isDarkMode, isDarkBtnSwitch: true)
                    .onChange(of: darkMode.isDarkMode, perform: {newValue in
                        viewModel.darkModeSetting(newValue: newValue)
                    })
                ThickBorderGradient()
                accountContent()
            }
            .padding(.horizontal, 16)
        }
    }
    
    @ViewBuilder
    func volumeContent() -> some View {
        VStack(alignment: .leading, spacing: 17) {
            TextLabelLightFont(stringData: "Audio")
            
            VStack(alignment: .leading, spacing: 5) {
                TextLabelMeduimFont(stringData: "Volume")
                    .font(.custom(TFonts.TSEMIBOLD.rawValue, size: TSize.TSIZE_16.rawValue))
                    .foregroundStyle(.timerSettingHeader)
                    VolumeView()
                    .frame(height: 2)
                    CustomVolumeSlider(volumeLevel: $viewModel.volumeNumber)
                        .onChange(of: viewModel.volumeNumber, perform: { value in
                            viewModel.setVolume(Float(viewModel.volumeNumber))
                        })
                
                
//                Slider(value: $viewModel.volumeNumber, in: 0...100)
//                    .tint(.volume)
//                    .accentColor(.blue)
            }
        }
    }
    
    @ViewBuilder
    func timerContent() -> some View {
        VStack(alignment: .leading, spacing: 14) {
            TextLabelLightFont(stringData: "Timer")
            
            VStack(spacing: 42) {
                VStack(alignment: .leading, spacing: 3) {
                    LabelSettingSwitch(settingName: "Disable Vibrations", isSwitchOn: $viewModel.disableVibration, disableEnableCallback: {
                        viewModel.disableVibrationControll()
                    })
                    TextLabelLightFont(stringData: "Disable vibrations on all timers")
                       
                        .multilineTextAlignment(.leading)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    LabelSettingSwitch(settingName: "Disable Auto Screen-Off", isSwitchOn: $viewModel.screenOff, disableEnableCallback: {
                        viewModel.disableAutoScreenOff()
                    })
//                    .onChange(of: viewModel.screenOff, perform: {value in
//                            if value{
//                                UIApplication.shared.isIdleTimerDisabled = value
//                            }
//                            else{
//                                UIApplication.shared.isIdleTimerDisabled = value
//                            }
//                        
//                    })
                    TextLabelLightFont(stringData: "Prevent phone’s screen turning off\nwhen timer is running")
                        .multilineTextAlignment(.leading)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    LabelSettingSwitch(settingName: "Enable Screen-Lock", isSwitchOn: $viewModel.screenLock,
                        disableEnableCallback: {
                        viewModel.enableScreenLockSetting()
                    }
                    )
                    TextLabelLightFont(stringData: "Disable on screen controls\nwhen timer is running")
                        .multilineTextAlignment(.leading)
                }
                
                VStack(alignment: .leading, spacing: 3){
                    LabelSettingSwitch(settingName: "Enable Hundredths", isSwitchOn: $viewModel.hundredthsMilliSeconds,
                        disableEnableCallback: {
                        if AppDefaults.shared.isUserSubscribed{
                            //                        viewModel.enableScreenLockSetting()
                            viewModel.enableDisableHundredthMilliSeconds()
                        }
                        else{
                            viewModel.hundredthsMilliSeconds = false
                            viewModel.isNaviagteSubscription = true
                        }
                    }
                    )
                    TextLabelLightFont(stringData: "Enable hundredth of a second input\nand display")
                        .multilineTextAlignment(.leading)
                }
            }
        }
    }
    
    @ViewBuilder
    func accountContent() -> some View {
        VStack(alignment: .leading, spacing: 17) {
            TextLabelLightFont(stringData: "Account")
                
            
            VStack(spacing: 25) {
         
                    NavigationLink {
                        PurchaseView()
                    } label: {
                        HStack {
                            TextLabelMeduimFont(stringData: "Manage Purchase")
                            Spacer()
                            Image("ShareSettingButton")
                                .padding(.trailing, 12)
                        }
                    }
            }
            
            VStack(spacing: 25) {
                HStack {
                    TextLabelMeduimFont(stringData: "Help")
                    Spacer()
                    Image("ShareSettingButton")
                        .padding(.trailing, 12)
                }
                .contentShape(.rect)
                .onTapGesture {
                    viewModel.isHelpNavigation.toggle()
                }
            }
        }
    }
    
    @ViewBuilder
    func footerContent() -> some View {
        HStack {
            Color(.footerBackgroundColor)
        }
        .frame(height: 8)
    }
}

import Foundation
import MediaPlayer

struct VolumeView: UIViewRepresentable{
    
    func makeUIView(context: Context) -> MPVolumeView {
    
       let volumeView = MPVolumeView(frame: CGRect.zero)
       volumeView.alpha = 0.001

       return volumeView
    }

    func updateUIView(_ uiView: MPVolumeView, context: Context) {
    
    }

}
