//
//  AppComman.swift
//  TIMER
//
//  Created by Aditya Maroo on 11/10/24.
//

import Foundation
import SwiftUI

class AppComman{
    //MARK: - CREATE SHARED OBJECT
    //MARK: -
    static var shared:AppComman = {
        return AppComman()
    }()
    static var blackModeColorString = "#202020"
    static var whiteColorModeString = "#FFFEFC"
   private var backgroundTaskID: UIBackgroundTaskIdentifier?
    private init(){}
//    let subscriptionProductID:String = "com.intervals.yearly.subscription"//"com.sixpackmacros.monthly"
    let verifyReceiptPassword =        "d976bd976a04481f8eabc9edad984373"
    let oneTimePurchaseProductID: String = "pbintervals.product.premium"
    
    
    func generateStartTimeMap(_ intervalItems: [IntervalItem]) -> [Int64: String] {
        var timeMap: [Int64: String] = [:]
        var totalTime: Double = 0

     

        for interval in intervalItems {
            let index = interval.indexValue
            timeMap[index] = formatTime(totalTime)

            // Add current interval duration for the next index
            if let min = interval.intervalDuration?.min,
               let duration = parseTime(min) {
                totalTime += duration
            }
        }

        return timeMap
    }
    
    ///
    ///Handling Start Time Adding
    ///
    func handlingStartTimeCount(item: Item?, indexValue: Int64)-> String{
        var startTimeData: Double = 0
        guard let item = item , let intervalItemsSet = item.intervalItem, var intervalItems = intervalItemsSet.allObjects as? [IntervalItem] else{
            return ""
        }
        intervalItems.sort{$0.indexValue < $1.indexValue}
        if indexValue > 0 {
            startTimeData = getIntervalsTotalTime(Array(intervalItems.prefix(Int(indexValue))))
            return formatTime(startTimeData)
        }
        return "00:00:00"
    }
    
    ///
    /// GET INTERVALS TOTAL TIME
    ///
    private func getIntervalsTotalTime(_ intervals: [IntervalItem]) -> Double {
        
        // Parse each interval's duration from "MM:SS" format and sum them up
        return intervals.compactMap { parseTime($0.intervalDuration?.min ?? "") }.reduce(0, +)
    }
    
    ///
    /// PARSE "MM:SS" STRING TO TOTAL SECONDS
    ///
    private func parseTime(_ timeString: String) -> Double? {
        let components = timeString.split(separator: ":").compactMap { Double($0) }
        
        guard components.count >= 2 else { return nil }
        
        let minutes = components[0]
        let seconds = components[1]
        if AppDefaults.shared.hundredthMilliSeconds{
            let milliseconds = (components.count == 3) ? components[2] / 100 : 0
            return (minutes * 60) + seconds + milliseconds
        }
        
        return (minutes * 60) + seconds
    }
    
