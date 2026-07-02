//
//  AlertPopScreens.swift
//  TIMER
//
//  Created by Aditya Maroo on 17/09/24.
//

import SwiftUI
 //MARK: - Main body code
struct AlertPopScreens: View {
     //MARK: - PROPERTIES
    var alertHeader: String = "STOP TIMER AND RESET?"
    var alertDescription: String = "Are you sure you want to end this session and reset the timer."
    var alertOkText: String = "YES, RESET"
    var alertCancelText: String = "NO, GO BACK"
    var isTextFieldHidden: Bool = true
    var isCheckBoxFieldHidden: Bool = true
    var isOkayBtnHidden: Bool = false
    
    //Color Property Variable
    @State var copyColorObject = ColorPropertyStructure()
    
    @State var keyboardResponder = KeyboardResponder()
    //ColorData properties
    @Binding var colorHexCode: String
    @Binding var colorOpacity: Double
    var colorObject: ColorObject?
    //MARK: - State PROPERTIES
    @State var folderName: String = ""
    @State var isCheckBoxChecked: Bool = false
    @State var stringTextFieldEmpty: Bool = false
    var onTapCancelText:(()->Void)?
    var onTapOkText:(()->Void)?
    @State var isAppeared:Bool = true
    var callBackData: ((String)-> Void)?
    
    var body: some View {
        ZStack{
            Color.blurBackground
                .ignoresSafeArea()
              
            setUp()
                .background(Color(uiColor: .popAlertWhiteBackground))
                .cornerRadius(6.0)
                .frame(width: UIScreen.main.bounds.size.width * 0.74)
                .offset(y: isTextFieldHidden ? 0 : -(UIScreen.main.bounds.size.height * 0.08))
        }
        .onAppear(perform: {
            if isAppeared{
                setCopyColor(colorObject: colorObject)
                isAppeared = false
            }
        })
        .ignoresSafeArea(.keyboard)
    }
}

#Preview {
    AlertPopScreens( colorHexCode: .constant(""), colorOpacity: .constant(1))
}

 //MARK: - Extension for view components
extension AlertPopScreens{
    @ViewBuilder
    func setUp()-> some View{
        VStack(spacing: 16){
            headerContent()
            if !isTextFieldHidden{
                textFieldDescriptionBox()
                    .padding(.vertical, 8)
            }
            else{
                descriptionContent()
            }
            buttonStack()
            if !isCheckBoxFieldHidden{
                checkBoxBtn()
                    .padding(.vertical, 8)
            }
        }
        .padding(.all, 24)
    }
    //header content for pop alert view function
    @ViewBuilder
    func headerContent()-> some View{
        HStack{
            TextLabelBoldFont(stringData: alertHeader ,fontColor: Color(uiColor: .timerWorkoutColor), fontSize: .TSIZE_16 )
            Spacer()
        }
    }
    //description content of alert
    @ViewBuilder
    func descriptionContent()-> some View{
        HStack{
            TextView(fontName: .TREGULAR, fontsSize: .TSIZE_14, fontColor: .timerWorkoutColor, multiLineAlignment: .leading, textTitle: alertDescription)
            Spacer()
        }
    }
    //text field alertBox
    @ViewBuilder
    func textFieldDescriptionBox()-> some View{
        ZStack(alignment: .topLeading){
            RoundedRectangle(cornerRadius: 4)
                .fill(.clear)
                .overlay{
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(stringTextFieldEmpty ? .wrongTextFieldAlert : .noteBoxBorder, lineWidth: 1.0)
                }
            TextView(fontName: .TREGULAR, fontsSize: .TSIZE_12, fontColor: stringTextFieldEmpty ? .wrongTextFieldAlert : .boxFieldText, frameHeight: 16, textTitle: "Folder Name", paddingHorizontal: 4)
                .background(Color(uiColor: .popAlertWhiteBackground))
                .offset(x: 10, y: -8)
            HStack{
                TextField("Input", text: $folderName)
                    .font(.custom("Roboto-Regular", size: 16))
                    .foregroundColor(.fIxedTextField)
                    .offset(x: 14)
                    .frame(maxWidth: .infinity)
                    .textInputAutocapitalization(.words)
                Spacer()
                if stringTextFieldEmpty{
                    Image(.popAlertIcon)
                        .offset(x: -14)
                    Spacer()
                }
              RectangularColorBox(colorHexString: $colorHexCode, colorOpacity: $colorOpacity, colorObject: colorObject)
                    .offset(x: -14)
            }
            .offset(y: 16)
            
        }
        .frame(height: 56)

    }
    //button Stack of goBack and commit changes
    @ViewBuilder
    func buttonStack()-> some View{
        HStack{
            Button(action: {
                       getCopyColor()
                        onTapOkText?()
                        //MARK: - Adding data to core database
                       
            })
            {
                TextLabelBoldFont(stringData: alertOkText, fontColor: Color(uiColor: .thickBorderWidthGradientFirstColor), fontSize: .TSIZE_14)
            }
            Spacer()
            Button(action: {
                if folderName.trimmingCharacters(in: .whitespaces) != ""{
                callBackData?(folderName)
                }
                else{
                    stringTextFieldEmpty = true
                }
            })
            {
                TextLabelBoldFont(stringData: alertCancelText , fontColor: Color(uiColor: .footerBackgroundColor), fontSize: .TSIZE_14)
            }
        }
        
    }
    // Check box btn View return
    @ViewBuilder
    func checkBoxBtn()-> some View{
        HStack(spacing: 8){
            Button(action: {
                isCheckBoxChecked.toggle()
            })
            {
                Image(isCheckBoxChecked ? .stateCheckBtn : .buttonCheckBox)
            }
            TextView(fontName: .TREGULAR, fontsSize: .TSIZE_12, fontColor: .gray, textTitle: "Don’t ask me this again")
            Spacer()
        }
    }
}

