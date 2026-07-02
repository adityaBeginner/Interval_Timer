import SwiftUI

struct ReactionTimeCallView: View {
    
    //MARK: - State variables and objects
    @StateObject var viewModel = ReactionTimeCallVM()
    @State private var orientation = UIDeviceOrientation.unknown
    
    //MARK: - Item data property
    var itemData: Item?
    
    var body: some View {
        ZStack {
            // Background color based on reaction interval color and opacity
            Color(hex: viewModel.reactionIntervalColor)
                .opacity(viewModel.reactionColorOpacty)
                .ignoresSafeArea()
            
            // Adjust layout for landscape or portrait mode
            if orientation.isLandscape && viewModel.viewState != .ViewGuide {
                if viewModel.noTaskPerform{
                    Image(.lAndScapeSessionScreen)
                        .resizable()
////                        .scaledToFit()
//                        .frame(height: screenDeviceWidth)
                        .ignoresSafeArea()
//                        .padding(.top, 20)
                       
                }
                landscapeSetup()
                    .onAppear{
                        AppDelegate.orientationLock = .landscape
                    }
                    .navigationBarHidden(true)
                    .blur(radius: viewModel.resetAlertPop ? 12 : 0)
            } else {
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
                    }
                    .padding(.horizontal, 16)
                    .navigationBarHidden(true)
                    .blur(radius: viewModel.resetAlertPop ? 12 : 0)
            }
            
            // Display guide view if in ViewGuide state
            if viewModel.viewState == .ViewGuide {
                ZStack {
                    Color(uiColor: .timerWorkoutColor)
                        .opacity(0.2)
                        .ignoresSafeArea()
                    
                    PopContainerView(
                        popHidding: $viewModel.viewState,
                        popHandlingScreens: .ReactionTimePotrait,
                        descriptionString: $viewModel.popDescription,
                        offSetNumberY: 55,
                        alignmentPostion: .topLeading,
                        triangleOffsetX: -120.0,
                        triangleOffestY: TrianglePosition.topSideTriangle.rawValue
                    )
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.bottom)
            }
            if viewModel.resetAlertPop{
                AlertTextPopScreen(alertHeader: viewModel.alertHeaderText, alertDescription: viewModel.alertDescriptionBox, alertCancelText: viewModel.alertGoBackBtn ,alertOkText: viewModel.alertResetBtn, okayCallBack: {
                    viewModel.reloadTimerSession()
                    viewModel.resetAlertPop = false
                } ,cancelCallBack: {
                    viewModel.resetAlertPop = false
                    if !viewModel.noTaskPerform && viewModel.etTimerNotStart{
                        viewModel.isPlayPause = true
                        viewModel.runningtime()
                        viewModel.startTimer()
                    }
                }
                )
            }
        }
        
        .onRotateDevice { newDeviceOrientation in
            if newDeviceOrientation == .landscapeLeft || newDeviceOrientation == .portrait || newDeviceOrientation == .landscapeRight {
                orientation = newDeviceOrientation
            }
        }
        .onAppear {
            
            ///Handling pop second more time
            if AppDefaults.shared.isIntroCompletedOnIntervalReationCallView{
                viewModel.viewState = .Normal
            }
            viewModel.itemData = itemData
            viewModel.intervalItems = itemData?.intervalItem?.allObjects as? [IntervalItem] ?? []
            viewModel.reactionName = itemData?.title ?? "Reaction"
            if !viewModel.intervalItems.isEmpty && validationRandomData(breakTime: itemData?.intervalDuration ?? IntervalDuration()){
                DispatchQueue.main.async{
                    AppComman.shared.startBackgroundTask()
                }
                viewModel.intervalItems.sort { $0.indexValue < $1.indexValue }
                viewModel.intervalBreakStore()
                viewModel.audioValidation(itemData: itemData)
                viewModel.startAudioSession()
                viewModel.updateIntervalData(intervalItem: viewModel.intervalbreakList.first ?? viewModel.defaultIntervalList, firstTimeRun: true)
               
                    ///Rt Time handling
                    //                    viewModel.handlingRTtimer()
                    viewModel.addingAllReactionData()
                    /// ``shuffle`` is using for ``hidecall out``
                    viewModel.hideIntervalTime = itemData?.shuffle ?? false
                if !(itemData?.session?.trimmingCharacters(in: .whitespaces) != "" && itemData?.session != "00:00:00" && viewModel.totalRemaingDurationTime != "00:00:00"){
                    viewModel.sessionHandling()
                }
               
            }
            else{
                viewModel.sessionHandling()
            }
            UIApplication.shared.isIdleTimerDisabled = AppDefaults.shared.disableAutoScreenOff
        }
        .onDisappear{
            AppDelegate.orientationLock = .portrait
        }
        
    }
}

extension ReactionTimeCallView {
    
