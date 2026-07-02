//
//  ImportExportCSV.swift
//  TIMER
//
//  Created by Aditya Maroo on 04/10/24.
//

import SwiftUI
import CoreData
import Compression

//MARK: -
//MARK: EXPORT CSV CLASS
enum IntervalImportError{
    case Name
    case Duration
    case Color
    case HalfWayAlert
    case Other
}

 //MARK: - Model for Item
struct ItemModelData{
    var name: String?
    var itemColor: String?
    var alertName: AlertModelData?
    var sessionRound: String?
    var vibrateOnAlert: Bool?
    var shufffe: Bool?
    var restInterval: IntervalTimeModelData?
    var intervalDuration: IntervalTimeModelData?
    var restRound: IntervalTimeModelData?
    
}

 //MARK: - Alert VibrationModel
struct AlertModelData{
    var isNoAudio: Bool?
    var alertSong: String?
    var isTextToSpeech: Bool?
    var vibrationName: String?
}

 //MARK: - IntervalRest Model
struct IntervalTimeModelData{
    var maxTime: String?
    var minTime: String?
    var random: Bool?
    var totalRounds: Int64?
}



//Zip File Error
enum CreateZipError: Swift.Error {
    case urlNotADirectory(URL)
    case failedToCreateZIP(Swift.Error)
}


enum ReactionImportError{
    case Name
    case IntervalCall
    case Color
}

//Paid Folder Model
struct PaidFolderModel{
    var folderName: String
    var folderColor: String
}

//

class ExportCSV {
    var csvFileURL: URL?
    var folderUrl: URL?
    private init(csvFileURL: URL? = nil) { self.csvFileURL = csvFileURL }
    private init() {}

    static var shared: ExportCSV = {
        return ExportCSV()
    }()

    /// EXPORT ITEMS TO CSV
    func exportItemsToCSV(from items: [Item]) {
        var csvString = "TimerName,TimerColour,Alert,Vibration,IntervalShuffle,ReactionSessionRound,ReactionSessionRoundHundredths,ReactionIntervalDurationMin,ReactionIntervalDurationMinHundredths,ReactionIntervalDurationMax,ReactionIntervalDurationMaxHundredths,RestBetweenIntervalsMin,RestBetweenIntervalsMinHundredths,RestBetweenIntervalsMax,RestBetweenIntervalsMaxHundredths,NumberOfRounds,RestBetweenRoundsMin,RestBetweenRoundsMinHundredths,RestBetweenRoundsMax,RestBetweenRoundsMaxHundredths,CallName,CallColour,ReactionMaxNumberOfCalls,CallDurationMin,CallDurationMinHundredths,CallDurationMax,CallDurationMaxHundredths,HalfWayAlert,MessageText,MessageDelay,MessageDelayHundredths\n"
        let baseCsvString = csvString
        let finalItems = flattenItems(items)
        for item in finalItems {
            // Fetch and format Item-level data
            var title = item.title ?? ""
            if title.contains(",") {
                title = "\"\(title)\"" // Wrap in double quotes
            }
            let type = item.type ?? ""
            if type == "Folder"{continue}
            
            var alertSong: String = ""
            if item.setting?.isNoAudio ?? false {
                alertSong = ""
            }
            else if !(item.setting?.isNoAudio ?? false){
                if item.setting?.isTextToSpeech ?? false{
                    alertSong = item.setting?.textToSpeech ?? "Without Count"
                }
                else{
                    alertSong = item.setting?.audio ?? "No Audio"
                }
            }
            if alertSong.contains(","){
                alertSong = "\"\(alertSong)\""
            }
//            let textToSpeach = item.setting?.isTextToSpeech ?? false ? "TRUE" : "FALSE"
//            let textToSpeechType = item.setting?.textToSpeech ?? "Without Count"
            let vibrationName = item.setting?.vibration ?? "One Vibration"
//            let isNoAudio = item.setting?.isNoAudio ?? false ? "TRUE" : "FALSE"
//            let indexValue = item.indexValue
//            let isChild = "FALSE"
//            let isSelected = "FALSE"
            let session = splitHourTimeComponents(from: item.session ?? "").0
            let sessionHundreth = splitHourTimeComponents(from: item.session ?? "").1
            let shuffle = item.shuffle ? "TRUE" : "FALSE"
            
//            let vibrateAlert = item.viibrateAlert ? "TRUE" : "FALSE"
            
            // Get color information from colorObject relationship
            let itemColorHex = item.colorObject?.colorHexCode ?? ""
//            let itemColorAlpha = item.colorObject?.alphaValue ?? 1.0
            
            //Rest Between Interval
            let restIntervalMin = splitTimeComponents(from: item.restBetweenInterval?.min ?? "").0
            let restIntervalMinHundreth = splitTimeComponents(from: item.restBetweenInterval?.min ?? "").1
            
            let restIntervalMax = splitTimeComponents(from: item.restBetweenInterval?.max ?? "").0
            let restIntervalMaxHundreth = splitTimeComponents(from: item.restBetweenInterval?.max ?? "").1
            
//            let restBetweenIntervals = minMaxDataToSingle(minData: restIntervalMin, maxData: restIntervalMax) ?? ""
//            let restIntervalRandom = item.restBetweenInterval?.random ?? false ? "TRUE" : "FALSE"
            
            //Rest Between Rounds
            let restRoundMin =  splitTimeComponents(from: item.restBetweenRounds?.min ?? "").0
            let restRoundMinHundredth = splitTimeComponents(from: item.restBetweenRounds?.min ?? "").1
            let restRoundMax = splitTimeComponents(from: item.restBetweenRounds?.max ?? "").0
            let restRoundMaxHundredth = splitTimeComponents(from: item.restBetweenRounds?.max ?? "").1
//            let restBetweenRounds = minMaxDataToSingle(minData: restRoundMin, maxData: restRoundMax) ?? ""
//            let restRoundRandom = item.restBetweenRounds?.random ?? false ? "TRUE" : "FALSE"
            let restTotalRounds = item.restBetweenRounds?.rounds ?? 1
            
            //IntervalDuratiom
            let intervalDurationMin = splitTimeComponents(from:  item.intervalDuration?.min ?? "").0
            let intervalDurationMinHundredth = splitTimeComponents(from:  item.intervalDuration?.min ?? "").1
            let intervalDurationMax = splitTimeComponents(from: item.intervalDuration?.max ?? "").0
            let intervalDurationMaxHundredth = splitTimeComponents(from: item.intervalDuration?.max ?? "").1
//            let intervalDuration = minMaxDataToSingle(minData: intervalDurationMin, maxData: intervalDurationMax) ?? ""
//            let intervalDurationRandom = item.intervalDuration?.random ?? false ? "TRUE" : "FALSE"
            
            // Base row for the item-level data
            let itemRow = "\(title),\(itemColorHex),\(alertSong),\(vibrationName),\(shuffle),\(session),\(sessionHundreth),\(intervalDurationMin),\(intervalDurationMinHundredth),\(intervalDurationMax),\(intervalDurationMaxHundredth),\(restIntervalMin),\(restIntervalMinHundreth),\(restIntervalMax),\(restIntervalMaxHundreth),\(restTotalRounds),\(restRoundMin),\(restRoundMinHundredth),\(restRoundMax),\(restRoundMaxHundredth)"
            
            // Fetch Interval Items (one-to-many relationship with Item)
            if let intervalItems = item.intervalItem as? Set<IntervalItem>, !intervalItems.isEmpty {
                let sortedIntervals = intervalItems.sorted { $0.indexValue < $1.indexValue } // Sorting by index
                
                for (intervalIndex, interval) in sortedIntervals.enumerated() {
                    var intervalName = interval.intervalName ?? ""
                    // Escape and format the intervalName
                    if intervalName.contains(",") {
                        intervalName = "\"\(intervalName)\"" // Wrap in double quotes
                    }
                    let intervalColorHex = interval.colorObject?.colorHexCode ?? ""
//                    let intervalColorAlpha = interval.colorObject?.alphaValue ?? 1.0
                    
                    let intervalDurationmin = splitTimeComponents(from: interval.intervalDuration?.min ?? "").0
                    let intervalDurationminHundredth = splitTimeComponents(from: interval.intervalDuration?.min ?? "").1
                    let intervalDurationMax = splitTimeComponents(from: interval.intervalDuration?.max ?? "").0
                    let intervalDurationMaxHundredth = splitTimeComponents(from: interval.intervalDuration?.max ?? "").1
//                    let intervalDurationIntervalData = minMaxDataToSingle(minData: intervalDurationmin, maxData: intervalDurationMax) ?? ""
//                    let intervalDurationRandom = (interval.intervalDuration?.random ?? false) ? "TRUE" : "FALSE"
                    
                    let intervalNumberCalls = interval.intervalCall?.maxNumber ?? 0 == 0 ? "" : "\(interval.intervalCall?.maxNumber ?? 0)"
//                    let intervalNumberCalsRandom = (interval.intervalCall?.random ?? false) ? "TRUE" : "FALSE"
                    let halfWayAlert = (interval.halfWayAlert) ? "TRUE" : "FALSE"
                    // For the first interval item, add item details; otherwise, leave those columns empty
                    let intervalRow = intervalIndex == 0 ? "\(itemRow),\(intervalName),\(intervalColorHex),\(intervalNumberCalls),\(intervalDurationmin),\(intervalDurationminHundredth),\(intervalDurationMax),\(intervalDurationMaxHundredth),\(halfWayAlert)" : ",,,,,,,,,,,,,,,,,,,,\(intervalName),\(intervalColorHex),\(intervalNumberCalls),\(intervalDurationmin),\(intervalDurationminHundredth),\(intervalDurationMax),\(intervalDurationMaxHundredth),\(halfWayAlert)"
                    
                    // Fetch Message Items (one-to-many relationship with IntervalItem)
                    if let messageItems = interval.messageItems as? Set<MessageItems>, !messageItems.isEmpty {
                        let sortedMessages = messageItems.sorted { $0.indexValue < $1.indexValue } // Sorting by index
                        
                        for (messageIndex, message) in sortedMessages.enumerated() {
                            var messageName = message.messageName ?? ""
                            if messageName.contains(","){
                                messageName = "\"\(messageName)\""
                            }
                            let messageDelay = splitTimeComponents(from: message.delay ?? "").0
                            let messageDelayHundredth = splitTimeComponents(from: message.delay ?? "").1
                            
                            // For the first message, add interval details; otherwise, leave those columns empty
                            let messageRow = messageIndex == 0 ? "\(intervalRow),\(messageName),\(messageDelay),\(messageDelayHundredth)" : ",,,,,,,,,,,,,,,,,,,,,,,,,,,,\(messageName),\(messageDelay),\(messageDelayHundredth)"
                            csvString.append("\(messageRow)\n")
                        }
                    } else {
                        // If no message items, just append the interval row
                        csvString.append("\(intervalRow)\n")
                    }
                }
            } else {
                // If no intervals, append just the item row
                csvString.append("\(itemRow)\n")
            }
            debugPrint(csvString)
            saveCSVFile(csvString: csvString, fileName: item.title?.replacingOccurrences(of: "/", with: "_") ?? "PBIntervals\(item.indexValue)")
            csvString.removeAll()
            csvString.append(baseCsvString)
        }
//        saveCSVFile(csvString: csvString, fileName: items.first?.title ?? "PBIntervals")
        guard let directoryURL = getDirectoryURL() else { return }
        do{
            csvFileURL = try createZipAtTmp(zipFilename: "PBIntervalsApp\(Date.now)", fromDirectory: folderUrl ?? directoryURL)
        }
        catch{
            debugPrint("Folder Not Created")
        }
    }


