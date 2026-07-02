//
//  IntervalCallView.swift
//  TIMER
//
//  Created by Aditya Maroo on 28/08/24.
//

import SwiftUI

struct IntervalCallView: View {
    
    //MARK: - state and state objc variable
    //MARK: -Item Data
    var itemData: Item?
    @State private var orientation = UIDeviceOrientation.unknown
    @StateObject var viewModel = IntervalCallsVM()
    var intervalCallName: String = ""
    var intervalCallLength: String = ""
    //    var fontColor: Color =
    //MARK: - My body
    var body: some View {
        ZStack{
            Color(hex: viewModel.intervalHexColorCode)
                .opacity(viewModel.intervalColorOpacity)
                .ignoresSafeArea()
            
//            RadialGradient(stops: [Gradient.Stop(color: Color(hex: "FF9C1A"), location: 0.23) , Gradient.Stop(color: Color(hex: "ED683C"), location: 1.0)], center: .topTrailing, startRadius: 50, endRadius: 450)
           
            
            if orientation.isLandscape && viewModel.viewState != .ViewGuide{
                if viewModel.noTaskPerform{
                    Image(.lAndScapeSessionScreen)
                        .resizable()
////                        .scaledToFit()
//                        .frame(height: screenDeviceWidth)
                        .ignoresSafeArea()
//                        .padding(.top, 20)
                       
                }
                landScapeSetUp()
                    .onAppear{
                        AppDelegate.orientationLock = .landscape
                        viewModel.isLandScapeScroll = true
                    }
                    .navigationBarHidden(true)
                    .blur(radius: viewModel.resetAlertPop ? 12 : 0)
            }else{
                if viewModel.noTaskPerform{

                    Image(.sessionBackGround)
                        .resizable()
//                        .scaledToFit()
//                        .frame(width: screenDeviceWidth)
                        .ignoresSafeArea()
                }
                setUp()
                    .onAppear{
                        AppDelegate.orientationLock = .portrait
                        viewModel.isLandScapeScroll = false
                    }
                    .padding(.horizontal, 16)
                    .navigationBarHidden(true)
                    .blur(radius: viewModel.resetAlertPop ? 12 : 0)
            }
            if viewModel.viewState == .ViewGuide{
                ZStack{
                    Color(uiColor:.timerWorkoutColor)
                        .opacity(0.2)
                        .ignoresSafeArea()
                    PopContainerView(popHidding: $viewModel.viewState, popHandlingScreens: .IntervalPotrait,descriptionString: $viewModel.popDescription, offSetNumberY: 70, alignmentPostion: .topLeading, triangleOffsetX: -120.0,triangleOffestY: TrianglePosition.topSideTriangle.rawValue)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.bottom )
            }
            if viewModel.resetAlertPop{
                AlertTextPopScreen(alertHeader: viewModel.alertHeaderText, alertDescription: viewModel.alertDescriptionBox, alertCancelText: viewModel.alertGoBackBtn ,alertOkText: viewModel.alertResetBtn, okayCallBack: {
                    viewModel.reloadDataSession()
                    viewModel.resetAlertPop = false
                } ,cancelCallBack: {
                        viewModel.resetAlertPop = false
                    if !viewModel.noTaskPerform && viewModel.notAgainStart{
                        viewModel.isTimeStartPause = true
                        viewModel.runningtime()
                        viewModel.startTimer()
                }
                }
                )
            }
        }
        
        .onAppear{
            if AppDefaults.shared.isIntroCompletedOnTimerCreationCallView{
                viewModel.viewState = .Normal
            }
            viewModel.itemData = itemData
            viewModel.textToSpecchAvail = itemData?.setting?.isTextToSpeech ?? false
            viewModel.intervalListItemData = itemData?.intervalItem?.allObjects as? [IntervalItem] ?? []
            if viewModel.intervalListItemData.isEmpty{
                viewModel.sessionOver()
                viewModel.intervalCount = 0
            }
            
            else if !viewModel.intervalListItemData.isEmpty{
                viewModel.totalNoIntervalInSession = viewModel.intervalListItemData.count * Int(itemData?.restBetweenRounds?.rounds ?? 1)
                viewModel.intervalListItemData.sort{$0.indexValue < $1.indexValue}
                viewModel.convertListData()
                viewModel.addingAllSessionTime()
                viewModel.audioValidation(itemData: itemData)
                viewModel.startAudioSession()
                viewModel.updateIntervaData(intervalDataProperties: viewModel.listIntervalCall.first ?? IntervalCallProperties(), firstAppear: true)
                DispatchQueue.main.async {
                    AppComman.shared.startBackgroundTask()
                }
            }
            UIApplication.shared.isIdleTimerDisabled = AppDefaults.shared.disableAutoScreenOff
            
            //
        }
        .onRotateDevice(){newDeviceOrientation in
            if newDeviceOrientation == .landscapeLeft || newDeviceOrientation == .portrait || newDeviceOrientation == .landscapeRight{
//                if viewModel.viewState == .ViewGuide{
//                    orientation = .portrait
//                }
//                else{
                    orientation = newDeviceOrientation
//                }
//                print(newDeviceOrientation.isLandscape)
            }
        }
        .onDisappear{
            viewModel.etTimerPause()
            viewModel.pauseTimer()
            AppDelegate.orientationLock = .portrait
        }
        
    }
}
#Preview {
    IntervalCallView()
}
extension IntervalCallView{
    /**
     * load the the view of header and content and footer
     *
     * - Parameters:
     *
     * - Returns: return setup view.
     *
     */
    @ViewBuilder
    func setUp()-> some View{
        ///spacing of vstack can be adjuusted
        VStack(spacing: 0){
            VStack(spacing: screenDeviceHeight * 0.06){
                VStack(spacing: screenDeviceWidth * 0.02){
                    headerContent()
                    Spacer()
                    currentIntervalContent()
                    Spacer()
                    callerNameContent()
                }
                VStack(spacing: 0){
                    Spacer()
                    HStack{viewModel.bestContrastColor()}
                        .frame(height: 1)
                        .padding(.horizontal,-16)
                    VStack(spacing: 0){
                        listOfIntervalContent()
                        //                if !viewModel.isMorePlusBtnVisible{
                        moreButtonComponents()
                    }
                        .padding(.bottom, 20)
                    //                }
                }
            }
            footerContent()
                .padding(.bottom, 24)
            
            
        }
        .edgesIgnoringSafeArea(.bottom)
        
        //        .navigationBarHidden(true)
    }
    /**
     *headerContent
     *
     * - Parameters:no Paramerter
     *
     * - Returns: return header view.
     *
     */
    
