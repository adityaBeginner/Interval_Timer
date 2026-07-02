//
//  TimerSettingView.swift
//  TIMER
//
//  Created by Aditya Maroo on 23/08/24.
//

import SwiftUI

struct TimerSettingView: View {
    
    //MARK: PROPERTIES
    @StateObject var viewModel = TimerSettingViewModel()
    var audioSetting: Settings?
    
    //MARK: VIEWS
    var body: some View {
        ZStack{
            Color.background
                .ignoresSafeArea()
            settingUp()
                .navigationBarHidden(true)
            //MARK: ON APPEAR
            ///ON APPEAR
                .onAppear(perform: {
                    viewModel.audioSettingData = audioSetting
                    viewModel.showAudioSettingsData()
                })
            //MARK: ON DISAPPEAR
            ///ON DISAPPEAR
                .onDisappear(perform: {
                    viewModel.stopAudio()
                })
        }
    }
}

#Preview {
    TimerSettingView()
}


//MARK: - Extension of ViewBuilder Function

extension TimerSettingView{
    
    @ViewBuilder
    func settingUp()-> some View{
        VStack(spacing: 32){
            ComHeaderView(titleHeader: .constant("Timer Settings"), isBackBtnHidden: false, isSettingBtnHidden: true, callback: {
                viewModel.saveAudioSettingData()
            })
                .padding(.horizontal, 16)
            bodyContent()
        }
        .edgesIgnoringSafeArea(.bottom)
    }
    
    @ViewBuilder
    func bodyContent()-> some View{
         
        ScrollView{
            VStack(spacing: 24){
                muteContent()
                    .padding(.horizontal, 16)
                
                ThickBorderGradient()
                    
                if viewModel.isNoAudio{EmptyView()}else{
                    audioContent()
                        .padding(.horizontal, 16)
                    textToSpeechContent()
                        .padding(.horizontal, 16)
                    ThickBorderGradient()
                }
                vibrateContent()
                    .padding(.horizontal, 16)
            }
        }
        footerContent()
    }

    @ViewBuilder
    func audioContent()->some View{
       
        VStack(alignment: .leading, spacing: 14){
            TextLabelLightFont(stringData: "Audio")
            VStack(spacing: 24){
                ForEach($viewModel.audioData){audio in
                    CircularSettingToggleBtn( isTextToSpeech: viewModel.isTextToSpeech, settingName: audio.name.wrappedValue, isBtnStateChange: audio.isSelected)
                        .onTapGesture {
                                viewModel.isTextToSpeech = false
                            debugPrint(audio)
                                viewModel.selectAudio(audio.wrappedValue)
                            
                        }
                }
            }
//            .disabled(viewModel.isNoAudio)
            
        }
   
    }
    
    @ViewBuilder
    func textToSpeechContent()->some View{
        LabelSettingSwitch(settingName: "Text-to-speech", isSwitchOn: $viewModel.isTextToSpeech)
            .onChange(of: viewModel.isTextToSpeech, perform: { value in
                ///
                ///WHENEVER USER UPDATES
                ///``text-To-Speech`` ON OR OFF
                ///STOP AUDIO
                viewModel.stopAudio()
                //Saving Data to coreData
                viewModel.saveAudioSettingData()
            })
            .onChange(of: viewModel.isNoAudio, perform: { value in
                //Saving Data to coreData
                viewModel.saveAudioSettingData()
            })
            .padding(.bottom, 3)
//        if viewModel.isTextToSpeech{
            VStack(spacing: 24){
                ForEach($viewModel.textSpeechData){speech in
                    
                    CircularSettingToggleBtn(isTextToSpeech: !viewModel.isTextToSpeech, settingName: speech.name.wrappedValue, isBtnStateChange: speech.isSelected)
                        .onTapGesture {
                            if viewModel.isTextToSpeech{
                                viewModel.selectSpeech(speech.wrappedValue)
                            }
                        }
                }
                .padding(.leading, 32)
            }
//        }else{
//            EmptyView()
//                .padding(.leading, 32)
//        }
        
    }
    @ViewBuilder
    func vibrateContent()->some View{
        VStack(alignment: .leading, spacing: 14){
//            Text("Vibrate only")
//                .customTimerSettingHeader()
            TextLabelLightFont(stringData: "Vibrate only")
//            if viewModel.isVibration{
                VStack(spacing: 24){
                    ForEach($viewModel.textVibrationData){vibration in
                        
                        CircularSettingToggleBtn(settingName: vibration.name.wrappedValue, isBtnStateChange: vibration.isSelected)
                            .onTapGesture {
                                viewModel.selectVibration(vibration.wrappedValue)
                            }
                    }
//                    .padding(.leading, 16)
                    
                }
//            }else{ EmptyView() }
        }
       
    }
    
    @ViewBuilder
    func muteContent()->some View{
        VStack(alignment: .leading , spacing: 14 ){
            TextLabelLightFont(stringData: "Mute")
            LabelSettingSwitch(settingName: "No Audio", isSwitchOn: $viewModel.isNoAudio.animation()).onChange(of: viewModel.isNoAudio, perform: { value in
                ///
                ///WHENEVER USER UPDATES
                ///``NO AUDIO`` ON OR OFF
                ///STOP AUDIO
                viewModel.stopAudio()
            })
        }
    }
    
    @ViewBuilder
    func footerContent()->some View{
        HStack{
            Color(uiColor: .footerBackgroundColor)
        }
        .frame(height: 8)
    }
}

//MARK: - extension for custom color and Fonts
extension Text{
    @ViewBuilder
    func customTimerSettingHeader()-> some View{
        self.font(.custom(TFonts.TLIGHT.rawValue, size: TSize.TSIZE_14.rawValue))
            .foregroundStyle(.timerSettingHeader)
    }
}