    @ViewBuilder
    func setUp() -> some View {
        VStack() {
            IntervalCallHeader(completedRounds: viewModel.reactionName, etTime: viewModel.etTimerString, rtTime: viewModel.totalRemaingDurationTime, fontColor: viewModel.bestContrastColor())
//                .padding(.top, 24)
            
            Spacer()
            
            bodyContentData()
                .padding(.bottom, viewModel.hideIntervalTime ? 30 : 0)
            
            Spacer()
            if !viewModel.hideIntervalTime{
                bodyEndContentData()
                    .padding(.bottom, 30)
            }
            footerContentData()
                .padding(.bottom, 18)
        }
        .edgesIgnoringSafeArea(.bottom)
    }
    
    @ViewBuilder
    func bodyContentData() -> some View {
        VStack(spacing: 10){
            if viewModel.reactionIntervalName != "Mission accomplished!"{
                TextLabelRegularFont(stringData: viewModel.reactionIntervalName, fontColor: viewModel.bestContrastColor(), customFontSize: 64, isCustomFont: true)
                    .multilineTextAlignment(.center)
            }
            
            if viewModel.reactionIntervalName == "Mission accomplished!"{
                TextLabelRegularFont(stringData: viewModel.reactionIntervalName, fontColor: viewModel.bestContrastColor(), customFontSize: 64, isCustomFont: true)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            
            if viewModel.noTaskPerform{
                TextLabelRegularFont(stringData: "(Session Over)", fontColor: viewModel.bestContrastColor(), customFontSize: 24, isCustomFont: true)
            }
        }
    }
    
    @ViewBuilder
    func bodyEndContentData() -> some View {
        if AppDefaults.shared.hundredthMilliSeconds{
            MilliSecondsAttributeTxt(timeString: viewModel.reactionIntervalTime, fontColor: viewModel.bestContrastColor(), fontWeight: .regular)
                .monospacedDigit()
        }
        else{
            TextLabelRegularFont(stringData: viewModel.reactionIntervalTime, fontColor: viewModel.bestContrastColor())
                .monospacedDigit()
                .multilineTextAlignment(.center)
        }
    }
    
    //Footer View
    @ViewBuilder
    func footerContentData()-> some View{
        IntervalCallFooter(
            isIntervalfooterImageChange: true, foreGroundColor: viewModel.bestContrastColor(), isPlayButtonTap: $viewModel.isPlayPause,
            startAction: {
                if !viewModel.noTaskPerform{
                    viewModel.startTimer()
                    if !viewModel.etTimerNotStart{
                        viewModel.runningtime()
                        viewModel.etTimerNotStart = true
                        if viewModel.isAudioPresent{
                            AudioPlayer.shared.playAudioFileName(fileName: "One Single Beep (Short)" , vibrationName: viewModel.vibrationData)
                        }
                            runWithDelay(delay: 0.8){
                                if viewModel.textToSpeechWithTime{
                                        let intervalTimeString = viewModel.intervalbreakList.first?.intervalTime ?? "00:00"
                                        viewModel.textToSpeech(intervalName: " \(viewModel.intervalbreakList.first?.intervalName ?? "No Interval") , \(AppComman.shared.readableTime(from: intervalTimeString))")
                                }
                                else{
                                    viewModel.textToSpeech(intervalName: viewModel.intervalbreakList.first?.intervalName ?? "No Interval")
                                }
                            }
                            
                        
                    }
                    viewModel.isInteractionLock = AppDefaults.shared.enableScreenLock
                }
            },
            stopaction: {
                viewModel.pauseTimer()
            }, reloadSession: {
                viewModel.pauseTimer()
                viewModel.etTimerPause()
                viewModel.resetAlertPop = true
            },
            nextInterval: {
                viewModel.isNextTap = true
                viewModel.justNextIntervalDate = Date.now
                viewModel.nextSessionShift()
            },dismissCallBack: {
                AudioPlayer.shared.stopAudioVibration()
                viewModel.cancellable?.cancel()
                viewModel.etTimer?.cancel()
                UIApplication.shared.isIdleTimerDisabled = false
                viewModel.stopAudioSession()
                AudioPlayer.shared.stopAudioVibration()
                DispatchQueue.main.async{
                    AppComman.shared.endBackgroundTask()
                }
            }, interactionLocked: $viewModel.isInteractionLock
            
        )
    }
    
    ///
    ///LandScape oreiention setup
    ///
    @ViewBuilder
    func landscapeSetup()->some View{
        VStack(){
            IntervalCallHeader(completedRounds: viewModel.reactionName, etTime: viewModel.etTimerString, rtTime: viewModel.totalRemaingDurationTime, fontColor: viewModel.bestContrastColor())
                .padding(.top, 24)
            
            Spacer()
            
            bodyContentData()
                .padding(.bottom, viewModel.hideIntervalTime ? 30 : -(screenDeviceHeight * 0.03))
            
            Spacer()
            if !viewModel.hideIntervalTime{
                bodyEndContentData()
                    .padding(.bottom, 30)
            }
            footerContentData()
                .padding(.bottom, 18)
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

// Preview
#Preview {
    ReactionTimeCallView()
}
