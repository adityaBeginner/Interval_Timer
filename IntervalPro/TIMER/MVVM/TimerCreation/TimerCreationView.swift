//
//  ContentView.swift
//  TIMER
//
//  Created by Aditya Maroo on 20/08/24.
//

import SwiftUI

struct TimerCreationView: View {
    //MARK: - State Variable properties for navigation (color selection and add interval)
    @State var isAddInterval: Bool = false
    @State var isUpdateNavigation: Bool = false
    //    @State private var previousChangeHandling: (String, String, Bool, Bool, String, Bool, String, String, Bool, String, Int64)?
    
    //MARK: - state object or view model object for for displaying and saving data
    @StateObject var viewModel = TimerCreationVM()
    
    //MARK: -State object for keyboard observation
    @StateObject var keyboardResponder = KeyboardResponder()
    
    
    @Environment(\.presentationMode) var isPresented
    //MARK: - variable for saving data withut update
    var isEdited:Bool = false
    var itemData: Item?
    var itemCount: Int?
    
    
    //MARK: - Main content view
    var body: some View {
        ZStack{
            Color.background
                .ignoresSafeArea()
            VStack(spacing: 0){
                ComHeaderView(titleHeader: .constant("Timer Creation"), audioSettingData: viewModel.item?.setting,isBackBtnHidden: false, settingScreen: .AudioSetting, shouldDismissOnBackButton: false, callback: {
                    //Change for Copy Item to be deselect and remove all
                    viewModel.stateChange = .Edit
                    viewModel.selectedItems.removeAll()
                    viewModel.changeValueSelected()
                    
                    if viewModel.validationTimer(){
                        viewModel.indexChanging()
                        viewModel.addOrUpdateItemData()
                        isPresented.wrappedValue.dismiss()
                    }else{
                        
                        ///
                        /// ITEM IS CREATED BUT,
                        /// TITLE IS EMPTY.
                        /// SO DELETE EMPTY NSMANAGEDOBJECT AND,
                        /// DISMISS VIEW.
                        ///
                        viewModel.deleteItem()
                        isPresented.wrappedValue.dismiss()
                    }
                    
                    ///
                    /// THIS CODE IS FOR FOLDER TYPE
                    /// FOLDER WILL CONTAINS MULTIPLE  CHILDRENS
                    ///  IF ``itemData.type`` IS ``FOLDER`` IN THAT CASE
                    ///  APPEND ``viewmodel.item`` OBJECT TO ``self.itemData.children``
                    ///
                    if let itemData = itemData{
                        if let type = itemData.type, type == "Folder", let item = viewModel.item{
                            viewModel.item?.isChild = true
                            var allObjects = (itemData.children?.allObjects as? [Item]) ?? []
                            allObjects.append(item)
                            itemData.children = NSSet(array: allObjects)
                            CoreDataManager.shared.saveContext()
                            
                        }
                    }
                    viewModel.selectedItems.removeAll()
                    viewModel.changeValueSelected()
                    
                }).padding(.horizontal, 16)
                ScrollViewReader{scrollViewProxy in
                    List{
                        Section{
                            VStack(spacing: 0){
                                ///Child components present in common components folder
                                TextFieldView(txtPlaceHolder: "Name", textFieldPlaceHolder: "Name", stringData: $viewModel.titleName)
                                    .textInputAutocapitalization(.words)
                                    .padding(.top, 32)
                                
                                SettingColorLabel(colorObject: viewModel.item?.colorObject, settingName: "Colour", colorOpacity: $viewModel.colorOpacity, colorHex: $viewModel.colureHexCode, saveItemData: {
                                    viewModel.colorNavigate = true
                                })
                                .padding(.top, 39)
                                
                                LabelDropDown(txtDropDown: viewModel.alertSong, settingName: "Alert", audioSettingData: viewModel.item?.setting, callBackSoundNavigate: {
                                    viewModel.soundUpdate = true
                                })
                                .padding(.top,42)
                                
                                
                                LabelSettingSwitch(settingName: "Vibrate on Alert", isSwitchOn: $viewModel.vibrateOnAlert)
                                    .padding(.top, 42)
                                
                                LabelSettingSwitch(settingName: "Shuffle", isSwitchOn: $viewModel.shuffle)
                                    .padding(.top, 42)
                                
                                MinMaxTxtField(minData: $viewModel.restBetweenInterval.minTime, maxData: $viewModel.restBetweenInterval.maxTime, firstSettingLblName: "Rest Between Intervals", secondSettingLblName: "Random", textFieldType: .RestBetweenInterval, isSwitchOn: $viewModel.restBetweenInterval.random)
                                    .padding(.top, 42)
                                
                                SettingAddingRounds(settingName: "Rounds", rounds: $viewModel.totalNoOfRounds)
                                    .padding(.top, 40)
                                
                                MinMaxTxtField(minData: $viewModel.restBetweenRounds.minTime, maxData: $viewModel.restBetweenRounds.maxTime, firstSettingLblName: "Rest Between Rounds", secondSettingLblName: "Random",textFieldType: .RestBetweenRounds, isSwitchOn: $viewModel.restBetweenRounds.random)
                                    .padding(.top, 24)
                                
                                ThickBorderGradient()
                                    .padding(.top, 40)
                                
                                ///Dotted color line above interval list
                                
                                /// list of interval with check of count greater than 0
                                if viewModel.intervalItems.count > 0{
                                    Line()
                                        .stroke(style: .init(dash: [2]))
                                        .foregroundColor(Color(uiColor: .thinDotted))
                                        .frame(height: 1)
                                        .padding(.bottom, 0)
                                        .padding(.top, 24)
                                }
                                
                            }
                            
                        }
                        .onTapGesture {
                            if keyboardResponder.keyboardHeight > 0 {
                                dismissKeyboard()
                                viewModel.onChangeSaveData()
                            }
                        }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .listRowInsets(.init(top: 0, leading: 16, bottom: 0, trailing: 16))
                        .id("Section1")
                        // IntervalCartCell List Section
                        
                        Section {
                            // Interval List
                            ForEach(viewModel.intervalItems, id: \.self) { object in
                                IntervalCartCell(
                                    intervalItemData: object,
                                    addTimeTxt: viewModel.displayTxtDict,
                                    isTimerLabelHidden: false,
                                    messageCount: .constant(viewModel.intervalItems.count),
                                    itemData: viewModel.item,
                                    checkBoxState: false,
                                    callBackCheckState: { intervalItem in
                                        viewModel.selectedItems.append(intervalItem)
                                        viewModel.isFooterEdit = true
                                    },
                                    callBackRemoveState: { intervalItem in
                                        viewModel.removeSelectedItem(intervalItem: intervalItem)
                                        if viewModel.selectedItems.isEmpty {
                                            viewModel.isFooterEdit = false
                                        }
                                    }
                                )
                                .offset(x: viewModel.slideListAnimation ? object.isSelected ? -400 : 0 : 0)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    viewModel.intervalItem = object
                                    isAddInterval = true
                                    viewModel.isEditInterval = true
                                }
                                .listRowSeparator(.hidden)
                                .listRowInsets(.init(top: 24, leading: 16, bottom: 0, trailing: 0))
                                .listRowBackground(Color.clear)
                                .id(object)
                            }
                            .onMove(perform: { indices, newOffset in
                                viewModel.indexUpdate(indices: indices, newOffset: newOffset)
                            }
                            )
                            .onDelete(perform: { indexSet in
                                viewModel.deleteSingleIntervalItem(indexSet: indexSet)
                            }
                            )
                            VStack(spacing: 0){
                                ///func for adding csv file
                                addCsvAttach()
                                    .padding(.top, 24)
                                
                                //Adding hidden line for scroll to down
                                Color.clear.frame(height: 1)
                                    .padding(.top, 10)
                            }
                            .onTapGesture {
                                if keyboardResponder.keyboardHeight > 0 {
                                    dismissKeyboard()
                                    viewModel.onChangeSaveData()
                                }
                            }
                            .id("NoteBox")
                            .padding(.horizontal, 16)
                            .listRowBackground(Color.clear)
                            VStack(spacing: 0){
                                ThickBorderGradient()
                                    .padding(.top, 50)
                                ///text field components of box structure
                                NoteBox(noteStringData: $viewModel.noteBoxText)
                                    .padding(.vertical, 24)
                                    .onTapGesture {
                                        viewModel.isNoteBoxFocuse = true
                                    }
                            }
                            .id("Section2_LastView")
                            .padding(.horizontal, 16)
                            .listRowBackground(Color.clear)
                        }
                        .listRowSeparator(.hidden)
                        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .background(.clear)
                        .onChange(of: viewModel.isScrollDown) { value in
                            // Scroll to the bottom when new item is added or list changes
                            if value{
                                    scrollViewProxy.scrollTo("NoteBox", anchor: .bottom)
                                viewModel.isScrollDown = false
                            }
                            //                            .padding(.trailing, -16)
                            
                        }
                    }
                    .listStyle(.plain)
                    .buttonStyle(PlainButtonStyle())
                    .listRowSpacing(0)
                    //               .frame(height: CGFloat(viewModel.intervalItems.count) * 89)
                    .padding(.bottom, keyboardResponder.keyboardHeight > 0 ? keyboardResponder.keyboardHeight : 0)
                    //                    .padding(.bottom, viewModel.isNoteBoxFocuse ? UIScreen.main.bounds.size.height * 0.40 : 0)
                }
                withAnimation{
                    EditFooterView(isCheckBoxChecked: viewModel.isFooterEdit,
                                   callBackDeleteData: {
                        if !viewModel.selectedItems.isEmpty{
                            dismissKeyboard()
                            viewModel.alertHeaderTitle = "DELETE THIS SELECTION"
                            viewModel.validationErrorMessage = "Are you sure you want to permanently\ndelete the selected item(s)?"
                            viewModel.isDeletePop = true
                            viewModel.blurEffectPresent = true
                        }
                    }, callBackCopyData: {
                        dismissKeyboard()
                        /// Copy Data Habdling footer call back
                        //                        if !viewModel.selectedItems.isEmpty{
                        EditOperations.copyEntity(selectedItems: viewModel.selectedItems, entityType: .timerInterval)
//                        viewModel.stateChange = .Edit
//                        viewModel.selectedItems.removeAll()
//                        viewModel.changeValueSelected()
                        
                        
                    }, callBackPasteData: {
                        
                        /// Paste Call Back Functionality
                        if EditOperations.editEntityType == .timerInterval{
                            dismissKeyboard()
                            EditOperations.pasteTimerDrillInterval(inObject: itemData == nil ? viewModel.item : itemData, lastItemIndex: (viewModel.intervalItems.last?.indexValue ?? -1) + 1)
                            runWithDelay(delay: 0.5) {
                                viewModel.intervalItems = (itemData == nil ? viewModel.item : itemData)?.intervalItem?.allObjects as? [IntervalItem] ?? []
                                viewModel.intervalItems.sort{$0.indexValue < $1.indexValue}
                                viewModel.isFooterEdit = false
                                viewModel.isScrollDown = true
                                viewModel.stateChange = .Edit
                                viewModel.selectedItems.removeAll()
                                viewModel.changeValueSelected()
                            }
                            
                        }
                    }, callBackCutData: {
                        /// Cut Call Back Functionality
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100), execute: {
                            withAnimation(.smooth){
                                dismissKeyboard()
                                viewModel.slideListAnimation = true
                            }
                        })
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000)){
                            withAnimation{
                                
                                EditOperations.cutEntity(selectedItems: viewModel.selectedItems, entityType: .timerInterval)
                                viewModel.intervalItems = cutChangeIndex(selectedIntervalItem: viewModel.selectedItems, totalIntervalItem: viewModel.intervalItems)
                                viewModel.selectedItems.removeAll()
                                viewModel.slideListAnimation = false
                                viewModel.changeValueSelected()
                            }
                        }
                    }, itemSelected: viewModel.selectedItems)
                    .offset(y: keyboardResponder.keyboardHeight > 0 ? -keyboardResponder.keyboardHeight : 0)
                }
            }
            .edgesIgnoringSafeArea(.bottom)
            .navigationBarHidden(true)
            .blur(radius: viewModel.blurEffectPresent ? 12 : 0)
            
            //
            //MARK: - ON APPEAR
            .onAppear(perform: {
                
                viewModel.updateAudioLabel()
                
                ///Item count
                viewModel.itemCount = itemCount
                //                if EditOperations.editEntityType == .timerInterval{
                //                    viewModel.isFooterEdit = true
                //                }
                
                //Displaying content of itemdata  throught view model properties
                if isEdited{
                    
                    viewModel.item = itemData
                    viewModel.titleName = itemData?.title ?? ""
                    viewModel.fetchAllDataOnAppear()
                    //                        viewModel.intervalItems = itemData?.intervalItem?.allObjects as? [IntervalItem] ?? []
                    //                        viewModel.intervalItems.sort{$0.indexValue < $1.indexValue}
                    //
                    viewModel.restBetweenInterval.minTime = (itemData?.restBetweenInterval?.min) ?? ""
                    viewModel.restBetweenInterval.random = itemData?.restBetweenInterval?.random ?? false
                    viewModel.restBetweenInterval.maxTime = itemData?.restBetweenInterval?.max ?? ""
                    viewModel.restBetweenRounds.minTime = itemData?.restBetweenRounds?.min ?? ""
                    viewModel.restBetweenRounds.maxTime = itemData?.restBetweenRounds?.max ?? ""
                    viewModel.restBetweenRounds.random = itemData?.restBetweenRounds?.random ?? false
                    viewModel.colureHexCode = itemData?.colorObject?.colorHexCode ?? ""
                    viewModel.colorOpacity = itemData?.colorObject?.alphaValue ?? 1.0
                    viewModel.vibrateOnAlert = itemData?.viibrateAlert ?? false
                    viewModel.shuffle = itemData?.shuffle ?? false
                    viewModel.totalNoOfRounds = itemData?.restBetweenRounds?.rounds ?? 0
                    viewModel.noteBoxText = itemData?.noteBox ?? ""
                    viewModel.updateAudioLabel()
                }else{
                    ///
                    /// IF itemData IS NIL SO THAT
                    /// CREATE A NEW ITEM NSMANAGEDOBJECT FOR CURRENT VIEW
                    ///
                    ///
                    if viewModel.item == nil{
                        viewModel.item = viewModel.createItem()
                    }
                    ///
                    /// UPDATE INTERVAL ITEMS IF USER
                    /// COME BACK FROM MESSAGE SCREEN
                    ///
                    
                    viewModel.intervalItems = (viewModel.item?.intervalItem?.allObjects as? [IntervalItem]) ?? []
                    viewModel.intervalItems.sort{$0.indexValue < $1.indexValue}
                }
            })
            //
            
            //MARK: - Navigation linK for add interval
            NavigationLink(isActive: $isAddInterval) {
                /// When user want to change value
                if isAddInterval{
                    if let intervalItem = viewModel.intervalItem{
                        IntervalView(isEdited: viewModel.isEditInterval, intervalItem: intervalItem, totalInterval: viewModel.item?.intervalItem?.count){
                            runWithDelay(delay: 0.3, {
                                if !viewModel.isEditInterval{
                                    viewModel.isScrollDown = true
                                }
                            })
                           
                        }
                    }else{
                        EmptyView().onAppear {
                            debugPrint("interval item is nil, while navigating")
                        }
                    }
                }
            } label: {
                EmptyView()
            }
            .hidden()
            
            NavigationLink(isActive: $viewModel.isNaviagteSubscription) {
                if viewModel.isNaviagteSubscription{
                    PurchaseView()
                }
            } label: {
                EmptyView()
            }
            .hidden()

            
            
            ///
            /// delete alert of selected item
            ///
            if viewModel.isDeletePop {
                AlertTextPopScreen(alertHeader: viewModel.alertHeaderTitle, alertDescription: viewModel.validationErrorMessage, alertCancelText: "NO, GO BACK", alertOkText: "YES, DELETE", okayCallBack: {
                    viewModel.isDeletePop = false
                    viewModel.blurEffectPresent = false
                    /// Delete functionality and animation Handling
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200), execute: {
                        withAnimation(.smooth){
                            viewModel.slideListAnimation = true
                        }
                    })
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000)){
                        withAnimation{
                            
                            viewModel.changeValueSelected()
                            viewModel.slideListAnimation = false
                            //Delete Call Back of intervalListItem
                            viewModel.deleteIntervalItems()
                            viewModel.selectedItems.removeAll()
                            viewModel.isFooterEdit = false
                        }
                    }
                },
                                   cancelCallBack: {
                    viewModel.isDeletePop = false
                    viewModel.blurEffectPresent = false
                }
                )
            }
            
            ///
            ///Csv File all Alert Handling 
            ///and presnting to file on new file chosse option
            ///
            if viewModel.csvFileAlert {
                if viewModel.alertHeaderTitle == "ERROR: MISSING FIELDS"{
                    ErrorAlertMissingField(cancelCallBack: {
                        viewModel.csvFileAlert = false
                        viewModel.blurEffectPresent = false
                    }, okayCallBack: {
                        viewModel.csvFileAlert = false
                        viewModel.blurEffectPresent = false
                        if !viewModel.isImportSucess{
                            viewModel.isActiveImportCSVView = true
                        }
                        else{
                            viewModel.isImportSucess = false
                        }
                    })
                }
                else if viewModel.alertHeaderTitle == "ERROR: INVALID FILE TYPE"{
                    AlertTextCsvAlert(okayCallBack: {
                        //Call file manager
                        viewModel.csvFileAlert = false
                        viewModel.blurEffectPresent = false
                        if !viewModel.isImportSucess{
                            viewModel.isActiveImportCSVView = true
                        }
                        else{
                            viewModel.isImportSucess = false
                        }
                        
                    },
                                      cancelCallBack: {
                        viewModel.csvFileAlert = false
                        viewModel.blurEffectPresent = false
                    }
                    )
                }
                else{
                    AlertTextPopScreen(alertHeader: viewModel.alertHeaderTitle, alertDescription: viewModel.validationErrorMessage,alertLastDescription: viewModel.lastEndDescription,alertCancelText: viewModel.cancelBtnText, alertOkText: viewModel.okayBtnText, textDescriptionDot: viewModel.textDesciptionBox,descriptionListHidden: viewModel.isDescriptionBox ,okayCallBack: {
                        //Call file manager
                        viewModel.csvFileAlert = false
                        viewModel.blurEffectPresent = false
                        if !viewModel.isImportSucess{
                            viewModel.isActiveImportCSVView = true
                        }
                        else{
                            viewModel.isImportSucess = false
                        }
                        
                    },
                                       cancelCallBack: {
                        viewModel.csvFileAlert = false
                        viewModel.blurEffectPresent = false
                    }
                    )
                }
            }
            
            ///
            ///Adding Csv File or replacing data to csv data  Alert and presnting existing data and replace data
            ///
            if viewModel.isReplaceExisting {
                AlertTextPopScreen(alertHeader: viewModel.alertHeaderTitle, alertDescription: viewModel.validationErrorMessage,alertLastDescription: viewModel.lastEndDescription,alertCancelText: viewModel.cancelBtnText, alertOkText: viewModel.okayBtnText, textDescriptionDot: viewModel.textDesciptionBox,descriptionListHidden: viewModel.isDescriptionBox ,okayCallBack: {
                    //For Deleting the data or replaced from csv
                    viewModel.isReplaceExisting = false
                    viewModel.blurEffectPresent = false
                    if viewModel.dataReplaced{
                        viewModel.removeExistingData(intervals: viewModel.csvIntervalItems, itemData: viewModel.itemModelData)
                        viewModel.dataReplaced = false
                    }
                    else{
                        viewModel.addToExistingData(intervals: viewModel.csvIntervalItems, itemData: viewModel.itemModelData)
                    }
                },
                                   cancelCallBack: {
                    viewModel.isReplaceExisting = false
                    viewModel.blurEffectPresent = false
                    //removing alert
                    if viewModel.dataReplaced{
                        viewModel.dataReplaced = false
                    }
                    else{
                        viewModel.handlingImportAlerts(index: 5)
                    }
                }
                )
            }
            
            
            ///
            /// IF USER SELECT ``IMPORT CSV`` BUTTON
            /// PRESENT CSV PICKER
            ///
        }.fileImporter(isPresented: $viewModel.isActiveImportCSVView, allowedContentTypes: [.commaSeparatedText], onCompletion: { result in
            switch result {
            case .success(let success):
                debugPrint("success file imported: \(success.absoluteString)")
                ///
                /// CHANGE ``viewmodel.csvUrl``
                viewModel.csvUrl = success
                
            case .failure(let failure):
                debugPrint("failed file imported: \(failure.localizedDescription)")
                viewModel.handlingImportAlerts(index: 2)
            }
        })
        ///
        /// WHEN USER SELECT ON CHANGE OF CSV URL
        /// ON CHANGE OF ``viewmodel.csvUrl``
        /// FETCH ITEMS INTERVALS ARRAY
        ///
        .onChange(of: viewModel.csvUrl, perform: { value in
            if let url = viewModel.csvUrl, url.pathExtension.lowercased() == "csv"{
                let importIntervalData = ImportCSV.shared.importFromCSV(url: url, fileType: .Timer)
                let intervals = importIntervalData?.1
                let itemData = importIntervalData?.itemData
                let errorInterval = importIntervalData?.intervalImportError
                
                //Alert pop for present intervalItem is emtpty not compatible in csv
                guard intervals?.count ?? 0 > 0 else{
                    debugPrint("Interval Count",intervals?.count)
                    viewModel.handlingImportAlerts(index: 2)
                    return
                }
                
                //Alert pop for not presenting any value in csv file
                guard errorInterval?.count ?? 0 == 0 else{
                    debugPrint("Interval Error", errorInterval?.count)
                    viewModel.handlingImportAlerts(index: 1)
                    return
                }
                
                //Validating Data is of Interval Timer
                guard let newData = viewModel.verifyTimerInterval(intervals: intervals ?? []), !newData.isEmpty else{
                    viewModel.handlingImportAlerts(index: 1)
                    return
                }
                
                viewModel.csvIntervalItems = intervals ?? []
                viewModel.itemModelData = itemData
                viewModel.handlingImportAlerts(index: 4)
                
                ///
                ///SET ``nil`` CSV URL AFTER IMPORTING INTERVALS
                ///
                viewModel.csvUrl = nil
                
            }else{
                debugPrint("CSV url is invalid while importing CSV")
            }
        })
        .onChange(of: isAddInterval, perform: { newValue in
            //if newValue{
            viewModel.addOrUpdateItemData()
            //}
        })
        .onChange(of: viewModel.colorNavigate, perform: {new in
            if new == true{
                
                viewModel.addOrUpdateItemData()
            }
            viewModel.colorNavigate = false
        })
        .onChange(of: viewModel.soundUpdate, perform: {new in
            if new == true{
                
                viewModel.addOrUpdateItemData()
            }
            viewModel.soundUpdate = false
        })
        
    }
    
    
}


