//
//  TextLabelFont.swift
//  TIMER
//
//  Created by Aditya Maroo on 30/09/24.
//

import SwiftUI
//Syste, Commom Fonts
struct TextLabelBoldFont: View {
    var stringData: String = ""
    var fontColor: Color = .textFontChild
    var fontSize: TSize = .TSIZE_14
    var body: some View {
        Text(stringData)
            .font(.system(size: fontSize.rawValue))
            .fontWeight(Font.Weight.bold)
            .foregroundStyle(fontColor)
    }
}

struct TextLabelRegularFont: View {
    var stringData: String = ""
    var fontColor: Color = .textFontChild
    var fontSize: TSize = .TSIZE_16
    var customFontSize: CGFloat?
    var isCustomFont: Bool = false
    var body: some View {
        Text(stringData)
            .font(.system(size: isCustomFont ? customFontSize ?? 145 : fontSize.rawValue))
            .fontWeight(Font.Weight.regular)
            .foregroundStyle(fontColor)
    }
}

struct TextLabelRegularMonoSpacedFont: View {
    var stringData: String = ""
    var fontColor: Color = .textFontChild
    var fontSize: TSize = .TSIZE_16
    var customFontSize: CGFloat?
    var isCustomFont: Bool = false
    var body: some View {
        Text(stringData)
            .font(.system(size: isCustomFont ? customFontSize ?? 145 : fontSize.rawValue))
            .fontWeight(Font.Weight.regular)
            .multilineTextAlignment(.leading)
            .minimumScaleFactor(0.8)
            .foregroundStyle(fontColor)
    }
}

struct TextLabelMeduimFont: View {
    var stringData: String = ""
    var fontColor: Color = .textFontChild
    var fontSize: TSize = .TSIZE_16
    var body: some View {
        Text(stringData)
           
            //.font(.custom("Medium", size: fontSize.rawValue))
            .font(.system(size: fontSize.rawValue))
            .fontWeight(Font.Weight.medium)
            .foregroundStyle(fontColor)
           
    }
}
struct TextLabelThinFont: View {
    var stringData: String = ""
    var fontColor: Color = .textFontChild
    var fontSize: TSize = .TSIZE_14
    var body: some View {
        Text(stringData)
            //.font(.custom("Thin", size: fontSize.rawValue))
            .font(.system(size: fontSize.rawValue))
            .fontWeight(Font.Weight.thin)
            .foregroundStyle(fontColor)
    }
}

struct TextLabelSemiBoldFont: View {
    var stringData: String = ""
    var fontColor: Color = .textFontChild
    var fontSize: TSize = .TSIZE_14
    var body: some View {
        Text(stringData)
          //  .font(.custom("SemiBold", size: fontSize.rawValue))
            .font(.system(size: fontSize.rawValue))
            .fontWeight(Font.Weight.semibold)
            .foregroundStyle(fontColor)
    }
}

struct TextLabelLightFont: View {
    var stringData: String = ""
    var fontColor: Color = .textFontChild
    var fontSize: TSize = .TSIZE_14
    var body: some View {
        Text(stringData)
            //.font(.custom("Thin", size: fontSize.rawValue))
            .font(.system(size: fontSize.rawValue))
            .fontWeight(Font.Weight.light)
            .foregroundStyle(fontColor)
    }
    
}
struct CustomTextLabelFont: View {
    var stringData: String = ""
    var fontColor: Color = .textFontChild
    var fontSize: TSize = .TSIZE_16
    var fontWeight: Font.Weight = .regular
    var body: some View {
        Text(stringData)
            //.font(.custom("Thin", size: fontSize.rawValue))
            .font(.system(size: fontSize.rawValue))
            .fontWeight(fontWeight)
            .foregroundStyle(fontColor)
    }
    
}

//Roberto Fonts or Custom Fonts
///Bold Font
struct CustomTextLabelBoldFont: View {
    var stringData: String = ""
    var fontColor: Color = .textFontChild
    var fontSize: TSize = .TSIZE_14
    var body: some View {
        Text(stringData)
            .font(.custom("Roboto-Bold", size: fontSize.rawValue))
            .foregroundStyle(fontColor)
    }
}

