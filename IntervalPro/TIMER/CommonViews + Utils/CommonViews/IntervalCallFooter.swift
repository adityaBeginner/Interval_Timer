//
//  IntervalCallFooter.swift
//  TIMER
//
//  Created by Aditya Maroo on 28/08/24.
//

import SwiftUI

struct IntervalCallFooter: View {
    var isIntervalfooterImageChange = false
    var foreGroundColor: Color = .white
    @Binding var isPlayButtonTap: Bool
    
    //Call back function
    var startAction: (()-> Void)?
    var stopaction:(() -> Void)?
    var reloadSession: (()-> Void)?
    var nextInterval: (()-> Void)?
    var interactionCallBack: (()-> Void)?
    var interactionUnlock: (()-> Void)?
    var dismissCallBack: (()-> Void)?
    
    @State var isReloadTap: Bool = false
    @Binding var interactionLocked: Bool
//    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
            setUp()
    }
}

#Preview {
    IntervalCallFooter( isPlayButtonTap: .constant(false), interactionLocked: .constant(false))
    
}

extension IntervalCallFooter{
    @ViewBuilder
    func setUp()-> some View{
        footerBtn()
            
    }
    @ViewBuilder
    func footerBtn()-> some View{
            HStack(spacing: 0){
                Button(action: {
                    dismissCallBack?()
                    presentationMode.wrappedValue.dismiss()
                }){
                    Image(.xFooterBtn)
                        .renderingMode(.template)
                        .foregroundStyle(foreGroundColor)
                }
                .padding(.all, 4)
                .disabled(interactionLocked)
                Spacer()
                    Image(interactionLocked ? .buttonLock : .lockUnlock)
                        .renderingMode(.template)
                        .foregroundStyle(foreGroundColor)
                .gesture(
                    TapGesture()
                        .onEnded {
                            hapticON()
                            interactionLocked = true  // Toggle lock state on tap
//                            interactionCallBack?()      // Trigger callback for tap
                        }
                )
                .simultaneousGesture(
                    LongPressGesture(minimumDuration: 2)
                        .onEnded { _ in
//                            interactionUnlock?()        // Trigger unlock callback on long press
                            hapticON()
                            interactionLocked = false   // Unlock after long press
                        }
                )
                .padding(.all, 6.5)
                Spacer()
                Button(action: {
                    isPlayButtonTap.toggle()
                    if isPlayButtonTap{
                        startAction?()
                    }
                    else{
                        stopaction?()
                    }
                }){
                    Image(isPlayButtonTap ? .pauseButton : .playFooterBtn)
                        .renderingMode(.template)
                        .foregroundStyle(foreGroundColor)
                        
                }
                .disabled(interactionLocked)
                Spacer()
                Button(action: {
                    isReloadTap.toggle()
                    reloadSession?()
                }){
                    Image(.replayFooterBtn)
                        .renderingMode(.template)
                        .foregroundStyle(foreGroundColor)
                        .rotationEffect(Angle(degrees: isReloadTap ? 360 : 0 ))
                        
                }
                .padding(.all, 4)
                .disabled(interactionLocked)
                Spacer()
                Button(action: {
                    nextInterval?()
                }){
                    Image(.fastFooterBtn)
                        .renderingMode(.template)
                        .foregroundStyle(foreGroundColor)
                       
                }
                .disabled(interactionLocked)
            }
        
    }
}
