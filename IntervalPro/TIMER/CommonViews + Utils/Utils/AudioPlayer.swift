//
//  AudioPlayer.swift
//  TIMER
//
//  Created by Aditya Maroo on 08/10/24.
//

import AVFoundation
import AudioToolbox

//MARK: -
//MARK: AUDIO PLAYER
class AudioPlayer {
    //MARK: SINGLETON PROPERTIES
    static let shared = AudioPlayer()
    
    //MARK: PROPERTIES
    private var audioPlayer: AVAudioPlayer?
    private let vibrationManager:VibrationManager = VibrationManager()

    //MARK: INITIALIZER
    private init(){}
    
    //MARK: RINGTONES
    enum RingtoneFileName: Int, CaseIterable {
        case FourBeeps = 1
        case OneSingleBeep
        case OneSingleLongBeep
        case TwoShortOneLongBeep
        case BoxingBell
        case MMABuzzer
        case MeditationChime
        var value: String {
            switch self {
            case .FourBeeps:
                return "Four Beeps (Default)"
            case .OneSingleBeep:
                return "One Single Beep (Short)"
            case .OneSingleLongBeep:
                return "One Single Beep (Long)"
            case .TwoShortOneLongBeep:
                return "Two Short, One Long Beep"
            case .BoxingBell:
                return "Boxing Bell"
            case .MMABuzzer:
                return "MMA Buzzer"
            case .MeditationChime:
                return "Meditation Chime"
            }
        }
    }

    //MARK: METHODS
    //MARK: -
    ///
    ///PLAY AUDIO FILE
    ///
    func playAudio(id: Int) {
        let fileName = RingtoneFileName(rawValue: id)
        guard let url = Bundle.main.url(forResource: fileName?.value ?? "", withExtension: "mp3") else {
            print("Audio file \(String(describing: fileName)) not found in the app bundle.")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.volume = AppDefaults.shared.globalVolumeSoundIntervalApp
            audioPlayer?.play()
            ///
            ///STOP VIBRATION WHENEVER
            ///AUDIO IS PLAYING
            ///
            vibrationManager.stopVibrating()
        } catch {
            print("Failed to play audio: \(error)")
        }
    }
    
    ///
    ///PLAY AUDIO through file name FILE
    ///
    func playAudioFileName(fileName: String, halfwayAlert: Bool = false, vibrationName: String, vibrationTime: Int = 0) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            let vibrationTimeCase = vibrationName != "" ? vibrationName == "One Vibration" ? vibrationTime : 0 : 0
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(vibrationTimeCase)){
                vibrationName != "" ? vibrationName == "One Vibration" ? self?.vibrateOnce() : self?.vibrateFourTimes() : self?.vibrationManager.stopVibrating()
            }
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
//                ///
//                ///STOP VIBRATION WHENEVER
//                ///AUDIO IS PLAYING
//                ///
//                self?.vibrationManager.stopVibrating()
//            })
            var url: URL?
            if fileName.isEmpty{
                guard halfwayAlert else{
                    print("Audio file \(String(describing: fileName)) not found in the app bundle.")
                    return
                   
                }
                  url = Bundle.main.url(forResource: "One Single Beep (Short)" , withExtension: "mp3")
            }
          url = Bundle.main.url(forResource: fileName , withExtension: "mp3")
               
            do {
                guard let url = url else{
                    return
                }
                    
                 
                    self?.audioPlayer = try AVAudioPlayer(contentsOf: url)
                    self?.audioPlayer?.volume = AppDefaults.shared.globalVolumeSoundIntervalApp
                    self?.audioPlayer?.play()
                   
                
            } catch {
                print("Failed to play audio: \(error)")
            }
        }
    }
    
    
    ///
    ///Halfway Alert
    ///
    func halfWayAlert(vibrateName: String?){
        DispatchQueue.global(qos: .background).async { [weak self] in
            let url = Bundle.main.url(forResource: "One Single Beep (Short)" , withExtension: "mp3")
            do{
                guard let url = url else{return}
                self?.audioPlayer = try AVAudioPlayer(contentsOf: url)
                self?.audioPlayer?.volume = AppDefaults.shared.globalVolumeSoundIntervalApp
                self?.audioPlayer?.play()
               
                if vibrateName != "" {self?.vibrateOnce()}
//                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
//                    //                self.stopAudio()
//                    ///
//                    ///STOP VIBRATION WHENEVER
//                    ///AUDIO IS PLAYING
//                    ///
//                    self?.vibrationManager.stopVibrating()
//                })
            }
            catch{
                debugPrint("Failde to play")
            }
        }
    }
    
    ///
    ///Play Vibration
    ///
    func playVibration(vibrationName: String){
        DispatchQueue.global(qos: .background).async { [weak self] in
            vibrationName != "" ? vibrationName == "One Vibration" ? self?.vibrateOnce() : self?.vibrateFourTimes() : self?.vibrationManager.stopVibrating()
//            if vibrationName == "One Vibration"{
//                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
//                    //                self.stopAudio()
//                    ///
//                    ///STOP VIBRATION WHENEVER
//                    ///AUDIO IS PLAYING
//                    ///
//                    self?.vibrationManager.stopVibrating()
//                })
//            }
        }
    }
    

    ///
    ///STOP AUDIO
    ///
    func stopAudio() {
        audioPlayer?.stop()
        audioPlayer = nil
    }
    
    //StopEveryAudio and vibration
    func stopAudioVibration(){
        audioPlayer?.stop()
        vibrationManager.stopVibrating()
    }
    
    ///
    ///VIBRATE ONCE
    ///
    func vibrateOnce() {
        vibrationManager.vibrateOnce()
        ///STOP AUDIO WHENEVER
        ///SELECT VIBRATION
//        stopAudio()
    }
    ///
    ///VIBRATE FOUR TIMES
    ///
    func vibrateFourTimes() {
        // Vibrate 4 times with a delay in between
        vibrationManager.vibrateFourTimes()
        ///STOP AUDIO WHENEVER
        ///SELECT VIBRATION
//        stopAudio()
    }
    
    ///
    ///STOP VIBRATION
    ///
    private func stopVibration(){
        vibrationManager.stopVibrating()
    }
    
}

//MARK: -
//MARK: VIBRATION MANAGER
private class VibrationManager {
    private var isVibrating = false
    private var vibrationTimers: [DispatchWorkItem] = []
    
    func vibrateOnce() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }

    func vibrateFourTimes() {
        stopVibrating()
        isVibrating = true
        let interval = 0.8 // interval in seconds between vibrations
        
        for i in 0..<4 {
            let workItem = DispatchWorkItem { [weak self] in
                guard let self = self, self.isVibrating else { return }
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            }
            vibrationTimers.append(workItem)
            DispatchQueue.main.asyncAfter(deadline: .now() + interval * Double(i), execute: workItem)
        }
    }

    func stopVibrating() {
        // Stop all scheduled vibrations
        isVibrating = false
        vibrationTimers.forEach { $0.cancel() }
        vibrationTimers.removeAll()
    }
}


