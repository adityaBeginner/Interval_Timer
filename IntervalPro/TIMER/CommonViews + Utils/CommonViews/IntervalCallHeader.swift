//
//  IntervalCallHeader.swift
//  TIMER
//
//  Created by Aditya Maroo on 28/08/24.
//

import SwiftUI

struct IntervalCallHeader: View {
    var isIntervalCallerHeader: Bool = false
    var completedRounds: String = "888"
    var intervalheaderTop = "Interval"
    var TotalRounds: String = "888"
    var intervalCompleted: String = "888"
    var totalInterval: String = "888"
    var etTime: String = "88:88:88"
    var rtTime: String = "00:00:00"
    var fontColor: Color = .white
    var body: some View {
       setUp()
//            .background(Color.red)
    }
}

#Preview {
    IntervalCallHeader()
}

extension IntervalCallHeader{
    
    @ViewBuilder
    func setUp()-> some View{
        VStack(spacing: 0){
            if isIntervalCallerHeader{
//                HStack{
//                    TextLabelRegularFont(stringData: intervalheaderTop, fontColor: fontColor)
//            
//                }
            }
            HStack(alignment: .bottom, spacing: 0){
                ZStack{
                    VStack(alignment: .leading){
                        TextLabelRegularFont(stringData: "ET", fontColor: fontColor)
                        
                        
                        //Have to make func for time consumed
                        TextLabelRegularFont(stringData: etTime, fontColor: fontColor)
                    }
                    .frame(width: 90, alignment: .leading)
                }
                Spacer()
                
                /// No of Rounds Completed
                /// label of rounds
                ///
                ZStack{
                    HStack(alignment: .bottom, spacing: 5){
                        TextLabelRegularFont(stringData: handlingStringCountData(countStringData: completedRounds), fontColor: fontColor)
                            .lineLimit(1)
                            .minimumScaleFactor(0.9)
                        
                        // total interval completed out of total intervals
                        if isIntervalCallerHeader{
                            TextLabelRegularFont(stringData: handlingStringCountData(countStringData: intervalCompleted) + "/" + handlingStringCountData(countStringData: totalInterval), fontColor: fontColor, customFontSize: 32, isCustomFont: true)
                                .minimumScaleFactor(0.8)
                                .offset(y: 3.5)
                                .lineLimit(1)
                            
                            ///Remaing rounds
                            ///Depends reactive Sports
                            ///
                            TextLabelRegularFont(stringData: handlingStringCountData(countStringData: TotalRounds), fontColor: fontColor)
                                .lineLimit(1)
                                .minimumScaleFactor(0.9)
                            
                        }
                    }
                    .padding(.horizontal, -16)
                }
              
                Spacer()
                ZStack{
                    VStack(alignment: .trailing){
                        TextLabelRegularFont(stringData: "RT", fontColor: fontColor)
                        
                        //Have to make function for  time remaing
                        TextLabelRegularFont(stringData: rtTime, fontColor: fontColor)
                    }
                }
                .frame(width: 90, alignment: .trailing)
                }
            }
     
    }
}

