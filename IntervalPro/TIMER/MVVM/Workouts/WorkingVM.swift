//
//  WorkingVM.swift
//  TIMER
//
//  Created by Aditya Maroo on 26/08/24.
//

import SwiftUI

import SwiftUI
import CoreData
import Combine
//MARK: - state enum
enum WorkoutViewState : String{
    case Normal
    case Edit
    case ViewGuide

}
//MARK: - file type contains timer, drill, folder
enum FileType: String{
    case Timer
    case Drill
    case Folder
}
// //MARK: -
//enum PopAppear: String{
//    case onNext
//   case onAppear
//}

//MARK: - View model class for workout view
// Contains function for storing data to database , updating, fetching and all type function
class WorkoutVM: ObservableObject {
    ///pop description string array
    @Published var popDescription: [String] = ["Tap the + button to create a new Interval Timer, Reaction Timer, or Folder.","Organise items: drag, copy, cut, delete.", "Access general app/individual timer settings."]
    ///item type entity data of nsset
    @Published var items: [Item] = []
    ///Selected items
    @Published var selectedItems:[Item] = []
    
    /// Toast Componets hiding and unhiding
    @Published var isToastHidden: Bool = false
    @Published var toastTitleName: String = ""
    ///state variable
    @Published var viewState:WorkoutViewState = .ViewGuide
    @Published var isActiveSettings:Bool = false
    @Published var userGuideViewActiveIndex:Int = 1
    //    @Published var navigationTag: String? = nil
    @Published var fileTypeCart: FileType? = nil
    @Published var folderName: String = ""
    @Published var isEditFolder: Bool = false
    
    //Slide Animation
    @Published var isSlideAnimation: Bool = false
    
    //Delete Pop
    @Published var isDeletePop: Bool = false
    @Published var alertHeaderTitle: String = ""
    @Published var validationErrorMessage: String = ""
    
    //Color object
    @Published var colorHexCode: String = Color(uiColor: .defaultFolderTimerReactionColor).toHex()
    @Published var colorOpacity: Double = 1.0
    
    @Published var isSubscription: Bool = /*AppDefaults.shared.isUserSubscribed*/ false
    
    //Scroll to last
    @Published var isScrollDown: Bool = false
    
    //Blur Effect
    @Published var isBlurEffectPreent: Bool = false
    
    //ItemSelected
    @Published var isItemSelected: Bool = false
    
    ///itemstoring for interval call and reaction call
    var itemData: Item?
    var folderItem: Item?
    
    
    
    init() {
        fetchAllItems()
        
    }
    
    // Fetch all records from Core Data
    func fetchAllItems() {
//        debugPrint(CoreDataManager.shared.printingfetchItems())
            items = CoreDataManager.shared.fetchItems()
            changeValueSelected()
            items.sort{$0.indexValue < $1.indexValue}
        
    }
    
    // Add a new item
    func addItem(title: String, subtitle: String, timestamp: Date, image: Data) {
        //        CoreDataManager.shared.addItem(title: title, subtitle: subtitle, timestamp: timestamp, image: image)
        fetchAllItems() // Refresh the items array
    }
    
    // Edit an existing item
    func editItem(item: Item, newTitle: String, newSubtitle: String, newTimestamp: Date, newImage: Data) {
        
        fetchAllItems() // Refresh the items array
    }
    
    // Delete an item
    func deleteItem(selectedItem: [Item]) {
        
        
        fetchAllItems() // Refresh the items array
    }
    
    // Move function to handle the rearranging of items
    func moveHandling(from source: IndexSet, to destination: Int) {
        if selectedItems.isEmpty{
            items.move(fromOffsets: source, toOffset: destination)
        }
        else{
            selectedMoveItem(destination: destination, indexSet: source)
        }
        for (index, _) in items.enumerated() {
            items[index].indexValue = Int64(index)
        }
        
        CoreDataManager.shared.saveContext()
    }
    
    ///
    /// REMOVE SELECTED ITEMS FROM COREDATA
    ///
    
