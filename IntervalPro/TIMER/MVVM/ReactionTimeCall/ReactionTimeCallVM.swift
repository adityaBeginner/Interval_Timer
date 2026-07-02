
//  ReactionTimeCallVM.swift
//  TIMER
//
//  Created by Aditya Maroo on 28/08/24.


import Foundation
import SwiftUI
import Combine
import AVFoundation

//import CoreData
//enum IntervalCallsState: String{
//    case UserGuide
//    case Normal
//}

struct ListInterval{
    var intervalName: String
    var intervalTime: String?
    var intervalColor: String
    var intervalColorOpacity: Double
    var intervalMaxNumberCalls: Bool?
    var breakType: BreakTime?
    
}




class ReactionTimeCallVM: ObservableObject {
    
    //MARK: - Binding Properties
    
    @Published var popDescription: [String] = ["Total elapsed time.", "Remaining session time.", "Remaining call time if selected.", "Start/Pause timer.", "Lock/unlock screen.\nLong press for unlock.", "Reset timer.", "Skip interval."]
    @Published var viewState: WorkoutViewState = .ViewGuide
    @Published var reactionName: String = ""
    @Published var reactionIntervalName: String = "No Reaction present"
    @Published var reactionItem: Item?
    //    @Published var elapsedtime  = Date.now
    @Published var remainingTime: Int = 1
    @Published var reactionIntervalTime: String = "00:00"
    @Published var totalDuration: Int = 765000
    @Published var reactionIntervalColor: String = "#FFFFFF"
    @Published var reactionColorOpacty: Double = 1.0
    @Published var roundCount: Int = 1
    @Published var intervalItems: [IntervalItem] = []
    @Published var isPlayPause: Bool = false
    @Published var etTimerString: String = "00:00:00"
    @Published var etTimerInteger:Int = 1
    @Published var listIntervalItems: [ListInterval] = []
    @Published var intervalbreakList: [ListInterval] = []
    @Published var pauseIntervalTimer: Int = 0
    @Published var noTaskPerform: Bool = false
    @Published var etTimerNotStart: Bool = false
    @Published var hideIntervalTime: Bool = false
    @Published var audioSong: String = "No Audio"
    @Published var textToSpeech: Bool = false
    @Published private var speechSynthesizer: AVSpeechSynthesizer?
    @Published var isNextTap: Bool = false
    @Published var isInteractionLock: Bool = false
    
    ///Handling session Last Round total time
    @Published var totalTimeRemaing: Int = 1
    @Published var totalRemaingDurationTime: String = "00:00:00"
    @Published var remaingRtTime: Int = 0
    
    @Published var timerCountMillSeconds: Int = 0
    
    //Reset Timer Alert Variablr
    @Published var resetAlertPop: Bool = false
    var alertHeaderText = "STOP TIMER AND RESET?"
    var alertDescriptionBox = "Are you sure you want to end this session and reset the timer."
    var alertGoBackBtn = "NO, GO BACK"
    var alertResetBtn = "YES, RESET"
    var breakType: BreakTime = .NoBreak
    
    
    //Audio Session
    var audioSession: AVAudioSession?
    
    // AudioStart Time and Clap condition variable
    var isAudioPresent: Bool = true
    var audioSartTime: Int = AppDefaults.shared.hundredthMilliSeconds ? 200 : 300
    var isClapAudioPlay: Bool = false
    var clapFileAudioName: String = "Claps"
    var stopAudioCheck: Bool = false
    var stopAudioClapCheck: Bool = false
    var textToSpeechWithCount: Bool = false
    var textToSpeechWithTime: Bool = false
    var everyIntervaltextToSpeechWithTime: Bool = false
    var isVibration: Bool = false
    
    //New random interval Condition
    var maxNumberOfCallList: [ListInterval] = []
    @Published var nextRound: Int = 1
    
