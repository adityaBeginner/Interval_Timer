//
//  EditOperations.swift
//  TIMER
//
//  Created by Aditya Maroo on 30/09/24.
//

import SwiftUI
import CoreData
class EditOperations{
    
    enum EditEntityType{
        case drilInterval
        case timerInterval
        case timerMessage
        case item
        case non
    }
    
    
    static private var shared:EditOperations{
        return EditOperations()
    }
    private init(){}
    
    
    ///
    //MARK: -
    //MARK: STATIC PROPERTIES
    static private var copiedItem:[NSManagedObject] = []
    static public var editEntityType:EditEntityType = .non
    static private var shouldDeleteAfterPaste:Bool = false
    static private var multiplePasteItem: [NSManagedObject] = []
    static private var parentCutItem: Item?
    ///
    ///THIS VAR WILL BE USED TO REMOVE RELATIONSHIP
    ///IN CASE OF ``CUT`` OPERATION
    ///
    static private var selectedEntities:[NSManagedObject]?
    
    ///
    /// CUT ENTITY
    /// SAVE ``selectedEntities``
    /// SO ``selectedEntities`` CAN BE REMOVE AFTER PASTE OPERATION
    ///
    static func cutEntity(selectedItems: [NSManagedObject], entityType:EditEntityType){
        shouldDeleteAfterPaste = true
        selectedEntities = selectedItems
        editEntityType = entityType
        copyEntity(selectedItems: selectedItems, entityType: entityType)
    }
    ///
    /// COPY SELECTED ENTITIES
    ///
    ///
    static func copyEntity(selectedItems: [NSManagedObject], entityType:EditEntityType){
        debugPrint("Start time",Date.now)
//        debugPrint(multiplePasteItem.count)
        // MARK: - Optimization: Background Handling for Cut/Copy/Paste

        /*
         This section handles cut/copy/paste operations which can involve deleting previous copied items
         and their associated intervals.

         ⚠️ Important Notes:
         - This action may need to process over 200,000 interval entries.
         - For performance reasons, this should be executed in the background to avoid blocking the main thread.
         - Consider batching updates or using background contexts (if using Core Data) to handle data efficiently.
         - Ensure previous data is cleared before inserting new content to prevent memory bloat or data inconsistency.

         🛠️ Optimization Suggestion:
         - Wrap this logic inside `DispatchQueue.global(qos: .userInitiated).async { ... }`
         - Then dispatch back to main queue only when UI needs to be updated.
        */
        CoreDataManager.shared.removeAllCopyItems()
        debugPrint("End time",Date.now)
//        debugPrint(multiplePasteItem.count)
        copiedItem = []
        multiplePasteItem = []
        switch entityType {
        case .drilInterval, .timerInterval:
            
            editEntityType = selectedItems.isEmpty ? .non : entityType
            ///
            /// CREATE COPY OF IntervalItem OR DrillItem
            ///
//            for child in selectedItems{
//                guard let interval = child as? IntervalItem else{debugPrint("Failed to copy interval of type drill-interval");return}
//                let drillInterval = IntervalItem(context: CoreDataManager.shared.context)
//                drillInterval.intervalName = interval.intervalName
//                drillInterval.colorObject = shared.getCopiedObjectOfColor(colorObject: interval.colorObject)
//                drillInterval.intervalDuration = shared.getCopyOfIntervalDurationObject(intervalDuration: interval.intervalDuration)
//                drillInterval.intervalCall = shared.getCopyOfIntervalCallObject(intervalCall: interval.intervalCall)
//                drillInterval.halfWayAlert = interval.halfWayAlert
//                drillInterval.messageItems = NSSet(array: shared.getCopyOfMessageObject(messageItems: interval.messageItems?.allObjects as? [MessageItems]) ?? [])
//                
//                copiedItem.append(drillInterval)
//            }
            multiplePasteItem = shared.getCopyOfIntervls(intervals: selectedItems as? [IntervalItem], isDataCopy: true) as? [NSManagedObject] ?? []
            
        case .timerMessage:
            editEntityType = selectedItems.isEmpty ? .non : entityType
            ///
            /// CREATE COPY OF Messages
            ///            editEntityType = entityType
            multiplePasteItem = shared.getCopyOfMessageObject(messageItems: selectedItems as? [MessageItems], isDataCopy: true) as? [NSManagedObject] ?? []
//            multiplePasteItem = copiedItem
        case .item:
            editEntityType = selectedItems.isEmpty ? .non : entityType
            multiplePasteItem = shared.getCopyOfItemObject(items: selectedItems as? [Item], isDataCopy: true, isChildValue: false) as? [NSManagedObject] ?? []
            //            multipleCopyItems = shared.getCopyOfItemObject(items: selectedItems as? [Item])  ?? []
//            multiplePasteItem = copiedItem
//            deleteMultiplePasteItem()
        case .non:
            editEntityType = entityType
            debugPrint("EdityEntityType is non in EditOperations")
            break
        }
    }
    
