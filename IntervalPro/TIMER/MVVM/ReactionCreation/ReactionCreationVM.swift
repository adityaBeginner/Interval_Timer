//
//  ReactionCreationVM.swift
//  TIMER
//
//  Created by Aditya Maroo on 11/09/24.
//

import Foundation
import CoreData
import Combine
import SwiftUI
 //MARK: - View Model Class for Reaction View
//Contains various properties and object
//handle function call back data saving and updating data
class ReactionCreationVM: ObservableObject{
    
    //MARK: -
    //MARK: - PUBLISHED PROPERTIES
    @Published var alertSong: String = "Default"
    @Published var colureHexCode: String = "#FF9C1A"
    @Published var colorOpacity: Double = 1.0
    @Published var session: String = ""
    @Published var hideCallDuration: Bool = false
    @Published var titleName: String = ""
    @Published var vibrateOnAlert: Bool = false
    @Published var intervalDuration: MaxMinData = MaxMinData(maxTime: "", minTime: "", averageTime: "", random: false)
    @Published var restBetweenInterval: MaxMinData = MaxMinData(maxTime: "", minTime: "", averageTime: "", random: false)
    @Published var restBetweenRounds: MaxMinData = MaxMinData(maxTime: "", minTime: "", averageTime: "", random: false)
    @Published var totalNoOfRounds: Int64 = 1
    @Published var intervalItems: [IntervalItem] = []
    @Published var textFieldType: TextFieldType?
    @Published var minMaxType: MinMaxTime?
    @Published var alertTimerPopScreen: Bool = false
    @Published var shouldShowValidationError: Bool = false
    @Published var textDesciptionBox: [String] = []
    @Published var alertHeaderTitle:String = "Error: Missing Fields"
    @Published var validationErrorMessage:String = "The field cannot be empty. Do you wish to delete this activity? Please note that this action cannot be undone.\nPlease make sure field are not empty:"
    var lastEndDescription = ""
    var isDescriptionBox = true
    var cancelBtnText = "CANCEL"
    var okayBtnText = ""
    @Published var csvFileAlert = false
    var isImportSucess = false
    
    @Published var selectedItems: [IntervalItem] = []
    
    /// Toast Componets hiding and unhiding
    @Published var isToastHidden: Bool = false
    @Published var toastTitleName: String = ""
    
    /// Slide animation of delete functionality
    @Published var slideListAnimation: Bool = false
    
    //is Footer Edit hide Button
    @Published var isFooterEdit: Bool = false
    
    //Note box String
    @Published var noteBoxText: String = ""
    @Published var isNoteScroll: Bool = false
    
    //delete pop
    @Published var isDeletePop: Bool = false
    
    //State change for selected value
    @Published var stateChange: TimerReactionMessageState = .Normal
    
    //Saving item on color navigation in edit state
    @Published var colorNavigate: Bool = false
    
    //SavingData on sound update
    @Published var soundUpdate: Bool = false
    
    //Scroll to last
    @Published var isScrollDown: Bool = false
    
    //Csv
    @Published var isActiveImportCSVView:Bool = false
    @Published var csvUrl:URL?
    
    //Replacing And existing Data
    @Published var isReplaceExisting: Bool = false
    
    //Blur Effect on Alerts
    @Published var blurEffectPresent: Bool = false
    
    //Navaigtion
    @Published var isNaviagteSubscription: Bool = false
    
    //Index Number
    @Published var indexNumber: Int = 0
    
    var dataReplaced: Bool = false
    
    //MARK: -
    //MARK: - PROPERTIES
    var intervalItem:IntervalItem?
    var csvIntervalItems: [IntervalItem] = []
    var itemModelData: ItemModelData?
    var item:Item?
    var fileType: String = FileType.Drill.rawValue
    var itemCount: Int?
    var noteBoxPadding: Double = UIScreen.main.bounds.size.height * 0.4
    
    //MARK: -
    //MARK: - FUNCTIONS
    