    func deleteSelectedItems(){
        selectedItems.forEach{
            if $0.type == "Folder"{
                deleteChildrenElement(folderItem: $0)
            }
            CoreDataManager.shared.deleteNSManagedObject(object: $0)
        }
        for index in 0..<items.count{
            items[index].indexValue = Int64(index)
        }
        CoreDataManager.shared.saveContext()
        fetchAllItems()
    }
    
    func removeSelectedItems(item: Item){
        let removeData = selectedItems.filter({$0 != item})
        selectedItems = removeData
    }
    
    ///
    ///Delete single Items
    ///
    func deleteSingleItems(indexSet: IndexSet){
        for index in indexSet {
            let deleteItem = items.remove(at: index)
            if deleteItem.type == "Folder" {
                deleteChildrenElement(folderItem: deleteItem)
            }
            CoreDataManager.shared.deleteNSManagedObject(object: deleteItem)
            
        }
        for index in 0..<items.count{
            items[index].indexValue = Int64(index)
        }
        CoreDataManager.shared.saveContext()
        fetchAllItems()
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
    ///func isSelected in intervalList false
    ///
    func changeValueSelected(){
        items.forEach { item in
            item.isSelected = false
        }
    }
    
    ///
    /// Handling Dissmis App pop
    ///
    func dismissPopAlert()-> Bool{
        return AppDefaults.shared.isIntroCompletedOnWorkingView
    }
    
    ///
    ///Update folder item
    ///
    func addUpdateItemToFolder(){
        folderItem?.title = folderName
        folderItem?.type = FileType.Folder.rawValue
        CoreDataManager.shared.saveContext()
    }
    
    ///
    ///Create folder item
    ///
    func createFolderItem(){
        folderName = ""
        folderItem = Item(context: CoreDataManager.shared.context)
        folderItem?.indexValue = Int64(items.isEmpty ? 0 : items.count)
        folderItem?.colorObject = createColorObject()
        folderItem?.colorObject?.alphaValue = 1
        colorHexCode = Color(uiColor: .defaultFolderTimerReactionColor).toHex()
        colorOpacity = 1.0
        folderItem?.colorObject?.colorHexCode = Color(.defaultFolderTimerReactionColor).toHex()
        folderItem?.colorObject?.colorRgbX = 16
        folderItem?.colorObject?.colorRgbY = 12
        folderItem?.colorObject?.colorOpacityX = UIScreen.main.bounds.size.width - 48
        folderItem?.colorObject?.colorOpacityY = 13
        folderItem?.colorObject?.colorShadesX = UIScreen.main.bounds.size.width - 40
        folderItem?.colorObject?.colorShadesY = 8
        
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
        guard let item = folderItem else{ debugPrint("item is nil, whil attempting to delete an Item");return}
     
            CoreDataManager.shared.deleteNSManagedObject(object: item)
            CoreDataManager.shared.saveContext()
            self.folderItem = nil
    
    }
    func selectedMoveItem(destination: Int, indexSet: IndexSet){
        var newDestination = destination
       print("destination: \(destination)")
        print("IndexSet: \(indexSet)")
        if destination < selectedItems.first?.indexValue ?? 0{
            selectedItems.reverse()
        }
        // Move each item from the selected index to the new destination
                for index in selectedItems {
                    if selectedItems.count < items.count - selectedItems.count {
                        items.move(fromOffsets: IndexSet(integer: Int(index.indexValue)), toOffset: newDestination)
                    }
                    else{
                        items.move(fromOffsets: IndexSet(integer: Int(index.indexValue)), toOffset: newDestination)
                        newDestination -= 1
                    }
                    
                    }
    }
    
    //Free Paste Item Count
    func deleteLastItemPasteFree(){
        if !AppDefaults.shared.isUserSubscribed{
            var totalItems = CoreDataManager.shared.fetchItems()
            changeValueSelected()
            totalItems.sort{$0.indexValue < $1.indexValue}
            if totalItems.count > CoreDataManager.freeLimitCount{
                for index in 0..<(totalItems.count - CoreDataManager.freeLimitCount){
                    CoreDataManager.shared.deleteNSManagedObject(object: totalItems[CoreDataManager.freeLimitCount + index])
                }
            }
        }
    }
    
    
}


