//
//  CommonFunction.swift
//  TIMER
//
//  Created by Aditya Maroo on 15/10/24.
//

import Foundation
import SwiftUI
import AVFoundation

func luminance(for color: Color) -> Double {
    func luminanceComponent(_ component: Double) -> Double {
        return component <= 0.03928 ? component / 12.92 : pow((component + 0.055) / 1.055, 2.4)
    }
    
    let uiColor = UIColor(color)
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    uiColor.getRed(&red, green: &green, blue: &blue, alpha: nil)
    
    return 0.2126 * luminanceComponent(Double(red)) +
           0.7152 * luminanceComponent(Double(green)) +
           0.0722 * luminanceComponent(Double(blue))
}

// Function to calculate contrast ratio between two luminances
func contrastRatio(luminance1: Double, luminance2: Double) -> Double {
    //This line can be change for color contrast according to client requirement
    return (max(luminance1, luminance2) + 0.05) / (min(luminance1, luminance2) + 0.05)
}

// Function to choose white or black button color based on background
func bestButtonColor(for backgroundColor: Color) -> Bool {
//    // Luminance for black and white
//    let luminanceWhite = 1.0
//    let luminanceBlack = 0.0
    
    // Calculate the luminance for the background
    let backgroundLuminance = luminance(for: backgroundColor)
    
    //Threshold Value
    let thresholdValue: Double = 0.5
    
    
    // Calculate contrast with black and white
//    let contrastWithWhite = contrastRatio(luminance1: luminanceWhite, luminance2: backgroundLuminance)
//    let contrastWithBlack = contrastRatio(luminance1: luminanceBlack, luminance2: backgroundLuminance)
    
    // Return the color with better contrast
    return backgroundLuminance < thresholdValue ? true : false
}

///
///Validation for IntervalDration
///
func validationRandomData(breakTime: IntervalDuration)-> Bool{
    let validationValue = (AppDefaults.shared.hundredthMilliSeconds ? "00:00:00" : "00:00")
//    guard isValidTime(breakTime.min ?? "") else {
//        debugPrint(breakTime.min)
//        return false
//    }
    guard isValidTimeInput(breakTime.min ?? "") else {
        return false
    }
    guard breakTime.min?.trimmingCharacters(in: .whitespaces) != "" && breakTime.min?.trimmingCharacters(in: .whitespaces) != validationValue && breakTime.min != nil else{
        return false
    }
//    guard breakTime.min?.count ?? 0 >= 5 else {
//        return false
//    }
    if breakTime.random{
//        guard isValidTime(breakTime.max ?? "") else {
//            return false
//        }
        guard isValidTimeInput(breakTime.max ?? "") else {
            return false
        }
        guard breakTime.max?.trimmingCharacters(in: .whitespaces) != "" && breakTime.max?.trimmingCharacters(in: .whitespaces) != validationValue && breakTime.max != nil else{
           
            return false
        }
//        guard breakTime.max?.count ?? 0 >= 5 else {
//            return false
//        }
        guard convertStringtoData(timeString: breakTime.min ?? "00:00") < convertStringtoData(timeString: breakTime.max ?? "00:00") else{
          
            return false
        }
    }
    return true
}


///
///Validation for restBetween Rounds
///
func validationRandomRoundsData(breakTime: RestBetweenRounds)-> Bool{
    let validationValue = (AppDefaults.shared.hundredthMilliSeconds ? "00:00:00" : "00:00")
    guard isValidTimeInput(breakTime.min ?? "") else {
        return false
    }
//    guard isValidTime(breakTime.min ?? "") else {
//        return false
//    }
    guard breakTime.min?.trimmingCharacters(in: .whitespaces) != "" && breakTime.min?.trimmingCharacters(in: .whitespaces) != validationValue && breakTime.min != nil else{
        return false
    }
//    guard breakTime.min?.count ?? 0 >= 5 else {
//        return false
//    }
    if breakTime.random{
//        guard isValidTime(breakTime.max ?? "") else {
//            return false
//        }
        guard isValidTimeInput(breakTime.max ?? "") else {
            return false
        }
        guard breakTime.max?.trimmingCharacters(in: .whitespaces) != "" && breakTime.max?.trimmingCharacters(in: .whitespaces) != validationValue && breakTime.max != nil else{
           
            return false
        }
//        guard breakTime.max?.count ?? 0 >= 5 else {
//            return false
//        }
        guard convertStringtoData(timeString: breakTime.min ?? "00:00") < convertStringtoData(timeString: breakTime.max ?? "00:00") else{
          
            return false
        }
    }
    return true
}