    ///
    ///Multiple Paste Handling
    ///
//    static private func multiplePasteObject(){
//        copiedItem = []
//        switch editEntityType {
//        case .drilInterval, .timerInterval:
//            break
//            ///
//            /// CREATE COPY OF IntervalItem OR DrillItem
//            ///
////            for child in multiplePasteItem{
////                guard let interval = child as? IntervalItem else{debugPrint("Failed to copy interval of type drill-interval");return}
////                let drillInterval = IntervalItem(context: CoreDataManager.shared.context)
////                drillInterval.intervalName = interval.intervalName
////                drillInterval.colorObject = shared.getCopiedObjectOfColor(colorObject: interval.colorObject)
////                drillInterval.intervalDuration = shared.getCopyOfIntervalDurationObject(intervalDuration: interval.intervalDuration)
////                drillInterval.intervalCall = shared.getCopyOfIntervalCallObject(intervalCall: interval.intervalCall)
////                drillInterval.halfWayAlert = interval.halfWayAlert
////                drillInterval.messageItems = NSSet(array: shared.getCopyOfMessageObject(messageItems: interval.messageItems?.allObjects as? [MessageItems]) ?? [])
////                
////                
////                copiedItem.append(drillInterval)
////            }
//            
//        case .timerMessage:
//            
//            ///
//            /// CREATE COPY OF Messages
//            ///            editEntityType = entityType
//            copiedItem = shared.getCopyOfMessageObject(messageItems: multiplePasteItem as? [MessageItems]) as? [NSManagedObject] ?? []
//        case .item:
//            let items = multiplePasteItem as? [Item]
//            copiedItem = shared.getCopyOfItemObject(items: items ?? []) as? [NSManagedObject] ?? []
//        case .non:
//            debugPrint("EdityEntityType is non in EditOperations")
//            break
//        }
//    }
//    
    
    ///
    ///MANAGE 'PASTE' OPERATION, OF TYPE: TIMER-INTERVAL & DRILL-INTERVAL
    ///
    static func pasteTimerDrillInterval(inObject: Item?, lastItemIndex: Int64 = 0){
        
        //        copyEntity(selectedItems: copiedItem, entityType: editEntityType)
        copiedItem = shared.getCopyOfIntervls(intervals: multiplePasteItem as? [IntervalItem], isDataCopy: false) as? [NSManagedObject] ?? []
        guard let item = inObject else{debugPrint("item is nil when paste in timer interval"); return}
        if shouldDeleteAfterPaste{
            removeIntervalEntity()
        }
        let totalCount = item.intervalItem?.count ?? 0
        if lastItemIndex > totalCount{
            var newIntervals = item.intervalItem?.allObjects as? [IntervalItem] ?? []
            newIntervals.sort{$0.indexValue < $1.indexValue}
            for index in 0..<totalCount{
                newIntervals[index].indexValue = Int64(index)
            }
            debugPrint(newIntervals)
            item.intervalItem = NSSet(array: newIntervals)
        }
        let intervalItems = indexChange(count: totalCount)
        var allIntervals = (item.intervalItem?.allObjects as? [IntervalItem]) ?? []
        allIntervals = ((allIntervals as [NSManagedObject]) + intervalItems) as? [IntervalItem] ?? []
        item.intervalItem = NSSet(array: allIntervals)
        CoreDataManager.shared.saveContext()
        
        changeValuetoDefault()
    }
    
