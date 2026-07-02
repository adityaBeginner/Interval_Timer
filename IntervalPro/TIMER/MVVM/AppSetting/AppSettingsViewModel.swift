//
//  AppSettingsViewModel.swift
//  TIMER
//
//  Created by Aditya Maroo on 11/10/24.
//

import SwiftUI
import Combine
import MediaPlayer
import AVFoundation

class AppSettingViewModel: ObservableObject {
    //MARK: - Published properties to bind with the view
    //MARK: -
    @Published var volumeNumber: Float = AppDefaults.shared.globalVolumeSoundIntervalApp
    @Published var disableVibration: Bool = AppDefaults.shared.isVibrationDisabled
    @Published var screenOff: Bool = AppDefaults.shared.disableAutoScreenOff
    @Published var screenLock: Bool = AppDefaults.shared.enableScreenLock
    @Published var hundredthsMilliSeconds: Bool = AppDefaults.shared.hundredthMilliSeconds
    @Published var isHelpNavigation: Bool = false
    @Published var isNaviagteSubscription: Bool = false
    var volumeHide: Bool = false
    
    ///
    ///Setting up the volume through the custom slider
    ///
    func setVolume(_ volume: Float) {
//        let volumeView = MPVolumeView(frame: .zero) // Create volume view with zero frame to hide it
//        volumeView.isHidden = true // Hide the volume view from the user interface
//        
//        let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
          let outputVolume = AVAudioSession.sharedInstance().outputVolume
//            slider?.value = volume
//            AppDefaults.shared.systemVolumeLevel = volume
            AppDefaults.shared.globalVolumeSoundIntervalApp = volume
        }
        debugPrint(volume)
        debugPrint(volumeNumber)
        debugPrint("App Defaults",AppDefaults.shared.globalVolumeSoundIntervalApp)
    }
    
    ///
    ///Disable or Enable vibration on timer and reaction call view
    ///
    func disableVibrationControll(){
        if disableVibration{
            AppDefaults.shared.isVibrationDisabled = disableVibration
        }
        else{
            AppDefaults.shared.isVibrationDisabled = disableVibration
        }
    }
    
    ///
    ///Disable auto screen offf
    ///
    func disableAutoScreenOff(){
//        if screenOff{
            AppDefaults.shared.disableAutoScreenOff = screenOff
//        }
//        else{
//            AppDefaults.shared.disableAutoScreenOff = screenOff
//        }
    }
    
    ///
    ///Handling dark Mode
    ///
    func darkModeSetting(newValue: Bool){
        if newValue{
            AppDefaults.shared.themeModeSettingDark = newValue
        }
        else{
            AppDefaults.shared.themeModeSettingDark = newValue
        }
    }
    
    ///
    ///Screen Lock For running timer
    ///
    func enableScreenLockSetting(){
        AppDefaults.shared.enableScreenLock = screenLock
    }
    
    ///
    ///Hundredth Milliseconds
    ///
    func enableDisableHundredthMilliSeconds(){
        AppDefaults.shared.hundredthMilliSeconds = hundredthsMilliSeconds
    }
}
