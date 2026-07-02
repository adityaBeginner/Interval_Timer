//
//  ReactionView.swift
//  TIMER
//
//  Created by Aditya Maroo on 21/08/24.
//

import SwiftUI

struct ReactionView: View {
    
    //MARK: -State object for keyboard observation
    @StateObject var keyboardResponder = KeyboardResponder()
    @StateObject var  viewModel = ReactionCreationVM()
    
    //MARK: - State properties
    @State var isReactionInterval: Bool = false
    @State var isEditReactionInterval: Bool = false
    @State var isColorNaviagtion: Bool = false
    @State var isUpdateNavigation: Bool = false
    @State var isActiveCSVImportError: Bool = false
    
    //Environment properties
    @Environment(\.presentationMode) var isPresented
    
    
    var itemData: Item?
    var isEdited: Bool = false
    var itemCount: Int?
    
    
    var body: some View {
        ZStack{
            Color.background
                .ignoresSafeArea()
            settingUp()
                .blur(radius: viewModel.blurEffectPresent ? 12 : 0)
            
            ///
            /// WHEN USER SELECT ON CHANGE OF CSV URL
            /// ON CHANGE OF ``viewmodel.csvUrl``
            /// FETCH ITEMS INTERVALS ARRAY
            ///
                .onChange(of: viewModel.csvUrl, perform: { value in
                    if let url = viewModel.csvUrl, url.pathExtension.lowercased() == "csv"{
                        let csvResponse = ImportCSV.shared.importFromCSV(url: url, fileType: .Drill)
                        let intervals = csvResponse?.1
                        let errorInterval = csvResponse?.intervalReactionError
                        let itemData = csvResponse?.itemData
                        
                        //Alert pop for present intervalItem is emtpty not compatible in csv
                        guard intervals?.count ?? 0 > 0 else{
                            viewModel.handlingImportAlerts(index: 2)
                            return
                        }
                        
                        //Alert pop for not presenting any value in csv file
                        guard errorInterval?.count ?? 0 == 0 else{
                            viewModel.handlingImportAlerts(index: 1)
                            return
                        }
                        
                        //validation interval max Call should't be zero
                        guard let newData = viewModel.verfityReactionInterval(intervals: intervals ?? []), !newData.isEmpty else{
                            viewModel.handlingImportAlerts(index: 1)
                            return
                        }
                        
                        
                        ///
                        ///SET ``nil`` CSV URL AFTER IMPORTING INTERVALS
                        ///
                        viewModel.csvUrl = nil
                        
                        viewModel.csvIntervalItems = intervals ?? []
                        viewModel.itemModelData = itemData
                        viewModel.handlingImportAlerts(index: 4)
                        
                    }else{
                        debugPrint("CSV url is invalid while importing CSV")
                    }
                })
            
                .onChange(of: isReactionInterval, perform: { newValue in
                    if newValue{
                        viewModel.addOrUpdateItemData()
                    }
                    
                })
                .onChange(of: viewModel.colorNavigate, perform: {newValue in
                    if newValue{
                        viewModel.addOrUpdateItemData()
                        
                    }
                    viewModel.colorNavigate = false
                })
                .onChange(of: viewModel.soundUpdate, perform: {newValue in
                    if newValue{
                        viewModel.addOrUpdateItemData()
                    }
                    viewModel.soundUpdate = false
                })
                .onAppear(perform: {
                    CoreDataManager.shared.getIntervalCallData()
                    if EditOperations.editEntityType == .drilInterval{
                        viewModel.isFooterEdit = true
                    }
                    viewModel.itemCount = itemCount
                    
                    //Displaying Sound Data
                    viewModel.updateAudioLabel()
                    
                    if isEdited{
                        viewModel.item = itemData
                        viewModel.titleName = itemData?.title ?? ""
                        guard let itemData else{debugPrint("itemData is in while setting data on view appearance"); return}
//                        DispatchQueue.main.async{
                            viewModel.intervalItems = itemData.intervalItem?.allObjects as! [IntervalItem]
                            viewModel.intervalItems.sort{$0.indexValue < $1.indexValue}
                        viewModel.indexChanging()
//                        }
                        viewModel.restBetweenInterval.minTime = (itemData.restBetweenInterval?.min) ?? ""
                        viewModel.restBetweenInterval.random = itemData.restBetweenInterval?.random ?? false
                        viewModel.restBetweenInterval.maxTime = itemData.restBetweenInterval!.max ?? ""
                        viewModel.restBetweenRounds.minTime = itemData.restBetweenRounds?.min ?? ""
                        viewModel.restBetweenRounds.maxTime = itemData.restBetweenRounds?.max ?? ""
                        viewModel.restBetweenRounds.random = itemData.restBetweenRounds?.random ?? false
                        viewModel.session = itemData.session ?? ""
                        viewModel.colureHexCode = itemData.colorObject?.colorHexCode ?? ""
                        viewModel.vibrateOnAlert = itemData.viibrateAlert
                        viewModel.hideCallDuration = itemData.shuffle
                        viewModel.totalNoOfRounds = itemData.restBetweenRounds?.rounds ?? 0
                        viewModel.intervalDuration.maxTime = itemData.intervalDuration?.max ?? ""
                        viewModel.intervalDuration.minTime = itemData.intervalDuration?.min ?? ""
                        viewModel.intervalDuration.random = itemData.intervalDuration?.random ?? false
                        viewModel.colorOpacity = itemData.colorObject?.alphaValue ?? 1.0
                        viewModel.noteBoxText = itemData.noteBox ?? ""
                        viewModel.updateAudioLabel()
//                        if let setting = itemData.setting, !setting.isNoAudio {
//                            viewModel.alertSong = setting.audio ?? ""
//                        } else {
//                            viewModel.alertSong = "No Audio"
//                        }
                    }else{
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
            ///
            /// delete alert of selected item
            ///
            if viewModel.isDeletePop{
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
                            viewModel.deleteSelectedIntervalItems()
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
            
            //
            NavigationLink(isActive: $isReactionInterval) {
                if isReactionInterval{
                    ReactionIntervalView(intervalItemData: viewModel.intervalItem, isEditedState: isEditReactionInterval, totalInterval: viewModel.item?.intervalItem?.count ?? 1){
                        runWithDelay(delay: 0.3, {
                            if !isEditReactionInterval{
                                viewModel.isScrollDown = true
                            }
                        })
                    }
                }
            } label: {
                EmptyView()
            }
            .hidden()
            .navigationBarHidden(true)
            
            NavigationLink(isActive: $viewModel.isNaviagteSubscription) {
                if viewModel.isNaviagteSubscription{
                    PurchaseView()
                }
            } label: {
                EmptyView()
            }
            .hidden()
            
            
            ///
            /// IF USER SELECT ``IMPORT CSV`` BUTTON
            /// PRESENT CSV PICKEr
            ///Csv File all Alert Handling and presnting to file on new file chosse option
            ///
            if viewModel.csvFileAlert {
                if viewModel.alertHeaderTitle == "ERROR: MISSING FIELDS"{
                    ErrorAlertMissingField(
                        cancelCallBack: {
                            viewModel.csvFileAlert = false
                            viewModel.blurEffectPresent = false
                    },okayCallBack: {
                        //Call file manager
                        viewModel.csvFileAlert = false
                        viewModel.blurEffectPresent = false
                        if !viewModel.isImportSucess{
                            viewModel.isActiveImportCSVView = true
                        }
                        viewModel.isImportSucess = false
                    })
                }
                else if viewModel.alertHeaderTitle == "ERROR: INVALID FILE TYPE"{
                    AlertTextCsvAlert(
                                       okayCallBack: {
                        //Call file manager
                        viewModel.csvFileAlert = false
                        viewModel.blurEffectPresent = false
                        if !viewModel.isImportSucess{
                            viewModel.isActiveImportCSVView = true
                        }
                        viewModel.isImportSucess = false
                        
                    },
                                       cancelCallBack: {
                        viewModel.csvFileAlert = false
                        viewModel.blurEffectPresent = false
                    }
                    )
                }
                else{
                    AlertTextPopScreen(alertHeader: viewModel.alertHeaderTitle, alertDescription: viewModel.validationErrorMessage,alertLastDescription: viewModel.lastEndDescription,alertCancelText: viewModel.cancelBtnText, alertOkText: viewModel.okayBtnText, textDescriptionDot: viewModel.textDesciptionBox,descriptionListHidden: viewModel.isDescriptionBox ,
                                       okayCallBack: {
                        //Call file manager
                        viewModel.csvFileAlert = false
                        viewModel.blurEffectPresent = false
                        if !viewModel.isImportSucess{
                            viewModel.isActiveImportCSVView = true
                        }
                        viewModel.isImportSucess = false
                        
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
                    viewModel.isReplaceExisting = false
                    viewModel.blurEffectPresent = false
                    //For Deleting the data or replaced from csv
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
                    else if !viewModel.dataReplaced{
                        viewModel.handlingImportAlerts(index: 5)
                    }
                    
                }
                )
            }
            
        }
        .fileImporter(isPresented: $viewModel.isActiveImportCSVView, allowedContentTypes: [.commaSeparatedText], onCompletion: { result in
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
    }
}

#Preview {
    ReactionView()
}
extension ReactionView{
    
    @ViewBuilder
    func settingUp()-> some View{
        VStack(spacing: 0){
            ComHeaderView(titleHeader: .constant("Reaction Creation"), audioSettingData: viewModel.item?.setting, isBackBtnHidden: false, settingScreen: .AudioSetting, shouldDismissOnBackButton: false){
                viewModel.changeValueSelected()
                viewModel.selectedItems.removeAll()
                if viewModel.validationTimer(){
                    viewModel.indexChanging()
                    viewModel.addOrUpdateItemData()
                    isPresented.wrappedValue.dismiss()
                }else{
                    //                    viewModel.shouldShowValidationError = true
                    viewModel.deleteItem()
                    isPresented.wrappedValue.dismiss()
                }
                
                ///
                /// THIS CODE IS FOR FOLDER TYPE
                /// FOLDER WILL CONTAINS MULTIPLE  CHILDRENS
                ///  IF ``itemData.type`` IS ``FOLDER`` IN THAT CASE
                ///  APPEND ``item`` OBJECT TO ``self.itemData.children``
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
                viewModel.changeValueSelected()
                viewModel.selectedItems.removeAll()
            }
            .padding(.horizontal, 16)
            middelContent()
            EditFooterView(isCheckBoxChecked: viewModel.isFooterEdit, callBackDeleteData: {
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
                //                if !viewModel.selectedItems.isEmpty{
                EditOperations.copyEntity(selectedItems: viewModel.selectedItems, entityType: .drilInterval)
//                viewModel.changeValueSelected()
//                viewModel.selectedItems.removeAll()
                //                }
                
            }, callBackPasteData: {
                /// Paste Call Back Functionality
                if EditOperations.editEntityType == .drilInterval {
                    dismissKeyboard()
                    EditOperations.pasteTimerDrillInterval(inObject: itemData == nil ? viewModel.item : itemData, lastItemIndex: (viewModel.intervalItems.last?.indexValue ?? -1) + 1)
                    runWithDelay(delay: 0.5) {
                        viewModel.intervalItems = (itemData == nil ? viewModel.item : itemData)?.intervalItem?.allObjects as? [IntervalItem] ?? []
                        viewModel.intervalItems.sort{$0.indexValue < $1.indexValue}
                        viewModel.isFooterEdit = false
                        viewModel.isScrollDown = true
                        viewModel.selectedItems.removeAll()
                        viewModel.changeValueSelected()
                    }
                    
                    
                }
            }, callBackCutData: {
                dismissKeyboard()
                /// Cut Call Back Functionality
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100), execute: {
                    withAnimation(.smooth){
                        viewModel.slideListAnimation = true
                    }
                })
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000)){
                    withAnimation{
                        EditOperations.cutEntity(selectedItems: viewModel.selectedItems, entityType: .drilInterval)
                        viewModel.intervalItems = cutChangeIndex(selectedIntervalItem: viewModel.selectedItems, totalIntervalItem: viewModel.intervalItems)
                        viewModel.changeValueSelected()
                        viewModel.selectedItems.removeAll()
                        viewModel.slideListAnimation = false
                        
                    }
                }
            }, itemSelected: viewModel.selectedItems)
            .offset(y: keyboardResponder.keyboardHeight > 0 ? -keyboardResponder.keyboardHeight : 0)
        }
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarBackButtonHidden()
    }
    @ViewBuilder
    func middelContent()-> some View{
        ScrollViewReader{scrollViewProxy in
            List{
                //                VStack(spacing: 24){
                Section{
                    VStack(spacing: 34){
                        TextFieldView(txtPlaceHolder: "Name", textFieldPlaceHolder: "Name" ,stringData: $viewModel.titleName)
                            .textInputAutocapitalization(.words)
                        
                        SessionTextField(txtPlaceHolder: "Session/Round Length", textFieldPlaceHolder: "HH:MM:SS",stringData: $viewModel.session)
                            .keyboardType(.numberPad)
                        //                            .onChange(of: viewModel.session, perform: viewModel.reformatAsTimeMax(_:))
                        MinMaxTxtField(minData: $viewModel.intervalDuration.minTime, maxData: $viewModel.intervalDuration.maxTime, firstSettingLblName: "Interval Duration", secondSettingLblName: "Random", textFieldType: .IntervalDuration, isSwitchOn: $viewModel.intervalDuration.random)
                        MinMaxTxtField(minData: $viewModel.restBetweenInterval.minTime, maxData: $viewModel.restBetweenInterval.maxTime, firstSettingLblName: "Rest Between Intervals", secondSettingLblName: "Random", textFieldType: .RestBetweenInterval, isSwitchOn: $viewModel.restBetweenInterval.random)
                    }
                    .padding(.top, 32)
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .listRowInsets(.init(top: 0, leading: 16, bottom: 0, trailing: 16))
                .onTapGesture {
                    dismissKeyboard()
                    viewModel.onChangeSaveData()
                }
                
                Section{
                    ThickBorderGradient()
                        .padding(.vertical, 24)
                    VStack(spacing: 24){
                        SettingAddingRounds(settingName: "Rounds", rounds: $viewModel.totalNoOfRounds)
                        MinMaxTxtField(minData: $viewModel.restBetweenRounds.minTime, maxData: $viewModel.restBetweenRounds.maxTime, firstSettingLblName: "Rest Between Rounds", secondSettingLblName: "Random", textFieldType: .RestBetweenRounds,isSwitchOn: $viewModel.restBetweenRounds.random)
                        
                        //                        .listRowInsets(.init(top: 0, leading: 16, bottom: 0, trailing: 16))
                        
                        ThickBorderGradient()
                        LabelSettingSwitch(settingName: "Hide Call Duration", isSwitchOn: $viewModel.hideCallDuration)
                        ThickBorderGradient()
                    }
                    .padding(.bottom, 24)
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .listRowInsets(.init(top: 0, leading: 16, bottom: 0, trailing: 16))
                .onTapGesture {
                    dismissKeyboard()
                    viewModel.onChangeSaveData()
                }
                Section{
                    VStack(spacing: 34){
                        SettingColorLabel(colorObject: viewModel.item?.colorObject, settingName: "Colour", colorOpacity: $viewModel.colorOpacity, colorHex: $viewModel.colureHexCode){
                            viewModel.colorNavigate = true
                        }
                        LabelDropDown(txtDropDown: viewModel.alertSong, settingName:"Alerts", audioSettingData: viewModel.item?.setting, callBackSoundNavigate: {
                            viewModel.soundUpdate = true
                        })
                        LabelSettingSwitch(settingName: "Vibrate on Alert", isSwitchOn: $viewModel.vibrateOnAlert)
                    }
                    VStack(spacing: 24){
                        ThickBorderGradient()
                        if viewModel.intervalItems.count > 0 {
                            Line()
                                .stroke(style: .init(dash: [2]))
                                .foregroundColor(Color(uiColor: .thinDotted))
                                .frame(height: 1)
                        }
                    }
                        .padding(.top, 24)
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .listRowInsets(.init(top: 0, leading: 16, bottom: 0, trailing: 16))
                .onTapGesture {
                    dismissKeyboard()
                    viewModel.onChangeSaveData()
                }
                
                Section{
                        listContent()
                    VStack(spacing: 0){
                        addCsvFile()
                            .padding(.top, 24)
                        Color.clear
                            .frame(height: 1)
                            .padding(.top, -12)
                    }
                    .padding(.bottom, 60)
                    .id("NoteBoxId")
                    
                    VStack(spacing: 24){
                        ThickBorderGradient()
                        NoteBox(noteStringData: $viewModel.noteBoxText)
                    }
                    .id("ThickBorderGradient")
                    .padding(.bottom, 24)
                }
                .onChange(of: viewModel.isScrollDown, perform: {newValue in
                    if newValue{
                        // Scroll to the last item's ID
                        
                        withAnimation(.smooth){
                            DispatchQueue.main.async {
                                scrollViewProxy.scrollTo("NoteBoxId", anchor: .bottom)
                            }
                        }
                    }
                    viewModel.isScrollDown = false
                    
                })
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .listRowInsets(.init(top: 0, leading: 16, bottom: 0, trailing: 16))
               
               
                
                //                    .onTapGesture {
                //                        viewModel.isNoteScroll = true
                //                    }
                //                }
                //                .listRowSeparator(.hidden)
                //                .listRowBackground(Color.clear)
                //                .listRowInsets(.init(top: 0, leading: 16, bottom: 0, trailing: 16))
                ////                .padding(.horizontal, 16)
                //                .padding(.bottom, 24)
                
            }
            .listStyle(.plain)
            .buttonStyle(PlainButtonStyle())
            .listRowSpacing(0)
            .padding(.bottom, keyboardResponder.keyboardHeight > 0 ? keyboardResponder.keyboardHeight : 0)
        }
    }
    
    @ViewBuilder
    func listContent()-> some View{
        ForEach(viewModel.intervalItems){interItem in
            IntervalCartCell( intervalItemData: interItem, isTimerLabelHidden: true, messageCount: .constant(viewModel.intervalItems.count), callBackCheckState: {intervalItem in
                viewModel.selectedItems.append(intervalItem)
                viewModel.isFooterEdit = true
            },
                              callBackRemoveState: { intervalItem in
                viewModel.removeSelectedItem(intervalItem: intervalItem)
                if viewModel.selectedItems.isEmpty{
                    viewModel.isFooterEdit = false
                }
                
            }
            )
            .offset(x: viewModel.slideListAnimation ? interItem.isSelected ? -400 : 0 : 0 )
            .contentShape(Rectangle())
            .onTapGesture {
                viewModel.intervalItem = interItem
                isReactionInterval = true
                isEditReactionInterval = true
                
            }
            .listRowSeparator(.hidden)
            .listRowInsets(.init(top: 24, leading: 16, bottom: 0, trailing: 0))
            .listRowBackground(Color.clear)
            .id(interItem.id)
            
        }
        .onMove(perform: { indices, newOffset in
            viewModel.indexUpdate(indices: indices, newOffset: newOffset, items: itemData)
        })
        .onDelete(perform: {indexset in
            viewModel.deleteSingleIntervalItem(indexSet: indexset)
        })
        
    }
    
    //        viewModel.intervalItems.count < 10 ? CGFloat(viewModel.intervalItems.count) * 88 : 880
    
    
    
    @ViewBuilder
    func addCsvFile()-> some View{
        HStack{
            Button(action: {
                viewModel.createInterval()
                isReactionInterval = true
                isEditReactionInterval = false
                dismissKeyboard()
            }){
                HStack{
                    Image(.iconAddInterval)
                        .renderingMode(.template)
                        .foregroundStyle(.headerTitleColerSet)
                    TextLabelMeduimFont(stringData: "Add Interval")
                }
            }
            Spacer()
            Button(action: {
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
                        .renderingMode(.template)
                        .foregroundStyle(.headerTitleColerSet)
                }
                
            }
            
        }
        
    }
}