    ///
    ///MANAGE 'PASTE' OPERATION, OF TYPE: ITEM
    ///
    static func pasteItem(inObject: Item?, count: Int?){
        //        copyEntity(selectedItems: copiedItem, entityType: editEntityType)
       
        guard let item = inObject else{
            copiedItem = shared.getCopyOfItemObject(items: multiplePasteItem as? [Item], isDataCopy: false, isChildValue: false) as? [NSManagedObject] ?? []
            debugPrint(copiedItem.count)
            debugPrint("item is nil, it means copied item are pasted in Workout View");
            ///
            /// THIS CODE WILL PASTE SELECTED ITEMS
            /// IN ROOT DIRECTORY
            ///
            if shouldDeleteAfterPaste{
                removeEntities()
            }
            let allItem = indexItemChange(count: count ?? 0)
            
            for item_ in (allItem){
                
                item_.isChild = false
            }
            
            CoreDataManager.shared.saveContext()
            changeValuetoDefault()
            return
        }
        
        ///
        /// IF SELECTED ITEM ARE PASTED IN
        /// FOLDER
        ///
        
        
        if let type = item.type, type == "Folder"{
            copiedItem = shared.getCopyOfItemObject(items: multiplePasteItem as? [Item], isDataCopy: false, isChildValue: true) as? [NSManagedObject] ?? []
            if shouldDeleteAfterPaste{
//                removeChildRelation()
                removeEntities()
            }
            var allItems = item.children?.allObjects as? [Item]
            let newCopyItem = indexItemChange(count: count ?? 0)
            
            allItems = (allItems ?? []) + (newCopyItem)
          allItems?.forEach{ obj in
                obj.isChild = true
                
            }
            item.children = NSSet(array: allItems ?? [])
            CoreDataManager.shared.saveContext()
        }
        
        changeValuetoDefault()
        
    }
    
    ///
    /// PASTE MESSAGE IN
    /// ``IntervalItems`` TYPE ENTITY
    ///
    static func pasteMessageInTimerInterval(inObject: IntervalItem?){
        //        copyEntity(selectedItems: copiedItem, entityType: editEntityType)
//        multiplePasteObject()
        copiedItem = shared.getCopyOfMessageObject(messageItems: multiplePasteItem as? [MessageItems], isDataCopy: false) as? [NSManagedObject] ?? []
        debugPrint("Message Count",copiedItem.count)
        guard let intervalItem = inObject else{debugPrint("IntervalItem is nil while performing paste message operation"); return}
        if shouldDeleteAfterPaste{
            removeIntervalEntity()
        }
        let messageItem = indexMessageChange(count: intervalItem.messageItems?.count ?? 0)
        debugPrint(messageItem.count)
        var allMessages = intervalItem.messageItems?.allObjects as? [MessageItems] ?? []
        debugPrint(allMessages)
        allMessages = ((allMessages as [NSManagedObject]) + messageItem) as? [MessageItems] ?? []
        debugPrint("All Messges", allMessages.count)
        intervalItem.messageItems = NSSet(array: allMessages)
        CoreDataManager.shared.saveContext()
        
        changeValuetoDefault()
    }
    