    ///
    /// TO MANAGE FOLDER ITEMS
    /// ADD ALL THE CHILDREN IN THE MAIN ARRAY
    ///
   private func flattenItems(_ items: [Item]) -> [Item] {
        var result: [Item] = []
        
        for item in items {
            // Append the current item to the result
            result.append(item)
            
            // If the item is a folder, recursively process its children
            if item.type == "Folder", let children = item.children?.allObjects as? [Item] {
                result.append(contentsOf: flattenItems(children))
            }
        }
        
        return result
    }


    /// Save CSV file to local storage
    private func saveCSVFile(csvString: String, fileName: String) {
//        let fileName = "\(fileName).csv"
//        let tempDirectory = FileManager.default.temporaryDirectory
//        let fileURL = tempDirectory.appendingPathComponent(fileName)
        guard let directoryURL = getDirectoryURL() else { return }
        let fileURL = directoryURL.appendingPathComponent("\(fileName).csv")
        do {
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
//            csvFileURL = fileURL
        } catch {
            print("Failed to save CSV file: \(error)")
        }
    }
    
    /// Folder URl
    func getDirectoryURL() -> URL? {
            let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
                print("Could not find documents directory")
                return nil
            }
            
        let folderURL = documentsDirectory.appendingPathComponent("PBIntervalsCSVFiles\(Date.now)")
            folderUrl = folderURL
            if !fileManager.fileExists(atPath: folderURL.path) {
                do {
                    try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print("Error creating directory: \(error)")
                    return nil
                }
            }
            
            return folderURL
        }
    
    //Zip Initializer
    func createZipAtTmp(
        zipFilename: String,
        zipExtension: String = "zip",
        fromDirectory directoryURL: URL
    ) throws -> URL {
        let finalURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(zipFilename)
            .appendingPathExtension(zipExtension)
        return try createZip(
            zipFinalURL: finalURL,
            fromDirectory: directoryURL
        )
    }

    
    
    //Zip File Code
    private func createZip(
        zipFinalURL: URL,
        fromDirectory directoryURL: URL
    ) throws -> URL {
        // see URL extension below
        guard directoryURL.isDirectory else {
            throw CreateZipError.urlNotADirectory(directoryURL)
        }
        
        var fileManagerError: Swift.Error?
        var coordinatorError: NSError?
        let coordinator = NSFileCoordinator()
        coordinator.coordinate(
            readingItemAt: directoryURL,
            options: .forUploading,
            error: &coordinatorError
        ) { zipCreatedURL in
            do {
                // will fail if file already exists at finalURL
                // use `replaceItem` instead if you want "overwrite" behavior
                try FileManager.default.moveItem(at: zipCreatedURL, to: zipFinalURL)
            } catch {
                fileManagerError = error
            }
        }
        if let error = coordinatorError ?? fileManagerError {
            throw CreateZipError.failedToCreateZIP(error)
        }
        return zipFinalURL
    }
    
    
    //Converting Min and Max string Data to One String
   private func minMaxDataToSingle(minData: String?, maxData: String?)->String?{
       guard let minData = minData, !minData.isEmpty else{
            return ""
        }
       guard let maxData = maxData, !maxData.isEmpty else{
            return minData /*+ ":00"*/
        }
        return minData + /*":00" +*/  "-" + maxData /*+ ":00"*/
    }
    
    /// Splits a time string into (`mm:ss`, `ms`) *only when* `ms` is valid.
    /// If `ms` is missing/invalid, returns (`original`, "").
    func splitTimeComponents(from timeInput: String) -> (String, String) {
        let parts = timeInput.split(separator: ":").map(String.init)
        guard parts.count >= 2 else { return ("", "") }          // malformed

        // Handle milliseconds safely
        let rawMS = parts.count > 2 ? parts[2] : ""              // "" when absent
        guard let ms = normalizeMilliseconds(rawMS) else {
            return ("00:" + timeInput, "")                               // keep original
        }

        // Build mm:ss using the first two parts
        let mm = String(format: "%02d", Int(parts[0]) ?? 0)
        let ss = String(format: "%02d", Int(parts[1]) ?? 0)
        return ("00:\(mm):\(ss)", ms)
    }
    
    /// Splits a `hh:mm:ss(:ms)` string into (`hh:mm:ss`, `ms`).
    /// If `ms` is missing/invalid, returns (`original`, "").
    func splitHourTimeComponents(from timeInput: String) -> (String, String) {
        let parts = timeInput.split(separator: ":").map(String.init)
        guard parts.count >= 3 else { return ("", "") }          // need hh, mm, ss

        // Milliseconds part (safe access)
        let rawMS = parts.count > 3 ? parts[3] : ""
        guard let ms = normalizeMilliseconds(rawMS) else {
            return (timeInput, "")                               // keep original
        }

        // Build hh:mm:ss (each component two digits)
        let hh = String(format: "%02d", Int(parts[0]) ?? 0)
        let mm = String(format: "%02d", Int(parts[1]) ?? 0)
        let ss = String(format: "%02d", Int(parts[2]) ?? 0)
        return ("\(hh):\(mm):\(ss)", ms)
    }

    /// Converts the raw ms string to exactly two digits, or nil if impossible.
    /// Rule: "5" → "50", "37" → "37"; "", "123" → nil.
    private func normalizeMilliseconds(_ s: String) -> String? {
        switch s.count {
        case 2:  return s
        case 1:  return s + "0"
        default: return nil
        }
    }
}



