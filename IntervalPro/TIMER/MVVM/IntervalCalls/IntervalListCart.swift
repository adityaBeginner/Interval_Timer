//
//  IntervalListCart.swift
//  TIMER
//
//  Created by Aditya Maroo on 28/08/24.
//

import SwiftUI



struct IntervalListCart: View {
    //MARK: - IntervalList data form parent view IntervalView
    var intervalLastItemData: IntervalCallProperties?
    var intervalItemData: IntervalCallProperties?
    var contentHeight: CGFloat = 57
    var fontBestContrastColor: Color?
    var fontWeight: Font.Weight = .regular
    var fontSize: CGFloat = 16
    var fontSizeMilliseconds: CGFloat = 13
    
    //Call Back Data
    var tapGuestureCallBack: (()-> Void)?
    
    var body: some View {
        VStack(spacing: 0){
            //            HStack{Color.white}
            //                .frame(height: 1)
            
            setUp()
                .frame(height: contentHeight)
                .background(Color.clear)
                          
            HStack{fontBestContrastColor ?? Color.white}
                .frame(height: 1)
        }
    }
}

#Preview {
    IntervalListCart()
}
extension IntervalListCart{
    @ViewBuilder
    func setUp()->some View{
        contentUp()
    }
    @ViewBuilder
    func contentUp()->some View{
        HStack(spacing: 0){
            VStack{
                //ADITYA
                Color(hex: (intervalItemData?.intervalColour) ?? "#000000")
                    .opacity(intervalItemData?.intervalColorOpacity ?? 1.0)
            }
            .frame(width: 22)
            VStack{
                fontBestContrastColor ?? Color.white
            }
            .frame(width: 1)
            Spacer()
            CustomTextLabelFont(stringData: intervalItemData?.intervalName ?? IntervalListCartListString.intervalName, fontColor: fontBestContrastColor ?? .white, fontSize: TSize(rawValue: fontSize) ?? .TSIZE_16, fontWeight: fontWeight)
                .padding(.trailing, 10)
            MilliSecondsAttributeTxt(timeString: intervalItemData?.intervalDuration ?? IntervalListCartListString.intervalTime, fontColor: fontBestContrastColor ?? .white, fontSize: TSize(rawValue: fontSize) ?? .TSIZE_16, fontSizeMillseconds: TSize(rawValue: fontSizeMilliseconds) ?? .TSIZE_16,fontWeight: fontWeight)
            Spacer()
            VStack{
                fontBestContrastColor ?? Color.white
            }
            .frame(width: 1)
            VStack{
                Color(hex: (intervalItemData?.intervalColour) ?? "#000000")
                    .opacity(intervalItemData?.intervalColorOpacity ?? 1.0)
            }
            .frame(width: 22)
        }
    }
}

struct IntervalListCartStrings{
    static let name = "Name"
}
