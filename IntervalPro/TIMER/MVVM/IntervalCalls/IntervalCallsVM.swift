//
//  IntervalCallsVM.swift
//  TIMER
//
//  Created by Aditya Maroo on 28/08/24.
//

import Foundation
import SwiftUI
import Combine
import AVFoundation

//import CoreData
//enum IntervalCallsState: String{
//    case UserGuide
//    case Normal
//}

struct MessageData: Hashable{
    var messageName: String?
    var messageTime: Int?
}


enum BreakTime: String{
    case IntervalBreak = "Interval Break"
    case RoundBreak = "Round Break"
    case NoBreak = "No Break"
}
struct IntervalCallProperties: Hashable{
    var id = UUID()
    var intervalName: String?
    var intervalColour: String?
    var intervalDuration: String?
    var intervalColorOpacity: Double?
    var indexValue: Int64?
    var breakTime: BreakTime = .IntervalBreak
    var messageDataItem: [MessageData]?
    var halfWayAlert: Bool = false
    var completeRounds: Int?
    var indexValueNo: Int?
    var currentIntervalIndexOfSession: Int?
    var milliseconds: String?
    
}

 //MARK: - Scroll View Helper for auto scroll on interaction Stop
//class ScrollViewHelper: ObservableObject {
//    
//    @Published var currentOffset: CGFloat = 0
//    @Published var offsetAtScrollEnd: CGFloat = 0
//    
//    private var cancellable: AnyCancellable?
//    
//    init() {
//        cancellable = AnyCancellable($currentOffset
//                                        .debounce(for: 3, scheduler: DispatchQueue.main)
//                                        .dropFirst()
//                                        .assign(to: \.offsetAtScrollEnd, on: self))
//    }
//    
//}

//MARK: - View model class for interval call
class IntervalCallsVM: ObservableObject {
    //MARK: - State property binded with view
    @Published var popDescription: [String] = ["Total elapsed time.", "Remaining session time.", "Interval count.", "Your current round.", "Total number of rounds.", "Your following calls are shown here.", "Start/Pause timer.", "Lock/unlock screen.\nLong press for unlock.", "Reset timer.", "Skip interval.",]
    @Published var viewState: WorkoutViewState = .ViewGuide
    @Published var intervalTime: String = "00:00"
    @Published var timer: Int = 1
    @Published var isTimeStartPause: Bool = false
    @Published var intervalListItemData: [IntervalItem] = []
    @Published var listIntervalCall: [IntervalCallProperties] = []
    @Published var completedRounds: Int = 1
    @Published var itemData: Item?
    @Published var intervalHexColorCode: String = ""
    @Published var intervalColorOpacity: Double = 1.0
    @Published var intervalNameStringData: String = "dgrngdflnd"
    @Published var intervalCount: Int = 1
    @Published var noTaskPerform: Bool = false
    @Published var newTimer: Int = 0
    @Published var pauseTimeStore = 0
    @Published var pauseIntervalTimeStore = 0
    @Published var messagePresent: Bool = false
    @Published private var speechSynthesizer: AVSpeechSynthesizer?
    @Published var audioName: String = "No audio"
    @Published var halfwayAlert: Bool = false
    @Published var textToSpecchAvail: Bool = false
    @Published var userInteractionLock: Bool = false
    @Published var isNextTap: Bool = false
    @Published var scrollToBottom = false
    @Published var isMorePlusBtnVisible: Bool = false
    @Published var emptyListPresent: Bool = false
    
    //Et Timer
    @Published var etTimerString: String = "00:00:00"
    @Published var etTimerInteger:Int = 0
    @Published var notAgainStart: Bool = false
    
    //Remainig Time
    @Published var rtTimerString: String = "00:00:00"
    @Published var rtTimeInteger: Int = 1
    
    @Published var isAudioToPlay: Bool = false
    
    //IndexValueChange
    @Published var indexCountOfList = 0
    
    //Potrait and Landscape Index Maanage for scroll
    @Published var isLandScapeScroll = false
    
    //Reset Timer Alert Variablr
    @Published var resetAlertPop: Bool = false
    
