//
//  CartContainerView.swift
//  TIMER
//
//  Created by Aditya Maroo on 13/08/24.
//

import SwiftUI

struct CartContainerView: View {
     //MARK: - Properties and object
    ///navigation link controller isActive binding property
    @State var isTimerNavigate: Bool = false
    @State var isReactionCreationNavigate: Bool = false
    @State var isItemCartSelected: Bool = false
    @State var allItemGetUnSelected: Bool = false
     ///penicl icon btn binded with workout and inner folder screen
    @Binding var isEditable: WorkoutViewState
    /// data or object  of timer and drill
    @Binding var itemData: Item
    @Binding var unSelectAllItem: Bool
    
    @State private var scaleEffect: CGFloat = 1
  
 //MARK: - call Back data
    var folderCallBack: (()-> Void)?
    var callBackAddSelectedData: ((Item)-> Void)?
    var callBackRemoveSelectedData: ((Item)-> Void)?
    
     //MARK: - Main view for displaying Content(header,footer, body)
    var body: some View {
        ZStack(){
            VStack(spacing: 20, content: {
                HStack(spacing: 14, content: {
                    HStack(spacing: 14){
                        if isEditable == .Edit{
                            //When state change to edit then movable button appers
                            Button(action: {})
                            {
                                Image(.movableIcon)
                                    .renderingMode(.template)
                                    .foregroundStyle(.headerTitleColerSet)
                                    .transition(.slide)
                            }
                        }
                        //Circle contains image and of type (timer, drill and folder)
                        Circle()
                            .fill(Color(hex: (itemData.colorObject?.colorHexCode) ?? "#000000").opacity(itemData.colorObject?.alphaValue ?? 1))
                            .overlay(alignment: .center, content: {
                                switch itemData.type {
                                case "Timer":
                                    Image(.clockTimer)
                                        .renderingMode(.template)
                                        .resizable()
                                        .foregroundStyle(bestButtonColor(for: Color(hex: itemData.colorObject?.colorHexCode ?? "#FFFFFF").opacity(itemData.colorObject?.alphaValue ?? 1.0)) ? .white : .black)
//                                        .scaledToFit()
                                        .frame(width: 24, height: 28)
                                        .padding(.bottom, 2)
                                case "Drill":
                                    Image(.newRWord)
                                        .renderingMode(.template)
                                        .resizable()
                                        .foregroundStyle(bestButtonColor(for: Color(hex: itemData.colorObject?.colorHexCode ?? "#FFFFFF").opacity(itemData.colorObject?.alphaValue ?? 1.0)) ? .white : .black)
//                                        .scaledToFit()
                                        .frame(width: 24, height: 28)
                                        .padding(.bottom, 2)
//                                        .overlay(
//                                            Image(.drillWordR)
//                                        )
                                case "Folder":
                                    Image(.folder)
                                        .renderingMode(.template)
                                        .resizable()
                                        .foregroundStyle(bestButtonColor(for: Color(hex: itemData.colorObject?.colorHexCode ?? "#FFFFFF").opacity(itemData.colorObject?.alphaValue ?? 1.0)) ? .white : .black)
//                                        .scaledToFit()
                                        .frame(width: 24, height: 19)
                                        .padding(.bottom, 2)
                                case nil:
                                    EmptyView()
                                case .some(_):
                                    EmptyView()
                                   
                                }
                            })
                        
                            .frame(width: 48, height: 48)
                    }
                    //Name of file or folder and timer data or call data which represent in cart view
                    VStack(alignment: .leading, content: {
                        TextLabelMeduimFont(stringData: itemData.title ?? "")
                        TextLabelLightFont(stringData: displayStringData(itemData: itemData))
                    })
                    Spacer()
                    //check boc button view depenend on state
                    HStack{
                        if isEditable == .Edit{
                            Button(action: {
                                hapticON()
                               
                                if !isItemCartSelected{
                                    scaleEffect = 0.4
                                    isItemCartSelected = true
                                    itemData.isSelected = true
                                    callBackAddSelectedData?(itemData)
                                    withAnimation(.spring(response: 0.2, dampingFraction: 0.4)) {
                                        scaleEffect = 1.4
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                        withAnimation(.spring()) {
                                            scaleEffect = 1.0
                                        }
                                    }
                                }
                                else{
                                    callBackRemoveSelectedData?(itemData)
                                    withAnimation(.spring(response: 0.2, dampingFraction: 0.4)) {
                                        scaleEffect = 0.4
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                                        withAnimation(.linear){
                                            isItemCartSelected = false
                                            itemData.isSelected = false
                                            scaleEffect = 1
                                        }
                                    }
                                }
                            }, label: {
                                ZStack(alignment: .trailing){
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.background)
                                    Image(isItemCartSelected ? .stateCheckBtn : .buttonCheckBox)
                                        .resizable()
                                    //                                    .renderingMode(.template)
                                    //                                    .foregroundColor(.headerTitleColerSet)
                                        .frame(width: 16, height: 16)
                                        .scaleEffect(scaleEffect)
                                }
                                .frame(width: 60, height: 50)
                                .contentShape(.rect)
                            })
                        }
                        else{
                            //navigation action handling through pencil button
                            Button(action: {
                                switch (itemData.type ?? "") {
                                case "Timer":
                                    isTimerNavigate = true
                                case "Drill":
                                    isReactionCreationNavigate = true
                                case "Folder":
                                    folderCallBack?()
                                    break
                                default: break
                                    
                                }
                            
                            }, label: {
                                Image("IconEditPencil")
                                    .resizable()
                                    .renderingMode(.template)
                                    .foregroundColor(.headerTitleColerSet)
                                    .frame(width: 16, height: 16)
                            })
                        }
                    }
                    
                })
                .padding(.top, 20)
                Line()
                    .stroke(style: .init(dash: [2]))
                    .foregroundColor(Color(uiColor: .thinDotted))
                    .frame(height: 1)
              
            } ) 
            
            //Navigation Link View Components
            NavigationLink(isActive: $isTimerNavigate) {
                if isTimerNavigate{
                    TimerCreationView(isEdited: true,itemData: itemData)
                }
            } label: {
                EmptyView()
            }
            .hidden()
            NavigationLink(isActive: $isReactionCreationNavigate) {
                if isReactionCreationNavigate{
                    ReactionView(itemData: itemData,isEdited: true)
                }
            } label: {
                EmptyView()
            }
            .hidden()
        }.onChange(of: isEditable, perform: { value in
            if isEditable == .Normal{
                isItemCartSelected = false
            }
        })
        .onChange(of: unSelectAllItem, perform: { value in
            if value{
                isItemCartSelected = false
                unSelectAllItem = false
            }
        })
        
 }
}

