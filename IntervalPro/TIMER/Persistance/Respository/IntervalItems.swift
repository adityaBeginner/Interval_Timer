//
//  IntervalItem.swift
//  TIMER
//
//  Created by Aditya Maroo on 09/09/24.
//

import Foundation
import CoreData
import SwiftUI


class IntervalItems {
    static let shared = IntervalItems()
    
    func addIntevalItems(halfWayAlert: Bool, intervalColour: String, intervalName: String, messageItems: [MessageItems], intervalDuration: IntervalDuration?, intervalCall: IntervalCalls?, intervalColourOpacity: Double, colorOpacityY: Double, colorOpacityX: Double, colorRgbX: Double, colorRgbY: Double, colorShadesX: Double, colorShadesY: Double, indexValue: Int64 )-> IntervalItem{
        let intervalItem = IntervalItem(context: CoreDataManager.shared.context)
        intervalItem.halfWayAlert = halfWayAlert
       
        intervalItem.intervalName = intervalName
        intervalItem.messageItems = NSSet(array: messageItems)
        intervalItem.intervalDuration = intervalDuration
        intervalItem.intervalCall = intervalCall
       

        return intervalItem
    }
    func addReactionInterval(intervalColour: String, intervalName: String, intervalCall: IntervalCalls?, colorOpacity: Double, colorOpacityY: Double, colorOpacityX: Double, colorRgbX: Double, colorRgbY: Double, colorShadesX: Double, colorShadesY: Double, indexValue: Int64 )-> IntervalItem{
        let intervalItem = IntervalItem(context: CoreDataManager.shared.context)
        intervalItem.intervalName = intervalName
        intervalItem.intervalCall = intervalCall
        intervalItem.indexValue = indexValue
        return intervalItem
    }
    func updateIntervalItemMessage(intervalitem: IntervalItem, messageItem: [MessageItems]){
        intervalitem.messageItems = NSSet(array: messageItem)
        CoreDataManager.shared.saveContext()
    }
    func updateIntervalItemData(intervalItem: IntervalItem, halfWayAlert: Bool, intervalColour: String, intervalName: String, messageItems: [MessageItems], intervalDuration: IntervalDuration?, intervalCall: IntervalCalls?, intervalColourOpacity: Double, colorOpacityY: Double, colorOpacityX: Double, colorRgbX: Double, colorRgbY: Double, colorShadesX: Double, colorShadesY: Double){
        intervalItem.halfWayAlert = halfWayAlert
        intervalItem.intervalName = intervalName
        intervalItem.messageItems = NSSet(array: messageItems)
        intervalItem.intervalDuration = intervalDuration
        intervalItem.intervalCall = intervalCall
      
        CoreDataManager.shared.saveContext()
    }
    func updateReactionIntervalData(intervalItem: IntervalItem, intervalColour: String, intervalName: String, intervalCall: IntervalCalls?, colorOpacity: Double, colorOpacityY: Double, colorOpacityX: Double, colorRgbX: Double, colorRgbY: Double, colorShadesX: Double, colorShadesY: Double){
        intervalItem.intervalName = intervalName
        intervalItem.intervalCall = intervalCall
        CoreDataManager.shared.saveContext()
    }
}
