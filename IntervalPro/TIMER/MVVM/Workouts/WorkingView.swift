//
//  ContentView.swift
//  TIMER
//
//  Created by Aditya Maroo on 13/08/24.
//

import SwiftUI

struct WorkingView: View {
    //MARK: - State Properties
    @State var isStateChange: WorkoutViewState = .Normal
    @State var isIntervalCall:Bool = false
    @State var isReactionIntervalCall:Bool = false
    @State var isFolderNavigation:Bool = false
    @State var isFolderButtonPressed: Bool = false
    @State var isActiveShareCSV = false
    @State var isPopBtnHidden: Bool = false
    
    
    //MARK: - VIEWMODEL
    @StateObject private var viewModel = WorkoutVM()
    //MARK: - ENVIRONMENT OBJECT
    @EnvironmentObject var appEnvironment: AppEnvironment
    
    var data:String = ""
    //MARK: -  Main body for View for Workout Screen
    var body: some View {
        NavigationView{
            ZStack{
                ///background color
                Color(.background )
                    .ignoresSafeArea()
                
                contentView()
                    .blur(radius: viewModel.isBlurEffectPreent ? 12 : 0)
                    .onAppear{
                        isPopBtnHidden = false
                    }
                ///for pop guide content
                if viewModel.viewState == .ViewGuide{
                    ZStack{
                        Color(uiColor: .timerWorkoutColor).opacity(0.2)
                            .ignoresSafeArea()
                        popHandling()
                    }
                    .edgesIgnoringSafeArea(.bottom)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                ///If Plus Button Pressed
                if isPopBtnHidden{
                    Color.darkLayer
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation{
                                isPopBtnHidden = false
                            }
                        }
                }
                footerContentData()
                    .blur(radius: viewModel.isBlurEffectPreent ? 12 : 0)
                
                /// Pop Folder Creation Screen
                if isFolderButtonPressed{
                    AlertPopScreens(alertHeader: WorkoutString.popFolderNameTitle, alertOkText: WorkoutString.popFolderOkayBtn, alertCancelText: viewModel.isEditFolder ? WorkoutString.updateFolderBtn : WorkoutString.popFolderCancelBtn,isTextFieldHidden: false,  colorHexCode: $viewModel.colorHexCode, colorOpacity: $viewModel.colorOpacity, colorObject: viewModel.folderItem?.colorObject,folderName: viewModel.folderName, onTapOkText: {
                        if !viewModel.isEditFolder{
                            viewModel.deleteEmptyFolder()
                        }
                        viewModel.isEditFolder = false
                        isFolderButtonPressed = false
                        viewModel.isBlurEffectPreent = false
                        viewModel.fetchAllItems()
                        /* fetching Data on Disappear of Alert folder screen*/
                        
                        
                        isPopBtnHidden = false
                    } ,callBackData: { folderName in
                        viewModel.folderName = folderName
                        viewModel.addUpdateItemToFolder()
                        viewModel.isBlurEffectPreent = false
                        isFolderButtonPressed = false
                        viewModel.isEditFolder = false
                        isPopBtnHidden = false
                        viewModel.fetchAllItems()
                    }
                    )
                }
                //MARK: - Navigation Link Controller for interval creation, reaction Drill and Inner folder
                NavigationLink(isActive: $isIntervalCall) {
                    if isIntervalCall{
                        IntervalCallView(itemData: viewModel.itemData)
                    }
                } label: {
                    EmptyView()
                }
                .hidden()
                NavigationLink(isActive: $isFolderNavigation) {
                    if isFolderNavigation{
                        InnerFolderView(stateOfParentFolder: viewModel.viewState, item: viewModel.itemData)
                    }
                } label: {
                    EmptyView()
                }
                .hidden()
                NavigationLink(isActive: $isReactionIntervalCall) {
                    if isReactionIntervalCall{
                        ReactionTimeCallView(itemData: viewModel.itemData)
                    }
                } label: {
                    EmptyView()
                }
                .hidden()
                
                NavigationLink(isActive: $appEnvironment.isActivePurchaseView) {
                    if appEnvironment.isActivePurchaseView{
                        PurchaseView()
                    }
                } label: {
                    EmptyView()
                }
                .hidden()
                
                // Copy Purchase view validation
                NavigationLink(isActive: $viewModel.isSubscription) {
                    if viewModel.isSubscription{
                        PurchaseView()
                    }
                } label: {
                    EmptyView()
                }
                
                
                if isActiveShareCSV{
                    ShareCSV(isPresentedShare: $isActiveShareCSV)
                }
                if viewModel.isDeletePop {
                    AlertTextPopScreen(alertHeader: viewModel.alertHeaderTitle, alertDescription: viewModel.validationErrorMessage, alertCancelText: "NO, GO BACK", alertOkText: "YES, DELETE", okayCallBack: {
                        viewModel.isDeletePop = false
                        viewModel.isBlurEffectPreent = false
                        /// Delete functionality and animation Handling
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200), execute: {
                            withAnimation(.smooth){
                                viewModel.isSlideAnimation = true
                            }
                        })
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000)){
                            withAnimation{
                                viewModel.changeValueSelected()
                                viewModel.isSlideAnimation = false
                                //Delete Call Back of intervalListItem
                                viewModel.deleteSelectedItems()
                                viewModel.selectedItems.removeAll()
                                viewModel.viewState = .Normal
                            }
                        }
                    },
                                       cancelCallBack: {
                        viewModel.isDeletePop = false
                        viewModel.isBlurEffectPreent = false
                    }
                    )
                }
            }
            .navigationBarHidden(true)
            .onAppear{
                if viewModel.dismissPopAlert() && viewModel.viewState == .ViewGuide {
                    viewModel.viewState = .Normal
                }
                
                viewModel.fetchAllItems()
                //                if EditOperations.editEntityType == .item{
                //                    viewModel.viewState = .Edit
                //                }
                ///
                ///REMOVE EMPTY ITEMS
                ///
                ///``Implemented for item data count not to save the object before pasting it and item cart children count should be updated``
                //                if !isFolderButtonPressed{
                //                    CoreDataManager.shared.removeEmptyItems()
                //                }
                
                ///HandlingPop Screen on to apperar on first
            }
            
            //Disappear is Working For Copy object
            .onDisappear{
                viewModel.selectedItems.removeAll()
                viewModel.changeValueSelected()
//                viewModel.viewState = .Normal
            }
            .onOpenURL{ url in
//                if let sharedContainerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "com.intervalpro.app") {
//                    let filePath = sharedContainerURL.appendingPathComponent("File Provider Storage/PBIntervals3.csv")
//                    debugPrint("Checking file existence at: \(filePath.path)")
//                    
//                    if FileManager.default.fileExists(atPath: filePath.path) {
//                        debugPrint("File exists at path")
//                    } else {
//                        debugPrint("File does not exist in shared container")
//                    }
//                } else {
//                    debugPrint("Shared container URL could not be retrieved.")
//                }
                if AppDefaults.shared.isUserSubscribed{
                  _ = ImportCSV.shared.importItemsFromCSV(url: url)
                    runWithDelay(delay: 0.5) {
                        viewModel.fetchAllItems()
                    }
                }
            }
            .onChange(of: isFolderButtonPressed, perform: {newValue in
                if !newValue{
                    CoreDataManager.shared.removeEmptyItems()
                }
            })
           
            
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}