///Regular Custom
struct CustomTextLabelRegualFont: View {
    var stringData: String = ""
    var fontColor: Color = .textFontChild
    var fontSize: TSize = .TSIZE_14
    var body: some View {
        Text(stringData)
            .font(.custom("Roboto-Regular", size: fontSize.rawValue))
            .lineSpacing(5)
            .foregroundStyle(fontColor)
    }
}

///Errror Alert Custom Text labe
struct ErrorCustomTextLabelRegualFont: View {
    var stringData: String = ""
    var fontColor: Color = .textFontChild
    var fontSize: TSize = .TSIZE_14
    var body: some View {
        Text(stringData)
            .font(.custom("Roboto-Regular", size: fontSize.rawValue))
            .lineSpacing(4)
            .foregroundStyle(fontColor)
    }
}


 //MARK: - Attributed Text for milliSeconds Handling
struct MilliSecondsAttributeTxt: View {
    var timeString: String
    var fontColor: Color = .textFontChild
    var fontSize: TSize = .TSIZE_16
    var fontSizeMillseconds: TSize = .TSIZE_13
    var fontWeight: Font.Weight = .medium

    var body: some View {
        timeText(for: timeString)
            .foregroundStyle(fontColor)
    }

    // Internal function for attributed time styling
    private func timeText(for time: String) -> Text {
        let components = time.split(separator: ":")

        guard components.count == 3 else {
            return Text(time).font(.system(size: fontSize.rawValue))
                .fontWeight(fontWeight)// fallback
        }

        let minutes = String(components[0])
        let seconds = String(components[1])
        let milliseconds = String(components[2])

        return Text("\(minutes):\(seconds):")
            .font(.system(size: fontSize.rawValue))
            .fontWeight(fontWeight)
        + Text(milliseconds)
            .font(.system(size: fontSizeMillseconds.rawValue))
            .fontWeight(fontWeight)
    }
}

struct SessionMilliSecondsAttributeTxt: View {
    var timeString: String
    var fontColor: Color = .textFontChild
    var fontSize: TSize = .TSIZE_16
    var fontSizeMillseconds: TSize = .TSIZE_13
    var fontWeight: Font.Weight = .medium

    var body: some View {
        timeText(for: timeString)
            .foregroundStyle(fontColor)
    }

    // Internal function for attributed time styling
    private func timeText(for time: String) -> Text {
        let components = time.split(separator: ":")

        guard components.count == 4 else {
            return Text(time).font(.system(size: fontSize.rawValue))
                .fontWeight(fontWeight)// fallback
        }

        let hours = String(components[0])
        let minutes = String(components[1])
        let seconds = String(components[2])
        let milliseconds = String(components[3])

        return Text("\(hours):\(minutes):\(seconds):")
            .font(.system(size: fontSize.rawValue))
            .fontWeight(Font.Weight.medium)
        + Text(milliseconds)
            .font(.system(size: fontSizeMillseconds.rawValue))
            .fontWeight(Font.Weight.medium)
    }
    
}


//Interval Timer Play Screen
struct IntervalMilliSecondsAttributeTxt: View {
    var timeString: String
    var fontColor: Color = .textFontChild
    var fontSize: CGFloat = 16
    
    var body: some View {
        timeText(for: timeString)
            .foregroundStyle(fontColor)
    }
    
    // Internal function for attributed time styling
    private func timeText(for time: String) -> Text {
        let components = time.split(separator: ":")
        
        guard components.count == 3 else {
            return Text(time).font(.system(size: fontSize))
                .fontWeight(Font.Weight.regular)// fallback
        }
        
        let minutes = String(components[0])
        let seconds = String(components[1])
        let milliseconds = String(components[2])
        
        return Text("\(minutes):\(seconds)")
            .font(.system(size: fontSize))
            .fontWeight(Font.Weight.regular)
            .monospacedDigit() // Ensures stable character width
        + Text("\(milliseconds)")
            .font(.system(size: fontSize/4))
            .fontWeight(Font.Weight.regular)
            .monospacedDigit() // Prevents jittering of milliseconds
    }
}