private func isValidTime(_ input: String) -> Bool {
    let fullPattern = #"^\d{2}:\d{2}:\d{2}$"# // HH:mm:ss
    let shortPattern = #"^\d{2}:\d{2}$"#      // mm:ss

    if input.range(of: fullPattern, options: .regularExpression) != nil {
        return input != "00:00:00"
    } else if input.range(of: shortPattern, options: .regularExpression) != nil {
        return input != "00:00"
    } else {
        return false
    }
}

///
/// New validation time input
///
private func isValidTimeInput(_ input: String) -> Bool {
    let invalidInputs = ["0", "00", "00:0", "00:00", "00:00:0"]
    return !invalidInputs.contains(input)
}


  ///
  /// Comverting String Data into into Int Miliseconds
  ///
  func convertStringtoData(timeString: String?)-> Int{
      guard timeString?.count ?? 0 >= 5 else {
          return 0
      }
      var timeString = timeString ?? "00:00:00"
      timeString = timeString.isEmpty ? "00:00:00" : timeString
      let timeComponents = timeString.split(separator: ":")
      let minutes = Int(timeComponents[0]) ?? 00
      let seconds = Int(timeComponents[1]) ?? 00
      let milliSeconds = timeString.count > 5 ? Int(timeComponents[2]) ?? 00 : 0
      let totalSeconds = (minutes * 60) + seconds
      let totalMilliseconds = totalSeconds * 1000
      let adjustedMilliseconds = milliSeconds * 10
      let timer = totalMilliseconds + adjustedMilliseconds
      return timer
  }
///
///sub function for change text field value
///
func formatTime(minTime: String) -> String {
    
    var formattedTime = minTime
    
    // Case when input has 1 character (less than 10 seconds)
    if minTime.count == 5{
       formattedTime = childFormatMMSS(minTime: minTime)
    }
    else if minTime.count > 5{
        formattedTime = childFormatMilliseconds(minTime: minTime)
    }
    return formattedTime == "00:00" ? "00:00"  : formattedTime
}

//Child Function for fromating in MM:SS
func childFormatMMSS(minTime: String)-> String{
    var formattedTime = minTime
    if minTime.count == 1 {
        formattedTime = "00:0\(minTime)"
    }
    
    // Case when input has 2 characters (seconds between 10 and 59)
    else if minTime.count == 2 {
        let intSecondsValue = Int(minTime) ?? 0
        let minutes = intSecondsValue / 60
        let seconds = intSecondsValue % 60
        formattedTime = String(format: "%02d:%02d", minutes, seconds)
    }
    
    // Case when input has 4 characters (minutes and seconds)
    else if minTime.count == 4 {
        let minutes = Int(minTime.prefix(1)) ?? 0
        let components = minTime.split(separator: ":")  // Split by colon ":"
        let combinedString = components.joined()
        let seconds = Int(combinedString.suffix(2)) ?? 0
        
        // Handle overflow if seconds >= 60
        if seconds >= 60 {
            let totalSeconds = minutes * 60 + seconds
            let newMinutes = totalSeconds / 60
            let newSeconds = totalSeconds % 60
            formattedTime = String(format: "%02d:%02d", newMinutes, newSeconds)
        } else {
            formattedTime = String(format: "%02d:%02d", minutes, seconds)
        }
    }
    //the above code is not useful for this format
    else if minTime.count == 5{
        let minutes = Int(minTime.prefix(2)) ?? 0
        let components = minTime.split(separator: ":")  // Split by colon ":"
        let combinedString = components.joined()
        let seconds = Int(combinedString.suffix(2)) ?? 0
        if seconds >= 60 {
            var totalSeconds = minutes * 60 + seconds
            totalSeconds = totalSeconds < 3600 ? totalSeconds : 3599
            let newMinutes = totalSeconds / 60
            let newSeconds = totalSeconds % 60
            formattedTime = String(format: "%02d:%02d", newMinutes, newSeconds)
        } else {
            formattedTime = String(format: "%02d:%02d", minutes, seconds)
        }
    }
    return formattedTime == "00:00" ? "00:00"  : formattedTime
}

//Child Function for Milliseconds Handling
func childFormatMilliseconds(minTime: String)-> String{
    var splitArray = minTime.split(separator: ":")
    let milliSecondsString = splitArray.removeLast()
    var minSecondsString = childFormatMMSS(minTime: splitArray.joined(separator: ":"))
    return minSecondsString + ":" + milliSecondsString
}