    //Reset the position for scroll View
    @Published var resetScrollPosition: Bool = false
    
    //Increase Height of LazyVstack
    @Published var increaseHeight = 0.0
    var previousOffset: CGFloat = 0
    var timerScroll: AnyCancellable?
    
    
    var alertHeaderText = "STOP TIMER AND RESET?"
    var alertDescriptionBox = "Are you sure you want to end this session and reset the timer."
    var alertGoBackBtn = "NO, GO BACK"
    var alertResetBtn = "YES, RESET"
    
    //Forstoring list item by default and changing on round
    var storingIntervalItemData: [IntervalCallProperties] = []
    //for stoping timer
    var cancellable: AnyCancellable?
    
    //Audio Session
    var audioSession: AVAudioSession?
    

 
    //update date
    var nowDate = Date.now
    var etNowDate = Date.now
    var justNextIntervalDate = Date.now
    
    //ET Timer Cancel
    var etTimerSource: AnyCancellable?
    //    var endTimeResult: String = "00:00:00"
    var etTimeStoring: Int = 0
    var intervalTimerStore = 0
    var rtTimeStore = 0
    
    //Message Time for 10 seconds display
    var messageTime = Date.now
    
    //Interval Property data
    var intervalPropertyData: IntervalCallProperties?
    
    //Total no of interval including rounds
    var totalNoIntervalInSession: Int = 0
    
    //Vibration
    var vibrationData: String = ""
    var sessionAudioCount: Int = 1
    
    // AudioStart Time and Clap condition variable
    var isNoAudioSelected: Bool = false
    var isAudioPresent: Bool = true
    var audioSartTime: Int = AppDefaults.shared.hundredthMilliSeconds ? 200 : 300
    var isClapAudioPlay: Bool = false
    var clapFileAudioName: String = "Claps"
    var stopAudioCheck: Bool = false
    var stopAudioClapCheck: Bool = false
    var textToSpeechWithCount: Bool = false
    var textToSpeechWithTime: Bool = false
    var everyIntervaltextToSpeechWithTime: Bool = false
    var isVibrationPresent: Bool = false
    var halfAlertMinusTime: Int = AppDefaults.shared.hundredthMilliSeconds ? 0 : 300
    //Session End Message Array
    var sessionEndStringArray = [ "And you’re done!",
                  "Mic Drop Time",
                  "Boom! Nailed it.",
                  "Mission accomplished!",
                  "You crushed it!",
                  "Done and done’r!",
                  "Awesome!",
                  "Easy Peasy!",
                  "Light work baby!",
                  "Oooh yeah!",
                  "Kaboom! Done!",
                  "And that’s how it’s done!"]
    
    
    private var addMilliseconds: Int{
        return AppDefaults.shared.hundredthMilliSeconds ? 0 : 1000
    }
    
    
    ///
    /// Pausing timer or suspending it
    ///
    func pauseTimer() {
        cancellable?.cancel()
        timer = pauseIntervalTimeStore
        rtTimeInteger = pauseTimeStore
        rtTimeStore = 0
        intervalTimerStore = 0
    }
    
    ///
    ///Et timer pause
    ///
    func etTimerPause(){
        etTimeStoring = etTimerInteger
        etTimerSource?.cancel()
        etTimerSource = nil
    }
    
