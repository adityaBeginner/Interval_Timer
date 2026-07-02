//
//  ReactionIntervalVM.swift
//  TIMER
//
//  Created by Aditya Maroo on 11/09/24.
//

import Foundation
import SwiftUI
import Combine
 //MARK: - view Model of Reaction Interval View
class ReactionIntervalVM: ObservableObject{
    
    //MARK: -
    //MARK: PUBLISHED PROPERTIES
    @Published var intervalName: String = ""
    @Published var maximumNumberOfCall: Int32 = 0
    @Published var random: Bool = false
    @Published var colourOpacity: Double = 1.0
    @Published var colorHex: String = Color(.defaultFolderTimerReactionColor).toHex()
    @Published var intervalCount: Int64 = 0
    @Published var intervalItem:IntervalItem?
    @Published var shouldShowAlert:Bool = false
    @Published var alertMessage:String = ""
    @Published var alertHeader: String = "Error: Missing Field"
  
    //Saving item on color navigation in edit state
    @Published var colorNavigate: Bool = false
   
    ///
    ///ADD OR UPDATE
    ///INTERVAL ITEM
    ///
    func addOrUpdateIntervalItem(){
        intervalItem?.intervalName = intervalName
        addOrUpdateIntervalCall()
        addOrUpdateColorObject()
        CoreDataManager.shared.saveContext()
    }
    
    ///
    ///CREATE OR UPDATE
    ///INTERVAL CALL
    ///
    private func addOrUpdateIntervalCall(){
        if intervalItem?.intervalCall == nil{
            intervalItem?.intervalCall = IntervalCalls(context: CoreDataManager.shared.context)
        }
        if random{
            intervalItem?.intervalCall?.maxNumber = maximumNumberOfCall
        }
        intervalItem?.intervalCall?.random = random
        CoreDataManager.shared.saveContext()
    }
    
    ///
    ///CREATE OR UPDATE
    ///COLOR OBJECT
    ///
    func addOrUpdateColorObject(){
        if intervalItem?.colorObject == nil{
            intervalItem?.colorObject = ColorObject(context: CoreDataManager.shared.context)
            intervalItem?.colorObject?.colorHexCode = colorHex
            intervalItem?.colorObject?.alphaValue = 1
            intervalItem?.colorObject?.colorRgbX = 16
            intervalItem?.colorObject?.colorRgbY = 12
            intervalItem?.colorObject?.colorOpacityX = UIScreen.main.bounds.size.width - 48
            intervalItem?.colorObject?.colorOpacityY = 13
            intervalItem?.colorObject?.colorShadesX = UIScreen.main.bounds.size.width - 40
            intervalItem?.colorObject?.colorShadesY = 8
        }
       
        CoreDataManager.shared.saveContext()
    }
    
    ///
    ///VALIDATE INPUTS
    ///
    func validateInputs()->Bool{
        guard intervalName.trimmingCharacters(in: .whitespaces) != "" else{
//            alertMessage = "The file have missing field. \nPlease check that there is no empty field:\nInterval name can not be empty.The data will be deleted"
           
        return false
        }
        if random{
            guard maximumNumberOfCall != 0 else{
                //            alertMessage = "The file have missing field. \nPlease check that there is no empty field:\nMax Number of Calls can not be empty or 0.The data will be deleted"
                return false
            }
        }
        return true
    }
    
    ///
    ///VALIDATE INPUTS
    ///
    func deleteInterval(){
        guard let intervalItem else{debugPrint("interval item is nil while deletig it"); return}
        CoreDataManager.shared.deleteNSManagedObject(object: intervalItem)
    }
}