///
///for hh:mm:ss
///
func formatHourTime(minTime: String, isDisplayMilliseconds: Bool = false) -> String {
    var formattedTime = ""
    if minTime.count > 0 {
      var totalDuration = convertHoursStringtoData(timeString: minTime, isDisplayMilliseconds: isDisplayMilliseconds)
        totalDuration = totalDuration < 360000000 ? totalDuration : 359999000
        formattedTime = updateEtTimeString(etRtTimeData: totalDuration, isDisplayMilliseconds: isDisplayMilliseconds)
    }
   return formattedTime
}

func dismissKeyboard() {
  UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.endEditing(true) // 4
}

///
///Random function for range
///
func randomMaxMin(min: String, max: String)-> Int{
    let minInt = convertStringtoData(timeString: min)
    let maxInt = convertStringtoData(timeString: max)
    return Int.random(in: minInt...maxInt)
}

///
///Convert int time to string
///
func timeIntToString(timeInt: Int)-> String{
   
        let minutes = timeInt / 60
        let seconds = timeInt % 60
        let minutesTimeString = String(format: "%02d", minutes)
        let secondsTimeString = String(format: "%02d", seconds)
         return minutesTimeString + ":" + secondsTimeString
   
}

///
///haptic feedback function
///

func hapticON(){
    // Add haptic vibration
    let generator = UIImpactFeedbackGenerator(style: .light)
    generator.impactOccurred()
}

func noHaptic(){}


 //MARK: - Timer function

///
///Convert int time to string
///
func updateTimeString(remainingTime: Int, isHundredthMilliseconds: Bool = false)-> String{
    if isHundredthMilliseconds{
        return updateTimeStringMilliSeconds(remainingTime: remainingTime, includeMilliseconds: isHundredthMilliseconds)
    }
    else{
        let newTotalTime = (remainingTime) / 1000
        let minutes = newTotalTime / 60
        let seconds = newTotalTime % 60
        let minutesTimeString = String(format: "%02d", minutes)
        let secondsTimeString = String(format: "%02d", seconds)
        return minutesTimeString + ":" + secondsTimeString
    }
}

///
///Update Milliseconds and convertToString
///
func updateTimeStringMilliSeconds(remainingTime: Int, includeMilliseconds: Bool = false) -> String {
    let totalSeconds = remainingTime / 1000
    let minutes = totalSeconds / 60
    let seconds = totalSeconds % 60
    let milliseconds = (remainingTime % 1000) / 10  // Extract hundredths of a second

    let minutesString = String(format: "%02d", minutes)
    let secondsString = String(format: "%02d", seconds)

    if includeMilliseconds {
        let millisecondsString = String(format: "%02d", milliseconds)
        return "\(minutesString):\(secondsString):\(millisecondsString)"
    } else {
        return "\(minutesString):\(secondsString)"
    }
}


///
///Convert int time to string for``for Et timer and rtTimer `` it handles hours
///
func updateEtTimeString(etRtTimeData: Int, isDisplayMilliseconds: Bool = false)-> String{
    if AppDefaults.shared.hundredthMilliSeconds && isDisplayMilliseconds{
       return updateEtTimeStringMilliseconds(etRtTimeData: etRtTimeData)
    }
    else{
        let newEtRtTime = etRtTimeData / 1000
        let hours = newEtRtTime / 3600
        let minutes = (newEtRtTime % 3600) / 60
        let seconds = newEtRtTime % 60
        
        let hoursTimeString = String(format: "%02d", hours)
        let minutesTimeString = String(format: "%02d", minutes)
        let secondsTimeString = String(format: "%02d", (seconds))
        
        return hoursTimeString + ":" + minutesTimeString + ":" + secondsTimeString
    }
}
/// Added Milliseconds Handling
func updateEtTimeStringMilliseconds(etRtTimeData: Int)-> String{
    let newEtRtTime = etRtTimeData / 1000
        let milliseconds = (etRtTimeData % 1000) / 10  // Convert to two-digit format

        let hours = newEtRtTime / 3600
        let minutes = (newEtRtTime % 3600) / 60
        let seconds = newEtRtTime % 60

        let hoursTimeString = String(format: "%02d", hours)
        let minutesTimeString = String(format: "%02d", minutes)
        let secondsTimeString = String(format: "%02d", seconds)
        let millisecondsTimeString = String(format: "%02d", milliseconds)

        return "\(hoursTimeString):\(minutesTimeString):\(secondsTimeString):\(millisecondsTimeString)"
}