    ///
    ///Et Timer Stop
    ///
    func runningtime() {
        etNowDate = Date.now
        etTimerSource = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
            .sink{[self] _ in
                etTimerInteger = etTimeStoring + Int(Date.now.timeIntervalSince(etNowDate) * 1000)
                etTimerString = updateEtTimeString(etRtTimeData: etTimerInteger)
            }
    }
    
    
    ///
    ///Timer Code for starting and running
    ///
    func startTimer() {
        if !noTaskPerform{
            nowDate = Date.now
            cancellable = Timer.publish(every: 0.01, on: .main, in: .common)
                .autoconnect()
                .sink { [self] _ in
                    
                    
                    let elapsedTime = Int(Date.now.timeIntervalSince(nowDate) * 1000)
                    intervalTimerStore = timer - elapsedTime
                    rtTimeStore = rtTimeInteger - elapsedTime
                    pauseTimeStore = max(0, rtTimeStore)
                    pauseIntervalTimeStore = max(0, intervalTimerStore)
                    
                    //Displaying time
                    intervalTime = updateTimeString(remainingTime: pauseIntervalTimeStore + addMilliseconds, isHundredthMilliseconds: AppDefaults.shared.hundredthMilliSeconds)
                    rtTimerString = updateEtTimeString(etRtTimeData: pauseTimeStore + addMilliseconds)
                    
                    
                    
                    //Default song for halfway alert
                    if halfwayAlert && (pauseIntervalTimeStore - halfAlertMinusTime) <= timer / 2  && !isNoAudioSelected{
                        DispatchQueue.global(qos: .background).async {[self] in
                            if textToSpecchAvail{textToSpeech(intervalName: "Halfway")}
                            else{
                                AudioPlayer.shared.halfWayAlert(vibrateName: vibrationData)
                            }
                        }
                        halfwayAlert = false
                    }
                    
                    //Shift to new after completion
                    if pauseIntervalTimeStore <= 0 {
                        justNextIntervalDate = Date.now
                        nextIntervalData()
                    }
                    if everyIntervaltextToSpeechWithTime && pauseIntervalTimeStore <= 3100{
                        textToSpeechWithTime(textArray: ["Three","Two","one"])
                        everyIntervaltextToSpeechWithTime = false
                    }
                    
                    //Message display
                    if messagePresent && (timer - pauseIntervalTimeStore) + 600 >= intervalPropertyData?.messageDataItem?.first?.messageTime ?? 5000 {
                        intervalNameStringData = intervalPropertyData?.messageDataItem?.first?.messageName ?? "No Message Name"
                        textToSpeech(intervalName: intervalNameStringData)
                        intervalPropertyData?.messageDataItem?.removeFirst()
                        messageTime = Date.now + 10
                        messagePresent = intervalPropertyData?.messageDataItem == [] ? false : true
                    }
                    if Int(Date.now.timeIntervalSince(messageTime)) >= 0  && !noTaskPerform {
                        intervalNameStringData = intervalPropertyData?.intervalName ?? ""
                    }
                    //                Playing Audio File on the end of the interval
                    if (audioSartTime >= pauseIntervalTimeStore && stopAudioCheck) || (audioSartTime >= pauseIntervalTimeStore && isVibrationPresent){
                        DispatchQueue.global(qos: .background).async {
                            AudioPlayer.shared.playAudioFileName(fileName: self.audioName, vibrationName: self.vibrationData, vibrationTime: (self.audioSartTime - 500))
                        }
                        
                        stopAudioCheck = false
                        isVibrationPresent = false
                    }
                    
                    //Clap Audio Play condition
                    if pauseIntervalTimeStore <= 10000 && stopAudioClapCheck && intervalPropertyData?.breakTime == .NoBreak && timer > 10000{
                        DispatchQueue.global(qos: .background).async {[self] in
                            AudioPlayer.shared.playAudioFileName(fileName: clapFileAudioName, vibrationName: vibrationData)
                        }
                        
                        stopAudioClapCheck = false
                    }
                    
                }
        }
    }
    
    
    ///
    ///Change to next interval call
    ///
    func nextIntervalData(){
        guard !noTaskPerform else{
            return
        }
        //for interval AudioPlay
        
        indexCountOfList += 1
       
        //        isAudioToPlay = false
        if listIntervalCall.last?.indexValueNo ?? 0 < indexCountOfList {
            sessionOver()
        }
        else{
            completedRounds = listIntervalCall[indexCountOfList].completeRounds ?? 1
            intervalCount  = Int(listIntervalCall[indexCountOfList].indexValue ?? 1)
            addingAllSessionTime()
            updateIntervaData(intervalDataProperties: listIntervalCall[indexCountOfList])
           
            if /*listIntervalCall[indexCountOfList].breakTime == .NoBreak &&*/ textToSpeechWithTime{
                if !(noTaskPerform){
                    let intervalTime = listIntervalCall[indexCountOfList].intervalDuration.map { String($0) } ?? "00:20"
                        let intervalTimeString = AppComman.shared.readableTime(from: intervalTime)
                    textToSpeech(intervalName: "\(listIntervalCall[indexCountOfList].intervalName ?? "No Interval"),\(intervalTimeString)")
                    }
                
            }
            else{
                textToSpeech(intervalName: self.listIntervalCall[indexCountOfList].intervalName ?? "No Interval")
            }
        }
    }
    