//MARK: -
//MARK: ENUM TO GET INDEX BASED ON CSV HEADER
private enum CSVHeader: String {
    case TimerName                       = "TimerName"
       case TimerColour                     = "TimerColour"
       case Alert                           = "Alert"
       case Vibration                       = "Vibration"
       case ReactionSessionRound            = "ReactionSessionRound"
       case ReactionSessionRoundHund        = "ReactionSessionRoundHundredths"
       case ReactionIntervalDurationMin     = "ReactionIntervalDurationMin"
       case ReactionIntervalDurationMinHundredths = "ReactionIntervalDurationMinHundredths"
       case ReactionIntervalDurationMax     = "ReactionIntervalDurationMax"
       case ReactionIntervalDurationMaxHundredths = "ReactionIntervalDurationMaxHundredths"
       case RestBetweenIntervalsMin         = "RestBetweenIntervalsMin"
       case RestBetweenIntervalsMinHundredths = "RestBetweenIntervalsMinHundredths"
       case RestBetweenIntervalsMax         = "RestBetweenIntervalsMax"
       case RestBetweenIntervalsMaxHundredths = "RestBetweenIntervalsMaxHundredths"
       case NumberOfRounds                  = "NumberOfRounds"
       case RestBetweenRoundsMin            = "RestBetweenRoundsMin"
       case RestBetweenRoundsMinHundredths  = "RestBetweenRoundsMinHundredths"
       case RestBetweenRoundsMax            = "RestBetweenRoundsMax"
       case RestBetweenRoundsMaxHundredths  = "RestBetweenRoundsMaxHundredths"
       case IntervalShuffle                 = "IntervalShuffle"
       case CallName                        = "CallName"
       case CallColour                      = "CallColour"
       case ReactionMaxNumberOfCalls        = "ReactionMaxNumberOfCalls"
       case CallDurationMin                 = "CallDurationMin"
       case CallDurationMinHundredths       = "CallDurationMinHundredths"
       case CallDurationMax                 = "CallDurationMax"
       case CallDurationMaxHundredths       = "CallDurationMaxHundredths"
       case HalfWayAlert                    = "HalfWayAlert"
       case MessageText                     = "MessageText"
       case MessageDelay                    = "MessageDelay"
       case MessageDelayHundredths          = "MessageDelayHundredths"
    
//    case title = "TimerName"
//    case type = "Type"
//    case alertSong = "Alert"
//    case textToSpecch = "TextToSpeech"
//    case TextToSpeechType = "TextToSpeechType"
//    case vibrationName = "Vibration"
//    case NoAudio = "NoAudio"
////    case indexValue = "Index Value"
////    case isChild = "Is Child"
////    case isSelected = "Is Selected"
//    case session = "ReactionSessionRound"
//    case seesionHundreth = "ReactionSessionRoundHundredths"
//    case intervalDurationMin = "ReactionIntervalDurationMin"
//    case intervalDurationHundreth = ""
//    
//    case shuffle = "Shuffle"
//    case vibrateAlert = "VibrateOnAlert"
//    case itemColorHex = "TimerColour"
//    case itemColorAlpha = "Item Color Alpha"
//    case intervalName = "CallName"
//    case intervalColorHex = "CallColour"
//    case intervalColorAlpha = "IntervalColorAlpha"
//   
//    case itemIntervalDurationRandom = "RandomInterval"
//    case callDuration = "CallDuration"
//    case intervalRandom = "IntervalRandom"
//    case restBetweenIntervals = "RestBetweenIntervals"
//    case restIntervalRandom = "RandomIntervals"
//    case restBetweenRounds = "RestBetweenRounds"
//    case roundIntervalRandom = "RandomRounds"
//    case totalRounds = "NumberOfRounds"
//    case intervalCalls = "MaxNumberOfCalls"
//    case intervalCallsRandom = "IntervalCallRandom"
//    case intervalHalfWay = "HalfWayAlert"
//    case messageName = "MessageTitle"
//    case messageDelay = "Delay"
}

enum CsvFileType: String{
    case Drill
    case Timer
    case Interval
    case reaction
}

//MARK: -
//MARK: IMPORT CSV CLASS
class ImportCSV {
    
    /// SHARED OBJECT
    static var shared: ImportCSV = {
        return ImportCSV()
    }()
    
    private init() {}
    
    /// IMPORT CSV FROM URL
    func importFromCSV(url: URL, fileType: FileType) -> (itemCount: Int, intervalArray: [IntervalItem], isValidated:Bool, intervalImportError:Set<IntervalImportError>, intervalReactionError: Set<ReactionImportError>, itemData: ItemModelData?)? {
        
        /// ACCESS SECURITY SCOPE
        if url.startAccessingSecurityScopedResource() {
            return getIntervals(url: url, fileType: fileType)
        } else {
            debugPrint("security scope is disabled")
        }
        return nil
    }
    
    /// GET INTERVALS FROM CSV
    private func getIntervals(url: URL, fileType: FileType) -> (itemCount: Int, intervalArray: [IntervalItem], isValidated:Bool, intervalImportError:Set<IntervalImportError>, intervalReactionError: Set<ReactionImportError>,itemData: ItemModelData?)?{
        var items = [Item]()
        var currentInterval: IntervalItem?
        var itemModelData: ItemModelData?
        var intervals = [IntervalItem]()
        var isValidCSV:Bool = true
        var intervalErrorSet = Set<IntervalImportError>()
        var intervalReactionErrorSet = Set<ReactionImportError>()
        
        
        // Read CSV file content
        let csvString: String
        do {
            csvString = try String(contentsOf: url, encoding: .utf8)
        } catch {
            // Try fallback encodings if UTF-8 fails
            do {
                csvString = try String(contentsOf: url, encoding: .isoLatin1)
            } catch {
                do {
                    csvString = try String(contentsOf: url, encoding: .windowsCP1252)
                } catch {
                    // Log or return error if all fail
                    print("Failed to import CSV data: \(error)")
                    intervalErrorSet.insert(.Other)
                    return nil
                }
            }
        }
        debugPrint(csvString)
        var rows = csvString.components(separatedBy: "\n").filter { !$0.isEmpty }
        
        
        let headers = Array(rows.removeFirst().components(separatedBy: ",").map{$0.trimmingCharacters(in: .whitespaces)})
        let headerIndexMap = mapHeadersToIndices(headers: headers)
        
        switch fileType{
                
            case .Timer:
                let timerImportData = importTimerInterval(headerIndexMap: headerIndexMap, rows: rows)
                intervals = timerImportData?.intervalArray ?? []
                intervalErrorSet = timerImportData?.intervalImportError ?? []
                isValidCSV = timerImportData?.isValidated ?? true
                itemModelData = timerImportData?.itemData
                break
            case .Drill:
                let drillImportData = importDrillInterval(headerIndexMap: headerIndexMap, rows: rows)
                intervals = drillImportData?.intervalArray ?? []
                intervalReactionErrorSet = drillImportData?.drillImportError ?? []
                isValidCSV = drillImportData?.isValidated ?? true
                itemModelData = drillImportData?.itemData
                break
            case .Folder:
                break
        }
        
        debugPrint(itemModelData ?? "")
        return (items.count, intervals, isValidCSV, intervalErrorSet, intervalReactionErrorSet, itemModelData)
    }
    
