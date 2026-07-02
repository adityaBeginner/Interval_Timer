//
//  InnerFolderMV.swift
//  TIMER
//
//  Created by Aditya Maroo on 26/08/24.
//

import Foundation
import SwiftUI


class InnerFolderMV: ObservableObject{
    
    //MARK: -
    //MARK: - PUBLISHED PROPERTIES
    @Published var viewState: WorkoutViewState = .Normal
    @Published var items: [Item] = []
    
    //Folder Name Change
    @Published var folderName: String = ""
    @Published var isEditFolder: Bool = false
    
    //Slide Animation
    @Published var isSlideAnimation: Bool = false
    
    //Delete Pop
    @Published var isDeletePop: Bool = false
    @Published var alertHeaderTitle: String = ""
    @Published var validationErrorMessage: String = ""
    
    //ItemSelected
    @Published var isItemSelected: Bool = false
    
    //Color object
    @Published var colorHexCode: String = Color.red.toHex()
    @Published var colorOpacity: Double = 1.0
    
    @Published var isSubscription: Bool = /*AppDefaults.shared.isUserSubscribed*/ false
    @Published var isScrollDown: Bool = false
    
    @Published var selectedItems:[Item] = []
    //Blur Effect
    @Published var isBlurEffectPresent: Bool = false
    
    //CSV File
    @Published var isCsvActive: Bool = false
   
    
    var item:Item?
    var childrenFolder: Item?
    
    func moveHandling(from source: IndexSet, to destination: Int) {
        items.move(fromOffsets: source, toOffset: destination)
        
        for (index, _) in items.enumerated() {
            items[index].indexValue = Int64(index)
        }
        
        CoreDataManager.shared.saveContext()
    }
    
    ///
    /// REMOVE SELECTED ITEMS FROM COREDATA
    ///
    func deleteSelectedItems(){
        selectedItems.forEach{ selectedItem in 
            if selectedItem.type == "Folder"{
                deleteChildrenElement(folderItem: selectedItem)
            }
            CoreDataManager.shared.deleteNSManagedObject(object: selectedItem)
            items.removeAll(where: {$0.objectID == selectedItem.objectID})
            item?.children = NSSet(array: items)
        }
        for index in 0..<items.count{
            items[index].indexValue = Int64(index)
        }
        CoreDataManager.shared.saveContext()
    }
    
    ///
    ///Delete single Items
    ///
    func deleteSingleItems(indexSet: IndexSet){
        for index in indexSet {
            let deleteItem = items[index]
            if deleteItem.type == "Folder" {
                deleteChildrenElement(folderItem: deleteItem)
            }
            CoreDataManager.shared.deleteNSManagedObject(object: deleteItem)
            items.remove(at: index)
             item?.children = NSSet(array: items)
        }
        for index in 0..<items.count{
            items[index].indexValue = Int64(index)
        }
        CoreDataManager.shared.saveContext()
    }
    
    
    ///
    ///deleting children element of item
    ///
    func deleteChildrenElement(folderItem: Item){
        if folderItem.children?.count ?? 0 > 0{
            guard let folderItems = folderItem.children?.allObjects as? [Item] else{
                return
            }
            folderItems.forEach{childItem in
                if childItem.type == "Folder"{
                    deleteChildrenElement(folderItem: childItem)
                }
                CoreDataManager.shared.deleteNSManagedObject(object: childItem)
            }
        }
        CoreDataManager.shared.saveContext()
    }
    
    
    ///
    ///Remove selected item
    func removeSelectedItems(item: Item){
        let removeData = selectedItems.filter({$0 != item})
        selectedItems = removeData
    }
    
    ///
    ///func isSelected in intervalList false
    ///
    func changeValueSelected(){
        items.forEach { item in
            item.isSelected = false
        }
    }
    
    ///
    ///Sort Items
    ///
    func sortItems(){
        items = items.filter{$0.title != nil || $0.title?.trimmingCharacters(in: .whitespaces) != ""}
        items.sort{$0.indexValue < $1.indexValue }
    }
    
    ///
    ///Update folder item
    ///
    func addUpdateItemToFolder(){
        childrenFolder?.title = folderName
        if let item{
            var allChildrenObjects = (item.children?.allObjects as? [Item]) ?? []
            allChildrenObjects.append(childrenFolder ?? Item())
            self.item?.children = NSSet(array: allChildrenObjects)
            items = (self.item?.children?.allObjects as? [Item]) ?? []
            CoreDataManager.shared.saveContext()
            sortItems()
        }
    }
    
    ///
    ///Create folder item
    ///
    func createFolderItem(){
        folderName = ""
        childrenFolder = Item(context: CoreDataManager.shared.context)
        childrenFolder?.type = "Folder"
        childrenFolder?.isChild = true
        childrenFolder?.title = folderName
        childrenFolder?.indexValue = Int64(item?.children?.count ?? 0)
        childrenFolder?.colorObject = createColorObject()
        childrenFolder?.colorObject?.alphaValue = 1
        colorHexCode = Color.red.toHex()
        colorOpacity = 1.0
        childrenFolder?.colorObject?.colorHexCode = Color.red.toHex()
        childrenFolder?.colorObject?.colorRgbX = 16
        childrenFolder?.colorObject?.colorRgbY = 12
        childrenFolder?.colorObject?.colorOpacityX = UIScreen.main.bounds.size.width - 48
        childrenFolder?.colorObject?.colorOpacityY = 13
        childrenFolder?.colorObject?.colorShadesX = UIScreen.main.bounds.size.width - 40
        childrenFolder?.colorObject?.colorShadesY = 8
        CoreDataManager.shared.saveContext()
        
    }
    
    ///
    /// CREATE COLOROBJECT
    ///
    private func createColorObject()->ColorObject{
        return ColorObject(context: CoreDataManager.shared.context)
    }
    
    ///
    ///Delete emptyFolder
    ///
    func deleteEmptyFolder(){
        guard let item = childrenFolder else{ debugPrint("item is nil, whil attempting to delete an Item");return}
        
        CoreDataManager.shared.deleteNSManagedObject(object: item)
        CoreDataManager.shared.saveContext()
        self.childrenFolder = nil
        
    }
    
    //This function is not used it's for removing empty item when we cut
    func deletEmptyItems(item: Item?){
        var deleteItem = item?.children?.allObjects as? [Item] ?? []
       var itemToDelete = deleteItem.filter{($0.title ?? "") == "" }
        itemToDelete.forEach{data in
            CoreDataManager.shared.deleteNSManagedObject(object: data)
        }
    }
    
    //Free Paste Item Count
    func deleteLastItemPasteFree(){
        if !AppDefaults.shared.isUserSubscribed{
            var totalItems = item?.children?.allObjects as? [Item] ?? []
            changeValueSelected()
            totalItems.sort{$0.indexValue < $1.indexValue}
            if totalItems.count > CoreDataManager.freeLimitCount{
                for index in 0..<(totalItems.count - CoreDataManager.freeLimitCount){
                    CoreDataManager.shared.deleteNSManagedObject(object: totalItems[CoreDataManager.freeLimitCount + index])
                }
            }
        }
    }
    
    //Deleting Cut empty null object
    func deletePasteNullItem(){
        if !AppDefaults.shared.isUserSubscribed{
            items = items.filter({$0.title != nil})
            item?.children = NSSet(array: items)
            CoreDataManager.shared.saveContext()
        }
    }
    
}