    ///
    ///update intervalData after every interval change
    ///
    func updateIntervaData(intervalDataProperties: IntervalCallProperties, firstAppear: Bool = false){
        rtTimeInteger += isNextTap ? 0 : intervalTimerStore
        if firstAppear || !isTimeStartPause{
            intervalTime = intervalDataProperties.intervalDuration ?? "00:00"
        }
        timer = isNextTap ? convertStringtoData(timeString: AppComman.shared.handlingMilliseconds(timeString: intervalDataProperties.intervalDuration)) : convertStringtoData(timeString:AppComman.shared.handlingMilliseconds(timeString: intervalDataProperties.intervalDuration)) + intervalTimerStore
        pauseIntervalTimeStore = timer
        nowDate = justNextIntervalDate
        intervalNameStringData = intervalDataProperties.intervalName ?? "No Interval"
        intervalHexColorCode = intervalDataProperties.intervalColour ?? "#202020"
        intervalColorOpacity = intervalDataProperties.intervalColorOpacity ?? 1.0
        //        intervalTime = intervalDataProperties.intervalDuration ?? "00: 12"
        messagePresent = intervalDataProperties.messageDataItem != nil ? true : false
        intervalPropertyData = intervalDataProperties
        halfwayAlert = /*stopAudioClapCheck ? false :*/ intervalDataProperties.halfWayAlert
      
//        print(intervalTimerStore)
        stopAudioCheck = isAudioPresent
        stopAudioClapCheck = isClapAudioPlay
        everyIntervaltextToSpeechWithTime = textToSpeechWithCount
        isVibrationPresent = vibrationData.isEmpty ? false : true
        //NextTap has to be false
        isNextTap = false
    }
    
    ///
    ///handling for session over
    ///
    func sessionOver(){
        
        intervalNameStringData = sessionEndStringArray.shuffled().first ?? "And you’re done!"
        textToSpeech(intervalName: intervalNameStringData)
        intervalHexColorCode =  "#202020"
        intervalColorOpacity = 1.0
        intervalTime =  "00:00"
        addingAllSessionTime()
        etTimerString = updateEtTimeString(etRtTimeData: (convertHoursStringtoData(timeString: etTimerString))) //- intervalTimerStore
        isTimeStartPause = false
        noTaskPerform = true
        notAgainStart = true
        etTimerSource?.cancel()
        cancellable?.cancel()
        rtTimeInteger = 0
        timer = 0
        stopAudioSession()
        emptyListPresent = true
    }
    
