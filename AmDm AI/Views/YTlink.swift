//
//  YTlink.swift
//  AmDm AI
//
//  Created by Anton on 30/03/2024.
//

import SwiftUI

struct YTlink: View {
    @ObservedObject var songsList: SongsList
    @State private var temporaryText: String = ""
    @FocusState private var isFocused: Bool
    private var placeholder = "Paste a Youtube link here"

    init(songsList: ObservedObject<SongsList>) {
        self._songsList = songsList
    }
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .trailing, vertical: .center)) {
            TextField("", text: $temporaryText, prompt: Text(placeholder).foregroundStyle(Color.customGray1))
                .disableAutocorrection(true)
                .focused($isFocused, equals: true)
                .onSubmit { Submit() }
                .onTapGesture {
                    isFocused = true
                }
                .textFieldStyle(CustomTextFieldStyle())
            Button {
                Submit()
            } label: {
                Image(systemName: "arrow.turn.down.left")
                    .foregroundColor(.purple)
                    .padding(.trailing,10)
                    .opacity(temporaryText.isEmpty ? 0 : 1)
            }
        }
    }
    
    private func Submit() {
//        text = temporaryText
        temporaryText = ""
        isFocused = false
        songsList.add(duration: TimeInterval(63))
    }
}

#Preview {
    @ObservedObject var songsList = SongsList()
    return ZStack {
        Color.black
        YTlink(songsList: _songsList)
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .foregroundStyle(Color.customGray1)
            .font(.system(size: 15))
            .padding(EdgeInsets(top: 5, leading: 55, bottom: 5, trailing: 15))
            .background(Color.customDarkGray)
            .cornerRadius(10)
            .frame(height: 20)
            .overlay(
                HStack {
                    Image("youtube.logo")
                        .resizable()
                        .frame(width: 28, height: 20)
                        .aspectRatio(contentMode: .fit)
                        .padding(EdgeInsets(top: 5, leading: 15, bottom: 5, trailing: 15))
                    Spacer()
                }
            )
    }
}
