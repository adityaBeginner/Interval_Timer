//
//  IntervalCreationVM.swift
//  TIMER
//
//  Created by Aditya Maroo on 09/09/24.
//

import Foundation
import CoreData
import Combine
import SwiftUI

class IntervalCreationVM: ObservableObject{
    //MARK: -
    //MARK: - PUBLISHED PROPERTIES
    @Published var coloropacity: Double = 1.0
    @Published var intervalDurationMaxTime: String = ""
    @Published var intervalDurationMinTime: String = ""
    @Published var intervalDurationRandom: Bool = false
    @Published var intervalName: String = ""
    @Published var intervalColour: String = Color(uiColor: .defaultFolderTimerReactionColor).toHex()
    @Published var intervalHalfWayAlert: Bool = false
    @Published var intervalMessage: [MessageItems] = []
    var colorObject: ColorObject?
    @Published var shouldShowValidationError:Bool = false
    @Published var validationMessage: String = "The file have missing field. \nPlease check that there is no empty field:"
    @Published var textFieldType: TextFieldType?
    @Published var minMaxType: MinMaxTime?
    @Published var alertTimePopScreen: Bool = false
    @Published var textDescriptionBox: [String] = ["CallName", "CallDuration", "HalfwayAlert", "Missng Message"]
    @Published var alertHeader: String = "ERROR: MISSING FIELDS"
    
    ///Selected Message Item
    @Published var selectedMessages: [MessageItems] = []
    
    /// Toast Componets hiding and unhiding
    @Published var isToastHidden: Bool = false
    @Published var toastTitleName: String = ""
    
    /// Slide animation of delete functionality
    @Published var slideListAnimation: Bool = false
    
    //is Footer Edit hide Button
    @Published var isFooterEdit: Bool = false
    
    //Delete pop
    @Published var isDeletePop: Bool = false
    
    //Navigate to Other Screen
    @Published var isNewEdit: Bool = false
    
    //State change for selected value
    @Published var stateChange: TimerReactionMessageState = .Edit
    
    //Saving item on color navigation in edit state
    @Published var colorNavigate: Bool = false
    
    //Scroll to last
    @Published var isScrollDown: Bool = false
    
    //Blur Effect
    @Published var blurEffectPresent: Bool = false
    
    //Messge is Created
    @Published var isMessageCreated: Bool = false
    
    //MARK: -
    //MARK: - PROPERTIES
    var isMessageEdit: Bool = false
    var messageData: MessageItems?
    var intervalItem:IntervalItem?
    //MARK: -
    //MARK: - ADD INTERVAL
    ///
    ///This function update message item in a default inetrvalList or edited intervalList
    ///

    
    // MARK: - VALIDATION
   func validateInputs() -> Bool {
//        shouldShowValidationError = false
   

        // Validate interval name
        guard !intervalName.isEmpty else {
//            shouldShowValidationError = true
            return false
        }

//         Validate duration times
       guard validationRandom(minTime: intervalDurationMinTime, maxTime: intervalDurationMaxTime, random: intervalDurationRandom) else{
//                shouldShowValidationError = true
                return false
        }

        return true
    }
    ///
    ///Validation for interval Duration of max and min field
    ///
    func validationRandom(minTime: String, maxTime: String, random: Bool)-> Bool{
        if random{
            if  minTime.trimmingCharacters(in: .whitespaces) != "" {
                return true
            }
             else if maxTime.trimmingCharacters(in: .whitespaces) != "" {
                return true
            }
//            guard convertStringtoData(timeString: minTime) < convertStringtoData(timeString: maxTime) else{
//                alertHeader = "Error: Max time"
//                validationMessage = "The max time field value is less than min time field value. Please make sure max time field will be greater than min time field./nChange the time in min or max time field "
//                textDescriptionBox = []
//                return false
//            }
        }
        else if minTime.trimmingCharacters(in: .whitespaces) != "" {
            return true
        }
        return false
    }
    
    func addOrUpdateInterval(){
        changingValueBreakField(textFieldType: .IntervalDuration)
        guard let intervalItem = intervalItem else{return}
        let intervalDuration = intervalItem.intervalDuration == nil ? ItemDurationInterval.shared.addIntervalDuration() : intervalItem.intervalDuration
        intervalItem.intervalDuration = AppComman.shared.validationIntervalData(durationType: intervalDuration ?? IntervalDuration(), minFieldValue: intervalDurationMinTime, maxFieldValue: intervalDurationMaxTime, random: intervalDurationRandom)
        
        intervalItem.halfWayAlert = intervalHalfWayAlert
        intervalItem.intervalName = intervalName
        ///if this line is needed in ``` add function ``` add intervalMessage a data
        ///intervalItem.messageItems = NSSet(array: intervalMessage)
        intervalItem.intervalCall = nil
        
        ///save interval
        CoreDataManager.shared.saveContext()
        
    }
    
    ///
    ///CREATE MESSAGE OBJECT
    ///
    func createMessageObject(){
       messageData = MessageItems(context: CoreDataManager.shared.context)
        messageData?.indexValue = Int64(intervalMessage.count)
       addMessage()
    }
    
