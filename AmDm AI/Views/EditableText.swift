//
//  EditableText.swift
//  AmDm AI
//
//  Created by Anton on 30/03/2024.
//

import SwiftUI

enum EditableTextDisplayStyle {
    static let songTitle = 0
    static let other = 1 //to be added later
}


struct EditableText: View  {
    @Binding var sourceText: String
    var isEditable: Bool? = true
    var style: Int? = 0

    @State private var temporaryText: String
    @FocusState private var isFocused: Bool

    init(text: Binding<String>, isEditable: Bool?) {
        self._sourceText = text
        self.temporaryText = text.wrappedValue
        self.isEditable = isEditable ?? true
    }
    
    init(text: Binding<String>, style: Int, isEditable: Bool?) {
        self.style = style
        self._sourceText = text
        self.temporaryText = text.wrappedValue
        self.isEditable = isEditable ?? true
    }

    var body: some View {
        if isEditable ?? true {
            if style == EditableTextDisplayStyle.songTitle {
                TextField("", text: $temporaryText)
                    .onSubmit {
                        if temporaryText == "" {
                            temporaryText = sourceText
                        } else {
                            sourceText = temporaryText
                        }
                    }
                    .foregroundStyle(Color.white)
                    .fontWeight(.semibold)
                    .font(.system(size: 17))
                    .onTapGesture { isFocused = true }
            }
        } else {
            if style == EditableTextDisplayStyle.songTitle {
                Text(sourceText)
                    .foregroundStyle(Color.white)
                    .fontWeight(.semibold)
                    .font(.system(size: 17))
            }
        }
    }
}

#Preview {
    @State var text = "Sample text"
    return ZStack {
        Color.black
        VStack {
            EditableText(text: $text, style: EditableTextDisplayStyle.songTitle, isEditable: true)
        }
    }.ignoresSafeArea()
}