///
///random intervalTime and interval rest check
///
func commonRandomTimeCheck(intervalDuration: IntervalDuration)-> String{
    if intervalDuration.random{
        if convertStringtoData(timeString: intervalDuration.min ?? "00:00") < convertStringtoData(timeString: intervalDuration.max ?? "00:00"){
            return updateTimeString(remainingTime: randomMaxMin(min: intervalDuration.min ?? "0", max: intervalDuration.max ?? "0"), isHundredthMilliseconds: AppDefaults.shared.hundredthMilliSeconds)
        }
    }
    return intervalDuration.min ?? ""
}

///
///random intervalTime and interval rest check
///
func commmonRandomRoundTimeCheck(intervalDuration: RestBetweenRounds)-> String{
    if intervalDuration.random{
        return updateTimeString(remainingTime: randomMaxMin(min: intervalDuration.min ?? "00:00", max: intervalDuration.max ?? "00:00"))
    }
    return intervalDuration.min ?? ""
}

///
/// Comverting String Data of hours into into Int Miliseconds
///
func convertHoursStringtoData(timeString: String, isDisplayMilliseconds: Bool = false)-> Int{
    if AppDefaults.shared.hundredthMilliSeconds && isDisplayMilliseconds{
        return childConvertHourMilliseconds(timeString: timeString)
    }
    else{
        let timeComponents = timeString.split(separator: ":")
        let hours = Int(timeComponents[0]) ?? 00
        let minutes = Int(timeComponents[1]) ?? 00
        let seconds = Int(timeComponents[2]) ?? 00
        let timer = ((hours * 3600) + (minutes * 60) + (seconds)) * 1000
        return timer
    }
}

func childConvertHourMilliseconds(timeString: String)-> Int{
    if timeString.count == 11{
        let timeComponents = timeString.split(separator: ":")
        let hours = Int(timeComponents[0]) ?? 00
        let minutes = Int(timeComponents[1]) ?? 00
        let seconds = Int(timeComponents[2]) ?? 00
        let milliseconds = Int(timeComponents[3]) ?? 0
        let timer = ((hours * 3600) + (minutes * 60) + (seconds)) * 1000
        let hundredTHMilliseconds = milliseconds * 10
        return timer + hundredTHMilliseconds
    }
    return 0
}

///
///Handling string data greater than ``10  or less then display would be 09``
///
func handlingStringCountData(countStringData: String)-> String{
    guard let convertInt = Int(countStringData) else{
        return countStringData
    }
    return convertInt / 10 != 0 ? String(convertInt) : "0\(convertInt)"
}





//func textToSpeech(intervalName: String) {
//    let speechSynthesizer = AVSpeechSynthesizer()
//    let audioSession = AVAudioSession.sharedInstance()
//    
//    do {
//        // Set the audio session category to playback
//        try audioSession.setCategory(.playback, mode: .default, options: .duckOthers)
//        try audioSession.setActive(true)  // Activate audio session
//    } catch let error {
//        print("Error setting audio session:", error.localizedDescription)
//    }
//    
//    let speechUtterance = AVSpeechUtterance(string: intervalName)
//    
//    // Set the voice; fall back to default if "en-AU" is unavailable
//    speechUtterance.voice = AVSpeechSynthesisVoice(language: "en-AU") ?? AVSpeechSynthesisVoice(language: "en-US")
//    
//    speechSynthesizer.speak(speechUtterance)
//}



///previous change for not showing rest interval

//            if index % 2 == 0{
//                //ADITYA
//                listIntervalCall.append(IntervalCallProperties(intervalName: intervalListItemData[index/2].intervalName, intervalColour: intervalListItemData[index/2].colorObject?.colorHexCode, intervalDuration: intervalListItemData[index/2].intervalDuration?.min, intervalColorOpacity: intervalListItemData[index/2].colorObject?.alphaValue, indexValue: intervalListItemData[index/2].indexValue, breakTime: .NoBreak))
//            }
//            else{
//                if index == countNumber - 1{
//                    listIntervalCall.append(IntervalCallProperties(breakTime: .RoundBreak))
//                }
//                else{
//                    listIntervalCall.append(IntervalCallProperties(breakTime: .IntervalBreak))
//                }
//            }
//        }
//        storingIntervalItemData = listIntervalCall
