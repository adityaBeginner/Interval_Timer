//
//  TimerSettingViewModel.swift
//  TIMER
//
//  Created by Aditya Maroo on 23/08/24.
//

import Foundation
import SwiftUI


//MARK: -
//MARK: - TIMER SETTING VIEW MODEL
class TimerSettingViewModel: ObservableObject {
    //MARK: -
    //MARK: PUBLISHED PROPERTIES
    @Published var audioData: [Audio] = AudioPlayer.RingtoneFileName.allCases.map { Audio(name: $0.value, isSelected: false) }
    @Published var textSpeechData: [Audio] = [
        Audio(name: "With Count", isSelected: false),
        Audio(name: "Without Count", isSelected: false),
        Audio(name: "With Time", isSelected: false)
    ]
    @Published var textVibrationData: [Audio] = [
        Audio(name: "One Vibration", isSelected: false),
        Audio(name: "Four Vibrations", isSelected: false),
    ]
    @Published var isNoAudio: Bool = false
    @Published var isTextToSpeech: Bool = false
    @Published var isVibration: Bool = false
    
    //MARK: - Normal var property
    var audioSettingData: Settings?
    
    
    //MARK: -
    //MARK: METHODS
    ///
    ///SELECT AUDIO & PLAY
    ///
    func selectAudio(_ selectedAudio: Audio) {
        selectItem(in: &audioData, selectedItem: selectedAudio, shouldPlayAudio: true)
    }
    
    ///
    ///Default Data applying
    ///
    func defaultSoundData(audioSettingData: Settings){
            isNoAudio = audioSettingData.isNoAudio
        isTextToSpeech = audioSettingData.isTextToSpeech
        if !isNoAudio{
            if isTextToSpeech{
                selectSpeech(Audio(name: audioSettingData.textToSpeech ?? "", isSelected: true))
            }
                selectAudio(Audio(name: audioSettingData.audio ?? "", isSelected: true))
        }
           selectVibration(Audio(name: audioSettingData.vibration ?? "", isSelected: true))
    }
    
    ///
    ///SELECT SPEECH
    ///
    func selectSpeech(_ selectedSpeech:Audio) {
        selectItem(in: &textSpeechData, selectedItem: selectedSpeech)
    }
    
    ///
    ///SELECT VIBRATION
    ///
    func selectVibration(_ selectedVibration:Audio) {
        selectItem(in: &textVibrationData, selectedItem: selectedVibration)
        selectedVibration.name == "One Vibration" ? vibrateOnce() : vibrateFourTimes()
    }
    ///
    ///SELECT ITEM
    ///
    private func selectItem(in data: inout [Audio], selectedItem: Audio, shouldPlayAudio: Bool = false) {
        // Deselect all items
        for i in data.indices {
            data[i].isSelected = false
        }
        
        // Find the index of the selected item
        if let index = data.firstIndex(where: { $0.name == selectedItem.name }) {
            // Set isSelected to true for the selected item
            data[index].isSelected = true
            
            // Play audio if needed
            if shouldPlayAudio {
                runWithDelay(delay: 0.5){
                    AudioPlayer.shared.playAudio(id: index + 1)
                }
            }
        }
        
        //Saving Data to coreData
        runWithDelay(delay: 0.25, {
            self.saveAudioSettingData()
        })
        
    }
    
    ///
    ///STOP AUDIO
    ///
    func stopAudio(){
        AudioPlayer.shared.stopAudio()
    }
    
    ///
    ///VIBRATE ONCE
    ///
    private func vibrateOnce(){
        AudioPlayer.shared.vibrateOnce()
    }
    
    ///
    ///VIBRATE FOUR TIMES
    ///
    private func vibrateFourTimes(){
        AudioPlayer.shared.vibrateFourTimes()
    }
    
    ///
    /// save Date to coreDataBase
    ///
    func saveAudioSettingData(){
        audioSettingData?.isNoAudio =  isNoAudio
        audioSettingData?.isTextToSpeech =  isTextToSpeech
        if !isNoAudio{
            if isTextToSpeech{
                audioSettingData?.textToSpeech = textSpeechData.filter{$0.isSelected}.first?.name
                audioSettingData?.audio = ""
            }
            else{
                audioSettingData?.audio = audioData.filter{$0.isSelected}.first?.name
                audioSettingData?.textToSpeech = ""
            }
        }else{
            audioSettingData?.audio = "No Audio"
            audioSettingData?.textToSpeech = ""
            audioSettingData?.isTextToSpeech = false
        }
        audioSettingData?.vibration = textVibrationData.filter{$0.isSelected}.first?.name
        CoreDataManager.shared.saveContext()
    }
    
    ///
    /// UPDATE SELECTED VALUES FROM ``SETTINGS`` ENTITY
    ///
    func showAudioSettingsData(){
        guard let audioSettingData = audioSettingData else {return}
        
        isNoAudio = audioSettingData.isNoAudio
        isTextToSpeech = audioSettingData.isTextToSpeech
        if audioSettingData.isTextToSpeech{
            for index in 0..<textSpeechData.count{
                   textSpeechData[index].isSelected = textSpeechData[index].name == (audioSettingData.textToSpeech ?? "")
            }
        }
        if let vibration = audioSettingData.vibration{
            for index in 0..<textVibrationData.count{
                textVibrationData[index].isSelected = textVibrationData[index].name == vibration
            }
        }
        if let audio = audioSettingData.audio{
            for index in 0..<audioData.count{
                audioData[index].isSelected = audioData[index].name == audio
            }
        }
        
    }
 
    ///
    ///RESET VIBRATIONS
    ///
    func resetVibrationView(){
        for index in 0..<textVibrationData.count{
            textVibrationData[index].isSelected = false
        }
    }
}


//MARK: -
//MARK: - AUDIO MODEL
struct Audio:Identifiable{
    var name:String
    var isSelected:Bool
    var id: UUID = UUID()
}