    ///
    ///For timer Interval
    ///
    private func importTimerInterval(headerIndexMap: [CSVHeader: Int], rows: [String])->(intervalArray: [IntervalItem], isValidated:Bool, intervalImportError:Set<IntervalImportError>, itemData: ItemModelData?)?{
        let headerIndexMap = headerIndexMap
        var currentInterval: IntervalItem?
        var currentItem = ItemModelData()
        var indexValue = 0
        var isValidCSV:Bool = true
        var intervals = [IntervalItem]()
        var intervalErrorSet = Set<IntervalImportError>()
        do{
            for row in rows {
                // Skip header row
                debugPrint()
                
                let columns = parseCSVRow(row) /*row.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }*/
                debugPrint(columns)
                var intervalDuration = ""
                var intervalName: String = ""
                if let intervalNameIndex = headerIndexMap[.CallName], columns.count > intervalNameIndex{
                    intervalName = columns[intervalNameIndex]
                }
                if let intervalDurationIndex = headerIndexMap[.CallDurationMin], columns.count > intervalDurationIndex {
                    intervalDuration = columns[intervalDurationIndex]
                }
                
                if let titleNameIndex = headerIndexMap[.TimerName], columns.count > titleNameIndex, !columns[titleNameIndex].isEmpty{
                    currentItem.name = columns[titleNameIndex]
                    
                    //Audio
                    if let alertAudioIndex = headerIndexMap[.Alert], columns.count > alertAudioIndex{
                        if currentItem.alertName == nil{
                            currentItem.alertName = AlertModelData()
                        }
                        if columns[alertAudioIndex].isEmpty{
                            currentItem.alertName?.isNoAudio = true
                        }
                        else{
                            if checkTextToSpeech(alert: columns[alertAudioIndex]){
                                currentItem.alertName?.isTextToSpeech = true
                                currentItem.alertName?.isNoAudio = false
                            }
                            else {
                                currentItem.alertName?.isTextToSpeech = false
                                currentItem.alertName?.isNoAudio = false
                            }
                        }
                        currentItem.alertName?.alertSong = columns[alertAudioIndex]
                    }
                    //                    if let isAlertAudioIndex = headerIndexMap[.NoAudio], columns.count > isAlertAudioIndex{
                    //                        currentItem.alertName?.isNoAudio = columns[isAlertAudioIndex].uppercased() == "TRUE"
                    //                    }
                    //                    if let isTextSpeechIndex = headerIndexMap[.textToSpecch], columns.count > isTextSpeechIndex{
                    //                        currentItem.alertName?.isTextToSpeech = columns[isTextSpeechIndex].uppercased() == "TRUE"
                    //                    }
                    //                    if let TextSpeechIndex = headerIndexMap[.TextToSpeechType], columns.count > TextSpeechIndex{
                    //                        if !columns[TextSpeechIndex].isEmpty{
                    //                            currentItem.alertName?.alertSong = columns[TextSpeechIndex]
                    //                        }
                    //                    }
                    if let vibrationData = headerIndexMap[.Vibration], columns.count > vibrationData{
                        currentItem.alertName?.vibrationName = columns[vibrationData]
                    }
                    
                    //Color, Shuffle, Vibrateon Alert
                    currentItem.itemColor = columns[headerIndexMap[.TimerColour] ?? 0]
                    
                    currentItem.vibrateOnAlert = columns[headerIndexMap[.Vibration] ?? 0].lowercased() == "true"
                    
                    currentItem.shufffe = columns[headerIndexMap[.IntervalShuffle] ?? 0].uppercased() == "TRUE"
                    
                    //Rest Interval
                    if let restIntervalMinIndex = headerIndexMap[.RestBetweenIntervalsMin], columns.count > restIntervalMinIndex{
                        if currentItem.restInterval == nil {
                            currentItem.restInterval = IntervalTimeModelData()
                        }
                        //                        let restIntervalMinHundredrh = columns[headerIndexMap[.RestBetweenRoundsMinHundredths]]
                        //
                        //
                        //                        let minString =  columns[restIntervalMinIndex]
                        //                        let maxString = splitData.last ?? ""
                        //                        currentItem.restInterval?.minTime = handlingMillisecondsCSV(timeString: minString)
                        //                        currentItem.restInterval?.maxTime = handlingMillisecondsCSV(timeString: maxString)
                        //                        currentItem.restInterval?.random = checkRandomPresent(timeString: columns[restIntervalIndex])
                        //                    }
                        currentItem.restInterval = handlingDataDurationData(min: headerIndexMap[.RestBetweenIntervalsMin], max: headerIndexMap[.RestBetweenIntervalsMax], minH: headerIndexMap[.RestBetweenIntervalsMinHundredths], maxH: headerIndexMap[.RestBetweenIntervalsMaxHundredths], coloumns: columns)
                        
                    }
                    
                    
                    //Rest Round
                    if let restRoundIndex = headerIndexMap[.RestBetweenRoundsMin], columns.count > restRoundIndex{
                        if currentItem.restRound == nil {
                            currentItem.restRound = IntervalTimeModelData()
                        }
                        
                        currentItem.restRound = handlingDataDurationData(min: headerIndexMap[.RestBetweenRoundsMin], max: headerIndexMap[.RestBetweenRoundsMax], minH: headerIndexMap[.RestBetweenRoundsMinHundredths], maxH: headerIndexMap[.RestBetweenRoundsMaxHundredths], coloumns: columns)
                        //                        let splitData = singleDataToMinMax(breakValue: columns[restRoundIndex]) ?? []
                        //
                        //                        let minString = splitData.first ?? ""
                        //                        let maxString = splitData.last ?? ""
                        //                        currentItem.restRound?.minTime = handlingMillisecondsCSV(timeString: minString)
                        //                        currentItem.restRound?.maxTime = handlingMillisecondsCSV(timeString: maxString)
                        //
                        //                        currentItem.restRound?.random = checkRandomPresent(timeString: columns[restRoundIndex])
                    }
                    
                    //                    currentItem.restRound?.random = columns[headerIndexMap[.roundIntervalRandom] ?? 0].uppercased() == "TRUE"
                    currentItem.restRound?.totalRounds = Int64(columns[headerIndexMap[.NumberOfRounds] ?? 0])
                    
                }
                
                //                else{
                //                    intervalErrorSet.insert(.Name)
                //                    intervalReactionErrorSet.insert(.Name)
                //                }
                // Check for IntervalItem details in this row
                if !intervalName.isEmpty && !intervalDuration.isEmpty{
                    // New IntervalItem creation
                    currentInterval = IntervalItem(context: CoreDataManager.shared.context)
                    currentInterval?.intervalName = intervalName
                    
                    // Assign color object to IntervalItem
                    let intervalColorObject = ColorObject(context: CoreDataManager.shared.context)
                    
                    // Safely access columns based on header enum
                    if let colorHexIndex = headerIndexMap[.CallColour], columns.count > colorHexIndex {
                        intervalColorObject.colorHexCode = columns[colorHexIndex]
                        intervalColorObject.alphaValue = 1
                    }
                    else{
                        intervalErrorSet.insert(.Color)
                        //                    intervalReactionErrorSet.insert(.Color)
                    }
                    
                    //                    if let colorAlphaIndex = headerIndexMap[.c], columns.count > colorAlphaIndex {
                    //                        intervalColorObject.alphaValue = Double(columns[colorAlphaIndex]) ?? 1.0
                    //                    }
                    
                    currentInterval?.colorObject = intervalColorObject
                    
                    if let callDuration = headerIndexMap[.CallDurationMin], columns.count > callDuration {
                        currentInterval?.intervalDuration = IntervalDuration(context: CoreDataManager.shared.context)
                        //                        let splitData = singleDataToMinMax(breakValue: columns[callDuration]) ?? []
                        //
                        //                        let minString = splitData.first ?? ""
                        //                        let maxString = splitData.last ?? ""
                        //                        currentInterval?.intervalDuration?.min = handlingMillisecondsCSV(timeString: minString)
                        //                        currentInterval?.intervalDuration?.max = handlingMillisecondsCSV(timeString: maxString)
                        //                        if minString?.count == 8{
                        //                           var data = minString?.split(separator: ":")
                        //                            currentInterval?.intervalDuration?.min = "\(data?[0] ?? "00")" + ":" + "\(data?[1] ?? "00")"
                        //                            debugPrint(currentInterval?.intervalDuration?.min)
                        //                            currentInterval?.intervalDuration?.minMilliSeconds = "\(data?.last ?? ":00")"
                        //                        }
                        //                        if maxString?.count == 8{
                        //                            var data = maxString?.split(separator: ":")
                        //                            currentInterval?.intervalDuration?.max = "\(data?[0] ?? "00")" + ":" + "\(data?[1] ?? "00")"
                        //                            currentInterval?.intervalDuration?.maxMilliSeconds = "\(data?.last ?? ":00")"
                        //                        }
                        //                        else if maxString?.count != 8 && minString?.count != 8{
                        //                            currentInterval?.intervalDuration?.min = splitData.first ?? ""
                        //                            currentInterval?.intervalDuration?.max = splitData.last ?? ""
                        //                        }
                        //                        currentInterval?.intervalDuration?.random = checkRandomPresent(timeString: columns[callDuration])
                        currentInterval?.intervalDuration = handlingCoreDataDurationData(min: headerIndexMap[.CallDurationMin], max: headerIndexMap[.CallDurationMax], minH: headerIndexMap[.CallDurationMinHundredths], maxH: headerIndexMap[.CallDurationMaxHundredths], coloumns: columns, intervalDuration: currentInterval?.intervalDuration)
                    }
                    else{
                        intervalErrorSet.insert(.Duration)
                    }
                    //                    var intervalImportErrors:Set<IntervalImportError> = Set<intervalErrorSet>()
                    
                    //                    if let intervalRandomIndex = headerIndexMap[.intervalRandom], columns.count > intervalRandomIndex {
                    //                        currentInterval?.intervalDuration?.random = columns[intervalRandomIndex].lowercased() == "true" ? true : false
                    //                    }
                    
                    if let halfWayAlertIndex = headerIndexMap[.HalfWayAlert], columns.count > halfWayAlertIndex {
                        currentInterval?.halfWayAlert = columns[halfWayAlertIndex] == "TRUE" ? true : false
                    }
                    else{
                        intervalErrorSet.insert(.HalfWayAlert)
                    }
                    currentInterval?.indexValue = Int64(indexValue)
                    indexValue+=1
                    intervals.append(currentInterval ?? IntervalItem())
                    
                    /// Ensure we have a current Interval to work with
                    guard let interval = currentInterval else { try CoreDataManager.shared.context.save(); continue }
                    
                    //Validation of Message
                    intervalErrorSet = importIntervalMessage(headerIndexMap: headerIndexMap, columns: columns)?.0 ?? []
                    let messageData = importIntervalMessage(headerIndexMap: headerIndexMap, columns: columns)?.1
                    if !intervalErrorSet.contains(.Other) && intervalErrorSet.isEmpty{
                        ///Adding MessageData
                        guard let messageData = messageData else{continue}
                        interval.addToMessageItems(messageData)
                    }
                    else{
                        CoreDataManager.shared.deleteNSManagedObject(object: interval)
                        break
                    }
                }
                else{
                    /// Ensure we have a current Interval to work with
                    guard let interval = currentInterval else { try CoreDataManager.shared.context.save(); continue }
                    //Validation of Message
                    intervalErrorSet = importIntervalMessage(headerIndexMap: headerIndexMap, columns: columns)?.0 ?? []
                    let messageData = importIntervalMessage(headerIndexMap: headerIndexMap, columns: columns)?.1
                    if !intervalErrorSet.contains(.Other) && intervalErrorSet.isEmpty{
                        ///Adding MessageData
                        guard let messageData = messageData else{continue}
                        interval.addToMessageItems(messageData)
                    }
                    else{
                        CoreDataManager.shared.deleteNSManagedObject(object: interval)
                        intervalErrorSet.insert(.Name)
                        break
                    }
                    
                }
            }
            
            
            // Save all items to Core Data
            try CoreDataManager.shared.context.save()
        }
        catch let error{
            isValidCSV = false
            debugPrint(error.localizedDescription)
        }
        return (intervals, isValidCSV, intervalErrorSet, currentItem)
    }
    
