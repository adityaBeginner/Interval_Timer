//
//  SplashView.swift
//  TIMER
//
//  Created by Aditya Maroo on 22/08/24.
//

import SwiftUI

struct SplashView: View {
    @State var isShowSplash = true
    @State var isAnimation = false
    var body: some View {
        if isShowSplash{
            splashContent()
                .offset(y: isAnimation ? -UIScreen.main.bounds.size.height : 0)
                .onChange(of: isAnimation, perform: {newValue in 
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(10), execute: {
                        withAnimation {
                          isShowSplash = false
                        }
                    })
                })
                .onAppear(perform: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                        withAnimation {
                            self.isAnimation = true
                        }
                    })
                   
                })
        }else{
            WorkingView()
        }
    }
    
    @ViewBuilder
    func splashContent() -> some View{
        ZStack{
            Color(uiColor: .footerBackgroundColor)
            //Image(.myIntervalNewSplashLogo)
            LottieView(filename: "Timer_Interval_LightBlue", loopMode: .loop)
        }
        .ignoresSafeArea()
    }
        
}

#Preview {
    SplashView()
}
