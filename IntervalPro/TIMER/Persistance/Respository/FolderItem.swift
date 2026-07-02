//
//  FolderItem.swift
//  TIMER
//
//  Created by Aditya Maroo on 09/09/24.
//
import Foundation
import CoreData
import SwiftUI


class FolderItem {
    static let shared = FolderItem()
    func addFolderItems(alertSong: String, colure: String, session: String, shuffle: Bool, title: String, type: String, vibrateAlert: Bool, restBetweenRounds: RestBetweenRounds, intervalItem: [IntervalItem], intervalDuration: IntervalDuration?, restBetweenInterval: IntervalDuration, folderItem: [FolderItems], colorOpacity: Double, colorOpacityY: Double, colorOpacityX: Double, colorRgbX: Double, colorRgbY: Double, colorShadesX: Double, colorShadesY: Double)-> FolderItems{
        let newItem = FolderItems(context: CoreDataManager.shared.context)
            newItem.alertSong = alertSong
            newItem.colour = colure
            newItem.colorOpacity = colorOpacity
//            newItem.indexValue = Int64(CoreDataManager.indexValue)
            newItem.session = session
            newItem.shuffle = shuffle
            newItem.title = title
            newItem.type = type
            newItem.viibrateAlert = vibrateAlert
            newItem.restBetweenRounds = restBetweenRounds
            newItem.intervalItem = NSSet(array: intervalItem)
            newItem.intervalDuration = intervalDuration
            newItem.restBetweenInterval = restBetweenInterval
            newItem.colorRgbX = colorRgbX
            newItem.colorRgbY = colorRgbY
            newItem.colorShadesX = colorShadesX
            newItem.colorShadesY = colorShadesY
            newItem.colorOpacityX = colorOpacityX
            newItem.colorOpacityY = colorOpacityY
            return newItem
    }
}