    //MARK: - Variable and Properties
    var extraDataExceeds: Bool = false
    var vibrationData: String = ""
    var nowTime = Date.now
    var etNowDate = Date.now
    var justNextIntervalDate = Date.now
    var cancellable: AnyCancellable?
    var itemData: Item?
    var etTimer: AnyCancellable?
    var defaultIntervalList = ListInterval(intervalName: "IntervalName", intervalTime: "00:04", intervalColor: "#FFFFFF", intervalColorOpacity: 1.0)
    var etTimeStoring: Int = 0
    
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
        ///For not storing time in next button
        totalDuration = pauseIntervalTimer
        remaingRtTime = totalTimeRemaing
    }
    
    ///
    ///Et timer pause
    ///
    func etTimerPause(){
        etTimeStoring = etTimerInteger
        etTimer?.cancel()
    }
    
    ///
    ///Et Timer Stop
    ///
    func runningtime(){
        etNowDate = Date.now
        etTimer = Timer.publish(every: 0.01, on: .main, in: .common)
            .autoconnect()
            .sink{ [ self] _ in
                etTimerInteger = etTimeStoring + Int(Date.now.timeIntervalSince(etNowDate) * 1000)
                etTimerString =  updateEtTimeString(etRtTimeData: etTimerInteger)
            }
    }
    
    ///
    ///Timer Code for starting and running
    ///
    func startTimer() {
        
        nowTime = Date.now
        cancellable = Timer.publish(every: 0.01, on: .main, in: .common)
            .autoconnect()
            .sink { [ self] _ in
                // Calculate remaining time and intervalTime
                let elapsedtime = Int((Date.now.timeIntervalSince(nowTime)) * 1000)
                pauseIntervalTimer =  totalDuration - elapsedtime
                
                totalTimeRemaing = remaingRtTime - elapsedtime
                reactionIntervalTime = updateTimeString(remainingTime: pauseIntervalTimer + addMilliseconds , isHundredthMilliseconds: AppDefaults.shared.hundredthMilliSeconds)
                totalRemaingDurationTime = updateEtTimeString(etRtTimeData: totalTimeRemaing + addMilliseconds)
                if pauseIntervalTimer <= 0{
                    justNextIntervalDate = Date.now
                    nextSessionShift()
                }
                
                //Text to Speech
                if everyIntervaltextToSpeechWithTime && pauseIntervalTimer <= 3100{
                    textToSpeechWithTime(textArray: ["Three","Two","one"])
                    everyIntervaltextToSpeechWithTime = false
                }
                
                //Playing Audio File on the end of the interval
                if (audioSartTime >= pauseIntervalTimer && stopAudioCheck) || (audioSartTime >= pauseIntervalTimer && isVibration){
                    DispatchQueue.global(qos: .background).async {
                        AudioPlayer.shared.playAudioFileName(fileName: self.audioSong, vibrationName: self.vibrationData)
                    }
                    
                    stopAudioCheck = false
                    isVibration = false
                }
                if pauseIntervalTimer <= 10000 && stopAudioClapCheck && breakType == .NoBreak && totalDuration > 10000{
                    DispatchQueue.global(qos: .background).async {[self] in
                        AudioPlayer.shared.playAudioFileName(fileName: clapFileAudioName, vibrationName: vibrationData)
                    }
                    stopAudioClapCheck = false
                }
                
                
            }
        
    }
    
    ///
    ///session over handling
    ///
    func sessionHandling(){
        reactionIntervalColor =  "#202020"
        reactionColorOpacty =  1.0
        reactionIntervalName = sessionEndStringArray.shuffled().first ?? "And you’re done!"
        textToSpeech(intervalName: reactionIntervalName)
        reactionIntervalTime = "00:00"
        isPlayPause = false
        noTaskPerform = true
        pauseTimer()
        etTimerPause()
        etTimeStoring = 0
        pauseIntervalTimer = 0
        totalTimeRemaing = 0
        addingAllReactionData()
        stopAudioSession()
        //        etTimerString =  updateEtTimeString(etRtTimeData: etTimerInteger)
        return
    }
    
    ///
    ///nextSessionChange
    ///
    func nextSessionShift(){
        if !noTaskPerform{
            intervalbreakList.removeFirst()
          
            if intervalbreakList.isEmpty {
                sessionHandling()
            }
            else{
                updateIntervalData(intervalItem: intervalbreakList.first ?? defaultIntervalList)
                if textToSpeechWithTime{
                    debugPrint(AppComman.shared.readableTime(from: intervalbreakList.first?.intervalTime ?? "00:00"))
                        textToSpeech(intervalName: "\(intervalbreakList.first?.intervalName ?? "No Interval"),\(AppComman.shared.readableTime(from: intervalbreakList.first?.intervalTime ?? "00:00"))")
                }
                else{
                    textToSpeech(intervalName: intervalbreakList.first?.intervalName ?? "No Interval")
                }
            }
        }
        
    }
    
    
    
    
    ///
    ///Update IntervalItemData on timerCompletion
    ///
    func updateIntervalData(intervalItem: ListInterval, firstTimeRun: Bool = false){
        totalDuration =  isNextTap ? convertStringtoData(timeString: intervalItem.intervalTime ?? "00:00") : convertStringtoData(timeString: intervalItem.intervalTime ?? "00:00") + pauseIntervalTimer
        isNextTap ? addingAllReactionData() : (remaingRtTime = totalTimeRemaing)
        pauseIntervalTimer = totalDuration
        nowTime = justNextIntervalDate
        reactionIntervalName =  intervalItem.intervalName
        reactionIntervalColor = intervalItem.intervalColor
        reactionColorOpacty = intervalItem.intervalColorOpacity
        if firstTimeRun || !isPlayPause{
            reactionIntervalTime = AppComman.shared.handlingMilliseconds(timeString: intervalItem.intervalTime)
        }
        breakType = intervalItem.breakType ?? .RoundBreak
        stopAudioCheck = isAudioPresent
        stopAudioClapCheck = isClapAudioPlay
        everyIntervaltextToSpeechWithTime = textToSpeechWithCount
        isVibration = vibrationData.isEmpty ? false : true
    }
    
    
    
    ///
    ///reload timer in reaction drill
    ///
    func reloadTimerSession(){
        if !intervalItems.isEmpty && validationRandomData(breakTime: itemData?.intervalDuration ?? IntervalDuration()){
            isPlayPause = false
            roundCount = 1
            noTaskPerform = false
            etTimerNotStart = false
            etTimerPause()
            pauseTimer()
            etTimeStoring = 0
            etTimerString = "00:00:00"
            nextRound = 1
            startAudioSession()
            intervalBreakStore()
            addingAllReactionData()
            totalTimeRemaing = remaingRtTime
            updateIntervalData(intervalItem: intervalbreakList.first ?? defaultIntervalList, firstTimeRun: true)
        }
        
    }
    
    ///
    ///Storing interval according to number calls in listIntertval
    ///
    func storeInArray(){
        if validationRandomData(breakTime: itemData?.intervalDuration ?? IntervalDuration()){
            listIntervalItems.removeAll()
            intervalItems.forEach{intervalItem in
                if !(intervalItem.intervalCall?.random ?? false){
                    listIntervalItems.append(ListInterval(intervalName: intervalItem.intervalName ?? "IntervalName" , intervalTime: commonRandomTimeCheck(intervalDuration: itemData?.intervalDuration ?? IntervalDuration()), intervalColor: intervalItem.colorObject?.colorHexCode ?? "#FFFFFF", intervalColorOpacity: intervalItem.colorObject?.alphaValue ?? 1.0, intervalMaxNumberCalls: intervalItem.intervalCall?.random, breakType: .NoBreak))
                }
            }
        }
    }
    
    
    
    ///
    ///Re-arranging order of interval break and interval
    ///
    func intervalBreakStore(){
        intervalbreakList = []
        storingMaxNumberOfValue()
        if !intervalItems.isEmpty {
            for roundIndex in 0..<Int(itemData?.restBetweenRounds?.rounds ?? 1){
//                storeInArray()
            if validationRandomData(breakTime: itemData?.restBetweenInterval ?? IntervalDuration()){
                addingIntervalDataToMaxNumberCall()
                
                if !intervalbreakList.isEmpty{
                    intervalbreakList.removeLast()
                }
                
                if validationRandomRoundsData(breakTime: itemData?.restBetweenRounds ?? RestBetweenRounds()) && itemData?.restBetweenRounds?.rounds ?? 1 > roundIndex + 1{
                    intervalbreakList.append(ListInterval(intervalName: "Round \(roundIndex + 1) of \(itemData?.restBetweenRounds?.rounds ?? 1) done, get ready", intervalTime: commmonRandomRoundTimeCheck(intervalDuration: itemData?.restBetweenRounds ?? RestBetweenRounds()), intervalColor: "#C0C0C0", intervalColorOpacity: 1.0, breakType: .RoundBreak))
                }
            }
            else if validationRandomRoundsData(breakTime: itemData?.restBetweenRounds ?? RestBetweenRounds())  && itemData?.restBetweenRounds?.rounds ?? 1 >= roundIndex + 1{
                addingIntervalDataToMaxNumberCall()
                if itemData?.restBetweenRounds?.rounds ?? 1 > roundIndex + 1{
                    intervalbreakList.append(ListInterval(intervalName: "Round \(roundIndex + 1) of \(itemData?.restBetweenRounds?.rounds ?? 1) done, get ready", intervalTime: commmonRandomRoundTimeCheck(intervalDuration: itemData?.restBetweenRounds ?? RestBetweenRounds()), intervalColor: "#C0C0C0", intervalColorOpacity: 1.0, breakType: .RoundBreak))
                }
            }
            else{
                addingIntervalDataToMaxNumberCall()
            }
            nextRound += 1
        }
    }
    }
    
    ///
    ///text to sppech
    ///
    func textToSpeech(intervalName: String) {
        if textToSpeech {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                let synthesizer = AVSpeechSynthesizer()
                let utterance = AVSpeechUtterance(string: intervalName)
                utterance.volume = AppDefaults.shared.globalVolumeSoundIntervalApp
                utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
                
                // Notify main thread for any UI-related updates, if needed
                DispatchQueue.main.async {
                    self?.speechSynthesizer = synthesizer
                }
                
                synthesizer.speak(utterance)
            }
        }
    }
    
    ///
    ///Count of 3, 2 , 1
    ///
