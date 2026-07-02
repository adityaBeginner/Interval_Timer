//
//  InnerFolderView.swift
//  TIMER
//
//  Created by Aditya Maroo on 22/08/24.
//

import SwiftUI

struct InnerFolderView: View {
    
    var isBackBtnHidden: Bool = false
    //MARK: -
    //MARK: STATE PROPERTIES
    @State var isIntervalCall:Bool = false
    @State var isReactionIntervalCall:Bool = false
    @State var isFolderNavigation:Bool = false
    @StateObject var viewModel = InnerFolderMV()
    @State var isPopBtnHidden: Bool = false
    @State var isFolderBtnPressed: Bool = false
    var stateOfParentFolder: WorkoutViewState = .Normal
    
    @State var item:Item?
    
    var body: some View {
        settingUp()
            .navigationBarHidden(true)
    }
}

#Preview {
    InnerFolderView()
}

extension InnerFolderView{
    @ViewBuilder
    func settingUp() -> some View{
        
        ZStack{
            ///background color
            Color(isPopBtnHidden ? .darkLayer : .background )
                .ignoresSafeArea()
            VStack{
                contentView()
                    .blur(radius: isFolderBtnPressed ? 12 : 0)
                    .onAppear{
                        isPopBtnHidden = false
                    }
                ComFooterView(viewState: $viewModel.viewState, isPlusBtnPressed: $isPopBtnHidden, listItem: viewModel.items, item: item, callBackFolderdata: {
                    viewModel.createFolderItem()
                    isFolderBtnPressed = true
                    viewModel.isBlurEffectPresent = true
                }, callBackChangeSelectedValue: {
                    viewModel.changeValueSelected()
                    viewModel.selectedItems.removeAll()
                })
                .blur(radius: isFolderBtnPressed ? 12 : 0)
                
            }
            NavigationLink(isActive: $isIntervalCall) {
                if isIntervalCall{
                    IntervalCallView(itemData: viewModel.item)
                }
            } label: {
                EmptyView()
            }
            .hidden()
            
            NavigationLink(isActive: $isFolderNavigation) {
                if isFolderNavigation{
                    InnerFolderView(stateOfParentFolder: viewModel.viewState, item: viewModel.item)
                }
            } label: {
                EmptyView()
            }
            .hidden()
            NavigationLink(isActive: $isReactionIntervalCall) {
                if isReactionIntervalCall{
                    ReactionTimeCallView(itemData: viewModel.item)
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
            
            
            //Delete pop alert
            if viewModel.isDeletePop {
                AlertTextPopScreen(alertHeader: viewModel.alertHeaderTitle, alertDescription: viewModel.validationErrorMessage, alertCancelText: "NO, GO BACK", alertOkText: "YES, DELETE", okayCallBack: {
                    viewModel.isDeletePop = false
                    viewModel.isBlurEffectPresent = false
                    /// Delete functionality and animation Handling
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200), execute: {
                        withAnimation(.smooth){
                            viewModel.isSlideAnimation = true
                            viewModel.viewState = .Normal
                        }
                    })
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000)){
                        withAnimation{
                            viewModel.changeValueSelected()
                            viewModel.isSlideAnimation = false
                            //Delete Call Back of intervalListItem
                            viewModel.deleteSelectedItems()
                            viewModel.selectedItems.removeAll()
                        }
                    }
                },
                                   cancelCallBack: {
                    viewModel.isDeletePop = false
                    viewModel.isBlurEffectPresent = false
                }
                )
                .onDisappear{
                    isPopBtnHidden = false
                }
            }
            //Csv Alert Pop
            if viewModel.isCsvActive{
                ShareCSV(isPresentedShare: $viewModel.isCsvActive)
            }
            
            /// Pop Folder Creation Screen
            if isFolderBtnPressed{
                AlertPopScreens(alertHeader: WorkoutString.popFolderNameTitle, alertOkText: WorkoutString.popFolderOkayBtn, alertCancelText: viewModel.isEditFolder ? WorkoutString.updateFolderBtn : WorkoutString.popFolderCancelBtn,isTextFieldHidden: false,  colorHexCode: $viewModel.colorHexCode,  colorOpacity: $viewModel.colorOpacity, colorObject: viewModel.childrenFolder?.colorObject, folderName: viewModel.folderName,  onTapOkText: {
                    if !viewModel.isEditFolder{
                        viewModel.deleteEmptyFolder()
                    }
                    isPopBtnHidden = false
                    isFolderBtnPressed = false
                    viewModel.isBlurEffectPresent = false
                    viewModel.isEditFolder = false
                },callBackData: { folderName in
                    viewModel.folderName = folderName
                    viewModel.addUpdateItemToFolder()
                    isFolderBtnPressed = false
                    viewModel.isBlurEffectPresent = false
                    viewModel.isEditFolder = false
                    isPopBtnHidden = false
                })
                
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarBackButtonHidden()
        .onAppear(perform: {
            viewModel.items = ((item?.children?.allObjects as? [Item]) ?? []).filter({($0.title ?? "") != ""})
            viewModel.item = item
            viewModel.sortItems()
            viewModel.viewState = stateOfParentFolder
        })
        .onDisappear{
            viewModel.selectedItems.removeAll()
            viewModel.changeValueSelected()
//            viewModel.viewState = .Normal
        }
    }
    