    ///
    ///Parser for Drill Interval or Reaction Interval
    ///
    private func importDrillInterval(headerIndexMap: [CSVHeader: Int], rows: [String])->(intervalArray: [IntervalItem], isValidated:Bool, drillImportError:Set<ReactionImportError>, itemData: ItemModelData?)?{
        var headerIndexMap = headerIndexMap
        var currentInterval: IntervalItem?
        var currentItem = ItemModelData()
        var indexValue = 0
        var isValidCSV:Bool = true
        var intervals = [IntervalItem]()
        var intervalReactionErrorSet = Set<ReactionImportError>()
        do{
            for row in rows {  // Skip header row
                let columns =  parseCSVRow(row)/*row.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }*/
                
                
                var intervalDuration = ""
                var intervalName: String = ""
                if let intervalNameIndex = headerIndexMap[.CallName], columns.count > intervalNameIndex{
                    intervalName = columns[intervalNameIndex]
                }
                if let callDurationRandom = headerIndexMap[.CallDurationMin], columns.count > callDurationRandom {
                    intervalDuration = columns[callDurationRandom]
                }
                
                if let titleNameIndex = headerIndexMap[.TimerName], columns.count > titleNameIndex, !columns[titleNameIndex].isEmpty{
                    currentItem.name = columns[titleNameIndex]
                    
                    //Audio
                    if let alertAudioIndex = headerIndexMap[.Alert], columns.count > alertAudioIndex{
                        if currentItem.alertName == nil{
                            currentItem.alertName = AlertModelData()
                        }
                        if columns[alertAudioIndex].isEmpty{
                            currentItem.alertName?.isNoAudio = true
                        }
                        else{
                            if checkTextToSpeech(alert: columns[alertAudioIndex]){
                                currentItem.alertName?.isTextToSpeech = true
                                currentItem.alertName?.isNoAudio = false
                            }
                            else {
                                currentItem.alertName?.isTextToSpeech = false
                                currentItem.alertName?.isNoAudio = false
                            }
                        }
                        currentItem.alertName?.alertSong = columns[alertAudioIndex]
                    }
                    if let vibrationData = headerIndexMap[.Vibration], columns.count > vibrationData{
                        currentItem.alertName?.vibrationName = columns[vibrationData]
                    }
                    
                    //Color, Shuffle, Vibrateon Alert
                    currentItem.itemColor = columns[headerIndexMap[.TimerColour] ?? 0]
                    currentItem.vibrateOnAlert = columns[headerIndexMap[.Vibration] ?? 0].lowercased() == "true"
                    currentItem.shufffe = columns[headerIndexMap[.IntervalShuffle] ?? 0].uppercased() == "TRUE"
                    let milliseconds = ":" + columns[headerIndexMap[.ReactionSessionRoundHund] ?? 0]
                    currentItem.sessionRound = columns[headerIndexMap[.ReactionSessionRound] ?? 0] + (milliseconds.count == 1 ? "" : milliseconds)
                    
                    //Rest Interval
                    if let restIntervalIndex = headerIndexMap[.RestBetweenIntervalsMin], columns.count > restIntervalIndex{
                        if currentItem.restInterval == nil {
                            currentItem.restInterval = IntervalTimeModelData()
                        }
                        //                        let splitData = singleDataToMinMax(breakValue: columns[restIntervalIndex]) ?? []
                        //
                        //                        let minString = splitData.first ?? ""
                        //                        let maxString = splitData.last ?? ""
                        //                        currentItem.restInterval?.minTime = handlingMillisecondsCSV(timeString: minString)
                        //                        currentItem.restInterval?.maxTime = handlingMillisecondsCSV(timeString: maxString)
                        ////                        if minString?.count == 8{
                        ////                           var data = minString?.split(separator: ":")
                        ////                            currentItem.restInterval?.minTime = "\(data?[0] ?? "00")" + ":" + "\(data?[1] ?? "00")"
                        ////                            debugPrint(currentItem.restInterval?.minTime)
                        ////                        }
                        ////                        if maxString?.count == 8{
                        ////                            var data = maxString?.split(separator: ":")
                        ////                            currentItem.restInterval?.maxTime = "\(data?[0] ?? "00:")" + ":" + "\(data?[1] ?? "00")"
                        ////                        }
                        ////                        else if maxString?.count != 8 && minString?.count != 8{
                        ////                            currentItem.restInterval?.minTime = splitData.first ?? ""
                        ////                            currentItem.restInterval?.maxTime = splitData.last ?? ""
                        ////                        }
                        //                        currentItem.restInterval?.random = checkRandomPresent(timeString: columns[restIntervalIndex])
                        
                        currentItem.restInterval = handlingDataDurationData(min: headerIndexMap[.RestBetweenIntervalsMin], max: headerIndexMap[.RestBetweenIntervalsMax], minH: headerIndexMap[.RestBetweenIntervalsMinHundredths], maxH: headerIndexMap[.RestBetweenIntervalsMaxHundredths], coloumns: columns)
                    }
                    
                    //                    currentItem.restInterval?.random = columns[headerIndexMap[.restIntervalRandom] ?? 0].uppercased() == "TRUE"
                    
                    
                    //Rest Round
                    if let restRoundIndex = headerIndexMap[.RestBetweenRoundsMin], columns.count > restRoundIndex{
                        if currentItem.restRound == nil {
                            currentItem.restRound = IntervalTimeModelData()
                        }
                        //                        let splitData = singleDataToMinMax(breakValue: columns[restRoundIndex]) ?? []
                        //
                        //                        let minString = splitData.first ?? ""
                        //                        let maxString = splitData.last ?? ""
                        //                        currentItem.restRound?.minTime = handlingMillisecondsCSV(timeString: minString)
                        //                        currentItem.restRound?.maxTime = handlingMillisecondsCSV(timeString: maxString)
                        //                        if minString?.count == 8{
                        //                           var data = minString?.split(separator: ":")
                        //                            currentItem.restRound?.minTime = "\(data?[0] ?? "00")" + ":" + "\(data?[1] ?? "00")"
                        //                            debugPrint(currentItem.restRound?.minTime)
                        //                        }
                        //                        if maxString?.count == 8{
                        //                            var data = maxString?.split(separator: ":")
                        //                            currentItem.restRound?.maxTime = "\(data?[0] ?? "00")" + ":" + "\(data?[1] ?? "00")"
                        //                        }
                        //                        else if maxString?.count != 8 || minString?.count != 8{
                        //                            currentItem.restRound?.minTime = splitData.first ?? ""
                        //                            currentItem.restRound?.maxTime = splitData.last ?? ""
                        //                        }
                        //                        currentItem.restRound?.random = checkRandomPresent(timeString: columns[restRoundIndex])
                        currentItem.restRound = handlingDataDurationData(min: headerIndexMap[.RestBetweenRoundsMin], max: headerIndexMap[.RestBetweenRoundsMax], minH: headerIndexMap[.RestBetweenRoundsMinHundredths], maxH: headerIndexMap[.RestBetweenRoundsMaxHundredths], coloumns: columns)
                        
                    }
                    
                    //                    currentItem.restRound?.random = columns[headerIndexMap[.roundIntervalRandom] ?? 0].uppercased() == "TRUE"
                    currentItem.restRound?.totalRounds = Int64(columns[headerIndexMap[.NumberOfRounds] ?? 0])
                    
                    //IntervalDuration
                    if let intervalDurationIndex = headerIndexMap[.ReactionIntervalDurationMin], columns.count > intervalDurationIndex{
                        if currentItem.intervalDuration == nil {
                            currentItem.intervalDuration = IntervalTimeModelData()
                        }
                        //                        let splitData = singleDataToMinMax(breakValue: columns[intervalDurationIndex]) ?? []
                        //
                        //                        let minString = splitData.first ?? ""
                        //                        let maxString = splitData.last ?? ""
                        //                        currentItem.intervalDuration?.minTime = handlingMillisecondsCSV(timeString: minString)
                        //                        currentItem.intervalDuration?.maxTime = handlingMillisecondsCSV(timeString: maxString)
                        //                        if minString?.count == 8{
                        //                           var data = minString?.split(separator: ":")
                        //                            currentItem.intervalDuration?.minTime = "\(data?[0] ?? "00")" + ":" + "\(data?[1] ?? "00")"
                        //                            debugPrint(currentItem.intervalDuration?.minTime)
                        //                        }
                        //                        if maxString?.count == 8{
                        //                            var data = maxString?.split(separator: ":")
                        //                            currentItem.intervalDuration?.maxTime = "\(data?[0] ?? "00")" + ":" + "\(data?[1] ?? "00")"
                        //                        }
                        //                        else if maxString?.count != 8 && minString?.count != 8{
                        //                            currentItem.intervalDuration?.minTime = splitData.first ?? ""
                        //                            currentItem.intervalDuration?.maxTime = splitData.last ?? ""
                        //                        }
                        //                        currentItem.intervalDuration?.random = checkRandomPresent(timeString: columns[intervalDurationIndex])
                        
                        currentItem.intervalDuration = handlingDataDurationData(min: headerIndexMap[.ReactionIntervalDurationMin], max: headerIndexMap[.ReactionIntervalDurationMax], minH: headerIndexMap[.ReactionIntervalDurationMinHundredths], maxH: headerIndexMap[.ReactionIntervalDurationMaxHundredths], coloumns: columns)
                    }
                    //                    currentItem.intervalDuration?.random = columns[headerIndexMap[.itemIntervalDurationRandom] ?? 0].uppercased() == "TRUE"
                    
                    
                    
                }
                
                //                else{
                //                    intervalErrorSet.insert(.Name)
                //                    intervalReactionErrorSet.insert(.Name)
                //                }
                // Check for IntervalItem details in this row
                if !intervalName.isEmpty && intervalDuration.isEmpty{
                    // New IntervalItem creation
                    currentInterval = IntervalItem(context: CoreDataManager.shared.context)
                    currentInterval?.intervalName = intervalName
                    
                    // Assign color object to IntervalItem
                    let intervalColorObject = ColorObject(context: CoreDataManager.shared.context)
                    
                    // Safely access columns based on header enum
                    if let colorHexIndex = headerIndexMap[.CallColour], columns.count > colorHexIndex {
                        intervalColorObject.colorHexCode = columns[colorHexIndex]
                        intervalColorObject.alphaValue = 1
                    }
                    else{
                        intervalReactionErrorSet.insert(.Color)
                        //                    intervalReactionErrorSet.insert(.Color)
                    }
                    
                    //                    if let colorAlphaIndex = headerIndexMap[.intervalColorAlpha], columns.count > colorAlphaIndex {
                    //                        intervalColorObject.alphaValue = Double(columns[colorAlphaIndex]) ?? 1.0
                    //                    }
                    
                    currentInterval?.colorObject = intervalColorObject
                    
                    //Interval call Object for IntervalItem
                    let intervalCallObject = IntervalCalls(context: CoreDataManager.shared.context)
                    if let intervalCallNumberString = headerIndexMap[.ReactionMaxNumberOfCalls], columns.count > intervalCallNumberString{
                        
                        intervalCallObject.maxNumber = columns[intervalCallNumberString] == "" ? 0 : Int32(columns[intervalCallNumberString]) ?? 0
                        intervalCallObject.random = columns[intervalCallNumberString] == "" ? false : true
                    }
                    else{
                        intervalReactionErrorSet.insert(.IntervalCall)
                    }
                    //                    if let intervalCallRandom = headerIndexMap[.intervalCallsRandom], columns.count > intervalCallRandom{
                    //                        intervalCallObject.random = columns[intervalCallRandom].lowercased() == "true"
                    //                    }
                    currentInterval?.intervalCall = intervalCallObject
                    
                    // Assign the IntervalItem to the current Item
                    currentInterval?.indexValue = Int64(indexValue)
                    indexValue+=1
                    intervals.append(currentInterval ?? IntervalItem())
                    guard let interval = currentInterval else { try CoreDataManager.shared.context.save(); continue }
                }
                else if !intervalReactionErrorSet.isEmpty{
                    intervalReactionErrorSet.insert(.Name)
                    break
                }
            }
            try CoreDataManager.shared.context.save()
        }
        
        catch let error{
            isValidCSV = false
            debugPrint("Interval Not Imported : \(error)")
        }
        return (intervals, isValidCSV, intervalReactionErrorSet, currentItem)
    }
    
