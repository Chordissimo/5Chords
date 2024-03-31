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
    @Binding var text: String
    var style: Int? = 0

    @State private var temporaryText: String
    @FocusState private var isFocused: Bool

    init(text: Binding<String>) {
        self._text = text
        self.temporaryText = text.wrappedValue
    }
    
    init(text: Binding<String>, style: Int) {
        self.style = style
        self._text = text
        self.temporaryText = text.wrappedValue
    }

    var body: some View {
        switch style {
        case EditableTextDisplayStyle.songTitle:
            TextField("", text: $temporaryText, onCommit: { text = temporaryText })
                .foregroundStyle(Color.white)
                .fontWeight(.semibold)
                .font(.system(size: 17))
                .focused($isFocused, equals: true)
                .onTapGesture { isFocused = true }
        default:
            Text("To be added later")
        }
    }
}

#Preview {
    @State var text = "Sample text"
    return ZStack {
        Color.black
        VStack {
            EditableText(text: $text, style: EditableTextDisplayStyle.songTitle)
        }
    }.ignoresSafeArea()
}