    //MARK: -
    //MARK: PRIVATE METHODS
    ///
    ///GET COPIED OBJECT OF COLOR
    ///
    private func getCopiedObjectOfColor(colorObject: ColorObject?, isDataCopy: Bool) -> ColorObject? {
        
        let newCopy = ColorObject(context: CoreDataManager.shared.context)
        
        guard let colorObject else{debugPrint("color object is nil in Edit-Operations"); return nil}
        
        // Copy each property
        newCopy.alphaValue = colorObject.alphaValue
        newCopy.colorHexCode = colorObject.colorHexCode
        newCopy.colorOpacityX = colorObject.colorOpacityX
        newCopy.colorOpacityY = colorObject.colorOpacityY
        newCopy.colorRgbX = colorObject.colorRgbX
        newCopy.colorRgbY = colorObject.colorRgbY
        newCopy.colorShadesX = colorObject.colorShadesX
        newCopy.colorShadesY = colorObject.colorShadesY
        newCopy.isItemCopied = isDataCopy
        return newCopy
    }
    
    ///
    ///GET COPIED OBJECT OF INTERVAL CALL
    ///
    private func getCopyOfIntervalCallObject(intervalCall: IntervalCalls?, isDataCopy: Bool) -> IntervalCalls? {
        
        let newCopy = IntervalCalls(context: CoreDataManager.shared.context)
        
        guard let intervalCall else{debugPrint("intervalCall is nil while getting copy of intervall call in EditOperation"); return nil}
        
        // Copy properties
        newCopy.averageNumber = intervalCall.averageNumber
        newCopy.maxNumber = intervalCall.maxNumber
        newCopy.random = intervalCall.random
        //        newCopy.inetrvalItem = intervalCall.inetrvalItem
        newCopy.isItemCopied = isDataCopy
        return newCopy
    }
    
    ///
    ///GET COPIED OBJECT OF INTERVAL
    ///
    private func getCopyOfIntervls(intervals: [IntervalItem]?, isDataCopy: Bool) -> [IntervalItem?]? {
        
        var copiedIntervals:[IntervalItem] = []
        guard let intervals = intervals else{
            return []
        }
        for interval in intervals  {
            let newCopy = IntervalItem(context: CoreDataManager.shared.context)
            
            // Copy individual properties
            newCopy.halfWayAlert = interval.halfWayAlert
            newCopy.indexValue = interval.indexValue
            newCopy.intervalName = interval.intervalName
            newCopy.isSelected = interval.isSelected
            newCopy.colorObject = getCopiedObjectOfColor(colorObject: interval.colorObject, isDataCopy: isDataCopy)
            newCopy.intervalCall = getCopyOfIntervalCallObject(intervalCall: interval.intervalCall, isDataCopy: isDataCopy)
            newCopy.intervalDuration = getCopyOfIntervalDurationObject(intervalDuration: interval.intervalDuration, isDataCopy: isDataCopy)
            newCopy.isItemCopied = isDataCopy
//            newCopy.item = interval.item
            newCopy.isSelected = false
            // Copy related message items
            if let messages = getCopyOfMessageObject(messageItems: interval.messageItems?.allObjects as? [MessageItems], isDataCopy: isDataCopy)?.compactMap({ $0 }) {
                newCopy.messageItems = NSSet(array: messages)
            }
            
            ///update other values from the interval to new copy here
            ///
            copiedIntervals.append(newCopy)
        }
        
        return copiedIntervals
    }
    
    
    ///
    ///GET COPIED OBJECT OF INTERVAL DURATION
    ///
    private func getCopyOfIntervalDurationObject(intervalDuration: IntervalDuration?, isDataCopy: Bool) -> IntervalDuration? {
        
        let newCopy = IntervalDuration(context: CoreDataManager.shared.context)
        
        guard let intervalDuration else{debugPrint("intervalCall is nil while getting copy of intervalDuration call in EditOperation"); return nil}
        
        // Copy properties
        newCopy.max = intervalDuration.max
        newCopy.min = intervalDuration.min
        newCopy.random = intervalDuration.random
        newCopy.restTime = intervalDuration.restTime
        newCopy.isItemCopied = isDataCopy
        return newCopy
    }
    
