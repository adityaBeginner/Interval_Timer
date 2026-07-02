//
//  ConstantFile.swift
//  TIMER
//
//  Created by Aditya Maroo on 13/08/24.
//

import Foundation
import SwiftUI
var commonPadding: CGFloat = 16
var screenDeviceHeight = UIScreen.main.bounds.size.height
var screenDeviceWidth = UIScreen.main.bounds.size.width
enum TFonts:String,CaseIterable{
    case TBOLD = "SF-Pro-Display-Bold"
     case TLIGHT = "SF-Pro-Display-Light"
    case THEAVY = "SF-Pro-Display-Heavy"
    case TMEDIUM = "SF-Pro-Display-Medium"
    case TREGULAR = "SF-Pro-Display-Regular"
    case TSEMIBOLD = "SF-Pro-Display-Semibold"
    case TThin  = "SF-Pro-Display-Thin"
}


enum TSize:CGFloat{
    case TSIZE_12 = 12
    case TSIZE_13 = 13
    case TSIZE_14 = 14
    case TSIZE_16 = 16
    case TSIZE_18 = 18
    case TSIZE_20 = 20
    case TSIZE_22 = 22
    case TSIZE_24 = 24
    case TSIZE_34 = 34
    case TSIZE_36 = 36
    case TSIZE_38 = 38
    case TSIZE_40 = 40
    case TSIZE_48 = 48
    
    //Potrait Mode
    static var TSIZE_PORTRAIT: CGFloat {
           return screenDeviceWidth * 0.3721
       }
    static var TSIZE_LANDSCAPE: CGFloat {
           return screenDeviceHeight * 0.3721
       }
}

extension UIColor{
    static let textHeaderColor = #colorLiteral(red: 0.168627451, green: 0.168627451, blue: 0.168627451, alpha: 1)
    static let timerWorkoutColor = #colorLiteral(red: 0.1254901961, green: 0.1254901961, blue: 0.1254901961, alpha: 1)
    static let workoutExerciseColor = #colorLiteral(red: 0.08235294118, green: 0.08235294118, blue: 0.08235294118, alpha: 1)
    static let lineDottedColor = #colorLiteral(red: 0.1254901961, green: 0.1254901961, blue: 0.1254901961, alpha: 0.15)
    static let footerBackgroundColor = #colorLiteral(red: 0.537254902, green: 0.8117647059, blue: 0.9411764706, alpha: 1)
    static let footerAddBtnBackgroungColor = #colorLiteral(red: 0.9843137255, green: 0.8862745098, blue: 0.8156862745, alpha: 1)
    static let cancelSkipBtnColor = #colorLiteral(red: 0.7529411765, green: 0.7529411765, blue: 0.7529411765, alpha: 1)
    static let popBackgroundColor = #colorLiteral(red: 0.1254901961, green: 0.1254901961, blue: 0.1254901961, alpha: 0.2)
    static let lineBorderWidthColor = #colorLiteral(red: 0.1254901961, green: 0.1254901961, blue: 0.1254901961, alpha: 0.75)
    static let thickBorderWidthGradientFirstColor = #colorLiteral(red: 0.7529411765, green: 0.7529411765, blue: 0.7529411765, alpha: 1)
    static let thickBorderWidthGradientSecondColor = #colorLiteral(red: 0.8274509804, green: 0.8274509804, blue: 0.8274509804, alpha: 1)
    static let thickBorderWidthGradientThirdColor = #colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.9490196078, alpha: 1)
    static let noteHeadingContentColor = #colorLiteral(red: 0.2862745098, green: 0.2705882353, blue: 0.3098039216, alpha: 1)
    static let switchBackgroundColor = #colorLiteral(red: 0.8797428012, green: 0.8797428012, blue: 0.8797428012, alpha: 1)
    static let switchCircleBackgroundColor = #colorLiteral(red: 1, green: 0.9960784314, blue: 0.9882352941, alpha: 1)
    static let popAlertWhiteBackground = #colorLiteral(red: 1, green: 0.9921568627, blue: 0.9882352941, alpha: 1)
    static let playScreenFontColor = #colorLiteral(red: 1, green: 0.9960784314, blue: 0.9882352941, alpha: 1)
    static let playScreenBlackColorFont  = #colorLiteral(red: 0.1254901961, green: 0.1254901961, blue: 0.1254901961, alpha: 1)
    static let defaultFolderTimerReactionColor = #colorLiteral(red: 0.537254902, green: 0.8117647059, blue: 0.9411764706, alpha: 1)
}