    ///
    ///Parse intervalMessage
    ///
    private func importIntervalMessage(headerIndexMap: [CSVHeader: Int], columns: [String]) -> (Set<IntervalImportError>, MessageItems)?{
        /// Ensure we have a current Interval to work with
        var intervalErrorSet = Set<IntervalImportError>()
        var messageItem: MessageItems?
        // Check for MessageItem details in this row
        
        if let messageNameIndex = headerIndexMap[.MessageText], columns.count > messageNameIndex{
            if !columns[messageNameIndex].isEmpty{
                messageItem = MessageItems(context: CoreDataManager.shared.context)
                messageItem?.messageName = columns[messageNameIndex]
                if let messageDelayIndex = headerIndexMap[.MessageDelay], columns.count > messageDelayIndex{
                    messageItem?.delay = formattedFullTimeString(timeString: columns[messageDelayIndex], millisecond: columns[headerIndexMap[.MessageDelayHundredths] ?? 0])
                }
                else{
                    intervalErrorSet.insert(.Other)
                }
            }
        }
        else{
            intervalErrorSet.insert(.Other)
        }
        return (intervalErrorSet, messageItem) as? (Set<IntervalImportError>, MessageItems)
    }
    
    
    ///
    ///PARSE CSV AND SAVE ITEMS
    ///
    func importItemsFromCSV(url: URL, isPaidFolder: Bool = false) -> Item?{
        //        var items = [Item]()
        var currentItem: Item?
        var csvString: String = ""
       
//            defer { url.stopAccessingSecurityScopedResource() }
            do {
                // Read CSV file content
                csvString = try String(contentsOf: url, encoding: .utf8)
            }catch {
                // Try fallback encodings if UTF-8 fails
                do {
                    csvString = try String(contentsOf: url, encoding: .isoLatin1)
                } catch {
                    do {
                        csvString = try String(contentsOf: url, encoding: .windowsCP1252)
                    } catch {
                        // Log or return error if all fail
                        print("Failed to import CSV data: \(error)")
                        //                            intervalErrorSet.insert(.Other)
                        //return nil
                    }
                }
            }
            var rows = csvString.components(separatedBy: "\n").filter { !$0.isEmpty }
            let headers = Array(rows.removeFirst().components(separatedBy: ",").map{$0.trimmingCharacters(in: .whitespaces)})
            let headerIndexMap = mapHeadersToIndices(headers: headers)
            for row in rows {  // Skip header row
                let columns = parseCSVRow(row)
                //                if columns.count < 14 { continue } // Ensure we have enough columns
               
                var title = ""
                if let titleIndex = headerIndexMap[.TimerName], columns.count > titleIndex {
                    title = columns[titleIndex]
                }
                
                // If title is not empty, it's a new item
                
                
                if !title.isEmpty {
                    // Create a new Item entity
                    currentItem = Item(context: CoreDataManager.shared.context)
                    currentItem?.title = title
                    // Ensure the array has at least the required number of elements before accessing
                    
                    //                        if let typeIndex = headerIndexMap[.type], columns.count > typeIndex {
                    //                            currentItem?.type = columns[typeIndex]
                    //                        }
                    
                    //Audio
                    if let alertAudioIndex = headerIndexMap[.Alert], columns.count > alertAudioIndex{
                        if currentItem?.setting == nil{
                            currentItem?.setting = Settings(context: CoreDataManager.shared.context)
                        }
                        if columns[alertAudioIndex].isEmpty{
                            currentItem?.setting?.isNoAudio = true
                        }
                        else{
                            if checkTextToSpeech(alert: columns[alertAudioIndex]){
                                currentItem?.setting?.isTextToSpeech = true
                                currentItem?.setting?.isNoAudio = false
                            }
                            else {
                                currentItem?.setting?.isTextToSpeech = false
                                currentItem?.setting?.isNoAudio = false
                            }
                        }
                        currentItem?.setting?.audio = columns[alertAudioIndex]
                        if let vibrationData = headerIndexMap[.Vibration], columns.count > vibrationData{
                            currentItem?.setting?.vibration = columns[vibrationData]
                        }
                    }
                    
                    //                    if let indexValueIndex = headerIndexMap[.indexValue], columns.count > indexValueIndex {
                    //                        currentItem?.indexValue = Int64(columns[indexValueIndex]) ?? 0
                    //                    }
                    //
                    //                    if let isChildIndex = headerIndexMap[.isChild], columns.count > isChildIndex {
                    //                        currentItem?.isChild = columns[isChildIndex].lowercased() == "true"
                    //                    }
                    //
                    //                    if let isSelectedIndex = headerIndexMap[.isSelected], columns.count > isSelectedIndex {
                    //                        currentItem?.isSelected = columns[isSelectedIndex].lowercased() == "true"
                    //                    }
                    
                    //Color, Shuffle, Vibrateon Alert
                    if let isSessionIndex = headerIndexMap[.ReactionSessionRound], columns.count > isSessionIndex {
                        currentItem?.session = columns[isSessionIndex]
                    }
                    
                    if let isShuffleIndex = headerIndexMap[.IntervalShuffle], columns.count > isShuffleIndex{
                        currentItem?.shuffle = columns[isShuffleIndex].lowercased() == "true"
                    }
                    
                    if let isVibrateIndex = headerIndexMap[.Vibration], columns.count > isVibrateIndex{
                        currentItem?.viibrateAlert = columns[isVibrateIndex].lowercased() == "true"
                    }
                    
                    // Assign color object to Item if there are enough columns
                    if let itemColorHexIndex = headerIndexMap[.TimerColour], columns.count > itemColorHexIndex {
                        let itemColorObject = ColorObject(context: CoreDataManager.shared.context)
                        itemColorObject.colorHexCode = columns[itemColorHexIndex]
                        itemColorObject.alphaValue = 1
                        currentItem?.colorObject = itemColorObject
                    }
                    
                    //Interval Duration for item object
                    //let intervalDurationObject = IntervalDuration(context: CoreDataManager.shared.context)
                    
                    //Rest Interval
                    if let restIntervalMinIndex = headerIndexMap[.RestBetweenIntervalsMin], columns.count > restIntervalMinIndex{
                        var intervalDurationObject = IntervalDuration(context: CoreDataManager.shared.context)
                        intervalDurationObject = handlingCoreDataDurationData(min: headerIndexMap[.RestBetweenIntervalsMin], max: headerIndexMap[.RestBetweenIntervalsMax], minH: headerIndexMap[.RestBetweenIntervalsMinHundredths], maxH: headerIndexMap[.RestBetweenIntervalsMaxHundredths], coloumns: columns, intervalDuration: intervalDurationObject)
                        currentItem?.restBetweenInterval = intervalDurationObject
                    }
                    
                    
                    //Rest Round
                    if let restRoundIndex = headerIndexMap[.RestBetweenRoundsMin], columns.count > restRoundIndex{
                        var restInterval = RestBetweenRounds(context: CoreDataManager.shared.context)
                        
                        restInterval = handlingCoreDataDurationData(min: headerIndexMap[.RestBetweenRoundsMin], max: headerIndexMap[.RestBetweenRoundsMax], minH: headerIndexMap[.RestBetweenRoundsMinHundredths], maxH: headerIndexMap[.RestBetweenRoundsMaxHundredths], coloumns: columns, intervalDuration: restInterval)
                        restInterval.rounds = Int64(columns[headerIndexMap[.NumberOfRounds] ?? 0]) ?? 1
                        currentItem?.restBetweenRounds = restInterval
                    }
                    
                    //Reaction IntervalDuration
                    if let intervalDurationIndex = headerIndexMap[.ReactionIntervalDurationMin], columns.count > intervalDurationIndex{
                        if !columns[headerIndexMap[.ReactionIntervalDurationMin] ?? 1].isEmpty {
                            var intervalDurationObject = IntervalDuration(context: CoreDataManager.shared.context)
                            
                            intervalDurationObject = handlingCoreDataDurationData(min: headerIndexMap[.ReactionIntervalDurationMin], max: headerIndexMap[.ReactionIntervalDurationMax], minH: headerIndexMap[.ReactionIntervalDurationMinHundredths], maxH: headerIndexMap[.ReactionIntervalDurationMaxHundredths], coloumns: columns, intervalDuration: intervalDurationObject)
                            currentItem?.intervalDuration = intervalDurationObject
                        }
                    }
                    let timerIntervals = importTimerInterval(headerIndexMap: headerIndexMap, rows: rows)?.intervalArray
                    if !(timerIntervals?.isEmpty ?? true){
                        currentItem?.intervalItem = NSSet(array: timerIntervals ?? [])
                        currentItem?.type = "Timer"
                        debugPrint(timerIntervals?.count)
                        debugPrint(currentItem?.title)
                        debugPrint(currentItem?.intervalItem)
                    
                    }
                    let reactionIntervals = importDrillInterval(headerIndexMap: headerIndexMap, rows: rows)?.intervalArray
                    if !(reactionIntervals?.isEmpty ?? true){
                        currentItem?.intervalItem = NSSet(array: reactionIntervals ?? [])
                        currentItem?.type = "Drill"
                    }
                    currentItem?.isChild = isPaidFolder
                    CoreDataManager.shared.saveContext()
                    return currentItem
            }
        }
       
        
        // Save all items to Core Data
        //                try CoreDataManager.shared.context.save()
//    }
//    else{
//        debugPrint("errror")
//    }

        return nil
    }
    
    
    //For Paid Version
    func folderCreationPaid(folderModel: PaidFolderModel, indexValue: Int)-> Item?{
        let folderItem: Item? = Item(context: CoreDataManager.shared.context)
        folderItem?.title = folderModel.folderName
        folderItem?.indexValue = Int64(indexValue)
        folderItem?.colorObject = ColorObject(context: CoreDataManager.shared.context)
        folderItem?.colorObject?.alphaValue = 1
        folderItem?.colorObject?.colorHexCode = Color(hex: folderModel.folderColor).toHex()
        folderItem?.colorObject?.colorRgbX = 16
        folderItem?.colorObject?.colorRgbY = 12
        folderItem?.colorObject?.colorOpacityX = UIScreen.main.bounds.size.width - 48
        folderItem?.colorObject?.colorOpacityY = 13
        folderItem?.colorObject?.colorShadesX = UIScreen.main.bounds.size.width - 40
        folderItem?.colorObject?.colorShadesY = 8
        folderItem?.type = FileType.Folder.rawValue
        return folderItem
    }
    
    
    //Handling For 8 Folder
    func paidAllCsvFolderFile(){
        var childItemArray: [Item] = []
        let paidFolders: [PaidFolderModel] = [
            PaidFolderModel(folderName: "Circuit", folderColor: "#D89371"),
            PaidFolderModel(folderName: "Cycling", folderColor: "#FBEB67"),
            PaidFolderModel(folderName: "Martial Arts/Boxing", folderColor: "#67FBD7"),
            PaidFolderModel(folderName: "Running", folderColor: "#9C3737"),
            PaidFolderModel(folderName: "Strength", folderColor: "#31776B"),
            PaidFolderModel(folderName: "Stretch", folderColor: "#64379C"),
            PaidFolderModel(folderName: "Yoga", folderColor: "#FB6767")
        ]
        let itemCount = CoreDataManager.shared.parentItemCount()
        for  folderIndex in paidFolders.indices{
            childItemArray.removeAll()
            var count = 0;
            let folder = folderCreationPaid(folderModel: paidFolders[folderIndex], indexValue: itemCount + folderIndex)
            guard let csvUrls = readAllCSVFiles() else{
                CoreDataManager.shared.deleteItemNSManagedObject(object: folder!)
                return }
            for index in csvUrls.indices{
                if csvUrls[index].absoluteString.contains(folderNameHandling(folderName: paidFolders[folderIndex].folderName)){
                    let item = importItemsFromCSV(url: csvUrls[index], isPaidFolder: true)
                    item?.indexValue = Int64(count)
                    if let item = item{
                        childItemArray.append(item)
                        count += 1
                    }
                }
            }
            if childItemArray.isEmpty{
                CoreDataManager.shared.deleteItemNSManagedObject(object: folder!)
            }
            else{
                folder?.children = NSSet(array: childItemArray)
            }
        }
        CoreDataManager.shared.saveContext()
    }
    