    ///
    ///GET COPIED OBJECTS OF REST BETWEEN INTERVALS
    ///
    private func getCopyOfRestBetweenRoundsObject(restBetweenInterval: RestBetweenRounds?, isDataCopy: Bool) -> RestBetweenRounds? {
        
        let newCopy = RestBetweenRounds(context: CoreDataManager.shared.context)
        
        guard let restBetweenInterval else{debugPrint("intervalCall is nil while getting copy of intervalDuration call in EditOperation"); return nil}
        
        // Copy properties
        newCopy.max = restBetweenInterval.max
        newCopy.min = restBetweenInterval.min
        newCopy.random = restBetweenInterval.random
        newCopy.restTime = restBetweenInterval.restTime
        newCopy.rounds = restBetweenInterval.rounds
        newCopy.isItemCopied = isDataCopy
        
        return newCopy
    }
    
    ///
    ///GET COPIED OBJECT OF MESSAGE
    ///
    private func getCopyOfMessageObject(messageItems: [MessageItems?]?, isDataCopy: Bool) -> [MessageItems?]? {
        
        guard let messageItems else{debugPrint("messageItem is nil while getting copy of messageItem call in EditOperation"); return nil}
        
        // Copy properties
        var index:Int64 = 0
        var arrayOfMessages:[MessageItems] = []
        for messageItem in messageItems {
            let newCopy = MessageItems(context: CoreDataManager.shared.context)
            newCopy.delay = messageItem?.delay
            newCopy.indexValue = index
            newCopy.messageName = messageItem?.messageName
            newCopy.isItemCopied = isDataCopy
            newCopy.isSelected = false
            //            newCopy.messages = messageItem?.messages
            arrayOfMessages.append(newCopy)
            index += index
        }
//        debugPrint("Messge Count on Copy",arrayOfMessages.count)
        return arrayOfMessages
    }
    
    ///
    ///Creating new setting object for copy and cut
    ///
    private func getCopyOfSettingObject(setting: Settings?, isDataCopy: Bool)-> Settings?{
        let newCopy = Settings(context: CoreDataManager.shared.context)
        guard let setting else{
            debugPrint("Setting object is not creating")
            return nil
        }
        newCopy.audio = setting.audio
        newCopy.isNoAudio = setting.isNoAudio
        newCopy.isTextToSpeech = setting.isTextToSpeech
        newCopy.isVibration = setting.isVibration
        newCopy.textToSpeech = setting.textToSpeech
        newCopy.vibration = setting.vibration
        newCopy.isItemCopied = isDataCopy
        return newCopy
    }
    