    @ViewBuilder
    func contentView() -> some View{
        VStack(spacing: 0, content: {
            
            // Header
            headingView()
            
            //Workout List
            workoutLists()
            Spacer()
        })
    }
    
    @ViewBuilder
    func headingView() -> some View{
            ComEditHeaderView(viewState: $viewModel.viewState , headerTitleTxt: .constant(item?.title ?? "Folder Name"),selectedItem: viewModel.selectedItems,isBackBtnHidden: false,callBackDeleteData: {
                if !viewModel.selectedItems.isEmpty{
                    viewModel.alertHeaderTitle = "DELETE THIS SELECTION"
                    viewModel.validationErrorMessage = "Are you sure you want to permanently\ndelete the selected item(s)?"
                    viewModel.isDeletePop = true
                    viewModel.isBlurEffectPresent = true
                }
            }, callBackCopyData: {
                if CoreDataManager.shared.countUserReachedFreeTimerLimit() + viewModel.selectedItems.count <= CoreDataManager.freeLimitCount || AppDefaults.shared.isUserSubscribed{
                    EditOperations.copyEntity(selectedItems: viewModel.selectedItems, entityType: .item)
//                    viewModel.changeValueSelected()
//                    viewModel.selectedItems.removeAll()
//                    viewModel.isItemSelected = true
//                    viewModel.viewState = .Normal
                }
                else{
                    viewModel.selectedItems.removeAll()
                    viewModel.changeValueSelected()
                    viewModel.viewState = .Normal
                    viewModel.isSubscription = true
                }
                
            }, callBackPasteData: {
                if CoreDataManager.shared.countUserReachedFreeTimerLimit() < CoreDataManager.freeLimitCount || AppDefaults.shared.isUserSubscribed{
                    if EditOperations.editEntityType == .item{
                        EditOperations.pasteItem(inObject: item, count: viewModel.items.count)
                        runWithDelay(delay: 0.5) {
                            viewModel.deleteLastItemPasteFree()
                            viewModel.items = item?.children?.allObjects as? [Item] ?? []
                            viewModel.deletePasteNullItem()
                            viewModel.changeValueSelected()
                            viewModel.sortItems()
                            viewModel.selectedItems.removeAll()
//                            viewModel.viewState = .Normal
                            viewModel.isScrollDown = true
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
                        viewModel.isCsvActive = true
                        viewModel.changeValueSelected()
                        viewModel.selectedItems.removeAll()
                        viewModel.viewState = .Normal
                    }
                }
                else{
                    viewModel.viewState = .Normal
                    viewModel.isSubscription = true
                }
            } )
        
    }
    @ViewBuilder
    func workoutLists() -> some View{
        ScrollViewReader{scrollViewProxy in
            List{
                ForEach($viewModel.items){item in
                    CartContainerView( isEditable: $viewModel.viewState, itemData: item,unSelectAllItem: $viewModel.isItemSelected, folderCallBack: {
                        viewModel.folderName = item.wrappedValue.title ?? ""
                        isFolderBtnPressed = true
                        viewModel.isEditFolder = true
                        viewModel.childrenFolder = item.wrappedValue
                        viewModel.colorHexCode = item.wrappedValue.colorObject?.colorHexCode ?? ""
                        viewModel.colorOpacity = item.wrappedValue.colorObject?.alphaValue ?? 1
                    }, callBackAddSelectedData: { itemData in
                        viewModel.selectedItems.append(itemData)
                    },        callBackRemoveSelectedData: {itemData in
                        viewModel.removeSelectedItems(item: itemData)
                    })
                    .offset(x: viewModel.isSlideAnimation ? item.wrappedValue.isSelected ? -400 : 0 : 0)
                    .contentShape(Rectangle())
                    .onTapGesture{
                        if viewModel.viewState == .Normal{
                            if item.wrappedValue.type == "Timer"{
                                viewModel.item = item.wrappedValue
                                isIntervalCall = true
                            }
                            else if item.wrappedValue.type == "Folder"{
                                viewModel.item = item.wrappedValue
                                isFolderNavigation = true
                            }
                            else if item.wrappedValue.type == "Drill"{
                                viewModel.item = item.wrappedValue
                                isReactionIntervalCall = true
                            }
                            // The tap gesture triggers the NavigationLink programmatically
                        }
                        else if item.wrappedValue.type == "Folder"{
                            viewModel.item = item.wrappedValue
                            isFolderNavigation = true
                        }
                    }
                    .listRowInsets(.init(top: 0, leading: 16, bottom: 0, trailing: 16))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .id(item.wrappedValue.id)
                }
                .onMove(perform: { indices, newOffset in
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
}