    @ViewBuilder
    func headerContent()-> some View{
        IntervalCallHeader( isIntervalCallerHeader: true, completedRounds: String(viewModel.completedRounds), intervalheaderTop: (itemData?.title) ?? "Interval", TotalRounds: String(itemData?.restBetweenRounds?.rounds ?? 1), intervalCompleted: String(viewModel.intervalCount), totalInterval: String(itemData?.intervalItem?.count ?? 0), etTime: viewModel.etTimerString, rtTime: viewModel.rtTimerString, fontColor: viewModel.bestContrastColor())
        //            .onChange(of: viewModel.sessionAudioCount, perform: {newValue in
        //                if newValue != viewModel.completedRounds{
        //                    AudioPlayer.shared.playAudioFileName(fileName: viewModel.audioName, vibrationName: viewModel.vibrationData)
        //                    viewModel.sessionAudioCount = viewModel.completedRounds
        //                }
        //            })
    }
    
    ///
    ///Footer View for both landscapse and Potrait
    ///
    @ViewBuilder
    func footerContent()-> some View{
        IntervalCallFooter(foreGroundColor: viewModel.bestContrastColor() ,isPlayButtonTap: $viewModel.isTimeStartPause, startAction:{
            if !viewModel.notAgainStart{
                viewModel.runningtime()
                if viewModel.isAudioPresent{
                    AudioPlayer.shared.playAudioFileName(fileName: "One Single Beep (Short)", vibrationName: viewModel.vibrationData)
                }
                if viewModel.textToSpeechWithTime{
                    runWithDelay(delay: 0.8){
                        let intervalTimeString = viewModel.listIntervalCall.first?.intervalDuration.map { String($0) } ?? "00:00"
                        viewModel.textToSpeech(intervalName: "\(viewModel.listIntervalCall.first?.intervalName ?? "No Interval") , \(AppComman.shared.readableTime(from: intervalTimeString))")
                    }
                }
                else{
                    runWithDelay(delay: 0.8){
                        viewModel.textToSpeech(intervalName: viewModel.listIntervalCall.first?.intervalName ?? "No Interval")
                    }
                }
                viewModel.notAgainStart = true
            }
            viewModel.startTimer()
            viewModel.userInteractionLock = AppDefaults.shared.enableScreenLock
        }, stopaction: {
            viewModel.pauseTimer()
        }, reloadSession: {
            viewModel.pauseTimer()
            viewModel.etTimerPause()
            viewModel.resetAlertPop = true
        }, nextInterval:{
            AudioPlayer.shared.stopAudioVibration()
            viewModel.isNextTap = true
            viewModel.justNextIntervalDate = Date.now
            viewModel.nextIntervalData()
        },
                           interactionCallBack: {
                viewModel.userInteractionLock = true
            },
                           dismissCallBack: {
            viewModel.cancellable?.cancel()
            viewModel.etTimerSource?.cancel()
            AudioPlayer.shared.stopAudioVibration()
            UIApplication.shared.isIdleTimerDisabled = false
            viewModel.stopAudioSession()
            DispatchQueue.main.async {
                AppComman.shared.endBackgroundTask()
            }
        },
                           interactionLocked: $viewModel.userInteractionLock)
        
    }
    
    
    // Method for Showing Current Interval
    ///Displaying current interval time
    ///interval name
    @ViewBuilder
    func currentIntervalContent()-> some View{
        ///spacing will be adjusted from here to while doing split screen
        
        if AppDefaults.shared.hundredthMilliSeconds{
            IntervalMilliSecondsAttributeTxt(timeString: viewModel.intervalTime, fontColor: viewModel.bestContrastColor(), fontSize: orientation.isLandscape ? screenDeviceWidth * 0.36 : screenDeviceWidth * 0.31)
                .scaledToFill()
            
                .frame(maxWidth: .infinity )
        }
        else{
            TextLabelRegularFont(stringData: viewModel.intervalTime, fontColor: viewModel.bestContrastColor(), customFontSize: orientation.isLandscape ? screenDeviceWidth * 0.3721 : screenDeviceWidth * 0.3721, isCustomFont: true)
                .monospacedDigit()
                .scaledToFill()
                .frame(maxWidth: .infinity )
        }
        
//        IntervalMilliSecondsAttributeTxt(timeString: viewModel.intervalTime, fontColor: .white, fontSize: orientation.isLandscape ? screenDeviceWidth * 0.36 : screenDeviceWidth * 0.31)
    
        //
        //                .font(.custom(TFonts.TREGULAR.rawValue, size: orientation.isLandscape ? UIScreen.main.bounds.height * 0.3721 : UIScreen.main.bounds.size.width * 0.3721))
           
        
        
    }
    