    ///
    ///GET COPIED OBJECT OF Items
    ///
    private func getCopyOfItemObject(items: [Item?]?, isDataCopy: Bool, isChildValue: Bool = false) -> [Item?]? {
        var copiedItems: [Item] = []
        var index: Int64 = 0
        guard let items else{
            return nil
        }
        for item in items {
            guard let item = item else { continue }  // Safely unwrap optional items
            let newCopy = Item(context: CoreDataManager.shared.context)
            // Copy basic properties
            newCopy.alertSong = item.alertSong
            newCopy.indexValue = index
            newCopy.isChild = isChildValue
            newCopy.session = item.session
            newCopy.shuffle = item.shuffle
            newCopy.title = item.title
            newCopy.type = item.type
            newCopy.viibrateAlert = item.viibrateAlert
            newCopy.isItemCopied = isDataCopy
            newCopy.isSelected = false
            
            // Copy relationships (optional)
            newCopy.setting = getCopyOfSettingObject(setting: item.setting, isDataCopy: isDataCopy)
            newCopy.colorObject = getCopiedObjectOfColor(colorObject: item.colorObject, isDataCopy: isDataCopy)
            newCopy.intervalDuration = getCopyOfIntervalDurationObject(intervalDuration: item.intervalDuration, isDataCopy: isDataCopy)
            newCopy.restBetweenInterval = getCopyOfIntervalDurationObject(intervalDuration: item.restBetweenInterval, isDataCopy: isDataCopy)
            newCopy.restBetweenRounds = getCopyOfRestBetweenRoundsObject(restBetweenInterval:  item.restBetweenRounds, isDataCopy: isDataCopy)
            newCopy.intervalItem = NSSet(array: (getCopyOfIntervls(intervals: item.intervalItem?.allObjects as? [IntervalItem], isDataCopy: isDataCopy) ?? []))
            if item.children?.count ?? 0 > 0 {
                if let childrenItems = getCopyOfItemObject(items: item.children?.allObjects as? [Item], isDataCopy: isDataCopy,isChildValue: true)?.compactMap({ $0 }){
                    newCopy.children = NSSet(array: childrenItems)
                }
            }
//            newCopy.toFolderItems = item.toFolderItems
            
            // Append new copy to the array
            copiedItems.append(newCopy)
            
            index += 1
        }
        debugPrint(copiedItems.count)
        return copiedItems
    }
    
    
    static private func changeValuetoDefault(){
        //       editEntityType = .non
        //       copiedItem = []
    }
    ///
    /// neccesay for index change handling on viewmodel of timer and reaction pasteindec xhnage
    ///
    static private func indexChange(count: Int) -> [IntervalItem] {
        var changeIndexData: [IntervalItem] = []
        var indexValue = 0
        guard let data = copiedItem as? [IntervalItem] else { return [] }
       
        
        for item in data {
            item.indexValue = Int64(indexValue + count)
            indexValue += 1
            changeIndexData.append(item)
        }
        
//        print(changeIndexData.count)
        return changeIndexData
    }
    ///
    ///Index Mwssage Change
    ///
    static private func indexMessageChange(count: Int) -> [MessageItems] {
        var changeIndexData: [MessageItems] = []
        var indexValue = 0
        guard let data = copiedItem as? [MessageItems] else { return [] }
        
        
        for item in data {
            item.indexValue = Int64(indexValue + count)
            indexValue += 1
            changeIndexData.append(item)
        }
        
//        print(changeIndexData.count)
        return changeIndexData
    }
    ///
    ///Indec ItemChange
    ///
    static private func indexItemChange(count: Int) -> [Item] {
        var changeIndexData: [Item] = []
        var indexValue = 0
        guard let data = copiedItem as? [Item] else { return [] }
        
        for item in data {
            item.indexValue = Int64(indexValue + count)
            indexValue += 1
            changeIndexData.append(item)
        }
        return changeIndexData
    }
    
    ///
    ///Remove  Interval items and save after delete
    ///   /// IF USER SELECTED ``CUT`` OPERATION
    ///
    static private func removeIntervalEntity(){
        if shouldDeleteAfterPaste{
            if let entities = selectedEntities{
                for entity in entities {
                    CoreDataManager.shared.deleteNSManagedObject(object: entity)
                }
            }
            shouldDeleteAfterPaste = false
            selectedEntities = []
        }
    }
    
    
    static private func removeEntities(){
        ///
        /// REMOVE ENTITIES
        /// IF USER SELECTED ``CUT`` OPERATION
        ///
        if shouldDeleteAfterPaste{
            if let entities = selectedEntities{
                for entity in entities {
                    CoreDataManager.shared.deleteItemNSManagedObject(object: entity)
                }
            }
            shouldDeleteAfterPaste = false
            selectedEntities = []
        }
    }
    
    ///
    ///Remove Relation with parent item
    ///
//    static private func removeChildRelation(){
//        var childItem = selectedEntities as? [Item]
//        childItem?.forEach{data in
//            parentCutItem?.removeFromChildren(data)
//        }
//        parentCutItem = nil
//    }
    
    ///
    ///Deleting Child Copy Item or Emptying
    ///
    