///Handling for text for random millseconds in smaller size
struct AttributedTimerTextMilliSeconds: View {
    var timeString: String
    var fontColor: Color = .textFontChild
    var fontSize: TSize = .TSIZE_14  // Default font size

    var body: some View {
        formatAttributedText(for: timeString)
            .foregroundStyle(fontColor)
    }

    private func formatAttributedText(for text: String) -> Text {
        let nsText = text as NSString
        let fullRange = NSRange(location: 0, length: nsText.length)
        
        // 1. Find all ranges inside parentheses
        let bracketPattern = #"\([^\)]+\)"#
        let bracketRegex = try? NSRegularExpression(pattern: bracketPattern)
        let bracketMatches = bracketRegex?.matches(in: text, range: fullRange) ?? []
        let bracketRanges = bracketMatches.map { $0.range }

        // 2. Find 2-digit numbers at the end or before )/space/dash
        let milliPattern = #"\d{2}(?=$|[\)\s-])"#
        let milliRegex = try? NSRegularExpression(pattern: milliPattern)
        let milliMatches = milliRegex?.matches(in: text, range: fullRange) ?? []

        var attributedText = Text("")
        var lastIndex = 0

        for match in milliMatches {
            let matchRange = match.range
            let isInsideBracket = bracketRanges.contains { NSIntersectionRange($0, matchRange).length > 0 }

            let beforeMatch = nsText.substring(with: NSRange(location: lastIndex, length: matchRange.location - lastIndex))
            attributedText = attributedText + Text(beforeMatch).font(.system(size: fontSize.rawValue, weight: .light))

            let matchedText = nsText.substring(with: matchRange)
            if isInsideBracket {
                // Keep regular size
                attributedText = attributedText + Text(matchedText).font(.system(size: fontSize.rawValue, weight: .light))
            } else {
                // Shrink
                attributedText = attributedText + Text(matchedText).font(.system(size: fontSize.rawValue - 2, weight: .light))
            }

            lastIndex = matchRange.location + matchRange.length
        }

        let remainingText = nsText.substring(from: lastIndex)
        attributedText = attributedText + Text(remainingText).font(.system(size: fontSize.rawValue, weight: .light))

        return attributedText
    }
}


//struct AttributedTimerTextMilliSeconds: View {
//    var timeString: String
//    var fontColor: Color = .textFontChild
//    var fontSize: TSize = .TSIZE_14  // Default font size
//
//    var body: some View {
//        formatAttributedText(for: timeString)
//            .foregroundStyle(fontColor)
//    }
//    
//    /// Function to format text with milliseconds being smaller
//    private func formatAttributedText(for text: String) -> Text {
//        //let pattern = #"(\d{2})(?=$|[\)\s-])"# For milliseconds handling
//        let pattern = #"(\d{2})(?=$|[\)\s-])"#  // Matches milliseconds (2-digit numbers at the end or before a closing parenthesis, space, or dash)
//        let regex = try? NSRegularExpression(pattern: pattern)
//        let nsText = text as NSString
//        let matches = regex?.matches(in: text, range: NSRange(location: 0, length: nsText.length)) ?? []
//        
//        var attributedText = Text("")
//        var lastIndex = 0
//
//        for match in matches {
//            let range = match.range
//            let beforeMatch = nsText.substring(with: NSRange(location: lastIndex, length: range.location - lastIndex))
//            let matchedText = nsText.substring(with: range)
//
//            attributedText = attributedText +
//                Text(beforeMatch)
//                .font(.system(size: fontSize.rawValue, weight: .light)) + // Regular text
//                Text(matchedText)
//                .font(.system(size: fontSize.rawValue - 2, weight: .light)) // Smaller font for milliseconds
//
//            lastIndex = range.location + range.length
//        }
//        
//        let remainingText = nsText.substring(from: lastIndex)
//        return attributedText + Text(remainingText).font(.system(size: fontSize.rawValue, weight: .light))
//    }
//}
