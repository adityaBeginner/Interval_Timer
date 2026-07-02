//
//  CreatingDocCart.swift
//  TIMER
//
//  Created by Aditya Maroo on 26/08/24.
//

import SwiftUI

struct CreatingDocCart: View {
    
    //MARK: - Binded with footer view controller
    @Binding var isMovableAnimation: Bool
    
    //MARK: - STATE PROPERTIES
    @State var isStartingState: Bool = false
    @State var shouldShowCreateFolderInputPopup:Bool = false
    
     //MARK: - callbackData
    var callBackFolder: (()-> Void)?
   
    //MARK: - PROPERTIES
    var isChild:Bool?
    var item:Item?
    var itemCount: Int?
    
    //MARK: - Main content view to display
    var body: some View {
        ZStack{
            setUp()
        }
    }
}

#Preview {
    CreatingDocCart(isMovableAnimation: .constant(true))
}
 //MARK: - Extension for sub view content
extension CreatingDocCart{
    //setup file contains all child view return main content view
    @ViewBuilder
    func setUp()-> some View{
        insertingCircularBtn()
    }
    //Contain 3 circular button with animation of bounce and slide and offset re-change
    // According to binding and state variable offset changes
    // 35 cgfloat will be inital point where circular will stick
    @ViewBuilder
    func insertingCircularBtn()-> some View{
            VStack(spacing: 0){
                HStack{
                    CircularBtn(itemCount: itemCount, filesType: .Timer, item: item)
                        .transition(.opacity.combined(with: .scale))
                        .offset(y: isMovableAnimation ? isStartingState ? 0 : 35 : 35)
                }
                HStack(spacing: 0){
                    CircularBtn( callBackFolder: callBackFolder, filesType: .Folder, item: item)
                        .transition(.opacity.combined(with: .scale))
                        .offset(x: isMovableAnimation ? isStartingState ? 0 : 35 : 35)
                        .onTapGesture {
                            shouldShowCreateFolderInputPopup = true
                        }
                    if isStartingState{
                        Spacer()
                    }
                    CircularBtn(itemCount: itemCount, filesType: .Drill, item: item)
                        .transition(.opacity.combined(with: .scale))
                        .offset(x: isMovableAnimation ? isStartingState ? 0 : -35 : -35)
                }
                .offset(y: -12)
            }
            .frame(width: isMovableAnimation ? isStartingState ? UIScreen.main.bounds.size.width * 0.47 : 0 : 0 )
            .transition(.scale.combined(with: .opacity).animation(.bouncy))
            .offset(y: isMovableAnimation ? isStartingState ? -90 : -40 : -40 )
            
            .onAppear{
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                    
                    withAnimation(.bouncy){
                        self.isStartingState = true
                    }
                })
            }
            
        }
    
}