#Preview {
    CartContainerView(isEditable: .constant(.Normal), itemData: .constant(Item()), unSelectAllItem: .constant(false))
}

 //MARK: - Dotted line func
struct Line:Shape{
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        return path
    }
}
///
///GET SESSION TIME
///
extension CartContainerView{
    
    ///
    /// CALCULATE TOTAL TIME OF THE SESSION
    ///
   private func getSessionTime(_ item: Item) -> String {
        let totalRounds = item.restBetweenRounds?.rounds ?? 1
        var totalSessionTime = 0.0

        // Rest between intervals (assumed to be in minutes and needs parsing too)
         let restBetweenIntervalStr = item.restBetweenInterval?.min ?? "00:00"
       let restBetweenInterval = parseTime(restBetweenIntervalStr) ?? 0
       
           // Get all interval items and calculate total interval time
       var totalIntervalDuration: Double = 0
       var totalRestBetweenInterval: Double = 0
           let allIntervals = item.intervalItem?.allObjects as? [IntervalItem] ?? []
       if item.type == "Timer"{
           
            totalIntervalDuration = getIntervalsTotalTime(allIntervals)
           
           // Calculate total rest between intervals (for all but the last one)
            totalRestBetweenInterval = restBetweenInterval * Double(allIntervals.count == 0 ? 0 : allIntervals.count - 1)
       }
       else{
           
           //Interval session duration(assumed to be in minutes and needs parsing too)
           let intervalDurationTimeStr = item.intervalDuration?.min ?? "00:00"
           let intervalDurationTime = parseTime(intervalDurationTimeStr) ?? 0
           
           let totalIntervalCall = getIntervalsTotalCalls(allIntervals)
           
           // Calculate total rest between intervals (for all but the last one)
           totalRestBetweenInterval = restBetweenInterval * Double(totalIntervalCall == 0 ? 0 : intervalDurationTime == 0 ? 0 : totalIntervalCall - 1)
           
           //Calculate total interval duration call time
            totalIntervalDuration = intervalDurationTime * Double(totalIntervalCall)
       }
            
            
            // Total session time includes intervals and rest between them, multiplied by the number of rounds
            var restBetweenRounds = 0.0
            if let _restBetweenRounds = item.restBetweenRounds?.min{
                restBetweenRounds = parseTime(_restBetweenRounds) ?? 0.0
                restBetweenRounds = restBetweenRounds * Double((totalRounds - 1))
            }
            totalSessionTime = (totalIntervalDuration + totalRestBetweenInterval) * Double(totalRounds) + restBetweenRounds

        
        
        // Return total session time in a human-readable format (minutes and seconds)
       return validateRandom(item: item) ? formatTime(totalSessionTime) + " - " + getRandomMaxData(item: item)  : formatTime(totalSessionTime)
    }
    