    ///
    /// FORMAT TIME FROM SECONDS TO "HH:MM:SS"
    ///
    private func formatTime(_ totalSeconds: Double) -> String {
        if AppDefaults.shared.hundredthMilliSeconds{
            return formatTimeMilliSeconds(totalSeconds)
        }
        else{
            let hours = Int(totalSeconds) / 3600
            let minutes = (Int(totalSeconds) % 3600) / 60
            let seconds = Int(totalSeconds) % 60
            //        print(String(format: "%02d:%02d:%02d", hours, minutes, seconds))
            return hours > 0 ? String(format: "%02d:%02d:%02d", hours, minutes, seconds) : String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    ///
    /// FORMAT TIME FROM SECONDS TO "HH:MM:SS:ms"
    ///
    private func formatTimeMilliSeconds(_ totalSeconds: Double) -> String {
        let hours = Int(totalSeconds) / 3600
          let minutes = (Int(totalSeconds) % 3600) / 60
          let seconds = Int(totalSeconds) % 60
         // let milliseconds = Int((totalSeconds.truncatingRemainder(dividingBy: 1)) * 100) // Extracts hundredths of a second

        return hours > 0 ?  String(format: "%02d:%02d:%02d", hours, minutes, seconds /*milliseconds*/) : String(format: "%02d:%02d", minutes, seconds /*milliseconds*/)
    }
    
    ///
    ///Validation for IntervalDration
    ///
    func validationIntervalData(durationType: IntervalDuration, minFieldValue: String, maxFieldValue: String, random: Bool) -> IntervalDuration {
        var updatedDuration = durationType
        
        let trimmedMin = minFieldValue.trimmingCharacters(in: .whitespaces)
        let trimmedMax = maxFieldValue.trimmingCharacters(in: .whitespaces)
        
        // Helper checks for empty or "00:00"
        let isMinValid = !trimmedMin.isEmpty && trimmedMin != (AppDefaults.shared.hundredthMilliSeconds ? "00:00:00" : "00:00")
        let isMaxValid = !trimmedMax.isEmpty && trimmedMax != (AppDefaults.shared.hundredthMilliSeconds ? "00:00:00" : "00:00")
        
        if random {
            if isMinValid {
                updatedDuration.min = trimmedMin
                updatedDuration.random = isMaxValid
                
                if isMaxValid {
                    updatedDuration.max = trimmedMax
                    if convertStringtoData(timeString: trimmedMin) > convertStringtoData(timeString: trimmedMax) {
                        updatedDuration.max = trimmedMin
                        updatedDuration.min = trimmedMax
                    }
                }
            } else if isMaxValid {
                if !trimmedMin.isEmpty{
                    //As If min field is 00:00 it will convert to 00:01
                    updatedDuration.min = (AppDefaults.shared.hundredthMilliSeconds ? "00:01:00" : "00:01")
                    updatedDuration.max = trimmedMax
                    updatedDuration.random = true
                }
                else{
                    updatedDuration.min = trimmedMax
                    updatedDuration.max = nil
                    updatedDuration.random = false
                }
            } else {
                updatedDuration.random = false
            }
        } else if !trimmedMin.isEmpty { // if value is empty store to previous value
            updatedDuration.min = trimmedMin
            updatedDuration.max = nil
            updatedDuration.random = false
        }
        else{
            updatedDuration.min = nil
            updatedDuration.max = nil
            updatedDuration.random = false
        }
        
        return updatedDuration
    }

    ///
    ///Contrast Ratio of Black present in a Color
    ///
     func has95PercentBlackRatio(color: Color) -> Bool {
           // Convert Color to UIColor to extract RGB components
           guard let components = UIColor(color).cgColor.components, components.count >= 3 else {
               return false // Invalid color, assume it's not black enough
           }
           
           let red = components[0]
           let green = components[1]
           let blue = components[2]
           
           // Calculate relative luminance
           let luminance = 0.2126 * red + 0.7152 * green + 0.0722 * blue
           
           // If luminance is less than or equal to 0.15 (85% black), return true
         return luminance <= 0.20
       }
    
    ///
    ///Contrast Ratio of Black present in a Color
    ///
     func has95PercentWhiteRatio(color: Color) -> Bool {
           // Convert Color to UIColor to extract RGB components
           guard let components = UIColor(color).cgColor.components, components.count >= 3 else {
               return false // Invalid color, assume it's not black enough
           }
           
           let red = components[0]
           let green = components[1]
           let blue = components[2]
           
           // Calculate relative luminance
           let luminance = 0.2126 * red + 0.7152 * green + 0.0722 * blue
           
           // If luminance is less than or equal to 0.15 (85% black), return true
         return luminance >= 0.93
       }
    
    
    ///
    ///Change in interval Duration ``Max, Min and Random``according to user input
    ///Empty data will not be created if item is in edit state
    ///
    func validationRoundIntervalData(durationType: RestBetweenRounds, minFieldValue: String, maxFieldValue: String, random: Bool)-> RestBetweenRounds{
        var updatedDuration = durationType
        
        let trimmedMin = minFieldValue.trimmingCharacters(in: .whitespaces)
        let trimmedMax = maxFieldValue.trimmingCharacters(in: .whitespaces)
        
        // Helper checks for empty or "00:00"
        let isMinValid = !trimmedMin.isEmpty && trimmedMin != (AppDefaults.shared.hundredthMilliSeconds ? "00:00:00" : "00:00")
        let isMaxValid = !trimmedMax.isEmpty && trimmedMax != (AppDefaults.shared.hundredthMilliSeconds ? "00:00:00" : "00:00")
        
        if random {
            if isMinValid {
                updatedDuration.min = trimmedMin
                updatedDuration.random = isMaxValid
                
                if isMaxValid {
                    updatedDuration.max = trimmedMax
                    if convertStringtoData(timeString: trimmedMin) > convertStringtoData(timeString: trimmedMax) {
                        updatedDuration.max = trimmedMin
                        updatedDuration.min = trimmedMax
                    }
                }
            } else if isMaxValid {
                if !trimmedMin.isEmpty{
                    //As If min field is 00:00 it will convert to 00:01
                    updatedDuration.min = (AppDefaults.shared.hundredthMilliSeconds ? "00:01:00" : "00:01")
                    updatedDuration.max = trimmedMax
                    updatedDuration.random = true
                }
                else{
                    updatedDuration.min = trimmedMax
                    updatedDuration.max = nil
                    updatedDuration.random = false
                }
            } else {
                updatedDuration.random = false
            }
        } else if !trimmedMin.isEmpty {
            updatedDuration.min = trimmedMin
            updatedDuration.max = nil
            updatedDuration.random = false
        }
        else{
            updatedDuration.min = nil
            updatedDuration.max = nil
            updatedDuration.random = false
        }
        return updatedDuration
    }
    
    ///
    ///Change in interval Duration ``Max, Min and Random``according to user input
    ///Empty data will not be created if item is in edit state
    ///
    func validationIntervalItemData(durationType: IntervalTimeModelData, minFieldValue: String, maxFieldValue: String, random: Bool)-> IntervalTimeModelData{
        var updatedDuration = durationType
        
        let trimmedMin = minFieldValue.trimmingCharacters(in: .whitespaces)
        let trimmedMax = maxFieldValue.trimmingCharacters(in: .whitespaces)
        
        // Helper checks for empty or "00:00"
        let isMinValid = !trimmedMin.isEmpty && trimmedMin != (AppDefaults.shared.hundredthMilliSeconds ? "00:00:00" : "00:00")
        let isMaxValid = !trimmedMax.isEmpty && trimmedMax != (AppDefaults.shared.hundredthMilliSeconds ? "00:00:00" : "00:00")
        
        if random {
            if isMinValid {
                updatedDuration.minTime = trimmedMin
                updatedDuration.random = isMaxValid
                
                if isMaxValid {
                    updatedDuration.maxTime = trimmedMax
                    if convertStringtoData(timeString: trimmedMin) > convertStringtoData(timeString: trimmedMax) {
                        updatedDuration.maxTime = trimmedMin
                        updatedDuration.minTime = trimmedMax
                    }
                }
            } else if isMaxValid {
                if !trimmedMin.isEmpty{
                    //As If min field is 00:00 it will convert to 00:01
                    updatedDuration.minTime = (AppDefaults.shared.hundredthMilliSeconds ? "00:01:00" : "00:01")
                    updatedDuration.maxTime = trimmedMax
                    updatedDuration.random = true
                }
                else{
                    updatedDuration.minTime = trimmedMax
                    updatedDuration.maxTime = nil
                    updatedDuration.random = false
                }
            } else {
                updatedDuration.random = false
            }
        }
        else if isMinValid{
            updatedDuration.minTime = trimmedMin
            updatedDuration.maxTime = nil
            updatedDuration.random = false
        }
        else{
            updatedDuration.minTime = nil
            updatedDuration.maxTime = nil
            updatedDuration.random = false
        }
        return updatedDuration
    }
    
    ///
    ///Device width font handling header text according to Client
    ///
    func handlingDeviceSizeFont()->TSize{
        if screenDeviceWidth <= 415 && screenDeviceWidth > 372 {
            return TSize.TSIZE_36
        }
        else if screenDeviceWidth < 370{
            return TSize.TSIZE_34
        }
        return TSize.TSIZE_40
    }
    
    ///
    ///Color Inputs Hexadecimal Check
    ///
    func colorInputValiadateCheck(colorString: String)-> Bool{
        if colorString.count == 7{
            if isValid6DigitHexColor(colorString) {
                return true
            }
            return false
        }
        else if colorString.count == 9{
            if isValid8DigitHexColor(colorString) {
                return true
            }
            return false
        }
        return false
    }
    
    ///Is Hex Code 6 digit is valid or not
    private func isValid6DigitHexColor(_ hex: String) -> Bool {
        let regex = "^#([A-Fa-f0-9]{6})$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: hex)
    }
    
    ///Is Hex Code 8 digit is valid or not
    private func isValid8DigitHexColor(_ hex: String) -> Bool {
        let regex = "^#([A-Fa-f0-9]{8})$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: hex)
    }

    ///
    ///BackGround Thread for Music and Text To speech to run in background
    ///
    func startBackgroundTask() {
        backgroundTaskID = UIApplication.shared.beginBackgroundTask {
            if let taskID = self.backgroundTaskID {
                UIApplication.shared.endBackgroundTask(taskID)
                self.backgroundTaskID = .invalid
            }
        }
    }
    
    ///
    ///BackGround Thread for Music and Text To speech stop in background
    ///
    func endBackgroundTask() {
        if let taskID = self.backgroundTaskID {
            UIApplication.shared.endBackgroundTask(taskID)
            backgroundTaskID = .invalid
        }
    }
    
    ///
    ///Time Conversion in String language Format
    ///
    func readableTime(from timeString: String) -> String {
        if AppDefaults.shared.hundredthMilliSeconds && timeString.count > 5{
           return readableTimeWithMilliseconds(from: timeString)
        }
            debugPrint(timeString)
            let components = timeString.split(separator: ":").compactMap { Int($0) }
            guard components.count >= 2 else {
                return "Invalid time format"
            }
            
            let minutes = components[0]
            let seconds = components[1]
            
            var readableText = ""
            
            if minutes > 0 {
                readableText += "\(minutes) minute\(minutes > 1 ? "s" : "")"
            }
            if seconds > 0 {
                if !readableText.isEmpty {
                    readableText += " and "
                }
                readableText += "\(seconds) second\(seconds > 1 ? "s" : "")"
            }
            
            return readableText.isEmpty ? "0 seconds" : readableText
    }
    
    // Handling Milliseconds
    func readableTimeWithMilliseconds(from timeString: String) -> String {
        debugPrint(timeString)
        let components = timeString.split(separator: ":").compactMap { Int($0) }
        
        guard components.count == 3 else {
            return "Invalid time format"
        }

        let minutes = components[0]
        let seconds = components[1]
        let milliseconds = components[2]

        var readableText = ""

        if minutes > 0 {
            readableText += "\(minutes) minute\(minutes > 1 ? "s" : "")"
        }

        let totalSeconds = Double(seconds) + Double(milliseconds) / 100.0
           let whole = Int(totalSeconds)
           let decimalPart = Int((totalSeconds - Double(whole)) * 100)
           let spelledDecimal = "\(decimalPart / 10) \(decimalPart % 10)"
           let secondsText = "\(whole) point \(spelledDecimal)"

        
        if totalSeconds > 0 {
            if !readableText.isEmpty {
                readableText += " and "
            }
            readableText += "\(secondsText) second\(totalSeconds != 1 ? "s" : "")"
        }

        return readableText.isEmpty ? "0 seconds" : readableText
//            .replacingOccurrences(of: ".", with: "point")
    }
    

    
    ///
    ///Handling MilliSeconds according to the switch
    ///
    func handlingMilliseconds(timeString: String?) -> String {
        guard var timeString = timeString else {
            return ""
        }
        
        if AppDefaults.shared.hundredthMilliSeconds {
            if timeString.count == 5 {
                timeString.append(":00")
            }
        } else {
            if timeString.count == 8 {
                timeString.removeLast(3) // Remove `:XX` (2 digits + colon)
            }
        }
        
        return timeString
    }
    
    ///Same code handling for hours also
    func handlingHoursMilliseconds(timeString: String?)-> String{
        guard var timeString = timeString else{return "00:00:00:00"}
        if AppDefaults.shared.hundredthMilliSeconds {
            if timeString.count == 8 {
                timeString.append(":00")
            }
        } else {
            if timeString.count == 11 {
                timeString.removeLast(3) // Remove `:XX` (2 digits + colon)
            }
        }
        
        return timeString
    }

}