    static private func deleteMultiplePasteItem(){
        ///
        /// REMOVE ENTITIES
        /// IF USER SELECTED ``CUT`` OPERATION
        ///
        
        let entities = copiedItem
        for entity in entities {
            CoreDataManager.shared.deleteNSManagedObject(object: entity)
            copiedItem = []
        }
    }
}
//
//    // Create a background context
//        private func createBackgroundContext() -> NSManagedObjectContext {
//            CoreDataManager.shared.newContext
//        }
//
//        // Example of deep copying using background context for a ColorObject
//        private func getCopiedObjectOfColors(colorObject: ColorObject?) -> ColorObject? {
//            let backgroundContext = createBackgroundContext()
//            let newCopy = ColorObject(context: backgroundContext)
//
//            guard let colorObject else {
//                debugPrint("Color object is nil in Edit-Operations")
//                return nil
//            }
//
//            // Copy each property
//            newCopy.alphaValue = colorObject.alphaValue
//            newCopy.colorHexCode = colorObject.colorHexCode
//            newCopy.colorOpacityX = colorObject.colorOpacityX
//            newCopy.colorOpacityY = colorObject.colorOpacityY
//            newCopy.colorRgbX = colorObject.colorRgbX
//            newCopy.colorRgbY = colorObject.colorRgbY
//            newCopy.colorShadesX = colorObject.colorShadesX
//            newCopy.colorShadesY = colorObject.colorShadesY
//
//            return newCopy
//        }
//
//        // Copying IntervalCalls in the background context
//        private func getCopyOfIntervalCallObjects(intervalCall: IntervalCalls?) -> IntervalCalls? {
//            let backgroundContext = createBackgroundContext()
//            let newCopy = IntervalCalls(context: backgroundContext)
//
//            guard let intervalCall else {
//                debugPrint("Interval call is nil while getting copy in Edit-Operations")
//                return nil
//            }
//
//            // Copy properties
//            newCopy.averageNumber = intervalCall.averageNumber
//            newCopy.maxNumber = intervalCall.maxNumber
//            newCopy.random = intervalCall.random
//            //newCopy.intervalItem = intervalCall.intervalItem
//
//            return newCopy
//        }
//
//        // Copying IntervalItems in the background context
//        private func getCopyOfIntervlss(intervals: [IntervalItem]?) -> [IntervalItem]? {
//            var copiedIntervals: [IntervalItem] = []
//            let backgroundContext = createBackgroundContext()
//
//            for interval in intervals ?? [] {
//                let newCopy = IntervalItem(context: backgroundContext)
//
//                // Copy individual properties
//                newCopy.halfWayAlert = interval.halfWayAlert
//                newCopy.indexValue = interval.indexValue
//                newCopy.intervalName = interval.intervalName
//                newCopy.isSelected = interval.isSelected
//                newCopy.colorObject = getCopiedObjectOfColor(colorObject: interval.colorObject)
//                newCopy.intervalCall = getCopyOfIntervalCallObject(intervalCall: interval.intervalCall)
//                newCopy.intervalDuration = getCopyOfIntervalDurationObject(intervalDuration: interval.intervalDuration)
//                newCopy.item = interval.item
//
//                // Copy related message items
//                if let messages = getCopyOfMessageObject(messageItems: interval.messageItems?.allObjects as? [MessageItems])?.compactMap({ $0 }) {
//                    newCopy.messageItems = NSSet(array: messages)
//                }
//
//                copiedIntervals.append(newCopy)
//            }
//
//            return copiedIntervals
//        }
//
//        // Copying IntervalDuration in the background context
//        private func getCopyOfIntervalDurationObjects(intervalDuration: IntervalDuration?) -> IntervalDuration? {
//            let backgroundContext = createBackgroundContext()
//            let newCopy = IntervalDuration(context: backgroundContext)
//
//            guard let intervalDuration else {
//                debugPrint("Interval duration is nil while getting copy in Edit-Operations")
//                return nil
//            }
//
//            // Copy properties
//            newCopy.max = intervalDuration.max
//            newCopy.min = intervalDuration.min
//            newCopy.random = intervalDuration.random
//            newCopy.restTime = intervalDuration.restTime
//
//            return newCopy
//        }
//
//        // Copying RestBetweenRounds in the background context
//        private func getCopyOfRestBetweenRoundsObjects(restBetweenInterval: RestBetweenRounds?) -> RestBetweenRounds? {
//            let backgroundContext = createBackgroundContext()
//            let newCopy = RestBetweenRounds(context: backgroundContext)
//
//            guard let restBetweenInterval else {
//                debugPrint("RestBetweenRounds is nil while getting copy in Edit-Operations")
//                return nil
//            }
//
//            // Copy properties
//            newCopy.max = restBetweenInterval.max
//            newCopy.min = restBetweenInterval.min
//            newCopy.random = restBetweenInterval.random
//            newCopy.restTime = restBetweenInterval.restTime
//            newCopy.rounds = restBetweenInterval.rounds
//
//            return newCopy
//        }
//
//        // Copying MessageItems in the background context
//        private func getCopyOfMessageObjects(messageItems: [MessageItems?]?) -> [MessageItems?]? {
//            guard let messageItems else {
//                debugPrint("MessageItem is nil while getting copy in Edit-Operations")
//                return nil
//            }
//
//            var index: Int64 = 0
//            var arrayOfMessages: [MessageItems] = []
//
//            for messageItem in messageItems {
//                let backgroundContext = createBackgroundContext()
//                let newCopy = MessageItems(context: backgroundContext)
//                newCopy.delay = messageItem?.delay
//                newCopy.indexValue = index
//                newCopy.messageName = messageItem?.messageName
//                arrayOfMessages.append(newCopy)
//                index += 1
//            }
//
//            return arrayOfMessages
//        }
//    
//    
//
//        // Copying Item objects in the background context
//        private func getCopyOfItemObjects(items: [Item?]?) -> [Item?]? {
//            var copiedItems: [Item] = []
//            var index: Int64 = 0
//            guard let items else {
//                return nil
//            }
//
//            let backgroundContext = createBackgroundContext()
//
//            for item in items {
//                guard let item else { continue }
//
//                let newCopy = Item(context: backgroundContext)
//
//                // Copy basic properties
//                newCopy.alertSong = item.alertSong
//                newCopy.indexValue = index
//                newCopy.isChild = item.isChild
//                newCopy.session = item.session
//                newCopy.shuffle = item.shuffle
//                newCopy.title = item.title
//                newCopy.type = item.type
//                newCopy.viibrateAlert = item.viibrateAlert
//
//                // Copy relationships (optional)
//                newCopy.setting = getCopyOfSettingObject(setting: item.setting)
//                newCopy.colorObject = getCopiedObjectOfColor(colorObject: item.colorObject)
//                newCopy.intervalDuration = getCopyOfIntervalDurationObject(intervalDuration: item.intervalDuration)
//                newCopy.restBetweenInterval = getCopyOfIntervalDurationObject(intervalDuration: item.restBetweenInterval)
//                newCopy.restBetweenRounds = getCopyOfRestBetweenRoundsObject(restBetweenInterval: item.restBetweenRounds)
//                newCopy.intervalItem = NSSet(array: (getCopyOfIntervls(intervals: item.intervalItem?.allObjects as? [IntervalItem]) ?? []))
//                if let childrenItems = getCopyOfItemObject(items: item.children?.allObjects as? [Item])?.compactMap({ $0 }) {
//                    newCopy.children = NSSet(array: childrenItems)
//                }
//                newCopy.toFolderItems = item.toFolderItems
//
//                copiedItems.append(newCopy)
//
//                index += 1
//            }
//
//            return copiedItems
//        }
//
//        // Saving copied objects to the main context
////        func saveCopiedObjectsToMainContext() {
////            let backgroundContext = createBackgroundContext()
////            do {
////                try backgroundContext.save() // Save background context
////                // After saving the background context, you can merge the changes into the main context
////                CoreDataManager.shared.context.perform {
////                    CoreDataManager.shared.context.mergeChanges(fromContextDidSave: Notification(name: .NSManagedObjectContextDidSave, object: backgroundContext))
////                }
////            } catch {
////                debugPrint("Failed to save background context: \(error)")
////            }
////        }
//    }
//
//