func textToSpeechWithTime(textArray: [String]){
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            if self?.textToSpeech ?? false && !textArray.isEmpty {
            var textArray = textArray
            let synthesizer = AVSpeechSynthesizer()
            let utterance = AVSpeechUtterance(string: textArray.first ?? "Three")
                utterance.volume = AppDefaults.shared.globalVolumeSoundIntervalApp
//            utterance.voice = AVSpeechSynthesisVoice(language: "en-AU")
            
            // Notify main thread for any UI-related updates, if needed
            DispatchQueue.main.async {
                textArray.removeFirst()
                self?.speechSynthesizer = synthesizer
            }
            
            synthesizer.speak(utterance)
            runWithDelay(delay: 0.8){
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
    
    ///
    ///text to sppech
    ///
    func startAudioSession() {
        DispatchQueue.global(qos: .background).async {[weak self] in
            if self?.textToSpeech ?? false || self?.isAudioPresent ?? false{
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
    ///Handling Rt timer on Appera
    ///
    func handlingRTtimer(){
        totalRemaingDurationTime = itemData?.session ?? "00:00:00"
        remaingRtTime = convertHoursStringtoData(timeString: itemData?.session ?? "00:00:00", isDisplayMilliseconds: (AppDefaults.shared.hundredthMilliSeconds && itemData?.session?.count == 11))
        totalTimeRemaing = remaingRtTime
    }
    
    func addingAllReactionData(){
        remaingRtTime = intervalbreakList.reduce(0){(result, number) in
            return result + convertStringtoData(timeString: number.intervalTime ?? "00:00")
        }
//        if remaingRtTime < convertHoursStringtoData(timeString: itemData?.session ?? "00:00:00") && !extraDataExceeds{
//            checkingAddingIntervalData()
//        }
        totalRemaingDurationTime = updateEtTimeString(etRtTimeData: remaingRtTime)
    }
    
    ///
    ///best font color according to contrast
    ///
    func bestContrastColor()-> Color{
        let colorFont = bestButtonColor(for: Color(hex: reactionIntervalColor).opacity(reactionColorOpacty))
        return colorFont ? Color(uiColor: .playScreenFontColor) : Color(uiColor: .playScreenBlackColorFont)
    }
    
    ///
    ///Adding intervalAccording to session Length
    ///
    func addingIntervalDataToMaxNumberCall(){
        storeInArray()
        if !listIntervalItems.isEmpty || !maxNumberOfCallList.isEmpty{
            let roundBreakData = commmonRandomRoundTimeCheck(intervalDuration: itemData?.restBetweenRounds ?? RestBetweenRounds())
            let intrevalDataChoice = !maxNumberOfCallList.isEmpty ? randomProbabiltyPossibilty() ? true : false : false
            if intrevalDataChoice{
                let maxNumberListIndex = Int.random(in: 0..<maxNumberOfCallList.count)
                let restIntervalBreakData = commonRandomTimeCheck(intervalDuration: itemData?.restBetweenInterval ?? IntervalDuration())
                if checkingDataEntry(addTime: convertStringtoData(timeString: maxNumberOfCallList[maxNumberListIndex].intervalTime) + convertStringtoData(timeString: restIntervalBreakData),roundBreakTime: convertStringtoData(timeString: roundBreakData)){
                    if validationRandomData(breakTime: itemData?.restBetweenInterval ?? IntervalDuration()){
                        intervalbreakList.append(maxNumberOfCallList[maxNumberListIndex])
                        intervalbreakList.append(ListInterval(intervalName: "Reset, Get Ready", intervalTime: restIntervalBreakData, intervalColor: "#C0C0C0", intervalColorOpacity: 1.0, breakType: .IntervalBreak))
                    }
                    else{
                        intervalbreakList.append(maxNumberOfCallList[maxNumberListIndex])
                    }
                    maxNumberOfCallList.remove(at: maxNumberListIndex)
                    addingIntervalDataToMaxNumberCall()
                }
                
            }
            else{
                let listIntervalindex = Int.random(in: 0..<listIntervalItems.count)
                //            var maxNumberListIndex = Int.random(in: 0..<maxNumberOfCallList.count)
                let restIntervalBreakData = commonRandomTimeCheck(intervalDuration: itemData?.restBetweenInterval ?? IntervalDuration())
                let listIntervalData = changeRandomTimeInterval(intervalData: listIntervalItems[listIntervalindex])
                if checkingDataEntry(addTime: convertStringtoData(timeString: listIntervalData?.intervalTime) + convertStringtoData(timeString: restIntervalBreakData), roundBreakTime: convertStringtoData(timeString: roundBreakData)){
                    if validationRandomData(breakTime: itemData?.restBetweenInterval ?? IntervalDuration()){
                        intervalbreakList.append(listIntervalData ?? ListInterval(intervalName: "", intervalColor: "#202020", intervalColorOpacity: 1))
                        intervalbreakList.append(ListInterval(intervalName: "Reset, Get Ready", intervalTime: restIntervalBreakData, intervalColor: "#C0C0C0", intervalColorOpacity: 1.0, breakType: .IntervalBreak))
                    }
                    else{
                        intervalbreakList.append(listIntervalItems[listIntervalindex])
                    }
                    addingIntervalDataToMaxNumberCall()
                }
            }
        }
               
        }
    
    ///
    ///Adding Data according session to session time validation
    ///
    private func checkingDataEntry( addTime: Int, roundBreakTime: Int)-> Bool{
        let sessionTime = convertHoursStringtoData(timeString: itemData?.session ?? "00:00:00", isDisplayMilliseconds: (AppDefaults.shared.hundredthMilliSeconds && itemData?.session?.count == 11)) * nextRound
        let previousTime = intervalbreakList.filter{$0.breakType != .RoundBreak}.reduce(0){(result, number) in
            return result + convertStringtoData(timeString: number.intervalTime ?? "00:00")
        }
        guard previousTime + addTime < sessionTime else{
            guard previousTime + addTime - sessionTime < sessionTime - previousTime else{
                return false
            }
            return true
        }
//        guard previousTime + roundBreakTime <= sessionTime else{
//            return false
//        }
        return true
    }
   
    
    ///
    ///Random Probabilty function
    ///
    private func randomProbabiltyPossibilty()-> Bool{
        return Int.random(in: 0...10) < 4
    }
    
    ///
    ///Storing interval according to number calls in listIntertval
    ///
    private func storingMaxNumberOfValue(){
        if validationRandomData(breakTime: itemData?.intervalDuration ?? IntervalDuration()){
            maxNumberOfCallList.removeAll()
            intervalItems.forEach{intervalItem in
                if intervalItem.intervalCall?.random ?? false{
                    for _ in 0..<(intervalItem.intervalCall?.maxNumber ?? 0){
                        maxNumberOfCallList.append(ListInterval(intervalName: intervalItem.intervalName ?? "IntervalName" , intervalTime: commonRandomTimeCheck(intervalDuration: itemData?.intervalDuration ?? IntervalDuration()), intervalColor: intervalItem.colorObject?.colorHexCode ?? "#FFFFFF", intervalColorOpacity: intervalItem.colorObject?.alphaValue ?? 1.0, intervalMaxNumberCalls: intervalItem.intervalCall?.random))
                    }
                }
            }
        }
    }
    
    ///
    ///Returning ListInterval for randomTime.
    ///The array store all non false value
    ///when it is added the time should be randome
    ///
    private func changeRandomTimeInterval(intervalData: ListInterval?)-> ListInterval?{
        var data = intervalData
        data?.intervalTime = commonRandomTimeCheck(intervalDuration: itemData?.intervalDuration ?? IntervalDuration())
        return data
    }
    
    ///
    ///AudioValidation And Check
    ///
    func audioValidation(itemData: Item?){
        isAudioPresent = itemData?.setting?.isNoAudio ?? false ? false : true
        if isAudioPresent{
            if itemData?.setting?.isTextToSpeech ?? false{
                textToSpeech = true
                checkTextToSpeech(text: itemData?.setting?.textToSpeech)
            }
            //alert song
            else{
                audioSong = itemData?.setting?.audio ?? ""
                if itemData?.setting?.audio == "Four Beeps (Default)"{
                    audioSartTime = 3200 /*+ addMilliseconds*/
                }
                else if itemData?.setting?.audio == "Two Short, One Long Beep"{
                    audioSartTime = 2200 /*+ addMilliseconds*/
                }
                else if (itemData?.setting?.audio == "MMA Buzzer" || itemData?.setting?.audio == "Boxing Bell") && !(itemData?.shuffle ?? false) {
                    isClapAudioPlay = true
                }
            }
        }
        
        
        //vibration
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
            if !(itemData?.shuffle ?? false){
                textToSpeechWithCount = true
            }
            break
            
        case "Without Count":
            break
            
        case "With Time":
            if !(itemData?.shuffle ?? false){
                textToSpeechWithTime = true
            }
            break
        default:
            break
        }
    }
}





//Clap Audio Play condition
//                if pauseIntervalTimer <= 10100 && stopAudioClapCheck{
//                    DispatchQueue.global(qos: .background).async {[self] in
//                        AudioPlayer.shared.playAudioFileName(fileName: clapFileAudioName, vibrationName: vibrationData)
//                    }
//
//                    stopAudioClapCheck = false
//                }
