//
//  PopContainerView.swift
//  TIMER
//
//  Created by Aditya Maroo on 14/08/24.
//

import SwiftUI

struct PopContainerView: View {
     //MARK: - Prpoperties and object
    //binded with workout screen state
    @Binding var popHidding: WorkoutViewState
    var popHandlingScreens: PopHandlingScreens = .WorkoutScreen
    /// pop appear at which number
    @State var popNumberState: Int = 1
    /// description string is pop content string and binded with workout, interval calls and reactioncall screen
    @Binding var descriptionString: [String]
    /// cart offset number of x and y for postioning
    @State var offSetNumberX: Double = 0
    @State var offSetNumberY: Double = -110
    @State var desctionContent: String = ""
    /// alignment position of cart
    @State var alignmentPostion: Alignment = .bottom
    /// traingle offset of x and y
    @State var triangleOffsetX: Double = 0
    @State var triangleOffestY: Double = 98
    ///Button Name
    @State var nextButtonName = "Next"
 //MARK: - Main content view for displaying
    var body: some View {
        ZStack{
            HStack{
                    getPopContainer()
                }
                .frame(width: 287)
                .cornerRadius(6)
                .background{
                    ZStack{
                        //Triangle shape object creation
                        Rectangle()
                            .fill(Color(uiColor: .footerBackgroundColor))
                            .cornerRadius(2.0)
                            .frame(width: 20, height: 20)
                            .rotationEffect(.degrees(45))
                    }
                    .offset(x: triangleOffsetX, y: triangleOffestY)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignmentPostion)
            .padding(.horizontal, UIScreen.main.bounds.size.width * 0.044)
            .edgesIgnoringSafeArea(.bottom)
            .offset(x: offSetNumberX, y: offSetNumberY)
      }
}
#Preview {
    PopContainerView(popHidding: .constant(.Edit),  descriptionString: .constant(["", "", ""]))
}
 //MARK: - Extension for sub content view
