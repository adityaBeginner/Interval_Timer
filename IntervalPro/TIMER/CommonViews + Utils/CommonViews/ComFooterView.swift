import SwiftUI

struct ComFooterView: View {
    @Binding var viewState: WorkoutViewState
    @Binding var isPlusBtnPressed: Bool
    var listItem: [Item] = []
    var item:Item?
    
    //Call back folder
    var callBackFolderdata: (()-> Void)?
    var callBackChangeSelectedValue: (()-> Void)?
    
    var body: some View {
        ZStack{
            if isPlusBtnPressed{
                CreatingDocCart(isMovableAnimation: $isPlusBtnPressed, callBackFolder: callBackFolderdata, item: item, itemCount: listItem.isEmpty ? 0 : listItem.count)
                        .frame(height: 0)
            }
            Color(uiColor: .footerBackgroundColor)
                .frame(height: 64)
            HStack{
                Button(action: {
                    //                    if !listItem.isEmpty{
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15){
                        withAnimation(.smooth){
                            if viewState == .Normal{
                                viewState = .Edit
                            }
                            else{
                                callBackChangeSelectedValue?()
                                viewState = .Normal
                            }
                        }
                    }
                    //                    }
//                    else{
//                        callBackChangeSelectedValue?()
//                        viewState = .Normal
//                    }
                }){
                    Image(viewState == .Normal ? "IconEditWhitePencil" : viewState == .ViewGuide ? "IconEditWhitePencil" : "IconBtnTick" )
                        .padding(.all, 25)
                }
                    .frame(width: 60, height: 60)
                
                Spacer()
            }
            .padding(.leading, 17)
            
            //Dark Layer for Footer background Color and interaction off for pencil button
            
            if isPlusBtnPressed{
                Color.darkLayer
                .frame(height: 64)
            }
            Button(action: {
                withAnimation{
                    isPlusBtnPressed.toggle()
                }
                
            }){
                Circle()
                    .fill(Color(uiColor: .footerAddBtnBackgroungColor))
                    .background{
                        if isPlusBtnPressed{
                            Circle()
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.5), radius: 5, x: 0, y: 5)
                        }
                    }
                    
                    .overlay{
                        Image("FooterPlusBtn")
                            .renderingMode(/*@START_MENU_TOKEN@*/.template/*@END_MENU_TOKEN@*/)
                            .foregroundStyle(Color(uiColor: isPlusBtnPressed ? .footerBackgroundColor : .timerWorkoutColor))
                            .rotationEffect(.degrees(isPlusBtnPressed ? 45 : 0))
                            Circle()
                            .strokeBorder(isPlusBtnPressed ? .volume : .clear)
                            .frame(width: 64, height: 64)
                       
                        //
                    } .frame(width: 64, height: 64)
                    .offset(y: -15)
            }
           
        }
    }
}


#Preview {
    ComFooterView(viewState: .constant(.Edit), isPlusBtnPressed: .constant(false))
}
