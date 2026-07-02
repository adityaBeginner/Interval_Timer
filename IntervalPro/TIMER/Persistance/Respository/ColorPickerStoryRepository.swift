//
//  ColorPickerStoryRepository.swift
//  TIMER
//
//  Created by Aditya Maroo on 12/09/24.
//

import Foundation
import CoreData

class ColorPickerStoryRepository{
    static let shared = ColorPickerStoryRepository()
    
    func addColorDataBase(colorHexCode: String, alphaValue: Double, colorOpacityY: Double, colorOpacityX: Double, colorRgbX: Double, colorRgbY: Double, colorShadesX: Double, colorShadesY: Double, indexValue: Int64){
        let newColorItem = ColorObject(context: CoreDataManager.shared.context)
        newColorItem.colorHexCode = colorHexCode
        newColorItem.alphaValue = alphaValue
        newColorItem.colorShadesX = colorShadesX
        newColorItem.colorShadesY = colorShadesY
        newColorItem.colorRgbX = colorRgbX
        newColorItem.colorRgbY = colorRgbY
        newColorItem.colorOpacityX = colorOpacityX
        newColorItem.colorOpacityY = colorOpacityY
        newColorItem.indexValue = indexValue
        newColorItem.colorChoice = true
        CoreDataManager.shared.saveContext()
        
    }
    func fetchItems() -> [ColorObject] {
        let context = CoreDataManager.shared.context
        let fetchRequest: NSFetchRequest<ColorObject> = ColorObject.fetchRequest()
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch items: \(error)")
            return []
        }
    }
 
    
}