    //Fetch Files From folder
    func readAllCSVFiles()-> [URL]? {
        guard let folderURL = Bundle.main.resourcePath else {
            print("Folder not found in bundle.")
            return nil
        }
     
        do {
//           var newFolderUrl = folderURL.absoluteString.replacingOccurrences(of: "/Crossfader%20-%20Broken%20(ellipsis).csv", with: "")
//            guard let nreUrl = URL(string: newFolderUrl) else{return nil}
            let fileManager = FileManager.default
            let bundleURL = URL(fileURLWithPath: folderURL)

            let fileURLs = try fileManager.contentsOfDirectory(at: bundleURL , includingPropertiesForKeys: nil)
     
            let csvFiles = fileURLs.filter { $0.pathExtension == "csv" }
     
            return csvFiles
     
        } catch {
            print("Error accessing folder: \(error)")
        }
        return nil
    }

   private func mapHeadersToIndices(headers: [String]) -> [CSVHeader: Int] {
        var headerIndexMap: [CSVHeader: Int] = [:]
        
        for (index, header) in headers.enumerated() {
            if let headerEnum = CSVHeader(rawValue: header) {
                headerIndexMap[headerEnum] = index
            }
        }
        
        return headerIndexMap
    }

    //Conversion of single string in min and max string by return array of string
   private func singleDataToMinMax(breakValue: String?)->[String?]?{
        guard let breakValue = breakValue, !breakValue.isEmpty else{
            return ["",""]
        }
        guard breakValue.contains("-") else{
            return [breakValue,""]
        }
        let stringData = breakValue.split(separator: "-")
        return stringData.map{ String($0)}
    }
    
