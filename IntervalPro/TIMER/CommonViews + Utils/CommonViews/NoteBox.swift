//
//  NoteBox.swift
//  TIMER
//
//  Created by Aditya Maroo on 04/09/24.
//

import SwiftUI

struct NoteBox: View {
    @Binding var noteStringData: String
    @FocusState private var isFocused: Bool
    var body: some View {
       noteBox()
    }
}

#Preview {
    NoteBox(noteStringData: .constant(""))
}
extension NoteBox{
    @ViewBuilder
    func noteBox()-> some View{
        ZStack(alignment: .topLeading) {
            Rectangle()
                .fill(Color.clear)
                .frame(height: 204)
                .cornerRadius(4)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(isFocused ? Color(uiColor: .footerBackgroundColor) : Color.noteBoxBorder, lineWidth: 1)
                    
                )
            
            TextLabelLightFont(stringData: "Notes")
                .padding(.horizontal, 4)
                .background(Color.background)
                .cornerRadius(2)
                .offset(x: 8, y: -8)
            
            if #available(iOS 16, *){
                TextEditor(text: isFocused || noteStringData.trimmingCharacters(in: .whitespacesAndNewlines) != "" ?  $noteStringData : .constant("Notes about the timer, what it’s used for etc."))
                    .font(.system(size: 14, weight: Font.Weight.light))
                    .foregroundStyle(Color(uiColor: .textFontChild))
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                    .focused($isFocused)
                    .frame(height: 202)
            }
            else{
                TextEditor(text: isFocused || noteStringData.trimmingCharacters(in: .whitespacesAndNewlines) != "" ?  $noteStringData : .constant("Notes about the timer, what it’s used for etc."))
                    .font(.system(size: 14, weight: Font.Weight.light))
                    .foregroundStyle(Color(uiColor: .textFontChild))
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                    .focused($isFocused)
                    .frame(height: 202)
            }
         
        }
        .frame(height: 204, alignment: .topLeading)
    }
}
