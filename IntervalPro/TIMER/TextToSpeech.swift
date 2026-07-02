//
//  TextToSpeech.swift
//  TIMER
//
//  Created by Aditya Maroo on 23/09/24.
//

import Foundation
import AVFoundation

struct TextToSpeech{
   static let shared = TextToSpeech()
    func textSpeech(textData: String){
        let utterance = AVSpeechUtterance(string: textData)
        let voice = AVSpeechSynthesisVoice(language: "en-GB")
        utterance.voice = voice
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }
}