    ///
    ///converting IntervalItem to IntervalCallProperty type
    ///
    func convertListData() {
        listIntervalCall.removeAll()
        
        // Shuffle the list if needed - O(n)
        if itemData?.shuffle == true {
            intervalListItemData = intervalListItemData.shuffled()
        }
        
        // Pre-calculate whether we have interval and round breaks
        let hasRestBetweenInterval = validationRandomData(breakTime: itemData?.restBetweenInterval ?? IntervalDuration())
        let hasRestBetweenRounds = validationRandomRoundsData(breakTime: itemData?.restBetweenRounds ?? RestBetweenRounds())
        
        //Index Value for maintaing of the item to call
        var indexValueCount = 0
        var totalIntervalCount = 1
        
        // Iterate over intervalListItemData in a single loop - O(n)
        for totalRoundsIndex in 0..<Int(itemData?.restBetweenRounds?.rounds ?? 1){
            var count: Int64 = 1
            for intervalItem in intervalListItemData {
                let newIntervalDuration = commonRandomTimeCheck(intervalDuration: intervalItem.intervalDuration ?? IntervalDuration())
                
                // Add the main interval
                listIntervalCall.append(
                    IntervalCallProperties(
                        intervalName: intervalItem.intervalName,
                        intervalColour: intervalItem.colorObject?.colorHexCode,
                        intervalDuration: AppComman.shared.handlingMilliseconds(timeString: newIntervalDuration),
                        intervalColorOpacity: intervalItem.colorObject?.alphaValue,
                        indexValue: count,
                        breakTime: .NoBreak,
                        messageDataItem: addIntervalMessages(intervalItem: intervalItem, intervalDurationString: newIntervalDuration),
                        halfWayAlert: intervalItem.halfWayAlert,
                        completeRounds: totalRoundsIndex + 1,
                        indexValueNo: indexValueCount,
                        currentIntervalIndexOfSession: totalIntervalCount
                    )
                )
                count += 1
                totalIntervalCount += 1
                
                // If there is a rest between intervals, add the interval break
                if hasRestBetweenInterval {
                    let breakDuration = commonRandomTimeCheck(intervalDuration: itemData?.restBetweenInterval ?? IntervalDuration())
                    listIntervalCall.append(
                        IntervalCallProperties(
                            intervalName: "Rest/Transition",
                            intervalColour: "#C0C0C0",
                            intervalDuration: AppComman.shared.handlingMilliseconds(timeString: breakDuration),
                            intervalColorOpacity: 1.0,
                            indexValue: count,
                            messageDataItem: nil, // No message for breaks
                            halfWayAlert: false,
                            completeRounds: totalRoundsIndex + 1,
                            indexValueNo: indexValueCount + 1
                        )
                    )
                    indexValueCount += 1
                }
                indexValueCount += 1
            }
            
            // Remove the last "Interval Break" if it exists - O(1)
            if hasRestBetweenInterval && !listIntervalCall.isEmpty {
                listIntervalCall.removeLast()
                indexValueCount -= 1
            }
            
            // Handle round breaks if applicable - O(1)
            if hasRestBetweenRounds && (itemData?.restBetweenRounds?.rounds ?? 1) > totalRoundsIndex + 1{
                roundCheckTimer(roundCount: totalRoundsIndex + 1,indexValueCount: indexValueCount)
                indexValueCount += 1
            }
        }
        print(listIntervalCall)
    }
    
    
    ///
    /// Checking round count which greater than ``1 or not``
    ///
    func roundCheckTimer(roundCount: Int, indexValueCount: Int){
        let restIntervalTime = commmonRandomRoundTimeCheck(intervalDuration: itemData?.restBetweenRounds ?? RestBetweenRounds())
        let restIntervalTimeString = AppComman.shared.handlingMilliseconds(timeString: restIntervalTime)
        listIntervalCall.append(IntervalCallProperties(intervalName: "End of round \(roundCount) of \(itemData?.restBetweenRounds?.rounds ?? 1)", intervalColour: "#C0C0C0", intervalDuration: restIntervalTimeString ,intervalColorOpacity: 1.0, breakTime: .RoundBreak, completeRounds: roundCount, indexValueNo: indexValueCount))
        
    }
    
