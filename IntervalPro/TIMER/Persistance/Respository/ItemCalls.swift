//
//  ItemCalls.swift
//  TIMER
//
//  Created by Aditya Maroo on 09/09/24.
//

import Foundation
import CoreData
import SwiftUI


class ItemCalls {
    static let shared = ItemCalls()
  
    
    func addItemsCalls(maxNumber: Int32, averageNumber: Int32, random: Bool)-> IntervalCalls{
        let newItem = IntervalCalls(context: CoreDataManager.shared.context)
        newItem.maxNumber = maxNumber
        newItem.averageNumber = averageNumber
        newItem.random = random
        return newItem
    }
}
