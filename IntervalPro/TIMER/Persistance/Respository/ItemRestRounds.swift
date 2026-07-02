//
//  ItemRestRounds.swift
//  TIMER
//
//  Created by Aditya Maroo on 09/09/24.
//

import Foundation
import CoreData
import SwiftUI


class ItemRestRounds {
    static let shared = ItemRestRounds()
    
    func addItem(maxTime: String, minTime: String, random: Bool, restTime: String, rounds: Int64)-> RestBetweenRounds{
        let restBetwwenRounds = RestBetweenRounds(context: CoreDataManager.shared.context)
        restBetwwenRounds.max = maxTime
        restBetwwenRounds.min = minTime
        restBetwwenRounds.random = random
        restBetwwenRounds.restTime = restTime
        restBetwwenRounds.rounds = rounds
        return restBetwwenRounds
    }
}