    ///
    /// ADD OR UPDATE THE ITEM DATA
    ///
    func addOrUpdateItemData(){
        
        guard let item = item else{debugPrint("item is nil, while attempting to AddItem");return}
        
       onChangeSaveData()
        
        let restBetweenRounds = item.restBetweenRounds == nil ? createRestBetweenRounds() : item.restBetweenRounds
        restBetweenRounds?.rounds = self.totalNoOfRounds
        item.restBetweenRounds = AppComman.shared.validationRoundIntervalData(durationType: restBetweenRounds ?? RestBetweenRounds(), minFieldValue: self.restBetweenRounds.minTime, maxFieldValue: self.restBetweenRounds.maxTime, random: self.restBetweenRounds.random)
        
        let restBetweenIntervals = item.restBetweenInterval == nil ? createRestBetweenInterval() : item.restBetweenInterval
        item.restBetweenInterval = AppComman.shared.validationIntervalData(durationType: restBetweenIntervals ?? IntervalDuration(), minFieldValue: restBetweenInterval.minTime, maxFieldValue: restBetweenInterval.maxTime, random: restBetweenInterval.random)
        
        let intervalDurations = item.intervalDuration == nil ? createIntervalDuration() : item.intervalDuration
        item.intervalDuration = AppComman.shared.validationIntervalData(durationType: intervalDurations ?? IntervalDuration(), minFieldValue: intervalDuration.minTime, maxFieldValue: intervalDuration.maxTime, random: intervalDuration.random)
        
        let colorObject = item.colorObject == nil ? createColorObject() : item.colorObject
        addOrUpdateColorObject(colorObject: colorObject)
        
        let audioSetting = item.setting
        updateAudioSong(audio: itemModelData?.alertName, setting: audioSetting)
        
        item.title = titleName
        item.viibrateAlert = vibrateOnAlert
        item.session = session
        item.type = "Drill"
        item.noteBox = noteBoxText
        ///
        ///SHUFFLE VARIABLE IS USED FOR
        ///``shuffle``  IN ``TIMER`` TYPE ITEM
        ///``hideCallDuration`` IN ``DRILL`` TYPE ITEM
        ///
        item.shuffle = hideCallDuration
        
        CoreDataManager.shared.saveContext()
    }
    
    
    ///
    /// UPDATE AUDIO LABEL
    ///
        func updateAudioLabel(){
            guard let audioSetting = item?.setting else { return }
            if !audioSetting.isNoAudio{
                if audioSetting.isTextToSpeech{
                    alertSong = ReactionCreationString.textToSpeech + " " + (audioSetting.textToSpeech ?? "Without Count")
                }
                else{
                    alertSong = audioSetting.audio ?? "Default"
                }
            }else{
                alertSong = "No Audio"
            }
        }
    
    
    ///
    /// CREATE ITEM
    ///
    func createItem()->Item{
        let item = Item(context: CoreDataManager.shared.context)
        item.indexValue = Int64(itemCount ?? 0)
        item.setting = createAlertSong()
        item.setting?.audio = "Four Beeps (Default)"
        item.setting?.isNoAudio = false
        item.setting?.isTextToSpeech = false
        item.setting?.vibration = "One Vibration"
        item.colorObject = createColorObject()
        item.colorObject?.alphaValue = 1
        item.colorObject?.colorHexCode = Color(uiColor: .defaultFolderTimerReactionColor).toHex()
        item.colorObject?.colorRgbX = 16
        item.colorObject?.colorRgbY = 12
        item.colorObject?.colorOpacityX = UIScreen.main.bounds.size.width - 48
        item.colorObject?.colorOpacityY = 13
        item.colorObject?.colorShadesX = UIScreen.main.bounds.size.width - 40
        item.colorObject?.colorShadesY = 8
        colureHexCode = Color(.defaultFolderTimerReactionColor).toHex()
        return item
    }
    
    ///
    /// CREATE INTERVAL
    ///
    func createInterval(){
        intervalItem = IntervalItem(context: CoreDataManager.shared.context)
        intervalItem?.indexValue = Int64(item?.intervalItem?.count ?? 0)
        addInterval()
    }
    