    ///
    ///New SessIon Time using session length
    ///
    func sessionLengthTime(_ item: Item) -> String {
        guard let sessionData = item.session, !sessionData.isEmpty else {
            return "00:00:00"
        }
        
        let totalRounds = Int(item.restBetweenRounds?.rounds ?? 1)
        let randomIsOn = item.restBetweenRounds?.random ?? false
        let roundMin = convertStringtoData(timeString: item.restBetweenRounds?.min ?? "00:00") * (totalRounds - 1)
        let roundMax = convertStringtoData(timeString: item.restBetweenRounds?.max ?? "00:00") * (totalRounds - 1)
        let sessionTime = convertHoursStringtoData(timeString: sessionData) * totalRounds
        
        let totalTimeMin = sessionTime + roundMin
        let totalTimeMax = sessionTime + roundMax
        
        let totalTimeString = updateEtTimeString(etRtTimeData: totalTimeMin)
        let totalTimeMaxString = updateEtTimeString(etRtTimeData: totalTimeMax)
        
        return randomIsOn ? "\(totalTimeString) - \(totalTimeMaxString)" : totalTimeString
    }
    
    
    ///
    ///Private func for ramdom Data max Data
    ///
    private func getRandomMaxData(item: Item)-> String{
        let totalRounds = item.restBetweenRounds?.rounds ?? 1
        var totalSessionTime = 0.0

        // Rest between intervals (assumed to be in minutes and needs parsing too)
        let restBetweenIntervalStr = item.restBetweenInterval?.random ?? false ? item.restBetweenInterval?.max ?? "00:00" : item.restBetweenInterval?.min ?? "00:00"
       let restBetweenInterval = parseTime(restBetweenIntervalStr) ?? 0
        
     
        
        
            // Get all interval items and calculate total interval time
        var totalIntervalDuration: Double = 0
        var totalRestBetweenInterval: Double = 0
            let allIntervals = item.intervalItem?.allObjects as? [IntervalItem] ?? []
        if item.type == "Timer"{
            
             totalIntervalDuration = getMaxIntervalTotalTime(allIntervals)
            
            // Calculate total rest between intervals (for all but the last one)
             totalRestBetweenInterval = restBetweenInterval * Double(allIntervals.count == 0 ? 0 : allIntervals.count - 1)
        }
        else{
            
            //Interval session duration(assumed to be in minutes and needs parsing too)
            let intervalDurationTimeStr = item.intervalDuration?.random ?? false ? item.intervalDuration?.max ?? "00:00" : item.intervalDuration?.min ?? "00:00"
                let intervalDurationTime = parseTime(intervalDurationTimeStr) ?? 0
            
            let totalIntervalCall = getIntervalsTotalCalls(allIntervals)
            
            // Calculate total rest between intervals (for all but the last one)
             totalRestBetweenInterval = restBetweenInterval * Double(totalIntervalCall - 1)
            
            //Calculate total interval duration call time
             totalIntervalDuration = intervalDurationTime * Double(totalIntervalCall)
        }
            
            // Total session time includes intervals and rest between them, multiplied by the number of rounds
            var restBetweenRounds = 0.0
        if let _restBetweenRounds = item.restBetweenRounds?.random ?? false ? item.restBetweenRounds?.max : item.restBetweenRounds?.min{
                restBetweenRounds = parseTime(_restBetweenRounds) ?? 0.0
                restBetweenRounds = restBetweenRounds * Double((totalRounds - 1))
            }
            totalSessionTime = (totalIntervalDuration + totalRestBetweenInterval) * Double(totalRounds) + restBetweenRounds

        
        
        // Return total session time in a human-readable format (minutes and seconds)
        return formatTime(totalSessionTime)
    }
    
 
    