enum PopOffset: CGFloat{
    case bottom = -110
    case top = 0
    
}
enum TextFieldType: String{
    case IntervalDuration
    case RestBetweenInterval
    case RestBetweenRounds
    case SessionLastTime
}
enum MinMaxTime: String{
    case MinTime
    case MaxTime
}
struct DateFormater{
    static let shared = DateFormater()
    func dateToString(){
        
    }
   
}
enum CheckBoxState: String{
    case CheckBoxCheck
    case checkBoxUnCheck
}
enum TrianglePosition: Double{
    case leftSideTriangleX = -131
    case rightSideTriangle = 131
    case topSideTriangle = -79
    case dowSideTriangle = 79
}

enum PopHandlingScreens: String{
    case WorkoutScreen
    case IntervalPotrait
    case ReactionTimePotrait
}


enum SettingScreen: String{
    case AudioSetting
    case AppSetting
}

enum TimerReactionMessageState: String{
    case Normal
    case Edit
}

struct ColorPropertyStructure{
    var colorHexCode: String?
    var colorAlpha: Double?
    var colorShadesX: Double?
    var colorShadesY: Double?
    var colorVariantX: Double?
    var colorVariantY: Double?
    var colorOpacityX: Double?
    var colorOpacityY: Double?
    
}

//    func changingValueBreakField(textFieldType: TextFieldType){
//        switch textFieldType{
//
//        case .IntervalDuration:
//            break
//        case .RestBetweenInterval:
//            if restBetweenInterval.minTime.count == 1 || restBetweenInterval.random{
//                restBetweenInterval.minTime = "0" + restBetweenInterval.minTime + ":" + "00"
//                if restBetweenInterval.maxTime.count == 1 && restBetweenInterval.random {
//                    restBetweenInterval.maxTime = "0" + restBetweenInterval.maxTime + ":" + "00"
//                }
//            }
//            else if restBetweenInterval.minTime.count == 2 || restBetweenInterval.random{
//                restBetweenInterval.minTime += ":" + "00"
//                if restBetweenInterval.maxTime.count == 2 && restBetweenInterval.random{
//                    restBetweenInterval.maxTime += ":" + "00"
//                }
//            }
//                else if restBetweenInterval.minTime.count == 4 || restBetweenInterval.random{
//                    restBetweenInterval.minTime = restBetweenInterval.minTime.prefix(3) + "0" + restBetweenInterval.minTime.suffix(1)
//                    if restBetweenInterval.maxTime.count == 4 && restBetweenInterval.random{
//                        restBetweenInterval.maxTime = restBetweenInterval.maxTime.prefix(3) + "0" + restBetweenInterval.maxTime.suffix(1)
//                    }
//
//            }
//            break
//        case .RestBetweenRounds:
//            if restBetweenRounds.minTime.count == 1 || restBetweenRounds.random{
//                restBetweenRounds.minTime = "0" + restBetweenRounds.minTime + ":" + "00"
//                if restBetweenRounds.maxTime.count == 1 && restBetweenRounds.random{
//                    restBetweenRounds.maxTime = "0" + restBetweenRounds.maxTime + ":" + "00"
//                }
//            }
//            else if restBetweenRounds.minTime.count == 2 || restBetweenRounds.random{
//                restBetweenRounds.minTime += ":" + "00"
//                if restBetweenRounds.maxTime.count == 1 && restBetweenRounds.random{
//                    restBetweenRounds.maxTime += ":" + "00"
//                }
//            }
//                else if restBetweenRounds.minTime.count == 4 || restBetweenRounds.random{
//                    restBetweenRounds.minTime = restBetweenRounds.minTime.prefix(3) + "0" + restBetweenRounds.minTime.suffix(1)
//                    if restBetweenRounds.maxTime.count == 1 && restBetweenRounds.random{
//                        restBetweenRounds.maxTime = restBetweenRounds.maxTime.prefix(3) + "0" + restBetweenRounds.maxTime.suffix(1)
//                    }
//
//            }
//            break
//        }
//    }