    ///
    ///Reassing index position
    ///
    func indexChanging(){
        if (intervalItems.last?.indexValue ?? 0) + 1 > intervalItems.count{
            for index in 0..<intervalItems.count{
                intervalItems[index].indexValue = Int64(index)
            }
        }
    }
    
    
    ///
    ///Create Alert Song Object
    ///
    private func createAlertSong()-> Settings{
        return Settings(context: CoreDataManager.shared.context)
    }
    
    ///
    /// ADD INTERVAL ITEM
    ///
    private func addInterval() {
        guard let item else {debugPrint("Interval item is nil while adding interval"); return }
        
        var array: [IntervalItem] = []
        if let setIntervalItem = item.intervalItem {
               for obj in setIntervalItem{
                   if let intervalIte = obj as? IntervalItem{
                       array.append(intervalIte)
                   }
               }
               if let intervalItem{
                   array.append(intervalItem)
               } // Convert NSSet to array
        }
        else{
            if let intervalItem {
                array.append(intervalItem)
            }
        }
        item.intervalItem = NSSet(array: array)
        CoreDataManager.shared.saveContext()
    }
    
    
    ///
    /// ADD OR UPDATE THE COLOR OBJECT
    ///
    private func addOrUpdateColorObject(colorObject:ColorObject?){
        colorObject?.colorHexCode = colureHexCode
        colorObject?.alphaValue = colorOpacity
        item?.colorObject = colorObject
    }
    
    
    ///
    /// CREATE REST BETWEEN ROUNDS
    ///
    private func createRestBetweenRounds()->RestBetweenRounds{
        return RestBetweenRounds(context: CoreDataManager.shared.context)
    }
    
    ///
    /// CREATE REST BETWEEN INTERVALS
    ///
    private func createRestBetweenInterval()->IntervalDuration{
        return IntervalDuration(context: CoreDataManager.shared.context)
    }
    
    /// 
    /// CREATES INTERVAL DURATION
    ///
    private func createIntervalDuration()-> IntervalDuration{
        return IntervalDuration(context: CoreDataManager.shared.context)
    }
    ///
    /// CREATE COLOROBJECT
    ///
    private func createColorObject()->ColorObject{
        return ColorObject(context: CoreDataManager.shared.context)
    }
    
    ///
    /// DELETE ITEM
    ///
    func deleteItem(){
        guard let item = item else{ debugPrint("item is nil, whil attempting to delete an Item");return}
        CoreDataManager.shared.deleteNSManagedObject(object: item)
        CoreDataManager.shared.saveContext()
        self.item = nil
    }
    
    
    ///
    /// UPDATE INDEX VALUE
    ///
    func indexUpdate(indices: IndexSet, newOffset: Int, items: Item?){
        intervalItems.move(fromOffsets: indices, toOffset: newOffset)
        for (index, _) in intervalItems.enumerated() {
            intervalItems[index].indexValue = Int64(index)
            
        }
        ///If item object is present then only it will be save otherwise object wiil be created for item
        if items != nil{
            items!.intervalItem = NSSet(array: intervalItems)
            CoreDataManager.shared.saveContext()
        }
    }
    ///
    ///Update Index Value after paste
    ///
    func pasteIndexUpdateValue(){
        for (index, _) in intervalItems.enumerated() {
            intervalItems[index].indexValue = Int64(index)
           
        }
        ///
        ///If item object is present then only it will be save otherwise object wiil be created for item
        ///
        if item != nil {
            item?.intervalItem = NSSet(array: intervalItems)
            CoreDataManager.shared.saveContext()
        }
    }
    ///
    /// remove selected item
    ///
    func removeSelectedItem(intervalItem: IntervalItem){
        let removeData = selectedItems.filter{ $0 != intervalItem}
        selectedItems = removeData
    }
    
    ///
    /// DELETE INTERVAL ITEMS
    ///
    func deleteSelectedIntervalItems(){
        for selectedItem in selectedItems {
            CoreDataManager.shared.deleteNSManagedObject(object: selectedItem)
            intervalItems.removeAll(where: {$0.id == selectedItem.id})
        }
        for index in 0..<intervalItems.count{
            intervalItems[index].indexValue = Int64(index)
        }
        CoreDataManager.shared.saveContext()
    }
    
