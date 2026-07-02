//
//  MessageVM.swift
//  TIMER
//
//  Created by Aditya Maroo on 09/09/24.
//

import Foundation
import CoreData
import Combine
import SwiftUI

class MessageViewVM: ObservableObject{
    
    //MARK: -
    //MARK: PUBLISHED PROPERTIES
    @Published var delay: String = ""
    @Published var messageName: String = ""
    @Published var shouldShowValidationError:Bool = false
    @Published var validationErrorMessage:String = ""
    
    //MARK: -
    //MARK: PROPERTIES
    var messageItem:MessageItems?
    
    
    func addMessageData()-> MessageItems{
        let messageData = MessageItem.shared.addMessageItems(delay: delay, messageName: messageName)
        return messageData
    }

    ///
    /// UPDATE MESSAGE
    /// IN CASE OF ADD & EDIT
    /// MESSAGEITEM WILL BE UPDATE FROM SAME METHOD
    ///
    func updateMessage(){
            messageItem?.messageName = messageName
            messageItem?.delay = delay
            CoreDataManager.shared.saveContext()        
    }
    ///
    ///VALIDATE MESSAGE INPUTS
    ///
    func validateMessageInput()->Bool{
        guard messageName.trimmingCharacters(in: .whitespaces) != "" else{
//            shouldShowValidationError = true
//            validationErrorMessage = "Please make sure Message field name can not be empty, please re-update your details"
            return false
        }

        guard delay.trimmingCharacters(in: .whitespaces) != "" else{
//            shouldShowValidationError = true
//            validationErrorMessage = "Please make sure Delay field can not be empty, please update the details"
            return false
        }
        return true
    }
    ///
    ///DELETE MESSAGE NSMANAGEDOBJECT
    ///
    func deleteMessage(){
        guard let messageItem else{debugPrint("Message item is nil, while attempting to delete message");return}
        CoreDataManager.shared.context.delete(messageItem)
        CoreDataManager.shared.saveContext()
    }
    
    /// Min seconds coversion
    
    public func reformatAsTimeMin(_ value: String) {
        let timeSeparator = ":"
           var cleanString = value.replacingOccurrences(of: timeSeparator, with: "")
           
           var minutesText = ""
           var secondsText = ""
           
           switch cleanString.count {
           case 1:
               // If only one digit, treat as 00:0X
               
               minutesText = "00"
               secondsText = "0\(cleanString)"
               
           case 2:
               // If two digits, treat as 00:XX
               minutesText = "00"
               secondsText = cleanString
               
           case 3:
               // If three digits, treat as 0X:XX
               minutesText = "0\(cleanString.prefix(1))"
               secondsText = String(cleanString.suffix(2))
               
           default:
               // If four or more digits, remove the first digit to fit MM:SS format
               if cleanString.prefix(1) == "0"{
                   cleanString = String(cleanString.suffix(4))
                   minutesText = String(cleanString.prefix(2))
                   secondsText = String(cleanString.suffix(2))
               }
               else{
                   cleanString = String(cleanString.prefix(4))
                   minutesText = String(cleanString.prefix(2))
                   secondsText = String(cleanString.suffix(2))
               }
           }
           
           // Update the formatted time
        if cleanString.count > 0 {
            delay = "\(minutesText)\(timeSeparator)\(secondsText)"
        }
           
           // Remove unnecessary leading zeros if the user backspaces
           if cleanString == "0" || cleanString == "00" || cleanString == "000" {
               if cleanString.count == 3{
                   cleanString = "00:0"
                 
               }
               else if cleanString.count == 2{
                   cleanString = "00"
               }
               else if cleanString.count == 1{
                   cleanString = "0"
               }
               else{
                   cleanString = ""
               }
               delay = cleanString
           }
       }
    
    ///
    /// MilliSeconds handling converSion
    ///
     public func reformatAsTimeMinForMilliseconds(_ value: String) {
         let timeSeparator = ":"
         var cleanString = value.replacingOccurrences(of: timeSeparator, with: "")
         
         var minutesText = ""
         var secondsText = ""
         var milliSecondsText = ""

 //        let length = cleanString.count
     
         switch cleanString.count {
         case 1:
             minutesText = "00"
             secondsText = "00"
             milliSecondsText = "0\(cleanString)"
             
         case 2:
             minutesText = "00"
             secondsText = "00"
             milliSecondsText = cleanString
             
         case 3:
             minutesText = "00"
             secondsText = "0\(cleanString.prefix(1))"
             milliSecondsText = String(cleanString.suffix(2))
             
         case 4:
             minutesText = "00"
             secondsText = String(cleanString.prefix(2))
             milliSecondsText = String(cleanString.suffix(2))
             
         case 5:
             minutesText = "0\(cleanString.prefix(1))"
             secondsText = String(cleanString.dropFirst(1).prefix(2))
             milliSecondsText = String(cleanString.suffix(2))
             
         default:
             if cleanString.prefix(1) == "0"{
                 cleanString = String(cleanString.suffix(6))
                 minutesText = String(cleanString.prefix(2))
                 secondsText = String(cleanString.dropFirst(2).prefix(2))
                 milliSecondsText = String(cleanString.suffix(2))
             }
             else{
                 cleanString = String(cleanString.prefix(6))
                 minutesText = String(cleanString.prefix(2))
                 secondsText = String(cleanString.dropFirst(2).prefix(2))
                 milliSecondsText = String(cleanString.suffix(2))
             }
         }

         // Final formatted result
         if cleanString.count > 0{
             delay = "\(minutesText)\(timeSeparator)\(secondsText)\(timeSeparator)\(milliSecondsText)"
         }

         // Handle if only zero is typed
         if cleanString == "0" || cleanString == "00" || cleanString == "000" || cleanString == "0000" || cleanString == "00000" {
             if cleanString.count == 5{
                 cleanString = "00:00:0"
             }
             else if cleanString.count == 4{
                 cleanString = "00:00"
             }
             else if cleanString.count == 3{
                 cleanString = "00:0"
               
             }
             else if cleanString.count == 2{
                 cleanString = "00"
             }
             else if cleanString.count == 1{
                 cleanString = "0"
             }
             else{
                 cleanString = ""
             }
             delay = cleanString
         }
     }

    
    
    func changeDelayValueOnDissmiss(){
        delay = formatTime(minTime: delay)
    }
}