    ///
    ///Scrollable Text for messgae Content
    ///
    @ViewBuilder
    func callerNameContent(isLandScape: Bool = false)-> some View{
        VStack(spacing: 0){
            ScrollTextView(stringData: viewModel.intervalNameStringData, fontColor: viewModel.bestContrastColor(), isLandScape: isLandScape)
                .frame(alignment: .bottom)

            if viewModel.noTaskPerform{
                TextLabelRegularFont(stringData: "(Session Over)", fontColor: viewModel.bestContrastColor(), customFontSize: screenDeviceWidth * 0.055, isCustomFont: true)
            }
            
        }
      
    }
    
    /**
     * list of interval are loaded
     *
     * - Parameters: no
     *
     * - Returns: return list of content.
     *
     */
    @ViewBuilder
    func listOfIntervalContent()-> some View {
        ScrollViewReader{ proxy in
            ScrollView(showsIndicators: true){
                LazyVStack(spacing: 0){
                    ForEach(viewModel.listIntervalCall, id: \.self){intervalItem in
                        // viewModel.listIntervalCall.last?.indexValueNo != viewModel.indexCountOfList &&
                        if viewModel.indexCountOfList < viewModel.listIntervalCall.count {
                            if viewModel.listIntervalCall.last?.indexValueNo != viewModel.indexCountOfList && viewModel.listIntervalCall[viewModel.indexCountOfList + 1] == intervalItem {
                                if orientation.isLandscape && viewModel.viewState != .ViewGuide{
                                    LandscapeListCart(intervalListItemData: intervalItem ,contentHeight: 134, fontBestContrastColor: viewModel.bestContrastColor(), fontWeight: .medium, fontSize: 20,fontSizeMilliseconds: 16, totalListCount: viewModel.totalNoIntervalInSession)
                                        .padding(.trailing, 12)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            viewModel.tapGuesture(intervalListItem: intervalItem)
                                        }
                                        .disabled(viewModel.userInteractionLock)
                                }
                                else{
                                    IntervalListCart(intervalItemData: intervalItem, contentHeight: 126, fontBestContrastColor: viewModel.bestContrastColor(), fontWeight: .medium, fontSize: 20,fontSizeMilliseconds: 16, tapGuestureCallBack: {
                                        viewModel.tapGuesture(intervalListItem: intervalItem)
                                    })
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        viewModel.tapGuesture(intervalListItem: intervalItem)
                                    }
                                    .disabled(viewModel.userInteractionLock)
                                }
                            }
                            else if viewModel.listIntervalCall.first?.indexValueNo != viewModel.indexCountOfList || viewModel.listIntervalCall.first?.indexValueNo != intervalItem.indexValueNo //if viewModel.listIntervalCall[0] != intervalItem
                            {
                                if orientation.isLandscape && viewModel.viewState != .ViewGuide{
                                    LandscapeListCart(intervalListItemData: intervalItem, fontBestContrastColor: viewModel.bestContrastColor(), totalListCount: viewModel.totalNoIntervalInSession)
                                        .padding(.trailing, 12)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            viewModel.tapGuesture(intervalListItem: intervalItem)
                                        }
                                        .disabled(viewModel.userInteractionLock)
                                }
                                else{
                                    IntervalListCart(intervalLastItemData: viewModel.listIntervalCall.last ,intervalItemData: intervalItem, fontBestContrastColor: viewModel.bestContrastColor(), tapGuestureCallBack: {
                                        viewModel.tapGuesture(intervalListItem: intervalItem)
                                    })
                                    .onAppear{
                                        
                                        //                                            viewModel.isMorePlusBtnVisible = false
//                                        if intervalItem == viewModel.listIntervalCall.last{
//                                            viewModel.isMorePlusBtnVisible = true
//                                        }
//                                        else if intervalItem != viewModel.listIntervalCall.last{
//                                            viewModel.isMorePlusBtnVisible = false
//                                        }
                                        
                                    }
                                    .onDisappear{
                                        //                                            if intervalItem != viewModel.listIntervalCall.last{
                                        //                                                viewModel.isMorePlusBtnVisible = false
                                        //                                            }
                                    }
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        viewModel.tapGuesture(intervalListItem: intervalItem)
                                    }
                                    .disabled(viewModel.userInteractionLock)
                                    
                                }
                            }
                            
                            
                        }
                        else if viewModel.emptyListPresent{
                            if orientation.isLandscape{
                                LandscapeListCart(intervalListItemData: intervalItem, fontBestContrastColor: viewModel.bestContrastColor(), totalListCount: viewModel.totalNoIntervalInSession)
                                    .padding(.trailing, 12)
//                                    .contentShape(Rectangle())
//                                    .onTapGesture {
//                                        viewModel.tapGuesture(intervalListItem: intervalItem)
//                                    }
                                    .disabled(viewModel.userInteractionLock)
                            }
                            else{
                                IntervalListCart(intervalLastItemData: viewModel.listIntervalCall.last ,intervalItemData: intervalItem, fontBestContrastColor: viewModel.bestContrastColor())
                                   
//                                .contentShape(Rectangle())
//                                .onTapGesture {
//                                    viewModel.tapGuesture(intervalListItem: intervalItem)
//                                }
                                .disabled(viewModel.userInteractionLock)
                                
                            }
                        }
                    }
                    .onChange(of: viewModel.scrollToBottom, perform: {value in
                        if value, let lastItem = viewModel.listIntervalCall.last {
                            withAnimation{
                                proxy.scrollTo(lastItem, anchor: .top)
                                viewModel.scrollToBottom = false
                            }
                            //                            viewModel.isMorePlusBtnVisible = false
                        }
                        
                        
                    })
                    .onChange(of: viewModel.indexCountOfList , perform: { value in
                        if viewModel.listIntervalCall.count - 2 >= viewModel.indexCountOfList{
                            withAnimation{
                                proxy.scrollTo(viewModel.listIntervalCall[viewModel.indexCountOfList + 1], anchor: .top)
                                viewModel.increaseHeight = 0.05
                            }
                        }
                        //Changes for scroll padding
                         if viewModel.listIntervalCall.count - 4 <= viewModel.indexCountOfList{
                             debugPrint(viewModel.indexCountOfList)
                             if viewModel.listIntervalCall.count - 1 == viewModel.indexCountOfList{
                                 withAnimation{
                                     viewModel.increaseHeight = 0.22
                                     proxy.scrollTo("CompletionBottomLast", anchor: .bottom)
                                 }
                             }
                             else{
                                 viewModel.increaseHeight = 0.22
                             }
                        }
                        else{
                            viewModel.increaseHeight = 0.0
                        }
                    })
                    .onChange(of: viewModel.isLandScapeScroll, perform: {value in
                        debugPrint(value)
                        if value{
                            if viewModel.listIntervalCall.count - 2 >= viewModel.indexCountOfList{
                                withAnimation{
                                    proxy.scrollTo(viewModel.listIntervalCall[viewModel.indexCountOfList + 1], anchor: .top)
                                }
                            }
//                            viewModel.isLandScapeScroll = false
                        }
                        else{
                            if viewModel.listIntervalCall.count - 2 >= viewModel.indexCountOfList{
                                withAnimation{
                                    proxy.scrollTo(viewModel.listIntervalCall[viewModel.indexCountOfList + 1], anchor: .top)
                                }
                            }
//                            viewModel.isLandScapeScroll = true
                        }
                    })
                    .onChange(of: viewModel.resetScrollPosition, perform: {value in
                        if value {
                            if viewModel.listIntervalCall.count - 2 >= viewModel.indexCountOfList{
                                withAnimation{
                                    proxy.scrollTo(viewModel.listIntervalCall[viewModel.indexCountOfList + 1], anchor: .top)
                                }
                            }
                            viewModel.resetScrollPosition = false
                        }
                        
                    })
                    .onChange(of: viewModel.emptyListPresent){value in
                        if value{
                            withAnimation{
                                proxy.scrollTo("CompletionBottom", anchor: .bottom)
                            }
                        }
                    }
                    LazyVStack{
                        Color.clear
                            .frame(height: screenDeviceHeight * viewModel.increaseHeight)
                            .onAppear{
                                viewModel.isMorePlusBtnVisible = true
                            }
                            .onDisappear{
                                viewModel.isMorePlusBtnVisible = false
                            }
                    }
                    if viewModel.listIntervalCall.count - 1 == viewModel.indexCountOfList{
                        LazyVStack{
                            Color.clear
                                .frame(height: screenDeviceHeight * 0.15)
                        }
                        .id("CompletionBottomLast")
                    }
                    