    ///
    ///Delete single Item
    ///
    func deleteSingleIntervalItem(indexSet: IndexSet){
        for index in indexSet{
            CoreDataManager.shared.deleteNSManagedObject(object: intervalItems.remove(at: index))
           
        }
        for index in 0..<intervalItems.count{
            intervalItems[index].indexValue = Int64(index)
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
        intervalItems.forEach { item in
               item.isSelected = false
           }
    }
    
    ///
    ///Validation of timer in minutes and seconds
    ///
    func changingValueBreakField(textFieldType: TextFieldType) {
        switch textFieldType {
        case .IntervalDuration:
            intervalDuration.minTime = formatTime(minTime: intervalDuration.minTime)
            if intervalDuration.random{
                intervalDuration.maxTime = formatTime(minTime: intervalDuration.maxTime)
            }
        case .RestBetweenInterval:
            restBetweenInterval.minTime = formatTime(minTime: restBetweenInterval.minTime)
            if restBetweenInterval.random{
                restBetweenInterval.maxTime = formatTime(minTime: restBetweenInterval.maxTime)
            }
            break
        case .RestBetweenRounds:
            restBetweenRounds.minTime = formatTime(minTime: restBetweenRounds.minTime)
            if restBetweenRounds.random{
                restBetweenRounds.maxTime = formatTime(minTime: restBetweenRounds.maxTime)
            }
            break
        case .SessionLastTime:
            session = formatHourTime(minTime: session)
        }
    }

    ///
    ///Validating data and fields
    ///
    func validationTimer()-> Bool{
        guard titleName.trimmingCharacters(in: .whitespaces) != "" else{
            textDesciptionBox = ["Name Field", "Interval Duration","Rest Between Intervals", "Rest Between Rounds"]
            return false
        }
    
//        guard validationRandom(breakTime: intervalDuration) else{
//            return false
//        }
//        guard validationRandom(breakTime: restBetweenInterval) else{
//            return false
//        }
//        guard validationRandom(breakTime: restBetweenRounds) else{
//            return false
//        }
        guard totalNoOfRounds > 0 else{
            return false
        }
         
        return true
    }
    
    func validationRandom(breakTime: MaxMinData)-> Bool{
        guard breakTime.minTime.trimmingCharacters(in: .whitespaces) != "HH:MM:SS" && breakTime.minTime.trimmingCharacters(in: .whitespaces) != "00:00:00" else{
            textDesciptionBox = ["Name Field", "Interval Duration Fields","Rest Between Intervals Fields", "Rest Between Rounds Fields"]
            return false
        }
        if breakTime.random{
            guard breakTime.maxTime.trimmingCharacters(in: .whitespaces) != "HH:MM:SS" && breakTime.maxTime.trimmingCharacters(in: .whitespaces) != "00:00:00" else{
                textDesciptionBox = ["Name Field", "Rest Between Intervals(Min & Max) Fields",  "Interval Duration (Min & Max) Fields", "Rest Between Rounds (Min & Max) Fields"]
                return false
            }
            guard convertStringtoData(timeString: breakTime.minTime) < convertStringtoData(timeString: breakTime.maxTime) else{
                alertHeaderTitle = "Error: Max time"
                validationErrorMessage = "The max time field value is less than min time field value. Please make sure max time field will be greater than min time field./nChange the time in min or max time field "
                textDesciptionBox = []
                return false
            }
        }
        return true
    }
    
    ///Conversion for session last round
    public func reformatAsTimeMax(_ value: String) {
        let timeSeparator = ":"
        let cleanString = value.replacingOccurrences(of: timeSeparator, with: "")
        
        if cleanString.count >= 5 {
            // Extract hours, minutes, and seconds
            let hourString = String(cleanString.prefix(2))
            var minuteString = String(cleanString.dropFirst(2).prefix(2))
            var secondsString = String(cleanString.dropFirst(4).prefix(2))
          
            // Ensure the first digit of the minutes is valid (less than 6)
            if let firstMinuteDigit = Int(minuteString.prefix(1)), firstMinuteDigit >= 6 {
                minuteString = "0" + minuteString.suffix(1)
            }
            
            // Ensure the first digit of the seconds is valid (less than 6)
            if let firstSecondDigit = Int(secondsString.prefix(1)), firstSecondDigit >= 6 {
                secondsString = "0" + secondsString.suffix(1)
            }
            
            session = hourString + timeSeparator + minuteString + timeSeparator + secondsString
        } else if cleanString.count >= 3{
            let minuteString = String(cleanString.prefix(2))
            var secondsString = String(cleanString.dropFirst(2).prefix(2))
            if Int(secondsString.prefix(1)) ?? 0 < 6{
                session = minuteString + timeSeparator + secondsString
            }
            else{
                secondsString = "0" + secondsString.suffix(1)
                session = minuteString + timeSeparator + secondsString
            }
        }else{
            session = cleanString
        }
    }
    func onChangeSaveData(){
        changingValueBreakField(textFieldType: .RestBetweenInterval)
        changingValueBreakField(textFieldType: .RestBetweenRounds)
        changingValueBreakField(textFieldType: .IntervalDuration)
        isNoteScroll = false
        session = formatHourTime(minTime: session, isDisplayMilliseconds: true)
    }
    
    ////
    ///Import Error for the missing Field``(index 1)``, Missing csv``(index 2)`` or url and succes alert ``(index 3)``
    ///
    func handlingImportAlerts(index: Int){
        switch index{
        case 1:
            //Missing field in csv
            alertHeaderTitle = "ERROR: MISSING FIELDS"
            validationErrorMessage = "The file you’re uploading appears to have different headings than required for this interval session.\nPlease check your file has these exact headings"
            textDesciptionBox = ["CallName","CallColour", "MaxNumberOfCalls"]
            lastEndDescription = "If in doubt, download the template from here:\nhttps://www.something.something.com"
            isDescriptionBox = false
            okayBtnText = "CHOOSE NEW FILE"
            cancelBtnText = "CANCEL"
            csvFileAlert = true
            blurEffectPresent = true
            break
        case 2:
            //Invalid csv file or url and data
            alertHeaderTitle = "ERROR: INVALID FILE TYPE"
            validationErrorMessage = "The file you’re uploading appears to have different headings or information than required for this type Timer.\nPlease check you’re importing the correct timer (e.g. Interval vs Reaction).\nFailing that, check the column headings against the templates available at:"
            textDesciptionBox = []
            lastEndDescription = ""
            okayBtnText = "CHOOSE NEW FILE"
            cancelBtnText = "CANCEL"
            isDescriptionBox = true
            csvFileAlert = true
            blurEffectPresent = true
            break
        case 3:
            ///Adding Succes alert
            alertHeaderTitle = "SUCCESS"
            validationErrorMessage = "Everything was imported successfully."
            textDesciptionBox = []
            lastEndDescription = ""
            okayBtnText = "OK"
            cancelBtnText = ""
            isDescriptionBox = true
            isImportSucess = true
            csvFileAlert = true
            blurEffectPresent = true
            break
            
        case 4:
            //Replace and Existing Data
            alertHeaderTitle = "CHOOSE IMPORT OPTION"
            validationErrorMessage = "Replace all the data or add to your existing session."
            textDesciptionBox = []
            lastEndDescription = ""
            okayBtnText = "ADD TO EXISTING"
            cancelBtnText = "REPLACE DATA"
            isDescriptionBox = true
            isReplaceExisting = true
            blurEffectPresent = true
            
        case 5:
            //Replace Data
            alertHeaderTitle = "REPLACE DATA"
            validationErrorMessage = "This action is irreversible; are you sure?"
            textDesciptionBox = []
            lastEndDescription = ""
            okayBtnText = "YES, DO IT"
            cancelBtnText = "NO, GO BACK"
            isDescriptionBox = true
            dataReplaced = true
            isReplaceExisting = true
            blurEffectPresent = true
            
        default:
            break
        }
    }
    
    func addToExistingData(intervals: [IntervalItem]?, itemData: ItemModelData?){
        updateItemAddtoExistingCsvData(itemData: itemData)

        var count = 0
        ///
        ///IN CASE OF EDIT ``itemData`` WILL USED
        ///IN CASE OF CREATE/ADD ``viewModel.item`` WILL BE USED
        ///
        let _item = item == nil ? createItem() : item
        
        ///
        ///UPDATE ``indexValue`` OF IMPORTED INTERVALS
        ///
        let intervals = verfityReactionInterval(intervals: intervals ?? [])
       let intervalCount = _item?.intervalItem?.allObjects.count ?? 0
        print(intervalCount)
        for index in 0..<(intervals ?? []).count{
            intervals?[index].indexValue = Int64(count + intervalCount)
            count += 1
        }
        
        _item?.intervalItem = NSSet(array: Array(item?.intervalItem?.allObjects as? [IntervalItem] ?? []) + (intervals ?? []))
        intervalItems = (_item?.intervalItem?.allObjects as? [IntervalItem] ?? []).sorted(by: {$0.indexValue < $1.indexValue})
        
        ///
        ///SET ``nil`` CSV URL AFTER IMPORTING INTERVALS
        ///
        csvUrl = nil
        
        handlingImportAlerts(index: 3)
    }
    
    ///Remove Data or replace data with csv file
    func removeExistingData(intervals: [IntervalItem]?, itemData: ItemModelData?){
        updateItemCsvData(itemData: itemData)
        var count = 0
        ///
        ///IN CASE OF EDIT ``itemData`` WILL USED
        ///IN CASE OF CREATE/ADD ``viewModel.item`` WILL BE USED
    
        ///filter out drill data
        ///
        let intervals = verfityReactionInterval(intervals: intervals ?? [])
        let _item = item == nil ? createItem() : item
        
        ///
        ///UPDATE ``indexValue`` OF IMPORTED INTERVALS
        ///
     
        for index in 0..<(intervals ?? []).count{
            intervals?[index].indexValue = Int64(count)
            count += 1
        }
        _item?.intervalItem?.forEach{interval in
            CoreDataManager.shared.deleteNSManagedObject(object: interval as? NSManagedObject ?? IntervalItem())
        }
        _item?.intervalItem = NSSet(array: intervals ?? [])
        intervalItems = (_item?.intervalItem?.allObjects as? [IntervalItem] ?? []).sorted(by: {$0.indexValue < $1.indexValue})
        
        ///
        ///SET ``nil`` CSV URL AFTER IMPORTING INTERVALS
        ///
        csvUrl = nil
        
        handlingImportAlerts(index: 3)
    }
    
    //Verify the the reaction drill
    func verfityReactionInterval(intervals: [IntervalItem])-> [IntervalItem]?{
//        print(intervals.forEach{$0.intervalCall?.maxNumber ?? 0})
//        return intervals.filter{$0.intervalCall?.maxNumber ?? 0 > 0 && $0.intervalCall?.maxNumber != nil }
        return intervals.filter{$0.intervalCall?.random != nil}
    }

    
    ///
    ///Add Item Data Updata
    ///
    func updateItemCsvData(itemData: ItemModelData?){
        guard let itemData = itemData else{return}
//        item = itemData
        titleName = itemData.name ?? ""
//        fetchAllDataOnAppear()
        //                        viewModel.intervalItems = itemData?.intervalItem?.allObjects as? [IntervalItem] ?? []
        //                        viewModel.intervalItems.sort{$0.indexValue < $1.indexValue}
        //
        session = csvSessionUpdate(sessionString: itemData.sessionRound)
        restBetweenInterval.minTime = AppComman.shared.handlingMilliseconds(timeString: itemData.restInterval?.minTime) /*?? ""*/
        restBetweenInterval.random = itemData.restInterval?.random ?? false
        restBetweenInterval.maxTime = AppComman.shared.handlingMilliseconds(timeString: itemData.restInterval?.maxTime) /*?? ""*/
        restBetweenRounds.minTime = AppComman.shared.handlingMilliseconds(timeString: itemData.restRound?.minTime) /*?? ""*/
        restBetweenRounds.maxTime = AppComman.shared.handlingMilliseconds(timeString: itemData.restRound?.maxTime) /*?? ""*/
        restBetweenRounds.random = itemData.restRound?.random ?? false
        intervalDuration.maxTime = AppComman.shared.handlingMilliseconds(timeString: itemData.intervalDuration?.maxTime) /*?? ""*/
        intervalDuration.minTime = AppComman.shared.handlingMilliseconds(timeString: itemData.intervalDuration?.minTime) /*?? ""*/
        intervalDuration.random = itemData.intervalDuration?.random ?? false
        colureHexCode = itemData.itemColor ?? ""
//        colorOpacity = itemData?.colorObject?.alphaValue ?? 1.0
        vibrateOnAlert = itemData.vibrateOnAlert ?? false
        hideCallDuration = itemData.shufffe ?? false
        debugPrint(itemData.restRound?.totalRounds ?? 1)
        totalNoOfRounds = itemData.restRound?.totalRounds ?? 1
        
       
        alertSong = itemData.alertName?.alertSong ?? ""
//        item?.setting?.audio = itemData.alertName?.alertSong ?? ""
//        item?.setting?.isTextToSpeech = itemData.alertName?.isTextToSpeech ?? false
//        item?.setting?.isNoAudio = itemData.alertName?.isNoAudio ?? false
//        item?.setting?.vibration = itemData.alertName?.vibrationName ?? ""
        
//        noteBoxText = itemData?.noteBox ?? ""
//        viewModel.updateAudioLabel()
    }
    
    
    ///
    ///Add to Existing Csv Handling
    ///
    func updateItemAddtoExistingCsvData(itemData: ItemModelData?){
        guard let itemData = itemData else{return}
        //        item = itemData
        if titleName.isEmpty{
            titleName = itemData.name ?? ""
            colureHexCode = itemData.itemColor ?? ""
            vibrateOnAlert = itemData.vibrateOnAlert ?? false
            hideCallDuration = itemData.shufffe ?? false
            alertSong = itemData.alertName?.alertSong ?? ""
        }
            if session.isEmpty{
                session = csvSessionUpdate(sessionString: itemData.sessionRound)
            }
            if intervalDuration.minTime.isEmpty{
                intervalDuration.maxTime = AppComman.shared.handlingMilliseconds(timeString: itemData.intervalDuration?.maxTime) /*?? ""*/
                intervalDuration.minTime = AppComman.shared.handlingMilliseconds(timeString: itemData.intervalDuration?.minTime) /*?? ""*/
                intervalDuration.random = itemData.intervalDuration?.random ?? false
            }
            if restBetweenInterval.minTime.isEmpty{
                restBetweenInterval.minTime = AppComman.shared.handlingMilliseconds(timeString: itemData.restInterval?.minTime) /*?? ""*/
                restBetweenInterval.random = itemData.restInterval?.random ?? false
                restBetweenInterval.maxTime = AppComman.shared.handlingMilliseconds(timeString: itemData.restInterval?.maxTime) /*?? ""*/
            }
            if restBetweenRounds.minTime.isEmpty{
                restBetweenRounds.minTime = AppComman.shared.handlingMilliseconds(timeString: itemData.restRound?.minTime) /*?? ""*/
                restBetweenRounds.maxTime = AppComman.shared.handlingMilliseconds(timeString: itemData.restRound?.maxTime) /*?? ""*/
                restBetweenRounds.random = itemData.restRound?.random ?? false
                totalNoOfRounds = itemData.restRound?.totalRounds ?? 1
            }
        
    }
    
    //Update Audio Song
    func updateAudioSong(audio: AlertModelData?, setting: Settings?){
        guard let alertName = audio else{return}
        alertSong = alertName.alertSong ?? ""
        setting?.audio = alertName.alertSong ?? ""
        setting?.isTextToSpeech = alertName.isTextToSpeech ?? false
        setting?.isNoAudio = alertName.isNoAudio ?? false
        setting?.vibration = alertName.vibrationName ?? ""
        
        item?.setting = setting
    }
    
    //Update Session
    func csvSessionUpdate(sessionString: String?)-> String{
        guard let sessionString = sessionString, !sessionString.isEmpty, sessionString != "00:00:00" else{
            return ""
        }
        if AppDefaults.shared.hundredthMilliSeconds{
            if sessionString.count == 8{
                return sessionString + ":00"
            }
            return sessionString
        }
        return sessionString
    }
    
}

