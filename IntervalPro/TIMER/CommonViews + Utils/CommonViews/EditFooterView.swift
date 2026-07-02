//
//  EditFooterView.swift
//  TIMER
//
//  Created by Aditya Maroo on 20/08/24.
//

import SwiftUI

struct EditFooterView: View {
     //MARK: - state for button
    @State var cutBtn: Bool = false
    @State var copyBtn: Bool = false
    @State var pasteBtn: Bool = false
    @State var deleteBtn: Bool = false
     //MARK: - properties to edit button
    var isCheckBoxChecked: Bool = true
     //MARK: - Call back
    var callBackDeleteData: (()-> Void)?
    var callBackCopyData: (()-> Void)?
    var callBackPasteData: (()-> Void)?
    var callBackCutData: (()-> Void)?
    @State var changeOffsetProp: Bool = false
    var itemSelected: [IntervalItem] = []
    var messageSelected: [MessageItems] = []
  
    
    var body: some View {
        ZStack{
            Color(uiColor: .footerBackgroundColor)
                .edgesIgnoringSafeArea(.horizontal)
                HStack(spacing: 40){
                    
                    Spacer()
                        Button(action: {
                            itemSelected.isEmpty ? messageSelected.isEmpty ? noHaptic() : hapticON() : hapticON()
                            withAnimation{
                                cutBtn.toggle()
                                changeOffsetState()
                            }
                            callBackCutData?()
                            changingState()
                        }){
                            ZStack{
                                if cutBtn{
                                    Circle()
                                        .fill(Color.black.opacity(0.2))
                                        .frame(width: 48)
                                        .transition(.scale)
                                    
                                }
                               
                                Image(.iconCut)
                                    .renderingMode(.template)
                                    .resizable()
                                    .scaledToFit()
                                
                                    .foregroundStyle(Color.white)
                                    .frame(width: 16, height: 17.3)
                            }
                            .frame(width: 16)
                        }
                        Button(action: {
                            itemSelected.isEmpty ? messageSelected.isEmpty ? noHaptic() : hapticON() : hapticON()
                            withAnimation{
                                copyBtn.toggle()
                                changeOffsetState()
                            }
                            changingState()
                            callBackCopyData?()
                        }){
                            ZStack{
                                if copyBtn{
                                    Circle()
                                        .fill(Color.black.opacity(0.2))
                                        .frame(width: 48)
                                        .transition(.scale)
//                                    CustomFooterShape()
//                                        .fill(Color(uiColor: .footerBackgroundColor))
//                                        .frame(width: 55, height: 50)
//                                        .offset(y: copyBtn ? changeOffsetProp ? -37 : -20 : -20)
                                }
                                Image("IconCopy")
                                    .renderingMode(.template)
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(Color.white.opacity(copyBtn ? 0.5 : 1))
                                    .frame(width: 16, height: 17.3)
                            }
                            .frame(width: 16)
                        }
                        Button(action: {
                            EditOperations.editEntityType == .non ? noHaptic() : hapticON()
                            withAnimation{
                                pasteBtn.toggle()
                                changeOffsetState()
                            }
                            changingState()
                            callBackPasteData?()
                        }){
                            ZStack{
                                if pasteBtn{
                                    Circle()
                                        .fill(Color.black.opacity(0.2))
                                        .frame(width: 48)
                                        .transition(.scale)
                                }
                                Image("IconPaste")
                                    .renderingMode(.template)
                                    .resizable()
                                    .scaledToFit()
                                
                                    .foregroundStyle(Color.white)
                                    .frame(width: 16, height: 17.3)
                            }
                            .frame(width: 16)
                        }
                        Button(action: {
                            itemSelected.isEmpty ? messageSelected.isEmpty ? noHaptic() : hapticON() : hapticON()
                            withAnimation{
                                deleteBtn.toggle()
                                changeOffsetState()
                            }
                            callBackDeleteData?()
                            changingState()
                        }){
                            ZStack{
                                if deleteBtn{
                                    Circle()
                                        .fill(Color.black.opacity(0.2))
                                        .frame(width: 48)
                                        .transition(.scale)
                                }
                                Image("IconDelete")
                                    .renderingMode(.template)
                                    .resizable()
                                    .scaledToFit()
                                
                                    .foregroundStyle(Color.white)
                                
                                    .frame(width: 16, height: 17.3)
                            }
                            .frame(width: 16)
                        }
            
                }
                .padding(.horizontal, 24)
        }
        .frame(height: 64)
    }
    
    func changingState(){
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(800), execute: {
                cutBtn = false
                copyBtn = false
                pasteBtn = false
                deleteBtn = false
        })
    }
    func changeOffsetState(){
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100), execute: {
            withAnimation{
                changeOffsetProp = true
            }
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600), execute: {
            withAnimation{
                changeOffsetProp = false
            }
        })
    }
}

#Preview {
    EditFooterView()
}