                    if viewModel.emptyListPresent{
                        LazyVStack{
                            Color.clear
                                .frame(height: screenDeviceHeight * 0.15)
                        }
                        .id("CompletionBottom")
                    }
                    }
                .background(
                    GeometryReader { geometry in
                                    Color.clear
                                        .preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .global).minY)
                                })
//                .onPreferenceChange(ScrollOffsetPreferenceKey.self, perform: { value in
//                    var previousVlaue: CGFloat = 0
//                    
////                    runWithDelay(delay: 5){
////                        if value == previousVlaue && viewModel.listIntervalCall.count - 2 >= viewModel.indexCountOfList{
////                            proxy.scrollTo(viewModel.listIntervalCall[viewModel.indexCountOfList + 1], anchor: .top)
////                        }
////                    }
//                    if value - (screenDeviceHeight * 0.6) <= CGFloat(-((viewModel.listIntervalCall.count - 6) * 57)){
//                        viewModel.isMorePlusBtnVisible = true
//                    }
//                    else{
//                        viewModel.isMorePlusBtnVisible = false
//                    }
//                    previousVlaue = value
//                    
//                })
               
                }
               .onPreferenceChange(ScrollOffsetPreferenceKey.self) { offset in
                    viewModel.handleScrollInteraction(offset: offset)
                }
            .padding(.horizontal, (orientation.isLandscape && viewModel.viewState != .ViewGuide) ? 0 : -16)
        }