    ///
    ///Reload the session into new
    ///
    func reloadDataSession(){
        if !intervalListItemData.isEmpty{
            emptyListPresent = false
            completedRounds = 1
            intervalCount = 1
            indexCountOfList = 0
            etTimerString = "00:00:00"
            isTimeStartPause = false
            pauseTimer()
            etTimerPause()
            rtTimeInteger = 0
            timer = 0
            etTimeStoring = 0
            etTimerInteger = 0
            notAgainStart = false
            noTaskPerform = false
//            startAudioSession()
            convertListData()
            addingAllSessionTime()
            updateIntervaData(intervalDataProperties: listIntervalCall.first ?? IntervalCallProperties(), firstAppear: true)
        }
    }
    
    
    ///
    ///Update list Item on tapping list item
    ///
    func tapGuesture(intervalListItem: IntervalCallProperties){
        justNextIntervalDate = Date.now
        AudioPlayer.shared.stopAudioVibration()
        var count = 0
        for intervalList in listIntervalCall{
            if intervalList == intervalListItem{
                break
            }
            count += 1
        }
        indexCountOfList = count
        completedRounds = listIntervalCall[indexCountOfList].completeRounds ?? 1
        intervalCount  = Int(listIntervalCall[indexCountOfList].indexValue ?? 1)
     
//        listIntervalCall.remove(at: count)
//        listIntervalCall.removeFirst()
//        listIntervalCall.insert(intervalListItem, at: 0)
//        pauseTimer()
        intervalTimerStore = 0
        addingAllSessionTime()
        isNextTap = true
//        isTimeStartPause =  false
        updateIntervaData(intervalDataProperties: intervalListItem)
        if /*listIntervalCall[indexCountOfList].breakTime == .NoBreak &&*/ textToSpeechWithTime{
            if !(noTaskPerform){
                let intervalTime = listIntervalCall[indexCountOfList].intervalDuration.map { String($0) } ?? "00:20"
                    let intervalTimeString = AppComman.shared.readableTime(from: intervalTime)
                    textToSpeech(intervalName: "\(listIntervalCall[indexCountOfList].intervalName ?? "No Interval"),\(intervalTimeString)")
                }
        }
        else{
            textToSpeech(intervalName: self.listIntervalCall[indexCountOfList].intervalName ?? "No Interval")
        }
    }
    
    ///
    ///Adding all time in remaining time
    ///
    func addingAllSessionTime(){
        rtTimeInteger = listIntervalCall.filter{ $0.indexValueNo ?? 0 >= indexCountOfList }.reduce(0){(result, number)-> Int in
            return result +  convertStringtoData(timeString: number.intervalDuration ?? "00:15")
        }
        rtTimerString = updateEtTimeString(etRtTimeData: rtTimeInteger)
    }
    
    ///
    ///Adding all mesages
    ///
    func addIntervalMessages(intervalItem: IntervalItem, intervalDurationString: String)-> [MessageData]?{
        var intervalPropertyMessage: [MessageData] = []
        guard var messageData = intervalItem.messageItems?.allObjects as? [MessageItems] else{
            return nil
        }
        messageData.sort{$0.indexValue < $1.indexValue}
        messageData.sort{convertStringtoData(timeString: $0.delay ?? "00:00") < convertStringtoData(timeString: $1.delay ?? "00:00")}
        messageData.filter{message in
            convertStringtoData(timeString: message.delay ?? "00:00") < convertStringtoData(timeString: intervalDurationString)
        }.forEach{message in
            intervalPropertyMessage.append(MessageData(messageName: message.messageName, messageTime: convertStringtoData(timeString: message.delay ?? "00:00")))
        }
        if intervalPropertyMessage.isEmpty{
            return nil
        }
        return intervalPropertyMessage
        
    }
    
    ///
    ///text to sppech
    ///
    func textToSpeech(intervalName: String) {
        if textToSpecchAvail {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
               
                let synthesizer = AVSpeechSynthesizer()
                let utterance = AVSpeechUtterance(string: intervalName)
                utterance.volume = AppDefaults.shared.globalVolumeSoundIntervalApp
//                utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
                
                // Notify main thread for any UI-related updates, if needed
                DispatchQueue.main.async {
                    self?.speechSynthesizer = synthesizer
                }
                
                synthesizer.speak(utterance)
                
                // Reactivate audio session after speech (optional)
            }
        }
    }
    ///
    ///best font color according to contrast
    ///
    func bestContrastColor()-> Color{
        var colorFont = bestButtonColor(for: Color(hex: intervalHexColorCode).opacity(intervalColorOpacity))
        return colorFont ? Color(uiColor: .playScreenFontColor) : Color(uiColor: .playScreenBlackColorFont)
    }
    
    ///
    ///text to sppech
    ///
    func startAudioSession() {
        DispatchQueue.global(qos: .background).async {[weak self] in
            if self?.textToSpecchAvail ?? false || self?.isAudioPresent ?? false{
                self?.audioSession = AVAudioSession.sharedInstance()
                do {
                    try self?.audioSession?.setCategory(.playback, mode: .default, options: [.mixWithOthers])
                    try self?.audioSession?.setActive(true) // Use `true` to activate the session
                } catch let error {
                    print("❓ Audio session error:", error.localizedDescription)
                    return
                }
                
                // Reactivate audio session after speech (optional)
            }
        }
        
    }
        
    ///
    ///Count of 3, 2 , 1
    ///
