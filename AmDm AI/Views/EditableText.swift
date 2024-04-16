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
        self.isEditable = isEditable!
    }
    
    init(text: Binding<String>, style: Int, isEditable: Bool?) {
        self.style = style
        self._sourceText = text
        self.temporaryText = text.wrappedValue
        self.isEditable = isEditable!
    }

    var body: some View {
        if isEditable ?? true {
            switch style {
            case EditableTextDisplayStyle.songTitle:
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
                    .focused($isFocused, equals: true)
                    .onTapGesture { isFocused = true }
            default:
                Text("To be added later")
            }
        } else {
            switch style {
            case EditableTextDisplayStyle.songTitle:
                Text(sourceText)
                    .foregroundStyle(Color.white)
                    .fontWeight(.semibold)
                    .font(.system(size: 17))
            default:
                Text("To be added later")
            }
        }
    }
}

#Preview {
    @State var text = "Sample text"
    return ZStack {
        Color.black
        VStack {
            EditableText(text: $text, style: EditableTextDisplayStyle.songTitle, isEditable: false)
        }
    }.ignoresSafeArea()
}
