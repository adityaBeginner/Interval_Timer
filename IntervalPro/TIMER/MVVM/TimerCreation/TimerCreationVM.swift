//
//  TimerCreationVM.swift
//  TIMER
//
//  Created by Aditya Maroo on 29/08/24.
//

import SwiftUI

import Foundation
import CoreData
import Combine

 //MARK: - Structure of call interval duration and rest between interval
struct MaxMinData{
    var maxTime: String
    var minTime: String
    var averageTime: String
    var random: Bool
}
 //MARK: -  View Model of timer creation
//Contains various variable which is binded with view
//contains function save data in databse
//contains function for conerting object to diiferent object
class TimerCreationVM: ObservableObject{
    //MARK: -
    //MARK: PUBLISHED PROPERTIES
    @Published var colorOpacity: Double = 1.0
    @Published var alertSong: String = "Default "
    @Published var colureHexCode: String = "#FF9C1A"
//    @Published var session: String = "Defaults Beeps"
    @Published var shuffle: Bool = false
    var fileType: String = FileType.Timer.rawValue
    @Published var titleName: String = ""
    @Published var vibrateOnAlert: Bool = false
    @Published var restBetweenInterval: MaxMinData = MaxMinData(maxTime: "", minTime: "", averageTime: "", random: false)
    @Published var restBetweenRounds: MaxMinData = MaxMinData(maxTime: "", minTime: "", averageTime: "", random: false)
    @Published var totalNoOfRounds: Int64 = 1
    @Published var intervalItems: [IntervalItem] = []
    @Published var shouldShowValidationError:Bool = false
    @Published var validationErrorMessage:String = "The field cannot be empty. Do you wish to delete this activity? Please note that this action cannot be undone.\nPlease make sure field are not empty:"
    @Published var alertTimePop: Bool = false
    @Published var textFieldType: TextFieldType?
    
    //    @Published var minMaxData: MinMaxTime?
    @Published var textDesciptionBox: [String] = []
    @Published var alertHeaderTitle:String = "Error: Missing Fields"
    var lastEndDescription: String = ""
    var isDescriptionBox: Bool = true
    var cancelBtnText = ""
    var isImportSucess: Bool = false
    var okayBtnText = ""
    @Published var selectedItems:[IntervalItem] = []
    @Published var displayTxtDict: [Int64: String] = [:]
    
    /// Toast Componets hiding and unhiding
    @Published var isToastHidden: Bool = false
    @Published var toastTitleName: String = ""
    
    /// Slide animation of delete and cut functionality
    @Published var slideListAnimation: Bool = false
    @Published var isActiveImportCSVView:Bool = false
    @Published var csvUrl:URL?
    @Published var isDeletePop: Bool = false
    //MARK: -
    //MARK: - NAVIGATION STATE
    @Published var isActiveColorNavigation:Bool = false
    
    //is Footer Edit hide Button
    @Published var isFooterEdit: Bool = false
    
    //Note Box Text
    @Published var noteBoxText:String = ""
    
    //Focuse State NoteBox
    @Published var isNoteBoxFocuse: Bool = false
    
    //State change for selected value
    @Published var stateChange: TimerReactionMessageState = .Normal
    
    //Saving item on color navigation in edit state
    @Published var colorNavigate: Bool = false
    
    //SavingData on sound update
    @Published var soundUpdate: Bool = false
    
    //Scroll to last
    @Published var isScrollDown: Bool = false
    
    //Csv File import alert
    @Published var csvFileAlert: Bool = false
    
    //Replacing And existing Data
    @Published var isReplaceExisting: Bool = false
    @Published var dataReplaced: Bool = false
    
    //Blur Effect on Alerts
    @Published var blurEffectPresent: Bool = false
    
    //Naviagtion to subscription Screen
    @Published var isNaviagteSubscription: Bool = false
    
    
    //MARK: -
    //MARK: PROPERTIES
    var deleteCsvFile = ""
    var isEditInterval: Bool = false
    var intervalItemData: IntervalItem?
    var itemDataFolder: Item?
    var intervalItem:IntervalItem?
    var csvIntervalItems: [IntervalItem] = []
    var itemModelData: ItemModelData?
    var item:Item?
    var itemCount: Int?
    var changeHandling: (String, String, Bool, Bool, String, Bool, String, String, Bool, String, Int64 ){
        return (titleName, alertSong, vibrateOnAlert, shuffle, restBetweenInterval.minTime, restBetweenInterval.random, restBetweenInterval.maxTime, restBetweenRounds.minTime, restBetweenRounds.random, restBetweenRounds.maxTime, totalNoOfRounds)
    }
    
    
    //MARK: - Environment object globally
    