    ///
    /// GET  TOTAL Number OF CALLS
    ///
    private func getIntervalsTotalCalls(_ intervals: [IntervalItem]) -> Double {
        // Parse each interval's duration from "MM:SS" format and sum them up
        return intervals.compactMap { Double($0.intervalCall?.maxNumber ?? 0) }.reduce(0, +)
    }
    
    ///
    ///Getting Validation for intervalItems
    ///
    private func getValidateIntervalItems(item: Item)-> Bool{
        var intervalItemvalidate: Bool = false
        guard let intervalItemsSet = item.intervalItem,
              let intervalItems = intervalItemsSet.allObjects as? [IntervalItem] else {
            return false
        }

        intervalItems.forEach{ intervalItem in
            if intervalItem.intervalDuration?.random ?? false{
                intervalItemvalidate = true
                return
            }
        }
        return intervalItemvalidate
    }
    
    
    ///
    ///Validation For Random
    ///
    private func validateRandom(item: Item)-> Bool{
        if item.restBetweenInterval?.random ?? false{
            return true
        }
        else if item.intervalDuration?.random ?? false{
            return true
        }
        else if itemData.restBetweenRounds?.random ?? false{
            return true
        }
        else if getValidateIntervalItems(item: item){
            return true
        }
        else{
            return false
        }
    }
    

    ///
    /// GET INTERVALS TOTAL TIME
    ///
    private func getIntervalsTotalTime(_ intervals: [IntervalItem]) -> Double {
        
        // Parse each interval's duration from "MM:SS" format and sum them up
        return intervals.compactMap { parseTime($0.intervalDuration?.min ?? "") }.reduce(0, +)
    }
    
    ///
    ///Get Interval Item TotalTime max
    ///
    private func getMaxIntervalTotalTime(_ intervals: [IntervalItem])-> Double{
        
        // Parse each interval's duration from "MM:SS" format and sum them up
        return intervals.compactMap { $0.intervalDuration?.random ?? false ? parseTime($0.intervalDuration?.max ?? "00:01") : parseTime($0.intervalDuration?.min ?? "00:01" ) }.reduce(0, +)
    }
    

    ///
    /// PARSE "MM:SS" STRING TO TOTAL SECONDS
    ///
    private func parseTime(_ timeString: String) -> Double? {
        let components = timeString.split(separator: ":").map { String($0)}
        
        if AppDefaults.shared.hundredthMilliSeconds && components.count == 3{
            if let minutes = Double(components[0]),
              let seconds = Double(components[1]), let milliSeconds = Double(components[2]){
               return (minutes * 60) + seconds + (milliSeconds / 100)
           }
        }
        
        // Ensure there are 2 components (minutes and seconds)
        else if components.count >= 2, let minutes = Double(components[0]),
           let seconds = Double(components[1]) {
            return (minutes * 60) + seconds
        }
        
        //debugPrint(components.count)
        // Return nil if parsing fails
        return 0
    }

    ///
    /// FORMAT TIME FROM SECONDS TO "MM:SS"
    ///
    private func formatTime(_ totalSeconds: Double) -> String {
        let hours = Int(totalSeconds) / 3600
        let minutes = (Int(totalSeconds) % 3600) / 60
        let seconds = Int(totalSeconds) % 60
//        print(String(format: "%02d:%02d:%02d", hours, minutes, seconds))
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    ///
    /// Total no of calls in reaction timer
    ///
    private func totalNoOfCalls(itemData: Item)-> Int{
        let intervalItems = itemData.intervalItem?.allObjects as? [IntervalItem]
        let totalICallCount = intervalItems?.count ?? 0 //intervalItems?.compactMap{Int($0.intervalCall?.maxNumber ?? 1)}.reduce(0, +) ?? 0
        return totalICallCount
    }
    
    ///
    /// Total no of calls in reaction timer
    ///
    private func totalNoOfItems(itemData: Item)-> Int{
        let childrenData = itemData.children?.allObjects as? [Item]
        let filterChildrenData = childrenData?.filter{$0.title != nil || $0.title != ""}
        return filterChildrenData?.count ?? 0
    }
    
    ///
    ///DISPLAY WHICH CALL OR ITEM OR
    ///
    private func displayStringData(itemData: Item)-> String{
        if itemData.type == "Timer"{
            return "Timed: " + (getSessionTime(itemData))
        }
        else if itemData.type == "Drill"{
            return "Calls: \(totalNoOfCalls(itemData: itemData))  |  \(sessionLengthTime(itemData))"
        }
        return "Items: \(totalNoOfItems(itemData: itemData))"
    }

}