//MARK: - Extension for function of returning view of sub-ContentView header, workout, footer
extension WorkingView{
    
    /**
     * Handling main content data  such as footer , header and workout acoording to the state
     *
     * - Parameters:No parameter
     *
     * - Returns: Content View with (footer, header, workout).
     *
     */
    @ViewBuilder
    func contentView() -> some View{
        VStack(spacing: 16, content: {
            // Header
            headingView()
            //Workout List
            workoutLists()
        })
        .padding(.bottom, 32)
    }
    
    @ViewBuilder
    func footerContentData()-> some View{
        VStack{
            Spacer()
            ///footer components
            ComFooterView(viewState: $viewModel.viewState, isPlusBtnPressed: $isPopBtnHidden, listItem: viewModel.items, callBackFolderdata: {
                viewModel.createFolderItem()
                isFolderButtonPressed = true
                viewModel.isBlurEffectPreent = true
            }, callBackChangeSelectedValue: {
                viewModel.changeValueSelected()
                viewModel.selectedItems.removeAll()
            })
        }
        .edgesIgnoringSafeArea(.bottom)
    }
    
    /**
     * For handling edit and normal header view component
     *
     * - Parameters: No Parameter
     *
     * - Returns: header and edit  header view according to state.
     *
     */
    @ViewBuilder
    func headingView() -> some View{
//        if viewModel.viewState == .Normal || viewModel.viewState == .ViewGuide{
//            ComHeaderView(titleHeader: .constant("Workouts"))
//                .padding(.horizontal, commonPadding)
//        }
//        else{
            ComEditHeaderView(viewState: $viewModel.viewState, headerTitleTxt: .constant("Workouts"),selectedItem: viewModel.selectedItems,
                              callBackDeleteData: {
                if !viewModel.selectedItems.isEmpty{
                    viewModel.alertHeaderTitle = "DELETE THIS SELECTION"
                    viewModel.validationErrorMessage = "Are you sure you want to permanently\ndelete the selected item(s)?"
                    viewModel.isDeletePop = true
                    viewModel.isBlurEffectPreent = true
                }
            }, callBackCopyData: {
                if CoreDataManager.shared.countUserReachedFreeTimerLimit() + viewModel.selectedItems.count <= CoreDataManager.freeLimitCount /* For testing purpose 10 items can be cut copy paste else it is 3*/ || AppDefaults.shared.isUserSubscribed{
                    EditOperations.copyEntity(selectedItems: viewModel.selectedItems, entityType: .item)
                    //                    viewModel.selectedItems.removeAll()
                    //                    viewModel.changeValueSelected()
                    //                viewModel.viewState = .Normal
                }
                else  {
                    viewModel.selectedItems.removeAll()
                    viewModel.changeValueSelected()
                    viewModel.viewState = .Normal
                    viewModel.isSubscription = true
                }
            }, callBackPasteData: {
                if CoreDataManager.shared.countUserReachedFreeTimerLimit() < CoreDataManager.freeLimitCount /* For testing purpose 10 items can be cut copy paste else it is 3*/ || AppDefaults.shared.isUserSubscribed{
                    if EditOperations.editEntityType == .item{
                        EditOperations.pasteItem(inObject: nil, count: viewModel.items.count)
                        runWithDelay(delay: 0.5) {
                            viewModel.deleteLastItemPasteFree()
                            viewModel.fetchAllItems()
                            viewModel.isScrollDown = true
                            viewModel.selectedItems.removeAll()
//                            viewModel.viewState = .Normal
//                            runWithDelay(delay: 0.2){
//                                viewModel.viewState = .Edit
//                            }
                            viewModel.isItemSelected = true
                        }
                    }
                }
                else{
                    viewModel.viewState = .Normal
                    viewModel.isSubscription = true
                }
            }, callBackCutData: {
                /// Cut Call Back Functionality
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100), execute: {
                    withAnimation(.smooth){
                        viewModel.isSlideAnimation = true
                    }
                })
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000)){
                    withAnimation{
                        EditOperations.cutEntity(selectedItems: viewModel.selectedItems, entityType: .item)
                        viewModel.items = cutChangeItemIndex(selectedMessage: viewModel.selectedItems, totalMessage: viewModel.items)
                        viewModel.selectedItems.removeAll()
                        viewModel.isSlideAnimation = false
                        viewModel.changeValueSelected()
                        
                    }
                }
                
            }, callBackShareData: {
                if AppDefaults.shared.isUserSubscribed{
                    if !viewModel.selectedItems.isEmpty{
                        ExportCSV.shared.exportItemsToCSV(from: viewModel.selectedItems)
                        isActiveShareCSV = true
                        viewModel.changeValueSelected()
                        viewModel.selectedItems.removeAll()
                        viewModel.viewState = .Normal
                    }
                }
                else{
                    viewModel.viewState = .Normal
                    viewModel.isSubscription = true
                }
            })
            //            .padding(.horizontal, commonPadding)