    //Handling for Milliseconds
    private func handlingMillisecondsCSV(timeString: String?)-> String{
        guard let timeString = timeString else{return ""}
        return formatTime(minTime: timeString)
    }
    
    
    // Helper function to parse a CSV row while handling values with commas
    private func parseCSVRow(_ row: String) -> [String] {
        var result = [String]()
        var currentField = ""
        var isInsideQuotes = false

        for character in row {
            switch character {
            case "\"":
                // Toggle the state of `isInsideQuotes` when encountering a quote
                isInsideQuotes.toggle()
            case ",":
                if isInsideQuotes {
                    // If inside quotes, treat the comma as part of the value
                    currentField.append(character)
                } else {
                    // Otherwise, treat it as a delimiter
                    result.append(currentField.trimmingCharacters(in: .whitespacesAndNewlines))
                    currentField = ""
                }
            default:
                currentField.append(character)
            }
        }

        // Add the last field
        result.append(currentField.trimmingCharacters(in: .whitespacesAndNewlines))
        return result
    }

    
    //Check alert song text to speech or not
    func checkTextToSpeech(alert: String)-> Bool{
        let keywords = ["With Count", "Without Count", "With Time"]
           return keywords.contains(where: alert.contains)
    }
    
    //Check func to hadnle if ranmdom is false or not
    func checkRandomPresent(timeString: String)-> Bool{
        return timeString.contains("-")
    }
    
    //Check millseconds String is Present or not
   private func formattedFullTimeString(timeString: String, millisecond: String) -> String {
        let formattedTime = formatingTimeString(timeString)
        let formattedMillis = formatingTimeStringMilliseconds(millisecond)
        
        switch (formattedTime.isEmpty, formattedMillis.isEmpty) {
        case (true, false):  return "00:00:" + formattedMillis
        case (false, true):  return formattedTime
        case (false, false): return "\(formattedTime):\(formattedMillis)"
        default:             return ""
        }
    }
    
    //Formating time string of import csv in hours milliseconds
    private func formatingTimeString(_ timeString: String) -> String {
        var newTimeString = timeString
        // If string is empty, return empty string
        if timeString.isEmpty || timeString == "00:00:00" || timeString == "00:00"{
            return ""
        }
        if timeString.count > 5{
             newTimeString = String(timeString.suffix(5))
        }

        let components = newTimeString.split(separator: ":").map { String($0) }

        switch components.count {
        case 1:
            // Only seconds provided -> format as 00:SS
            let seconds = String(format: "%02d", Int(components[0]) ?? 0)
            return "00:\(seconds)"
        case 2:
            // Minutes and seconds provided -> format as MM:SS
            let minutes = String(format: "%02d", Int(components[0]) ?? 0)
            let seconds = String(format: "%02d", Int(components[1]) ?? 0)
            return "\(minutes):\(seconds)"
        default:
            // Unexpected format — return original string
            return ""
        }
    }
    
   private func formatingTimeStringMilliseconds(_ milliseconds: String) -> String {
        guard !milliseconds.isEmpty else { return "" }

        switch milliseconds.count {
        case 2:
            return milliseconds
        case 1:
            return milliseconds + "0"
        default:
            return ""
        }
    }
    
    // MARK: – Random‑value helper
    /// Returns `true` only when `maxString` is non‑empty.
    @inline(__always)
    func hasRandomValue(maxString: String) -> Bool {
        !(maxString.isEmpty || maxString == (AppDefaults.shared.hundredthMilliSeconds ? "00:00:00" : "00:00"))   // same as “return !maxString.isEmpty”
    }

    // MARK: – Min / Max validation
    /// Returns `true` when *either* both values are non‑empty **or** `max`
    /// alone is non‑empty (i.e. `min` may be empty).
    /// If both are empty it returns `false`.
    @inline(__always)
    func validate(min: String, max: String) -> Bool {
        !(max.isEmpty && min.isEmpty)
    }
    
    func handlingDataDurationData(min: Int?, max: Int?, minH: Int?, maxH: Int?, coloumns: [String])-> IntervalTimeModelData{
        var minTime: String = ""
        var maxTime: String = ""
        var minHTime: String = ""
        var maxHTime: String = ""
        var intervalDurationData = IntervalTimeModelData()
        if let min = min, coloumns.count > 1{
          minTime = coloumns[min]
        }
        if let minH = minH, coloumns.count > 1{
            minHTime = coloumns[minH]
        }
        if let max = max, coloumns.count > 1{
          maxTime = coloumns[max]
        }
        if let maxH = maxH, coloumns.count > 1{
            maxHTime = coloumns[maxH]
        }
        
        intervalDurationData.minTime = formattedFullTimeString(timeString: minTime, millisecond: minHTime)
        intervalDurationData.maxTime = formattedFullTimeString(timeString: maxTime, millisecond: maxHTime)
        intervalDurationData.random = hasRandomValue(maxString: intervalDurationData.maxTime ?? "")
        intervalDurationData = AppComman.shared.validationIntervalItemData(durationType: intervalDurationData, minFieldValue: intervalDurationData.minTime ?? "", maxFieldValue: intervalDurationData.maxTime ?? "", random: intervalDurationData.random ?? false)
        return intervalDurationData
        
    }
    
    func handlingCoreDataDurationData(min: Int?, max: Int?, minH: Int?, maxH: Int?, coloumns: [String], intervalDuration: IntervalDuration?)-> IntervalDuration{
        var minTime: String = ""
        var maxTime: String = ""
        var minHTime: String = ""
        var maxHTime: String = ""
        if let min = min, coloumns.count > 1{
          minTime = coloumns[min]
        }
        if let minH = minH, coloumns.count > 1{
            minHTime = coloumns[minH]
        }
        if let max = max, coloumns.count > 1{
          maxTime = coloumns[max]
        }
        if let maxH = maxH, coloumns.count > 1{
            maxHTime = coloumns[maxH]
        }
        
        minTime = formattedFullTimeString(timeString: minTime, millisecond: minHTime)
        maxTime = formattedFullTimeString(timeString: maxTime, millisecond: maxHTime)
        let random = hasRandomValue(maxString: maxTime)
        return AppComman.shared.validationIntervalData(durationType: intervalDuration ?? IntervalDuration(), minFieldValue: minTime, maxFieldValue: maxTime, random: random)
    }
    
    //Rest Roound
    func handlingCoreDataDurationData(min: Int?, max: Int?, minH: Int?, maxH: Int?, coloumns: [String], intervalDuration: RestBetweenRounds?)-> RestBetweenRounds{
        var minTime: String = ""
        var maxTime: String = ""
        var minHTime: String = ""
        var maxHTime: String = ""
        if let min = min, coloumns.count > 1{
          minTime = coloumns[min]
        }
        if let minH = minH, coloumns.count > 1{
            minHTime = coloumns[minH]
        }
        if let max = max, coloumns.count > 1{
          maxTime = coloumns[max]
        }
        if let maxH = maxH, coloumns.count > 1{
            maxHTime = coloumns[maxH]
        }
        
        minTime = formattedFullTimeString(timeString: minTime, millisecond: minHTime)
        maxTime = formattedFullTimeString(timeString: maxTime, millisecond: maxHTime)
        let random = hasRandomValue(maxString: maxTime)
        return AppComman.shared.validationRoundIntervalData(durationType: intervalDuration ?? RestBetweenRounds(), minFieldValue: minTime, maxFieldValue: maxTime, random: random)
    }
    
    //Folder Name Handling
    func folderNameHandling(folderName: String) -> String {
        return folderName
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "/", with: "_and_")
            .lowercased()
    }
    
    
}

 //MARK: - Url Extensiom
extension URL {
    var isDirectory: Bool {
       (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }
}
