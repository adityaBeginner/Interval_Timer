//
//  CoreDataManager.swift
//  IntervalPro
//
//  Created by Aditya Maroo on 22/08/24.
//

import Foundation
import CoreData
import SwiftUI

class CoreDataManager {
    static let shared = CoreDataManager()
    static var indexValue = 0
    static let freeLimitCount = 3
    
    lazy var context = persistentContainer.viewContext
    
    private var persistentContainer: NSPersistentContainer = {
            let container = NSPersistentContainer(name: "TIMER1")
            container.loadPersistentStores(completionHandler: { (storeDescription, error) in
                if let error = error as NSError? {
                    print("Unresolved error \(error), \(error.userInfo)")
                }
            })
            return container
        }()
    
   
    
    // Fetch records from coredata
    func fetchItems() -> [Item] {
        let context = context
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        fetchRequest.returnsObjectsAsFaults = false
        
        // Create individual predicates
        let isChildPredicate = NSPredicate(format: "isChild == NO")
        let isItemCopiesPredicate = NSPredicate(format: "isItemCopied == NO")
//        let isEmptyTitlePredicate =  NSPredicate(format: "title != '' OR title != nil")
        // Combine predicates using NSCompoundPredicate
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [isChildPredicate, isItemCopiesPredicate])
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch items: \(error)")
            return []
        }
    }
    
    //Parent Item Count
    func parentItemCount()-> Int{
        let context = context
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        fetchRequest.returnsObjectsAsFaults = false
        
        // Create individual predicates
        let isChildPredicate = NSPredicate(format: "isChild == NO")
        let isItemCopiesPredicate = NSPredicate(format: "isItemCopied == NO")
//        let isEmptyTitlePredicate =  NSPredicate(format: "title != '' OR title != nil")
        // Combine predicates using NSCompoundPredicate
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [isChildPredicate, isItemCopiesPredicate])
        
        do {
            return try context.fetch(fetchRequest).count
        } catch {
            print("Failed to fetch items: \(error)")
            return 0
        }
    }

    //Counting Empty Items
    func printingfetchItems() {
        let context = context
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        fetchRequest.returnsObjectsAsFaults = false
        // Create individual predicates
//        let isChildPredicate = NSPredicate(format: "isChild == NO")
//        let isItemCopiesPredicate = NSPredicate(format: "isItemCopied == NO")
////        let isEmptyTitlePredicate =  NSPredicate(format: "title != '' OR title != nil")
//        // Combine predicates using NSCompoundPredicate
//        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [isChildPredicate, isItemCopiesPredicate])
        
        do {
            var data = try context.fetch(fetchRequest)
            debugPrint("total Count :\(data.count)")
            data.forEach{data in
                if data.isChild{
                    debugPrint("is Child Data: \(data)")
                }
                else{
                    debugPrint("not Child Dtaa : \(data.title)")
                }
                
            }
        } catch {
            debugPrint("Failed to fetch items: \(error)")
           
        }
    }
    
    
    // Add a new item
    func addItem(alertSong: String, colure: String, session: String, shuffle: Bool, title: String, type: String, vibrateAlert: Bool, restBetweenRounds: RestBetweenRounds, intervalItem: [IntervalItem], intervalDuration: IntervalDuration?, restBetweenInterval: IntervalDuration, folderItem: [FolderItems], colorOpacity: Double, colorOpacityY: Double, colorOpacityX: Double, colorRgbX: Double, colorRgbY: Double, colorShadesX: Double, colorShadesY: Double) {
        //        let context = persistentContainer.viewContext
        if title.trimmingCharacters(in: .whitespaces) != ""{
            let newItem = Item(context: CoreDataManager.shared.context)
            if type == FileType.Folder.rawValue {
                newItem.title = title
//                newItem.colour = "#000000"
                newItem.type = FileType.Folder.rawValue
                if folderItem.count > 0{
                    newItem.toFolderItems = NSSet(array: folderItem)
                    newItem.indexValue = Int64(CoreDataManager.indexValue)
                }
            }else{
                newItem.alertSong = alertSong
                newItem.indexValue = Int64(CoreDataManager.indexValue)
                newItem.session = session
                newItem.shuffle = shuffle
                newItem.title = title
                newItem.type = type
                newItem.viibrateAlert = vibrateAlert
                newItem.restBetweenRounds = restBetweenRounds
                newItem.intervalItem = NSSet(array: intervalItem)
                newItem.intervalDuration = intervalDuration
                newItem.restBetweenInterval = restBetweenInterval
                
//                newItem.colour = colure
//                newItem.colorOpacity = colorOpacity
//                newItem.colorRgbX = colorRgbX
//                newItem.colorRgbY = colorRgbY
//                newItem.colorShadesX = colorShadesX
//                newItem.colorShadesY = colorShadesY
//                newItem.colorOpacityX = colorOpacityX
//                newItem.colorOpacityY = colorOpacityY
            }
            CoreDataManager.indexValue += 1
            CoreDataManager.shared.saveContext()
        }
    }
        
    //Adding item to folderData
    
    
    // Add a new item
    func addItemToFolder(title: String, indexValue: Int64){
        if title.trimmingCharacters(in: .whitespaces) != ""{
            let newItem = Item(context: CoreDataManager.shared.context)
            newItem.colorObject?.colorHexCode = "000000"
            newItem.colorObject?.alphaValue = 1
            newItem.title = title
            //   newItem.colour = "#000000"
            //   newItem.colorOpacity = 1.0
            newItem.type = FileType.Folder.rawValue
            newItem.indexValue = indexValue
//            if folderItem.count > 0{
//                newItem.toFolderItems = NSSet(array: folderItem)
//                newItem.indexValue = Int64(CoreDataManager.indexValue)
//            }
            CoreDataManager.shared.saveContext()
        }
        
    }

    // Edit an existing item
    func updateEditItem(newItem: Item, alertSong: String, colure: String, session: String, shuffle: Bool, title: String, type: String, vibrateAlert: Bool, restBetweenRounds: RestBetweenRounds, intervalItem: [IntervalItem], intervalDuration: IntervalDuration?, restBetweenInterval: IntervalDuration, folderItem: [FolderItems], colorOpacity: Double, colorOpacityY: Double, colorOpacityX: Double, colorRgbX: Double, colorRgbY: Double, colorShadesX: Double, colorShadesY: Double) {
        newItem.alertSong = alertSong
        newItem.indexValue = Int64(CoreDataManager.indexValue)
        newItem.session = session
        newItem.shuffle = shuffle
        newItem.title = title
        newItem.type = type
        newItem.viibrateAlert = vibrateAlert
        newItem.restBetweenRounds = restBetweenRounds
        newItem.intervalItem = NSSet(array: intervalItem)
        newItem.intervalDuration = intervalDuration
        newItem.restBetweenInterval = restBetweenInterval
        
//        newItem.colour = colure
//        newItem.colorOpacity = colorOpacity
//        newItem.colorRgbX = colorRgbX
//        newItem.colorRgbY = colorRgbY
//        newItem.colorShadesX = colorShadesX
//        newItem.colorShadesY = colorShadesY
//        newItem.colorOpacityX = colorOpacityX
//        newItem.colorOpacityY = colorOpacityY
        saveContext()
    }
    //Update IntervalListData
    func updateIntervalListData(item: Item, intervalList: [IntervalItem]){
        item.intervalItem = NSSet(array: intervalList)
        saveContext()
    }
    func updateIndexValue(oldIndex: Int64, newIndex: Int64, item: Item){
        var intervalItemArray = item.intervalItem?.allObjects as? [IntervalItem]
        intervalItemArray?.move(fromOffsets: IndexSet(integer: Int(oldIndex)), toOffset: Int(newIndex))
        item.intervalItem = NSSet(array: intervalItemArray!)
        saveContext()
    }
    
    //Updating FolderItems
    
    func updateFolderItems(item: Item, folderItems: [FolderItems]){
        item.toFolderItems = NSSet(arrayLiteral: folderItems)
        CoreDataManager.shared.saveContext()
        
    }
    // Save changes to the context
    public func saveContext() {
        let context = context

        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save context: \(error)")
            }
        }
    }
    
    // Save changes to the context
    public func deleteNSManagedObject(object:NSManagedObject) {
        context.delete(object)
        saveContext()
    }
    
    // Save changes to the context
    public func deleteItemNSManagedObject(object:NSManagedObject) {
        context.delete(object)
    }
    
    
    //MARK: -
    //MARK: REMOVE EMPTY ITEMS
    func removeEmptyItems(){
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        
        do {
            let allItems = try context.fetch(fetchRequest)
            
            for item in allItems {
                // Check if title is empty
                if item.title == nil || item.title?.trimmingCharacters(in: .whitespaces) == "" {
                    
                    // Remove item from Core Data
                    context.delete(item)
                }
            }
            
            // Save changes
            try context.save()
        debugPrint("Items with empty titles removed.")
        } catch {
            debugPrint("Failed to fetch or delete items: \(error)")
        }
    }
    
    ///
    ///Remove Copy and Empy intervalItem and emply interval with not neccesary title
    ///
     func removeIntervalItemsWithoutTitle(){
         let fetchRequest: NSFetchRequest<IntervalItem> = IntervalItem.fetchRequest()
         do {
             let allItems = try context.fetch(fetchRequest)
//             print("Interval Count : \(allItems.count)")
             for item in allItems {
                
                 // Check if title is empty
                 if item.item == nil || item.intervalName == nil || item.intervalName?.trimmingCharacters(in: .whitespaces) == "" || item.isItemCopied {
//                     if item.messageItems?.count == 0 || item.messageItems == nil{
                         
                         // Remove item from Core Data
                         context.delete(item)
//                     }
                 }
             }
             // Save changes
             try context.save()
 //            print("Items with empty titles removed.")
         } catch {
             debugPrint("Failed to fetch or delete items: \(error)")
         }
     }
    
    ///
    ///Remove Copy and Empy intervalItem
    ///
   private func removeEmptyIntervalItem(){
        let fetchRequest: NSFetchRequest<IntervalItem> = IntervalItem.fetchRequest()
        do {
            let allItems = try context.fetch(fetchRequest)
            debugPrint("Interval Count : \(allItems.count)")
            for item in allItems {
               
                // Check if title is empty
                if item.intervalName == nil || item.intervalName?.trimmingCharacters(in: .whitespaces) == "" || item.isItemCopied {
                    if item.messageItems?.count == 0 || item.messageItems == nil{
                        
                        // Remove item from Core Data
                        context.delete(item)
                    }
                }
            }
            // Save changes
            try context.save()
//            print("Items with empty titles removed.")
        } catch {
            debugPrint("Failed to fetch or delete items: \(error)")
        }
    }
    
    ///
    ///Remove Empty and Copy Message object
    ///
    private func removeMessageItem(){
        let fetchRequest: NSFetchRequest<MessageItems> = MessageItems.fetchRequest()
        do {
            let allItems = try context.fetch(fetchRequest)
            
            for item in allItems {
                // Check if title is empty
                if item.messageName == nil || item.messageName?.trimmingCharacters(in: .whitespaces) == "" || item.isItemCopied {
                    
                    // Remove item from Core Data
                    context.delete(item)
                }
            }
            // Save changes
            try context.save()
//            print("Items with empty titles removed.")
        } catch {
            debugPrint("Failed to fetch or delete items: \(error)")
        }
    }
    
    ///
    ///Remove Empty and Copy IntervalDuraion object
    ///
   private func removeRestIntervalItem(){
        let fetchRequest: NSFetchRequest<IntervalDuration> = IntervalDuration.fetchRequest()
        do {
            let allItems = try context.fetch(fetchRequest)
            
            for item in allItems {
                // Check if title is empty
                if item.isItemCopied {
                    // Remove item from Core Data
                    context.delete(item)
                }
            }
            // Save changes
            try context.save()
//            print("Items with empty titles removed.")
        } catch {
            debugPrint("Failed to fetch or delete items: \(error)")
        }
    }
    
    ///
    ///Remove Empty and Copy RestBetwwen Interval object
    ///
   private func removeRestRoundIntervalItem(){
        let fetchRequest: NSFetchRequest<RestBetweenRounds> = RestBetweenRounds.fetchRequest()
        do {
            let allItems = try context.fetch(fetchRequest)
            
            for item in allItems {
                // Check if title is empty
                if item.isItemCopied {
                    // Remove item from Core Data
                    context.delete(item)
                }
            }
            // Save changes
            try context.save()
//            print("Items with empty titles removed.")
        } catch {
            debugPrint("Failed to fetch or delete items: \(error)")
        }
    }
    
    ///
    ///Remove Empty and Copy IntervalCall object
    ///
    private func removeIntervalCallItem(){
        let fetchRequest: NSFetchRequest<IntervalCalls> = IntervalCalls.fetchRequest()
        do {
            let allItems = try context.fetch(fetchRequest)
            
            for item in allItems {
                // Check if title is empty
                if item.isItemCopied {
                    // Remove item from Core Data
                    context.delete(item)
                }
            }
            // Save changes
            try context.save()
//            print("Items with empty titles removed.")
        } catch {
            debugPrint("Failed to fetch or delete items: \(error)")
        }
    }
    
     func getIntervalCallData(){
            let fetchRequest: NSFetchRequest<IntervalCalls> = IntervalCalls.fetchRequest()
            do {
                let allItems = try context.fetch(fetchRequest)
                debugPrint(allItems.count)
            }
            catch {
                debugPrint("Failed to fetch or delete items: \(error)")
            }
    }
    
    ///
    ///Remove Empty and Copy ColorObject object
    ///
   private func removeColorItem(){
        let fetchRequest: NSFetchRequest<ColorObject> = ColorObject.fetchRequest()
        do {
            let allItems = try context.fetch(fetchRequest)
            
            for item in allItems {
                // Check if title is empty
                if item.isItemCopied {
                    // Remove item from Core Data
                    context.delete(item)
                }
            }
            // Save changes
            try context.save()
//            print("Items with empty titles removed.")
        } catch {
            debugPrint("Failed to fetch or delete items: \(error)")
        }
    }
    
    ///
    ///Remove Empty and Copy sound object
    ///
   private func removeSoundSettingItem(){
        let fetchRequest: NSFetchRequest<Settings> = Settings.fetchRequest()
        do {
            let allItems = try context.fetch(fetchRequest)
            
            for item in allItems {
                // Check if title is empty
                if item.isItemCopied {
                    // Remove item from Core Data
                    context.delete(item)
                }
            }
            // Save changes
            try context.save()
//            print("Items with empty titles removed.")
        } catch {
            debugPrint("Failed to fetch or delete items: \(error)")
        }
    }
    
    ///
    ///Remove copy Items
    ///
   private func removeCopyItem(){
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        do {
            let allItems = try context.fetch(fetchRequest)
            
            for item in allItems {
                // Check if title is empty
                if item.isItemCopied {
                    // Remove item from Core Data
                    context.delete(item)
                }
            }
            // Save changes
            try context.save()
//            print("Items with empty titles removed.")
        } catch {
            debugPrint("Failed to fetch or delete items: \(error)")
        }
    }
    
    ///
    ///Remove all copy object from data on copy and app appear
    ///
    func removeAllCopyItems(){
        removeEmptyIntervalItem()
        removeMessageItem()
        removeColorItem()
        removeCopyItem()
        removeIntervalCallItem()
        removeRestIntervalItem()
        removeSoundSettingItem()
//        removeEmptyIntervalItem()
    }
    
   
    //MARK: -
    //MARK: CHECK IF USER REACHED FREE TIMER CREATION LIMIT
    func isUserReachedFreeTimerLimit() -> Bool {
        let fetchReq: NSFetchRequest<Item> = Item.fetchRequest()
        
        // Define the predicates for filtering items
        let typePredicate = NSPredicate(format: "type != %@", "Folder")
        let titlePredicate = NSPredicate(format: "title != nil AND title != ''")
        let isCopiedItem = NSPredicate(format: "isItemCopied == NO")
        
        // Combine predicates using AND
        fetchReq.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [typePredicate, titlePredicate,isCopiedItem])
        
        do {
            // Fetch items matching the criteria
            let filteredItems = try context.fetch(fetchReq)
            let freeTimerLimit = 3
            return filteredItems.count < freeTimerLimit
            
        } catch {
            debugPrint("Error while fetching items to check if user reached free timer creation limit: \(error.localizedDescription)")
            return false
        }
    }
    
    //MARK: -
    //MARK: CHECK IF USER REACHED FREE TIMER CREATION LIMIT count
    func countUserReachedFreeTimerLimit() -> Int {
        let fetchReq: NSFetchRequest<Item> = Item.fetchRequest()
        
        // Define the predicates for filtering items
        let typePredicate = NSPredicate(format: "type != %@", "Folder")
        let titlePredicate = NSPredicate(format: "title != nil AND title != ''")
        let isCopiedItem = NSPredicate(format: "isItemCopied == NO")
        // Combine predicates using AND
        fetchReq.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [typePredicate, titlePredicate,isCopiedItem])
        
        do {
            // Fetch items matching the criteria
            let filteredItems = try context.fetch(fetchReq)
            return filteredItems.count
            
        } catch {
            debugPrint("Error while fetching items to check if user reached free timer creation limit: \(error.localizedDescription)")
            return 0
        }
    }

}