//        .coordinateSpace(name: "scrollView")
    }
    
    
    ///
    /// More button sub view
    ///
    @ViewBuilder
    func moreButtonComponents()-> some View{
        if !viewModel.isMorePlusBtnVisible{
            Button(action: {
                if !viewModel.scrollToBottom{
                    viewModel.scrollToBottom = true
                }
//                else{
//                    viewModel.scrollToBottom = false
//                }
            })
            {
                TextLabelRegularFont(stringData: "+ more", fontColor: viewModel.bestContrastColor(),fontSize: .TSIZE_12)
             
            }
            .padding(.leading, -12)
        }
        
    }
    
    /**
     * landscapse Content contains orientation mode of list , header and footer
     *
     * - Parameters: no Content
     *
     * - Returns: landscape content.
     *
     */
    @ViewBuilder
    func landScapeSetUp()-> some View{
        HStack(alignment: .top, spacing: 0){
            listOfIntervalContent()
                .frame(width: screenDeviceHeight * 0.35)
            VStack{
                Color.white.opacity(0.2)
            }
            .frame(width: 8)
            .offset(x: -8)
            .edgesIgnoringSafeArea(.bottom)
            VStack(spacing: 0){
                headerContent()
//                    .padding(.horizontal, 24)
                Spacer()
                currentIntervalContent()
                    .padding(.top, 12)
                callerNameContent(isLandScape: true)
                .offset(y: -screenDeviceWidth * 0.04)
//                    .padding(.horizontal, 24)
                Spacer()
                footerContent()
         
            }
            .padding(.top, 24)
            .padding(.horizontal, 24)
            .padding(.trailing, 16)
            
//            .edgesIgnoringSafeArea(.bottom)
//            .edgesIgnoringSafeArea(.horizontal)
        }
        .edgesIgnoringSafeArea(.horizontal)
    }
    
}

extension IntervalCallView{
//    struct ScrollOffsetPreferenceKey: PreferenceKey {
//        static var defaultValue: CGFloat = 0
//        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
//            value += nextValue()
//        }
//    }
    
    struct ScrollOffsetPreferenceKey: PreferenceKey {
        static var defaultValue: CGFloat = 0

        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value += nextValue()
        }
    }
}



//            TextLabelRegularFont(stringData: viewModel.intervalNameStringData, fontColor: viewModel.bestContrastColor(), customFontSize: orientation.isLandscape ? screenDeviceWidth * 0.093 : screenDeviceWidth * 0.093, isCustomFont: true)
////                .minimumScaleFactor(0.8)
//                .multilineTextAlignment(.center)
//                .lineLimit(2)
