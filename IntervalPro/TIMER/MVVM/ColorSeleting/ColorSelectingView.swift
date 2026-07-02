//
//  ColorSelectingView.swift
//  TIMER
//
//  Created by Aditya Maroo on 21/08/24.
//

import SwiftUI

struct ColorSelectingView: View {
    
    @StateObject var viewModel = ColorGridVM()
    @Binding var colorHexString:String
    @Binding var colorOpacity:Double
    @Binding var previousNavigation: Bool
    let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0)
    
    ]
    var isScrollDisable = true
    
    //MARK: -
    //MARK: -
    var colorObject:ColorObject?
    var callBackData: ((ColorAdding)-> Void)?
    
    var body: some View {
        ZStack{
            Color.background
                .ignoresSafeArea()
            settingUp()
                .navigationBarHidden(true)
//            bodyContentView()
//                .edgesIgnoringSafeArea(.bottom)
            
            //                .onDisappear{
            //                    if viewModel.colorHexCode.trimmingCharacters(in: .whitespaces) != ""{
            ////                        callBackData?(viewModel.addingColorData())
            //                    }
            //                }
        }
    }
}



extension ColorSelectingView{
    @ViewBuilder
    func settingUp()-> some View{
            VStack(spacing: 32){
                ComHeaderView(titleHeader: .constant("Colour"), isBackBtnHidden: false, isSettingBtnHidden: true)
                    .padding(.horizontal, 16)
//                    .background(.blue)
                // Respect top safe area
                if #available(iOS 16.0, *){
                    bodyContentView()
                        .scrollDisabled(true)
                }
                else{
                    bodyContentView()
                }
                    //                bodyContentView()
                    //                    .padding(.top, -6)
                
            }
//            .edgesIgnoringSafeArea(.bottom)
         
    }
    @ViewBuilder
    func bodyContentView()-> some View{
        ScrollView{
            VStack(spacing: 24){
                TextColorField(txtPlaceHolder: "Hex", isColorBoxHidden: false, isNavigationOn: true, colorHexString: $colorHexString, colorOpacity: $colorOpacity ,previousNavigation: $previousNavigation, colorObject: colorObject, isNewTextFieldAppear: $viewModel.isHiddentextFieldAppear, selectedColorCallBack: {
                    colorObject?.colorHexCode = colorHexString
                    CoreDataManager.shared.saveContext()
                })
                .padding(.horizontal, 16)
                
                LazyVGrid(columns: columns, spacing: 0){
                    ForEach(0..<$viewModel.defaultColorArray.count, id: \.self){index in
                        ColorCartCell(colorHex: $colorHexString, colorModel: viewModel.defaultColorArray[index], colorObject: colorObject,
                                      dismissKeyBoardCallBack: {
                            viewModel.disableHideTextField()
                        }
                        )
                    }
                }
            }
            .padding(0)
        }
        
    }
    
//    private func safeAreaInsets() -> UIEdgeInsets {
//        UIApplication.shared.windows.first?.safeAreaInsets ?? .zero
//    }
}

#Preview {
    ColorSelectingView(colorHexString: .constant("#000000"), colorOpacity: .constant(1), previousNavigation: .constant(false))
}