///
///New Struct for Bullet point
///Adn for text Alert
///

struct AlertTextPopScreen: View{
    var alertHeader: String = ""
    var alertDescription: String = ""
    var alertLastDescription: String = ""
    var alertCancelText: String = ""
    var alertOkText: String = ""
    var textDescriptionDot: [String] = []
    var descriptionListHidden: Bool = true
    var okayCallBack: (()-> Void)?
    var cancelCallBack: (()-> Void)?
    var body: some View{
        ZStack{
            Color.blurBackground
                .ignoresSafeArea()
              
            setUp()
                .background(Color(uiColor: .popAlertWhiteBackground))
                .cornerRadius(6.0)
                .frame(width: UIScreen.main.bounds.size.width * 0.79)
                .offset(y: -(UIScreen.main.bounds.size.height * 0.08))
        }
    }
}
 //MARK: - for child components
extension AlertTextPopScreen{
    @ViewBuilder
    func setUp()-> some View{
        VStack(spacing: 24){
            headerContent()
            
            descriptionContent()
          
            buttonStack()
           
        }
        .padding(.all, 24)
    }
    //header content for pop alert view function
    @ViewBuilder
    func headerContent()-> some View{
        HStack{
            CustomTextLabelBoldFont(stringData: alertHeader, fontColor: Color(uiColor: .timerWorkoutColor), fontSize: .TSIZE_16 )
            Spacer()
        }
    }
    //description content of alert
    @ViewBuilder
    func descriptionContent()-> some View{
        VStack{
            HStack{
                CustomTextLabelRegualFont(stringData: alertDescription, fontColor: Color(uiColor: .timerWorkoutColor), fontSize: .TSIZE_14 )
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            if !descriptionListHidden{
                ForEach(textDescriptionDot, id: \.self){textDesc in
                    HStack(spacing: 12){
                        Circle()
                            .frame(width: 6)
                        CustomTextLabelRegualFont(stringData: textDesc, fontColor: Color(uiColor: .timerWorkoutColor), fontSize: .TSIZE_14 )
                            .multilineTextAlignment(.leading)
                        Spacer()
                    }
                    .padding(.leading, 12)
                }
                
                CustomTextLabelRegualFont(stringData: alertLastDescription, fontColor: Color(uiColor: .timerWorkoutColor), fontSize: .TSIZE_14 )
                    .multilineTextAlignment(.leading)
            }
        }
    }
    //button Stack of goBack and commit changes
    @ViewBuilder
    func buttonStack()-> some View{
        HStack{
            Button(action: {
          cancelCallBack?()
            })
            {
                CustomTextLabelBoldFont(stringData: alertCancelText, fontColor: Color(uiColor: .thickBorderWidthGradientFirstColor), fontSize: .TSIZE_14)
                
            }
            Spacer()
            Button(action: {
                okayCallBack?()
            })
            {
                CustomTextLabelBoldFont(stringData: alertOkText , fontColor: Color(uiColor: .footerBackgroundColor), fontSize: .TSIZE_14)
            }
        }
        
    }
    
}


extension AlertPopScreens{
    func setCopyColor(colorObject: ColorObject?){
        copyColorObject.colorHexCode = colorObject?.colorHexCode ?? "#000000"
        copyColorObject.colorAlpha = colorObject?.alphaValue
        copyColorObject.colorShadesX = colorObject?.colorShadesX
        copyColorObject.colorShadesY = colorObject?.colorShadesY
        copyColorObject.colorVariantX = colorObject?.colorRgbX
        copyColorObject.colorVariantY = colorObject?.colorRgbY
        copyColorObject.colorOpacityX = colorObject?.colorOpacityX
        copyColorObject.colorOpacityY = colorObject?.colorOpacityY
    }
    