#Preview {
    TimerCreationView()
}
//MARK: - Extension for sub- view components function
extension TimerCreationView{
    /**
     * Csv and add Interval sub view button
     *
     * - Parameters: no
     *
     * - Returns: view of addinterval and csv button
     *
     */
    @ViewBuilder
    func addCsvAttach()-> some View{
        HStack{
            Button(action: {
                viewModel.createInterval()
                isAddInterval = true
                viewModel.isEditInterval = false
                dismissKeyboard()
            }){
                HStack{
                    Image(.iconAddInterval)
                        .renderingMode(/*@START_MENU_TOKEN@*/.template/*@END_MENU_TOKEN@*/)
                        .foregroundStyle(.headerTitleColerSet)
                    TextLabelMeduimFont(stringData: "Add Interval")
                }
            }
            Spacer()
            Button(action: {
                ///If user ``user purchase the subscription then only import of interval will work`` handling theough userDefaults
                if AppDefaults.shared.isUserSubscribed{
                    viewModel.csvUrl = nil
                    viewModel.isActiveImportCSVView = true
                }
                else{
                    viewModel.isNaviagteSubscription = true
                }
            }){
                HStack{
                    TextLabelMeduimFont(stringData: "Import from CSV")
                    
                    Image(.iconImport)
                        .renderingMode(/*@START_MENU_TOKEN@*/.template/*@END_MENU_TOKEN@*/)
                        .foregroundStyle(.headerTitleColerSet)
                }
                
            }
        }
    }
}
