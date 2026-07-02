//
//  ItemDurationInterval.swift
//  TIMER
//
//  Created by Aditya Maroo on 09/09/24.
//

import Foundation
import CoreData
import SwiftUI


class ItemDurationInterval {
    static let shared = ItemDurationInterval()
    
   
    func addIntervalDuration()-> IntervalDuration{
        var intervalDuration = IntervalDuration(context: CoreDataManager.shared.context)
        return intervalDuration
    }
}
