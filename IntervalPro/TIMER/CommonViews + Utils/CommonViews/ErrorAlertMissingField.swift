//
//  ErrorAlertMissingField.swift
//  TIMER
//
//  Created by Aditya Maroo on 28/04/25.
//

import SwiftUI

struct ErrorAlertMissingField: View {
     //MARK: -  Propeties
    var alertheaderString = "ERROR: MISSINGS FIELDS"
    var alertDescriptionPara1 = "The file you’re uploading appears to have different headings or information than required for this type Timer."
    var alertDescriptionPara2 = "Please check you’re importing the correct timer (e.g. Interval vs Reaction)."
    var alertDescriptionPara3 = "Failing that, check the column headings against the templates available at:"
    var linkText = "https://www.pbintervals.app/resources"
    var alertCancelTxt = "CANCEL"
    var alertOkayTxt = "CHOOSE NEW FILE"
    var webModel = WebViewModel(allUrl: .Resoource)
    @State private var isWebView: Bool = false
    
    //Callback
    var cancelCallBack: (()-> Void)?
    var okayCallBack: (()-> Void)?
  
    
    var body: some View {
        ZStack{
            NavigationLink(isActive: $isWebView) {
                HelpWebViewController(model: webModel)
            } label: {
                EmptyView()
            }
            .hidden()

            Color.blurBackground
                .ignoresSafeArea()
            setup()
                .background(Color(uiColor: .popAlertWhiteBackground))
                .cornerRadius(6.0)
                .frame(width: UIScreen.main.bounds.size.width * 0.79)
                .offset(y: -(UIScreen.main.bounds.size.height * 0.08))
        }
    }
}

 //MARK: - Extension of Components and config of view
extension ErrorAlertMissingField{
    //Setup View
    func setup()-> some View{
        VStack(alignment: .leading,spacing: 16){
            headerTitle()
            alertContent()
            buttonStack()
        }
        .padding(.all, 24)
    }
    
    //Title View
    func headerTitle()-> some View{
        CustomTextLabelBoldFont(stringData: alertheaderString, fontColor: Color(uiColor: .timerWorkoutColor), fontSize: .TSIZE_16 )
    }
    
    //Content
    func alertContent()-> some View{
        VStack(alignment: .leading,spacing: 0){
            ErrorCustomTextLabelRegualFont(stringData: alertDescriptionPara1, fontColor: Color(uiColor: .timerWorkoutColor), fontSize: .TSIZE_14 )
                .multilineTextAlignment(.leading)
            
            ErrorCustomTextLabelRegualFont(stringData: alertDescriptionPara2, fontColor: Color(uiColor: .timerWorkoutColor), fontSize: .TSIZE_14 )
                .multilineTextAlignment(.leading)
                .padding(.top, 16)
            
            ErrorCustomTextLabelRegualFont(stringData: alertDescriptionPara3, fontColor: Color(uiColor: .timerWorkoutColor), fontSize: .TSIZE_14 )
                .multilineTextAlignment(.leading)
                .padding(.top, 16)
            
            ErrorCustomTextLabelRegualFont(stringData: linkText, fontColor: Color(uiColor: .blue), fontSize: .TSIZE_14 )
                .padding(.top, 4)
                .onTapGesture {
                    isWebView = true
                }
                  
          
        }
    }
    
    func buttonStack()-> some View{
        HStack{
            Button(action: {
          cancelCallBack?()
            })
            {
                CustomTextLabelBoldFont(stringData: alertCancelTxt, fontColor: Color(uiColor: .thickBorderWidthGradientFirstColor), fontSize: .TSIZE_14)
                
            }
            Spacer()
            Button(action: {
                okayCallBack?()
            })
            {
                CustomTextLabelBoldFont(stringData: alertOkayTxt , fontColor: Color(uiColor: .footerBackgroundColor), fontSize: .TSIZE_14)
            }
        }
        
    }
    
}


#Preview {
    ErrorAlertMissingField()
}