func textToSpeechWithTime(textArray: [String]){
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            if self?.textToSpecchAvail ?? false && !textArray.isEmpty {
            var textArray = textArray
            let synthesizer = AVSpeechSynthesizer()
            let utterance = AVSpeechUtterance(string: textArray.first ?? "Three")
                utterance.volume = AppDefaults.shared.globalVolumeSoundIntervalApp
                utterance.prefersAssistiveTechnologySettings = true
            //utterance.voice = AVSpeechSynthesisVoice(language: "en-AU")
            
            // Notify main thread for any UI-related updates, if needed
            DispatchQueue.main.async {
                textArray.removeFirst()
                self?.speechSynthesizer = synthesizer
            }
            
            synthesizer.speak(utterance)
            runWithDelay(delay: 0.7){
                self?.textToSpeechWithTime(textArray: textArray)
            }
        }
    }

    }
    
    ///Stoping Audio Session 
    func stopAudioSession(){
        DispatchQueue.global(qos: .background).async {[weak self] in
            do {
                try self?.audioSession?.setActive(false)
            } catch let error {
                print("❓ Failed to deactivate audio session:", error.localizedDescription)
            }
        }
    }
    
    ///Set Active Audio Session
    func setActiveAudioSession(){
        DispatchQueue.global(qos: .background).async {[weak self] in
            do {
                try self?.audioSession?.setActive(true)
            } catch let error {
                print("❓ Failed to deactivate audio session:", error.localizedDescription)
            }
        }
    }
    
    
    
    ///
    ///Audio Registeration for Text to Speech and Audio
    ///
    func audioValidation(itemData: Item?){
        isNoAudioSelected = itemData?.setting?.isNoAudio ?? false
        isAudioPresent = itemData?.setting?.isNoAudio ?? false ? false : true
        if isAudioPresent{
            if itemData?.setting?.isTextToSpeech ?? false{
                checkTextToSpeech(text: itemData?.setting?.textToSpeech)
            }
            else{
                audioName = itemData?.setting?.audio ?? ""
                if itemData?.setting?.audio == "Four Beeps (Default)"{
                    audioSartTime = 3200 /*+ addMilliseconds*/
                }
                else if itemData?.setting?.audio == "Two Short, One Long Beep"{
                    audioSartTime = 2200 /*+ addMilliseconds*/
                }
                else if itemData?.setting?.audio == "MMA Buzzer" || itemData?.setting?.audio == "Boxing Bell"{
                    isClapAudioPlay = true
                }
            }
        }
        if itemData?.viibrateAlert ?? false{
            vibrationData = itemData?.setting?.vibration ?? ""
        }
    }
    
    ///Text To Speech Check
    func checkTextToSpeech(text: String?){
        isAudioPresent = false  //Only text to Speech will work no Audio will Play
        guard let textToSpeechData = text else{
            return
        }
        switch textToSpeechData{
        case "With Count":
            textToSpeechWithCount = true
            break
            
        case "Without Count":
            break
            
        case "With Time":
            textToSpeechWithTime = true
            break
        default:
            break
        }
    }
 
    ///
    ///Handle Scroll Interaction is over or not
    ///
    func handleScrollInteraction(offset: CGFloat) {
           if offset != previousOffset {
               var countingVariable = 0
               resetScrollPosition = false
               previousOffset = offset
               timerScroll = Timer.publish(every: 1, on: .main, in: .common).autoconnect().sink{_ in 
                   if countingVariable == 4{
//                       withAnimation(.smooth){
                           self.resetScrollPosition = true
//                       }
                       //move;
                   }
                   countingVariable += 1
               }
        }
       }
 
    
}