    ///
    ///CREATE MESSAGE OBJECT
    ///
    func createColorObject(){
        colorObject = ColorObject(context: CoreDataManager.shared.context)
        colorObject?.colorHexCode = Color(.defaultFolderTimerReactionColor).toHex()
        colorObject?.colorRgbX = 16
        colorObject?.colorRgbY = 12
        colorObject?.colorOpacityX = UIScreen.main.bounds.size.width - 48
        colorObject?.colorOpacityY = 13
        colorObject?.colorShadesX = UIScreen.main.bounds.size.width - 40
        colorObject?.colorShadesY = 8
        colorObject?.alphaValue = coloropacity
        intervalColour = colorObject?.colorHexCode ?? Color(.defaultFolderTimerReactionColor).toHex()
        intervalItem?.colorObject = colorObject
        CoreDataManager.shared.saveContext()
    }

    ///
    /// ADD MESSAGE OBJECT
    /// IN INTERVAL NSMANAGEDOBJECT
    ///
    private func addMessage(){
        guard let intervalItem else {debugPrint("Interval item is nil while add message"); return}
        guard let messageData else {debugPrint("Message is nil while addMessage");return}
         var array:[MessageItems] = []
         if let setMessages = intervalItem.messageItems{
             for obj in setMessages{
                 if let message = obj as? MessageItems{
                     array.append(message)
                 }
             }
                 array.append(messageData)
         }else{
                 array.append(messageData)
         }
//        intervalMessage = array
         intervalItem.messageItems = NSSet(array: array)
         CoreDataManager.shared.saveContext()
    }
 
    ///
    /// DELETE INTERVAL OBJECT
    ///
    func deleteIntervalItem(intervalItem:IntervalItem){
        CoreDataManager.shared.deleteNSManagedObject(object: intervalItem)
        CoreDataManager.shared.saveContext()
    }
    
    func indexUpdate(indices: IndexSet, newOffset: Int, items: IntervalItem){
        intervalMessage.move(fromOffsets: indices, toOffset: newOffset)
        for (index, _) in intervalMessage.enumerated() {
            intervalMessage[index].indexValue = Int64(index)
           
        }
        ///
        ///If item object is present then only it will be save otherwise object wiil be created for item
        ///
        if items != nil {
            items.messageItems = NSSet(array: intervalMessage)
            CoreDataManager.shared.saveContext()
        }
    }
    
    ///
    /// remove selected item
    ///
    func removeSelectedItem(messageItem: MessageItems){
        let removeData = selectedMessages.filter{ $0 != messageItem}
        selectedMessages = removeData
    }
    
    ///
    /// DELETE MESSAGES
    ///
    func deleteSelectedMessages(){
        for message in selectedMessages {
            CoreDataManager.shared.deleteNSManagedObject(object: message)
            intervalMessage.removeAll(where: {$0.id == message.id})
        }
        for index in 0..<intervalMessage.count{
            intervalMessage[index].indexValue = Int64(index)
        }
        CoreDataManager.shared.saveContext()
    }
    
    ///
    ///DELETE SINGLE ITEM
    ///
    func deleteSingleMessage(indexSet: IndexSet){
        for index in indexSet{
            CoreDataManager.shared.deleteNSManagedObject(object: intervalMessage.remove(at: index))
        }
        for index in 0..<intervalMessage.count{
            intervalMessage[index].indexValue = Int64(index)
        }
        CoreDataManager.shared.saveContext()
    }
    
    ///
    ///Display toast view with animation
    ///
    func displayToast(){
        withAnimation{
            isToastHidden = true
        }
    }
    
    ///
    ///func isSelected in intervalList false
    ///
    func changeValueSelected(){
        intervalMessage.forEach { messageItem in
               messageItem.isSelected = false
           }
    }
    
    ///
    ///Validation of timer in minutes and seconds
    ///
    func changingValueBreakField(textFieldType: TextFieldType) {
        switch textFieldType {
        case .IntervalDuration:
            intervalDurationMinTime = formatTime(minTime: intervalDurationMinTime)
            if intervalDurationRandom{
                intervalDurationMaxTime = formatTime(minTime: intervalDurationMaxTime)
            }
            break
        case .RestBetweenInterval:
           
            break
        case .RestBetweenRounds:
          
            break
        case .SessionLastTime:
            break
        }
    }
    
    //Filter for func for message delay
    func delayFilter(){
        intervalMessage.sort{convertStringToMilliseconds(timeString: $0.delay) < convertStringToMilliseconds(timeString: $1.delay)}
    }
    
    /// Converts a time string in "MM:SS" or "MM:SS:MS" format to milliseconds.
    func convertStringToMilliseconds(timeString: String?) -> Int {
        guard let timeString = timeString, !timeString.isEmpty else {
            return 0
        }
        
        let timeComponents = timeString.split(separator: ":").map { Int($0) ?? 0 }
        
        guard timeComponents.count >= 2 else {
            return 0
        }
        
        let minutes = timeComponents[0]
        let seconds = timeComponents[1]
        let milliseconds = timeComponents.count > 2 ? timeComponents[2] : 0
        
        return ((minutes * 60 + seconds) * 1000) + (milliseconds * 10)
    }
}
