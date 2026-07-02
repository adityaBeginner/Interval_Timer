//
//  CIrcularBtn.swift
//  TIMER
//
//  Created by Aditya Maroo on 27/08/24.
//

import SwiftUI

struct CircularBtn: View {
    var itemCount: Int?
    @State var isTime:Bool = false
    @State var isInterval:Bool = false
    
     //MARK: - call back
    var callBackFolder: (()-> Void)?
    
    var filesType: FileType = .Folder
    var item:Item?
    
    var body: some View {
        ZStack{
            setUp()
            NavigationLink(isActive: $isTime) {
                if isTime{
                    if CoreDataManager.shared.isUserReachedFreeTimerLimit() || AppDefaults.shared.isUserSubscribed{
                        TimerCreationView(itemData: item, itemCount: itemCount)
                    }else{
                        PurchaseView()
                    }
                }
            } label: {
                EmptyView()
            }
            .hidden()
            NavigationLink(isActive: $isInterval) {
                if isInterval{
                    if CoreDataManager.shared.isUserReachedFreeTimerLimit() || AppDefaults.shared.isUserSubscribed{
                        ReactionView(itemData:item, itemCount: itemCount)
                    }else{
                        PurchaseView()
                    }
                }
            } label: {
                EmptyView()
            }
            .hidden()
  }

    }
    
}

#Preview {
    CircularBtn( )
}

extension CircularBtn{
    
    @ViewBuilder
    func setUp()-> some View{
        
        Button(action: {
            switch filesType {
            case .Timer:
                isTime = true
            case .Drill:
                isInterval = true
            case .Folder:
               callBackFolder?()
            }
        }){
            switch filesType {
            case .Timer:
                customButton(type: Image(.biggerTimerWatch))
            case .Drill:
                customButton(type: Image(.newRWord))
            case .Folder:
                customButton(type: Image(.biggerFolder))
            }
        }
    }
    
    @ViewBuilder
    func customButton(type:Image) -> some View{
        Circle()
            .fill(Color(uiColor: .footerBackgroundColor))
            .shadow(radius: 68)
            .overlay{
                type
                    .frame(width: 32 , height: type == Image(.biggerFolder) ? 25.33 : 37.29)
                    .padding(.bottom, 3)
            }
            .frame(width: 64, height: 64)
            .background(
            Circle()
                .fill(Color.white)
                .shadow(color: .black.opacity(0.5), radius: 5, x: 0, y: 5)
            
            )
    }
}