extension PopContainerView{
    //setup  file contennt all sub content view for displaying
    @ViewBuilder
    func getPopContainer()-> some View{
        VStack(spacing: 0){
            getTopViewContainer()
            getMiddlePopView()
            getLastPopView()
        }
     }
    /**
     *Top orange pop content view contain label components
     *Overiew and total count of pops appear
     *
     * - Parameters: No parameter
     *
     * - Returns: return top view of pop cart.
     *
     */
    @ViewBuilder
    func getTopViewContainer()-> some View{
        
        HStack{
            HStack{
                TextLabelBoldFont(stringData: "OVERVIEW", fontColor: .white, fontSize: .TSIZE_16)
                    .padding(.leading, 16)
                    Spacer()
                TextLabelLightFont(stringData: "\(handlingStringCountData(countStringData:  String(popNumberState))) of \(handlingStringCountData(countStringData: String(descriptionString.count)))", fontColor: .white, fontSize: .TSIZE_14)
                    .padding(.trailing, 16)
//                    .frame(width: 57)
            }
        }
        .frame(height: 56)
        .background(
            Color(uiColor: .footerBackgroundColor)
        )
    }
    @ViewBuilder
    func getMiddlePopView()-> some View{
        VStack(alignment: .leading,spacing: 0){
            HStack{
                TextLabelMeduimFont(stringData: descriptionString[popNumberState - 1], fontColor: .black, fontSize: .TSIZE_16)
                    .multilineTextAlignment(.leading)
             }
            .padding(.all, 16)
            HStack{
                Button(action: {
                    popHidding = .Normal
                    //set user guide view status in default
                    setUserGuideViewStatusInUserDefault()
                }){
                    TextLabelLightFont(stringData: "Skip All", fontColor: Color(uiColor: .cancelSkipBtnColor), fontSize: .TSIZE_14)
                }
                Spacer()
                Button(action: {
                    
                    
//                  if popNumber < 3{
//                      
//                        withAnimation{
//                            popNumber += 1
//                        }
//                    }
//                    else{
//                        popNumber += 1
//                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.10){
                        withAnimation{
                            switch popHandlingScreens{
                            case .WorkoutScreen:
                                workoutsViewPops()
                          
                            case .IntervalPotrait:
                                intervalViewPops()
                            case .ReactionTimePotrait:
                                reactionIntervalViewPops()
                            }
                        }
                    }
                    //set user guide view status in default
                    setUserGuideViewStatusInUserDefault()
                }){
                    TextLabelBoldFont(stringData: nextButtonName, fontColor: Color(uiColor: .footerBackgroundColor), fontSize: .TSIZE_14)
                    
                }
            }
            .frame(height: 17)
            .padding(.all, 16)
        }
        .background(Color(uiColor: .white))
    }
    @ViewBuilder
    func getLastPopView()-> some View{
        HStack{
            Color(uiColor: .footerBackgroundColor)
        }
        .frame(height: 8)
    }
    
     //MARK: - for logic function
    func getPopData(cartOffsetX: Double? ,cartOffsetY: Double?, triangleOffsetX: Double, triangleOffsetY: Double, alignmentPosition: Alignment){
        self.offSetNumberX = cartOffsetX ?? 0
        self.offSetNumberY = cartOffsetY ?? 0
        self.triangleOffsetX = triangleOffsetX
        self.triangleOffestY = triangleOffsetY
        self.alignmentPostion = alignmentPosition
        
    }
    /// workouts showing pops offsets and constraints
    func workoutsViewPops(){
        if popNumberState < 3 {
            popNumberState += 1
        }
        else{
            popHidding = .Normal
        }
        switch popNumberState{
        case 2:
            getPopData(cartOffsetX: 0, cartOffsetY: -90, triangleOffsetX: -120, triangleOffsetY: TrianglePosition.dowSideTriangle.rawValue + 10.0, alignmentPosition: .bottomLeading)
        case 3:
            getPopData(cartOffsetX: 0, cartOffsetY: 0, triangleOffsetX: TrianglePosition.rightSideTriangle.rawValue + 10, triangleOffsetY: -66, alignmentPosition: .top)
            nextButtonName = "End"
        default:
            popHidding = .Normal
            
        }

    }
    /// interval showing pops offsets and constraints
    func intervalViewPops(){
        if popNumberState < descriptionString.count{
            popNumberState += 1
        }
        else{
            popHidding = .Normal
        }
        switch popNumberState{
        case 2:
            getPopData(cartOffsetX: 0, cartOffsetY: 70, triangleOffsetX: 120, triangleOffsetY: TrianglePosition.topSideTriangle.rawValue, alignmentPosition: .topTrailing)
        case 3:
            getPopData(cartOffsetX: 0, cartOffsetY: 70, triangleOffsetX: 0, triangleOffsetY: TrianglePosition.topSideTriangle.rawValue , alignmentPosition: .top)
        case 4:
            getPopData(cartOffsetX:  UIScreen.main.bounds.size.width * 0.044, cartOffsetY: 70, triangleOffsetX: -36, triangleOffsetY: TrianglePosition.topSideTriangle.rawValue , alignmentPosition: .topLeading)
        case 5:
            getPopData(cartOffsetX: -UIScreen.main.bounds.size.width * 0.044, cartOffsetY: 70, triangleOffsetX: 36, triangleOffsetY: TrianglePosition.topSideTriangle.rawValue , alignmentPosition: .topTrailing)
        case 6:
            getPopData(cartOffsetX: 0, cartOffsetY: -40, triangleOffsetX: 0, triangleOffsetY: TrianglePosition.dowSideTriangle.rawValue + 10, alignmentPosition: .center)
        case 7:
            getPopData(cartOffsetX: 0, cartOffsetY: -85, triangleOffsetX: 0, triangleOffsetY: TrianglePosition.dowSideTriangle.rawValue, alignmentPosition: .bottom)
        case 8:
            getPopData(cartOffsetX: UIScreen.main.bounds.size.width * 0.044, cartOffsetY: -85, triangleOffsetX: -60, triangleOffsetY: TrianglePosition.dowSideTriangle.rawValue + 10, alignmentPosition: .bottomLeading)
        case 9:
            getPopData(cartOffsetX: -UIScreen.main.bounds.size.width * 0.044, cartOffsetY: -85, triangleOffsetX: 65, triangleOffsetY: TrianglePosition.dowSideTriangle.rawValue, alignmentPosition: .bottomTrailing)
        case 10:
            getPopData(cartOffsetX: 0, cartOffsetY: -85, triangleOffsetX: 120, triangleOffsetY: TrianglePosition.dowSideTriangle.rawValue, alignmentPosition: .bottomTrailing)
            nextButtonName = "End"
        default:
            popHidding = .Normal
            
        }
    }
    func reactionIntervalViewPops(){
        if popNumberState < descriptionString.count{
            popNumberState += 1
        }
        else{
            popHidding = .Normal
        }
        switch popNumberState{
        case 2:
            getPopData(cartOffsetX: 0, cartOffsetY: 55, triangleOffsetX: 120, triangleOffsetY: TrianglePosition.topSideTriangle.rawValue, alignmentPosition: .topTrailing)
        case 3:
            getPopData(cartOffsetX: 0, cartOffsetY: -171, triangleOffsetX: 0, triangleOffsetY: TrianglePosition.dowSideTriangle.rawValue , alignmentPosition: .bottom)
        case 4:
            getPopData(cartOffsetX: 0, cartOffsetY: -85, triangleOffsetX: 0, triangleOffsetY: TrianglePosition.dowSideTriangle.rawValue, alignmentPosition: .bottom)
        case 5:
            getPopData(cartOffsetX: UIScreen.main.bounds.size.width * 0.044, cartOffsetY: -85, triangleOffsetX: -60, triangleOffsetY: TrianglePosition.dowSideTriangle.rawValue + 10, alignmentPosition: .bottomLeading)
        case 6:
            getPopData(cartOffsetX: -UIScreen.main.bounds.size.width * 0.044, cartOffsetY: -85, triangleOffsetX: 65, triangleOffsetY: TrianglePosition.dowSideTriangle.rawValue, alignmentPosition: .bottomTrailing)
        case 7:
            getPopData(cartOffsetX: 0, cartOffsetY: -85, triangleOffsetX: 120, triangleOffsetY: TrianglePosition.dowSideTriangle.rawValue, alignmentPosition: .bottomTrailing)
                 nextButtonName = "End"
        default:
            popHidding = .Normal
        }
    }
    
    //MARK: -
    //MARK: SET INTRO USER GUIDE
    ///
    /// SET INTRO USER GUIDE VIEW IN USER DEFAULT
    /// 
    private func setUserGuideViewStatusInUserDefault(){
        switch popHandlingScreens{
        case .WorkoutScreen:
            AppDefaults.shared.isIntroCompletedOnWorkingView = true
        case .IntervalPotrait:
            AppDefaults.shared.isIntroCompletedOnTimerCreationCallView = true
        case .ReactionTimePotrait:
            AppDefaults.shared.isIntroCompletedOnIntervalReationCallView = true
        }
    }
}
//MARK: - Extension for calculatig Number of lines of text