    //MARK: -
    //MARK: FUNCTIONS
    
    
    ///
    /// ADD OR UPDATE THE ITEM DATA
    ///
    func addOrUpdateItemData(){
        
        guard let item = item else{debugPrint("item is nil, while attempting to AddItem");return}
       
        ///Formatting rest interval and restround through function
        onChangeSaveData()
        
        
        let restBetweenRoundss = item.restBetweenRounds == nil ? createRestBetweenRounds() : item.restBetweenRounds
        restBetweenRoundss?.rounds = totalNoOfRounds
        item.restBetweenRounds = AppComman.shared.validationRoundIntervalData(durationType: restBetweenRoundss ?? RestBetweenRounds(), minFieldValue: restBetweenRounds.minTime, maxFieldValue: restBetweenRounds.maxTime, random: restBetweenRounds.random)
        
        let restBetweenIntervals = item.restBetweenInterval == nil ? createRestBetweenInterval() : item.restBetweenInterval
        item.restBetweenInterval = AppComman.shared.validationIntervalData(durationType: restBetweenIntervals ?? IntervalDuration(), minFieldValue: restBetweenInterval.minTime, maxFieldValue: restBetweenInterval.maxTime, random: restBetweenInterval.random)
        
        let colorObject = item.colorObject == nil ? createColorObject() : item.colorObject
        addOrUpdateColorObject(colorObject: colorObject)
        
        let audioSetting = item.setting
        updateAudioSong(audio: itemModelData?.alertName, setting: audioSetting)
        
        //        updateAudioLabel()
        item.title = titleName
        item.viibrateAlert = vibrateOnAlert
//        item.session = session
        item.type = "Timer"
        item.shuffle = shuffle
        item.noteBox = noteBoxText
       // DispatchQueue.main.async{
            CoreDataManager.shared.saveContext()
     //}
    }
    
