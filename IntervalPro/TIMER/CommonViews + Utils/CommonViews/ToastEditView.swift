//
//  ToastEditView.swift
//  TIMER
//
//  Created by Aditya Maroo on 03/10/24.
//

import SwiftUI

struct ToastEditView: View {
    @Binding var isToastHidden: Bool
    @State var toastAnimation: Bool = false
    var titleName: String = "Copy"
    var body: some View {
        ZStack{
            setup()
                .offset(y: isToastHidden ? toastAnimation ? -60 : 50 : 50)
                .onAppear{
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100), execute: {
                        withAnimation(.easeInOut){
                           toastAnimation = true
                        }
                    })
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1500), execute: {
                        withAnimation(.easeInOut){
                           toastAnimation = false
                            if !toastAnimation{
                                isToastHidden = false
                            }
                        }
                    })
                }
        }
    }
}

#Preview {
    ToastEditView(isToastHidden: .constant(false))
}

 //MARK: - Extension for sub views
extension ToastEditView{
    @ViewBuilder
    func setup()-> some View{
        VStack{
            Spacer()
            bodyContent()
        }
        .edgesIgnoringSafeArea(.bottom)
    }
    @ViewBuilder
    func bodyContent()-> some View{
        RoundedRectangle(cornerRadius: 20)
            .fill(.black.opacity(0.1))
            .frame(width: 100, height: 40)
            .overlay{
                TextLabelRegularFont(stringData: titleName, fontColor: Color(uiColor: .footerBackgroundColor), fontSize: .TSIZE_16)
                    
            }
            
    }
}
