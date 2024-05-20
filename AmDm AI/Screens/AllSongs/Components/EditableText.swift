//
//  EditableText.swift
//  AmDm AI
//
//  Created by Anton on 30/03/2024.
//

import SwiftUI
import Combine

enum EditableTextDisplayStyle {
    static let songTitle = 0
    static let other = 1 //to be added later
}


struct EditableText: View  {
    @Binding var sourceText: String
    var isEditable: Bool? = true
    var style: Int? = 0
    
    @State private var temporaryText: String
//    @Binding var inFocus: Field?
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
                    .font(.system(size: 18))
                    .onTapGesture { isFocused = true }
                    .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { obj in
                        // Click to select all the text.
                        if let textField = obj.object as? UITextField {
                            textField.selectAll(nil)
                        }
                    }
                    .focused($isFocused)
//                    .onChange(of: isFocused) { _ in
//                        inFocus = .fieldId(i)     // << report selection outside
//                    }
            }
        } else {
            if style == EditableTextDisplayStyle.songTitle {
                Text(sourceText)
                    .foregroundStyle(Color.white)
                    .fontWeight(.semibold)
                    .font(.system(size: 18))
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
