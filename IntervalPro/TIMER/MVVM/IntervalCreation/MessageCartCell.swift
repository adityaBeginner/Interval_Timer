//
//  IntervalCustomCell.swift
//  TIMER
//
//  Created by Aditya Maroo on 20/08/24.
//

import SwiftUI

struct MessageCartCell: View {
    
    @State var isMessageSelected: Bool = false
    
    @State private var scaleEffect: CGFloat = 1
    
    var messageItem:MessageItems = MessageItems()
    var callBackAddMessage: ((MessageItems)-> Void)?
    var callBackRemoveMessage: ((MessageItems)-> Void)?
    var body: some View {
        VStack(spacing: 0){
            HStack(spacing: 14){
                Button(action: {})
                {
                    
                    Image("MovableIcon")
                        .renderingMode(/*@START_MENU_TOKEN@*/.template/*@END_MENU_TOKEN@*/)
                        .foregroundStyle(.headerTitleColerSet)
                    
                    //                .hidden()
                }
                
                
                VStack(alignment: .leading, content: {
                    TextLabelMeduimFont(stringData: messageItem.messageName ?? "")
                    MilliSecondsAttributeTxt(timeString: AppComman.shared.handlingMilliseconds(timeString: messageItem.delay), fontColor: .headerTitleColerSet, fontSize: .TSIZE_14, fontSizeMillseconds: .TSIZE_12,fontWeight: .regular)
                    //                        .font(.custom(TFonts.TREGULAR.rawValue, size: TSize.TSIZE_14.rawValue))
                    //                        .foregroundColor(Color(uiColor: .headerTitleColerSet))
                })
                
                Spacer()
                HStack{
                    Button(action: {
                        hapticON()
                        if !messageItem.isSelected{
                            isMessageSelected = true
                            scaleEffect = 0.4
                            messageItem.isSelected = true
                            callBackAddMessage?(messageItem)
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
                            withAnimation(.spring(response: 0.2, dampingFraction: 0.4)) {
                                scaleEffect = 0.4
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                withAnimation{
                                    messageItem.isSelected = false
                                    isMessageSelected = false
                                    scaleEffect = 1.0
                                    callBackRemoveMessage?(messageItem)
                                }
                            }
                            //                            withAnimation(.spring(response: 0.2, dampingFraction: 0.4)) {
                            //                                scaleEffect = 0.4
                            //                                messageItem.isSelected = false
                            //                                callBackRemoveMessage?(messageItem)
                            //                            }
                            //                            withAnimation(.linear.delay(0.2)){
                            //                                scaleEffect = 1
                            //                            }
                        }
                    }, label: {
                        ZStack(alignment: .trailing){
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.background)
                            Image( messageItem.isSelected ? .stateCheckBtn : .buttonCheckBox)
                                .resizable()
                                .frame(width: 16, height: 16)
                                .scaleEffect(scaleEffect)
                        }
                        .frame(width: 60, height: 50)
                        .contentShape(.rect)
                    })
                }
            }
            //            .frame(height: 40)
            //            .padding(.horizontal, 16)
            Line()
                .stroke(style: .init(dash: [3]))
            //                        .accentColor(Color(uiColor: .lineDottedColor))
                .foregroundColor(Color(uiColor: .lineDottedColor))
                .frame(height: 1)
                .padding(.top, 24)
            //                        .padding(.horizontal, 16)
        }
        
    }
}

#Preview {
    MessageCartCell()
}