//        }
    }
    /**
     *workout list view which contains number of timer driil and foler type
     *This are display in a cartContainer components
     *
     * - Parameters: No Parameter
     *
     * - Returns: list of type of cart
     *
     */
    @ViewBuilder
    func workoutLists() -> some View{
        ScrollViewReader{scrollViewProxy in
            List {
                ForEach($viewModel.items, id: \.self){itemArray in
                    //CartContainer folder contains name, timer, penicl button
                    CartContainerView(isEditable:  $viewModel.viewState,itemData: itemArray,unSelectAllItem: $viewModel.isItemSelected,
                                      folderCallBack: {
                        viewModel.folderName = itemArray.wrappedValue.title ?? ""
                        isFolderButtonPressed = true
                        viewModel.isEditFolder = true
                        viewModel.folderItem = itemArray.wrappedValue
                        viewModel.colorHexCode = itemArray.wrappedValue.colorObject?.colorHexCode ?? ""
                        viewModel.isBlurEffectPreent = true
                        viewModel.colorOpacity = itemArray.wrappedValue.colorObject?.alphaValue ?? 1
                    }, callBackAddSelectedData: { itemData in
                        viewModel.selectedItems.append(itemData)
                    },callBackRemoveSelectedData: {itemData in
                        viewModel.removeSelectedItems(item: itemData)
                    }
                    )
                    .offset(x: viewModel.isSlideAnimation ? itemArray.wrappedValue.isSelected ? -400 : 0 : 0)
                    // Ensures the whole area is tappable
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if viewModel.viewState == .Normal{
                            if itemArray.wrappedValue.type == "Timer"{
                                isIntervalCall = true
                                viewModel.itemData = itemArray.wrappedValue
                            }
                            else if itemArray.wrappedValue.type == "Folder"{
                                viewModel.itemData = itemArray.wrappedValue
                                isFolderNavigation = true
                            }
                            else if itemArray.wrappedValue.type == "Drill"{
                                viewModel.itemData = itemArray.wrappedValue
                                isReactionIntervalCall = true
                                
                            }
                            // The tap gesture triggers the NavigationLink programmatically
                        }
                        else if itemArray.wrappedValue.type == "Folder"{
                            viewModel.itemData = itemArray.wrappedValue
                            isFolderNavigation = true
                        }
                        
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(.init(top: 0, leading: 16, bottom: 0, trailing: 16))
                    .listRowBackground(Color.clear)
                    .id(itemArray.wrappedValue.id)  // Ensure each item has a unique ID
                }
                .onMove(perform: { indices, newOffset in
                    debugPrint("onMoveEvent running")
                    viewModel.moveHandling(from: indices, to: newOffset)
                })
                .onDelete(perform: {indexSet in
                    viewModel.deleteSingleItems(indexSet: indexSet)
                })
            }
            .listStyle(.plain)
            .buttonStyle(PlainButtonStyle())
            .listRowSpacing(0)
            .onChange(of: viewModel.isScrollDown, perform: {newValue in
                if newValue{
                    // Scroll to the last item's ID
                    if let lastItem = viewModel.items.last?.id {
                        withAnimation(.smooth){
                            scrollViewProxy.scrollTo(lastItem, anchor: .bottom)
                        }
                    }
                    viewModel.isScrollDown = false
                }
            })
        }
        
    }
    @ViewBuilder
    func popHandling()-> some View{
        PopContainerView(popHidding: $viewModel.viewState, popHandlingScreens: .WorkoutScreen, descriptionString: $viewModel.popDescription)
    }
}

#Preview {
    WorkingView()
}
extension WorkingView{
    public func calculateLineCount(in containerWidth: CGFloat, text: String)-> Int {
        let textAttributes: [NSAttributedString.Key: Any] = [.font: font]
        let attributedText = NSAttributedString(string: text, attributes: textAttributes)
        let textWidth = containerWidth
        let boundingRect = attributedText.boundingRect(
            with: CGSize(width: textWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )
        
        let lineHeight = 16.0
        let lineCount = Int(ceil(boundingRect.height / lineHeight))
        return lineCount
    }
}