    func getCopyColor(){
        colorObject?.colorHexCode =  copyColorObject.colorHexCode
        colorObject?.alphaValue =  copyColorObject.colorAlpha ?? 1
        colorObject?.colorShadesX = copyColorObject.colorShadesX ?? 0
        colorObject?.colorShadesY =  copyColorObject.colorShadesY ?? 0
        colorObject?.colorRgbX =  copyColorObject.colorVariantX ?? 0
        colorObject?.colorRgbY = copyColorObject.colorVariantY ?? 0
        colorObject?.colorOpacityX = copyColorObject.colorOpacityX ?? 0
        colorObject?.colorOpacityY = copyColorObject.colorOpacityY ?? 0
        CoreDataManager.shared.saveContext()
    }
}



struct AlertTextCsvAlert: View{
    var alertHeader: String = "ERROR: INVALID FILE TYPE"
    var alertDescription: String = "The file you’re uploading appears to have different headings or information than required for this type Timer.\n\nPlease check you’re importing the correct timer (e.g. Interval vs Reaction).\n\nFailing that, check the column headings against the templates available at:"
    var alertCancelText: String = "CANCEL"
    var alertOkText: String = "CHOOSE NEW FILE"
   
    var webModel = WebViewModel(allUrl: .Resoource)
    var linkText: String = "https://www.pbintervals.app/resources"
    @State var isWebView: Bool = false
  
    
    var okayCallBack: (()-> Void)?
    var cancelCallBack: (()-> Void)?
    
    var body: some View{
        ZStack{
            NavigationLink(isActive: $isWebView) {
                HelpWebViewController(model: webModel)
            } label: {
                EmptyView()
            }
            .hidden()
            Color.blurBackground
                .ignoresSafeArea()
              
            setUp()
                .background(Color(uiColor: .popAlertWhiteBackground))
                .cornerRadius(6.0)
                .frame(width: UIScreen.main.bounds.size.width * 0.79)
                .offset(y: -(UIScreen.main.bounds.size.height * 0.08))
        }
    }
}
 //MARK: - for child components
extension AlertTextCsvAlert{
    @ViewBuilder
    func setUp()-> some View{
        VStack(spacing: 24){
            headerContent()
            
            descriptionContent()
          
            buttonStack()
           
        }
        .padding(.all, 24)
    }
    //header content for pop alert view function
    @ViewBuilder
    func headerContent()-> some View{
        HStack{
            CustomTextLabelBoldFont(stringData: alertHeader, fontColor: Color(uiColor: .timerWorkoutColor), fontSize: .TSIZE_16 )
            Spacer()
        }
    }
    //description content of alert
    @ViewBuilder
    func descriptionContent()-> some View{
        VStack(spacing: 0){
            HStack{
                CustomTextLabelRegualFont(stringData: alertDescription, fontColor: Color(uiColor: .timerWorkoutColor), fontSize: .TSIZE_14 )
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            if alertHeader == "ERROR: INVALID FILE TYPE"{
                HStack(alignment: .top){
                    ErrorCustomTextLabelRegualFont(stringData: linkText, fontColor: Color(uiColor: .blue), fontSize: .TSIZE_14 )
                        .onTapGesture {
                            isWebView = true
                        }
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
                .padding(.top, 4)
            }
        }
    }
    //button Stack of goBack and commit changes
    @ViewBuilder
    func buttonStack()-> some View{
        HStack{
            Button(action: {
          cancelCallBack?()
            })
            {
                CustomTextLabelBoldFont(stringData: alertCancelText, fontColor: Color(uiColor: .thickBorderWidthGradientFirstColor), fontSize: .TSIZE_14)
                
            }
            Spacer()
            Button(action: {
                okayCallBack?()
            })
            {
                CustomTextLabelBoldFont(stringData: alertOkText , fontColor: Color(uiColor: .footerBackgroundColor), fontSize: .TSIZE_14)
            }
        }
        
    }
    
}
