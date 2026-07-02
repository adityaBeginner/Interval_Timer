//
//  LandscapeListCart.swift
//  TIMER
//
//  Created by Aditya Maroo on 30/08/24.
//

import SwiftUI

struct LandscapeListCart: View {
    var intervalListItemData: IntervalCallProperties?
    var contentHeight: CGFloat = 62
    var fontBestContrastColor: Color?
    var fontWeight: Font.Weight = .regular
    var fontSize: CGFloat = 16
    var fontSizeMilliseconds: CGFloat = 13
    var totalListCount: Int = 0
    var body: some View {
        VStack(spacing: 0){
            //            HStack{Color.white}
            //                .frame(height: 1)
            //               
            setUp()
                .frame(height: contentHeight)
                .background(Color.clear)
            HStack{fontBestContrastColor ?? Color.white}
                .frame(height: 1)
        }
    }
}

#Preview {
    LandscapeListCart()
}
extension LandscapeListCart{
    @ViewBuilder
    func setUp()->some View{
        contentUp()
    }
    
    @ViewBuilder
    func contentUp()->some View{
        HStack(spacing: 0){
            HStack{
                Color(hex: intervalListItemData?.intervalColour ?? "#000000")
                    .opacity(intervalListItemData?.intervalColorOpacity ?? 1.0)
            }
            .frame(width: 40)
            VStack{
                fontBestContrastColor ?? Color.white
            }
            .frame(width: 1)
          
            VStack(alignment: .leading,spacing: 2){
                    HStack{
                    CustomTextLabelFont(stringData: intervalListItemData?.intervalName ?? "", fontColor: fontBestContrastColor ?? .white, fontSize: TSize(rawValue: fontSize) ?? .TSIZE_16, fontWeight: fontWeight)
                        .multilineTextAlignment(.leading)
                    Spacer()
                        MilliSecondsAttributeTxt(timeString: intervalListItemData?.intervalDuration ?? "00:00:00", fontColor: fontBestContrastColor ?? .white, fontSize: TSize(rawValue: fontSize) ?? .TSIZE_16, fontSizeMillseconds: TSize(rawValue: fontSizeMilliseconds) ?? .TSIZE_13,fontWeight: fontWeight)
                }
                if intervalListItemData?.breakTime == .NoBreak{
                    TextLabelLightFont(stringData: "(\(intervalListItemData?.currentIntervalIndexOfSession  ?? 1)/\(totalListCount))", fontColor: fontBestContrastColor ?? .white, fontSize: .TSIZE_16)
                }
            }
            .padding(.horizontal, 10)
            
        }
        
    }
}
