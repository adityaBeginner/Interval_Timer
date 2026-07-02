//import SwiftUI
//import AVFoundation
//struct AuthenticationView: View {
//    
//    @State private var speechSynthesizer: AVSpeechSynthesizer? // 1)
//    var body: some View {
//        VStack{
//            Button(action: {
//                textToSpeech()
//            }, label: {
//                Text("Button")
//            })
//        }
//    }
//    
//    func textToSpeech(){
//        let audioSession = AVAudioSession() // 2) handle audio session first, before trying to read the text
//        do {
//            try audioSession.setCategory(.playback, mode: .default, options: .duckOthers)
//            try audioSession.setActive(false)
//        } catch let error {
//            print("❓", error.localizedDescription)
//        }
//        
//        speechSynthesizer = AVSpeechSynthesizer()
//        
//        let speechUtterance = AVSpeechUtterance(string: "Hello I am Aditya Maroo")
//        speechUtterance.voice = AVSpeechSynthesisVoice(language: "en-AU")
//        
//        speechSynthesizer?.speak(speechUtterance)
//    }
//}

/////
//    func pauseTimer() {
//        cancellable?.cancel()
//      
//            timer = pauseIntervalTimeStore
//            rtTimeInteger = pauseTimeStore
//        
//    }
//
/////
/////Et timer pause
/////
//func etTimerPause(){
//    etTimerSource?.cancel()
//       etTimerSource = nil
//}
//
/////
/////Et Timer Stop
/////
//func runningtime() {
//    etNowDate = Date.now
//    
//    // Cancel any existing timer if it's running
//    etTimerSource?.cancel()
//    
//    // Create a new DispatchSourceTimer
//    etTimerSource = DispatchSource.makeTimerSource(queue: DispatchQueue.global(qos: .background))
//    
//    // Schedule the timer to fire every 0.1 seconds (100 milliseconds)
//    etTimerSource?.schedule(deadline: .now(), repeating: 0.1)
//    
//    // Set the event handler for the timer
//    etTimerSource?.setEventHandler { [weak self] in
//        guard let self = self else { return }
//        
//        // Calculate the elapsed time in milliseconds
//        let elapsedTime = Int(Date.now.timeIntervalSince(self.etNowDate) * 1000)
//        
//        // Perform UI updates on the main thread
//        DispatchQueue.main.async {
//            self.etTimerString = updateEtTimeString(etRtTimeData: elapsedTime)
//        }
//    }
//    
//    // Start the timer
//    etTimerSource?.resume()
//}
//
//
/////
/////Timer Code for starting and running
/////
//func startTimer() {
//    nowDate = Date.now
//
//    // Run the timer on a background queue
//    DispatchQueue.global(qos: .background).async { [weak self] in
//        guard let self = self else { return }
//        
//        self.cancellable = Timer.publish(every: 0.1, on: .main, in: .common)
//            .autoconnect()
//            .sink { _ in
//                let elapsedTime = Int(Date.now.timeIntervalSince(self.nowDate)) * 1000
//
//                self.pauseTimeStore = max(0, self.rtTimeInteger - elapsedTime)
//                self.pauseIntervalTimeStore = max(0, self.timer - elapsedTime)
//
//                // Ensure UI updates are done on the main thread
//                DispatchQueue.main.async {
//                    self.intervalTime = updateTimeString(remainingTime: max(0, self.pauseIntervalTimeStore))
//                    self.rtTimerString = updateEtTimeString(etRtTimeData: max(0, self.pauseTimeStore))
//
//                    if self.messagePresent && self.newTimer == self.intervalPropertyData?.messageDataItem?.first?.messageTime {
//                        self.intervalNameStringData = self.intervalPropertyData?.messageDataItem?.first?.messageName ?? ""
//                        self.intervalPropertyData?.messageDataItem?.removeFirst()
//                    }
//
//                    if self.pauseIntervalTimeStore <= 0 {
//                        self.rtTimeInteger = self.pauseTimeStore
//                        self.nextIntervalData()
//                    }
//                }
//            }
//    }
//}


//
//  ReactionTimeCallVM.swift
//  TIMER
//
//  Created by Aditya Maroo on 28/08/24.
//
//
//import Foundation
//import SwiftUI
//import Combine
//
////import CoreData
////enum IntervalCallsState: String{
////    case UserGuide
////    case Normal
////}
//
//struct ListInterval{
//    var intervalName: String
//    var intervalTime: String
//    var intervalColor: String
//    var in

//import SwiftUI
//
//struct SwipeAndDeleteExample: View {
//    @State private var items = ["Item 1", "Item 2", "Item 3"]
//
//    var body: some View {
//        List {
//            ForEach(items, id: \.self) { item in
//                Text(item)
//                    .swipeActions {
//                        Button(role: .destructive) {
//                            deleteItem(item)
//                        } label: {
//                            Label("Delete", systemImage: "trash")
//                        }
//                    }
//            }
////            .onDelete(perform: delete)
//        }
//        .listStyle(PlainListStyle())
//    }
//
//    private func delete(at offsets: IndexSet) {
//        items.remove(atOffsets: offsets)
//    }
//
//    private func deleteItem(_ item: String) {
//        withAnimation {
//            items.removeAll { $0 == item }
//        }
//    }
//}
//
//#Preview {
//    SwipeAndDeleteExample()


import SwiftUI

struct RootView: View {
    @State private var navigateToB = false
    @State private var resetNavigation = false

    var body: some View {
        NavigationView {
            VStack {
                if resetNavigation {
                    Text("Root Screen") // Display Root content
                } else {
                    NavigationLink(isActive: $navigateToB) {
                        ScreenB(navigateToRoot: $resetNavigation)
                    } label: {
                        Text("Go to Screen B")
                    }
                }
            }
        }
    }
}

struct ScreenB: View {
    @Binding var navigateToRoot: Bool
    @State private var navigateToC = false

    var body: some View {
        VStack {
            NavigationLink(isActive: $navigateToC) {
                ScreenC(navigateToRoot: $navigateToRoot)
            } label: {
                Text("Go to Screen C")
            }
            Button("Back to Root") {
                navigateToRoot = true
            }
        }
    }
}

struct ScreenC: View {
    @Binding var navigateToRoot: Bool

    var body: some View {
        VStack {
            Text("Screen C")
            Button("Back to Root") {
                navigateToRoot = true
            }
        }
    }
}

#Preview{
    RootView()
}