    ///
    /// UPDATE AUDIO LABEL
    ///
    func updateAudioLabel(){
        guard let audioSetting = item?.setting else { return }
        if !audioSetting.isNoAudio{
            if audioSetting.isTextToSpeech{
                alertSong = TimerCreationString.textToSpeech + " " + (audioSetting.textToSpeech ?? "Without Count")
            }else{
                alertSong = audioSetting.audio ?? "Default"
            }
        }else{
            alertSong = "No Audio"
        }
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
    ///Create Alert Song Object
    ///
    private func createAlertSong()-> Settings{
        return Settings(context: CoreDataManager.shared.context)
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
        colureHexCode = Color(.defaultFolderTimerReactionColor).toHex()
        item.colorObject?.colorHexCode = Color(uiColor: .defaultFolderTimerReactionColor).toHex()
        item.colorObject?.colorRgbX = 16
        item.colorObject?.colorRgbY = 12
        item.colorObject?.colorOpacityX = UIScreen.main.bounds.size.width - 48
        item.colorObject?.colorOpacityY = 13
        item.colorObject?.colorShadesX = UIScreen.main.bounds.size.width - 40
        item.colorObject?.colorShadesY = 8
        
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
    /// ADD INTERVAL ITEM
    ///
    private func addInterval(){
        guard let item else {debugPrint("Interval item is nil while addInterval");return}
        var array:[IntervalItem] = []
        if let setIntervalItem = item.intervalItem{
            for obj in setIntervalItem{
                if let intervalIte = obj as? IntervalItem{
                    array.append(intervalIte)
                }
            }
            if let intervalItem{
                array.append(intervalItem)
            }
        }else{
            if let intervalItem{
                array.append(intervalItem)
            }
        }
        item.intervalItem = NSSet(array: array)
        CoreDataManager.shared.saveContext()
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
    
    
    func indexUpdate(indices: IndexSet, newOffset: Int){
        intervalItems.move(fromOffsets: indices, toOffset: newOffset)
        for (index, _) in intervalItems.enumerated() {
            intervalItems[index].indexValue = Int64(index)
            
        }
        ///
        ///If item object is present then only it will be save otherwise object wiil be created for item
        ///
        if item != nil {
            item!.intervalItem = NSSet(array: intervalItems)
            CoreDataManager.shared.saveContext()
        }
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
    /// remove selected item
    ///
    func removeSelectedItem(intervalItem: IntervalItem){
        let removeData = selectedItems.filter{ $0 != intervalItem}
        selectedItems = removeData
    }
    
    // delete intervalItem functionality code using filter
    func deleteIntervalItems(){
        withAnimation{
            for selectedItem in selectedItems {
                CoreDataManager.shared.deleteNSManagedObject(object: selectedItem)
                intervalItems.removeAll(where: {$0.id == selectedItem.id})
            }
            for index in 0..<intervalItems.count{
                intervalItems[index].indexValue = Int64(index)
            }
            CoreDataManager.shared.saveContext()
        }
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
    ///Delete Single item taking paramter as IntervalItem itself
    ///
    func deleteSingleIntervalItemSwipe(intervalItem: IntervalItem){
        CoreDataManager.shared.deleteNSManagedObject(object: intervalItem)
        intervalItems = intervalItems.filter{$0 != intervalItem}
        
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
            break
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
            break
        }
    }
    func validationTimer()-> Bool{
        guard titleName.trimmingCharacters(in: .whitespaces) != "" else{
            textDesciptionBox = ["Name Field", "Rest Between Intervals", "Rest Between Rounds"]
            return false
        }
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
        guard breakTime.minTime.trimmingCharacters(in: .whitespaces) != "" && breakTime.minTime.trimmingCharacters(in: .whitespaces) != "00:00" else{
            textDesciptionBox = ["Name Field", "Rest Between Intervals Fields", "Rest Between Rounds Fields"]
            return false
        }
        if breakTime.random{
            guard breakTime.maxTime.trimmingCharacters(in: .whitespaces) != "" && breakTime.maxTime.trimmingCharacters(in: .whitespaces) != "00:00" else{
                textDesciptionBox = ["Name Field", "Rest Between Intervals(Min & Max) Fields", "Rest Between Rounds (Min & Max) Fields"]
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
    ///
    /// ON CHANGE SAVE DATA
    ///
    func onChangeSaveData(){
        changingValueBreakField(textFieldType: .RestBetweenInterval)
        changingValueBreakField(textFieldType: .RestBetweenRounds)
        isNoteBoxFocuse = false
    }
    ///
    ///Fetching all Data
    ///
    func fetchAllDataOnAppear(){
        debugPrint("FetchStartTime:", Date.now )
//            DispatchQueue.main.async{[weak self] in
              intervalItems = item?.intervalItem?.allObjects as? [IntervalItem] ?? []
               intervalItems.sort{$0.indexValue < $1.indexValue}
        indexChanging()
        displayTxtDict = AppComman.shared.generateStartTimeMap(intervalItems)
//                print("FetchData: \(Date.now)")
//            }
        debugPrint("FetchEndTime:", Date.now )
    }
    
    ///
    ///Import Error for the missing Field``(index 1)``, Missing csv``(index 2)`` or url and succes alert ``(index 3)``
    ///
    func handlingImportAlerts(index: Int){
        switch index{
        case 1:
            //Missing field in csv
            alertHeaderTitle = "ERROR: MISSING FIELDS"
            validationErrorMessage = "The file you’re uploading appears to have different headings than required for this interval session.\nPlease check your file has these exact headings"
            textDesciptionBox = ["CallName", "CallDuration", "CallColour", "ExcludeFromTime", "HalfwayAlert"]
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
        updateItemCsvDataAddtoExisting(itemData: itemData)
        var count = 0
        ///
        ///IN CASE OF EDIT ``itemData`` WILL USED
        ///IN CASE OF CREATE/ADD ``viewModel.item`` WILL BE USED
        ///
        let intervals = verifyTimerInterval(intervals: intervals ?? [])
        let _item = item == nil ? createItem() : item
        
        ///
        ///UPDATE ``indexValue`` OF IMPORTED INTERVALS
        ///
        let intervalCount = _item?.intervalItem?.allObjects.count ?? 0
        for index in 0..<(intervals ?? []).count{
            intervals?[index].indexValue = Int64(count + intervalCount)
            count += 1
        }
        
        _item?.intervalItem = NSSet(array: Array(item?.intervalItem?.allObjects as? [IntervalItem] ?? []) + (intervals ?? []))
        //Saving in database
        CoreDataManager.shared.saveContext()
        runWithDelay(delay: 0.5){[weak self] in
            self?.intervalItems = (_item?.intervalItem?.allObjects as? [IntervalItem] ?? []).sorted(by: {$0.indexValue < $1.indexValue})
            self?.displayTxtDict = AppComman.shared.generateStartTimeMap(self?.intervalItems ?? [])
        }
        
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
        ///
        let intervals = verifyTimerInterval(intervals: intervals ?? [])
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
        displayTxtDict = AppComman.shared.generateStartTimeMap(intervalItems)
        ///
        ///SET ``nil`` CSV URL AFTER IMPORTING INTERVALS
        ///
        csvUrl = nil
        
        handlingImportAlerts(index: 3)
    }
    func verifyTimerInterval(intervals: [IntervalItem])-> [IntervalItem]?{
        return intervals.filter{validationRandomData(breakTime: $0.intervalDuration ?? IntervalDuration())}
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
        restBetweenInterval.minTime =  AppComman.shared.handlingMilliseconds(timeString: itemData.restInterval?.minTime) /*?? ""*/
        restBetweenInterval.random = itemData.restInterval?.random ?? false
        restBetweenInterval.maxTime = AppComman.shared.handlingMilliseconds(timeString: itemData.restInterval?.maxTime) /*?? ""*/
        restBetweenRounds.minTime = AppComman.shared.handlingMilliseconds(timeString: itemData.restRound?.minTime)/* ?? ""*/
        restBetweenRounds.maxTime = AppComman.shared.handlingMilliseconds(timeString: itemData.restRound?.maxTime) /*?? ""*/
        restBetweenRounds.random = itemData.restRound?.random ?? false
        colureHexCode = itemData.itemColor ?? ""
//        colorOpacity = itemData?.colorObject?.alphaValue ?? 1.0
        vibrateOnAlert = itemData.vibrateOnAlert ?? false
        shuffle = itemData.shufffe ?? false
        totalNoOfRounds = itemData.restRound?.totalRounds ?? 0
        
       
        alertSong = itemData.alertName?.alertSong ?? ""
//        item?.setting?.audio = itemData.alertName?.alertSong ?? ""
//        item?.setting?.isTextToSpeech = itemData.alertName?.isTextToSpeech ?? false
//        item?.setting?.isNoAudio = itemData.alertName?.isNoAudio ?? false
//        item?.setting?.vibration = itemData.alertName?.vibrationName ?? ""
        
//        noteBoxText = itemData?.noteBox ?? ""
//        viewModel.updateAudioLabel()
    }
    
    ///
    ///Update Required
    ///
    func updateItemCsvDataAddtoExisting(itemData: ItemModelData?){
        guard let itemData = itemData else{return}
//        item = itemData
        if titleName.isEmpty{
            titleName = itemData.name ?? ""
            
            //        fetchAllDataOnAppear()
            //                        viewModel.intervalItems = itemData?.intervalItem?.allObjects as? [IntervalItem] ?? []
            //                        viewModel.intervalItems.sort{$0.indexValue < $1.indexValue}
            //
            
            colureHexCode = itemData.itemColor ?? ""
            //        colorOpacity = itemData?.colorObject?.alphaValue ?? 1.0
            vibrateOnAlert = itemData.vibrateOnAlert ?? false
            shuffle = itemData.shufffe ?? false
            
            
            
            alertSong = itemData.alertName?.alertSong ?? ""
        }
        
        if restBetweenRounds.minTime.isEmpty{
            restBetweenRounds.minTime = AppComman.shared.handlingMilliseconds(timeString: itemData.restRound?.minTime)/* ?? ""*/
            restBetweenRounds.maxTime = AppComman.shared.handlingMilliseconds(timeString: itemData.restRound?.maxTime) /*?? ""*/
            restBetweenRounds.random = itemData.restRound?.random ?? false
            totalNoOfRounds = itemData.restRound?.totalRounds ?? 0
        }
        
        if restBetweenInterval.minTime.isEmpty{
            restBetweenInterval.minTime =  AppComman.shared.handlingMilliseconds(timeString: itemData.restInterval?.minTime) /*?? ""*/
            restBetweenInterval.random = itemData.restInterval?.random ?? false
            restBetweenInterval.maxTime = AppComman.shared.handlingMilliseconds(timeString: itemData.restInterval?.maxTime) /*?? ""*/
        }
//        item?.setting?.audio = itemData.alertName?.alertSong ?? ""
//        item?.setting?.isTextToSpeech = itemData.alertName?.isTextToSpeech ?? false
//        item?.setting?.isNoAudio = itemData.alertName?.isNoAudio ?? false
//        item?.setting?.vibration = itemData.alertName?.vibrationName ?? ""
        
//        noteBoxText = itemData?.noteBox ?? ""
//        viewModel.updateAudioLabel()
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
}

