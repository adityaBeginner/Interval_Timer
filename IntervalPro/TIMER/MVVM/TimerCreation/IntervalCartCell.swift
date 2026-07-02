//
//  IntervalCartCell.swift
//  TIMER
//
//  Created by Aditya Maroo on 20/08/24.
//

import SwiftUI

struct IntervalCartCell: View {
    var intervalItemData: IntervalItem = IntervalItem()
    var addTimeTxt: [Int64: String] = [:]
    @State var isTimerLabelHidden: Bool = false
    @Binding var messageCount: Int
    @State var itemData: Item?
    @State var checkBoxState: Bool = false
    @State private var scaleEffect: CGFloat = 1
     //MARK: - Call Back
    var callBackCheckState: ((IntervalItem)-> Void)?
    var callBackRemoveState: ((IntervalItem)-> Void)?
    
  
    //    var intervalItem: IntervalItem?
    var body: some View {
        ZStack(){
            VStack(spacing: 24){
                HStack(spacing: 6){
                    Button(action: {
                    })
                    {
                        Image("MovableIcon")
                            .renderingMode(/*@START_MENU_TOKEN@*/.template/*@END_MENU_TOKEN@*/)
                            .foregroundStyle(.headerTitleColerSet)
                    }
                    Rectangle()
                        .fill(Color(hex: intervalItemData.colorObject?.colorHexCode ?? IntervalCartString.colorHexCode).opacity(intervalItemData.colorObject?.alphaValue ?? 1))
                        .frame(width: 8, height: 40)
                        .padding(.leading, 10)
                    
                    VStack(alignment: .leading, content: {
                        TextLabelMeduimFont(stringData: intervalItemData.intervalName ?? IntervalCartString.intervalName)
                            .lineLimit(1)
                        if !isTimerLabelHidden{
                            if AppDefaults.shared.hundredthMilliSeconds{
                                AttributedTimerTextMilliSeconds(timeString: displayIntervalText(intervalItemData: intervalItemData))
                            }
                            else{
                                TextLabelLightFont(stringData: displayIntervalText(intervalItemData: intervalItemData))
                            }
                        }
                    })
                    Spacer()
                    HStack{
                        TextLabelLightFont(stringData: "\(intervalItemData.indexValue + 1)" + "/" + "\(messageCount)")
                        
                        Button(action: {
                            hapticON()
                            if !intervalItemData.isSelected{
                                callBackCheckState?(intervalItemData)
                                scaleEffect = 0.4
                                intervalItemData.isSelected = true
                                withAnimation(.spring(response: 0.2, dampingFraction: 0.4)) {
                                    scaleEffect = 1.4
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    withAnimation(.spring()) {
                                        scaleEffect = 1.0
                                    }
                                }
                            }
                            //                        intervalItemData.isSelected.toggle()
                            else{
                                callBackRemoveState?(intervalItemData)
                                withAnimation(.spring(response: 0.2, dampingFraction: 0.4)) {
                                    scaleEffect = 0.4
                                    
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                                withAnimation(.linear){
                                    intervalItemData.isSelected = false
                                    scaleEffect = 1
                                }
                            }
                            }
                            
                        }, label: {
                            ZStack(alignment: .trailing){
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.background)
                                Image(intervalItemData.isSelected ? .stateCheckBtn : .buttonCheckBox)
                                    .resizable()
                                    .frame(width: 16, height: 16)
                                    .scaleEffect(scaleEffect)
                            }
                            .frame(width: 60, height: 50)
                            .contentShape(.rect)
                            //                            .padding(.all, 16)
                        })
                        .padding(.trailing, 16)
                        //                    .buttonStyle(PlainButtonStyle())
                       
                        
                    }
                }
                Line()
                    .stroke(style: .init(dash: [2]))
                    .foregroundColor(Color(uiColor: .thinDotted))
                    .frame(height: 1)
                    .padding(.trailing, 16)
            }
        }
    }
}

 //MARK: - Extensiom Intervalcart
extension IntervalCartCell{
    func displayIntervalText(intervalItemData: IntervalItem) -> String {
        // Extracting interval duration
        let intervalDuration = intervalItemData.intervalDuration
        
        // Check if random is true, display min and max
        if intervalDuration?.random ?? false {
            let minDuration = AppComman.shared.handlingMilliseconds(timeString: intervalDuration?.min)
            let maxDuration = AppComman.shared.handlingMilliseconds(timeString: intervalDuration?.max)
            return ("Timed: \(minDuration) - \(maxDuration) (\(AppComman.shared.handlingStartTimeCount(item: itemData , indexValue: intervalItemData.indexValue)))")
            // \(addTimeTxt[intervalItemData.indexValue] ?? "")
        } else {
            // If not random, display only min
            let minDuration = AppComman.shared.handlingMilliseconds(timeString: intervalDuration?.min)
            return ("Timed: \(minDuration) (\(AppComman.shared.handlingStartTimeCount(item: itemData , indexValue: intervalItemData.indexValue)))")
            // \(addTimeTxt[intervalItemData.indexValue] ?? "")
        }
    }
}

#Preview {
    IntervalCartCell(messageCount: .constant(1) )
}



