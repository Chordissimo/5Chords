//
//  OptionsView.swift
//  AmDm AI
//
//  Created by Anton on 03/07/2024.
//

import SwiftUI

struct OptionsView: View {
    @Binding var hideLyrics: Bool
    @State var isAlertPresented = false
    @State var showAds = false
    var onChangeValue: (_ transposeUp: Bool) -> Void
    var onReset: (_ reset: Bool) -> Void

    var body: some View {
        VStack(spacing: 0) {
            
            VStack {
                Toggle("Hide lyrics:", isOn: $hideLyrics)
            }
            .padding(.top, 30)
            .frame(width: 250, height: 80)
            Divider()

            HStack {
                Button {
                    onChangeValue(true)
                } label: {
                    Image(systemName: "arrow.up")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.white)
                        .frame(width: 30, height: 30)
                        .background(.gray30, in: Capsule())
                }
                
                VStack {
                    Text("Transpose chords")
                    Button {
                        showAds = true
                    } label: {
                        Text("How it works?")
                    }
                }
                .padding(.horizontal, 30)
                
                Button {
                    onChangeValue(false)
                } label: {
                    Image(systemName: "arrow.down")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.white)
                        .frame(width: 30, height: 30)
                        .background(.gray30, in: Capsule())
                }
            }
            .frame(height: 80)

            Divider()
            
            VStack {
                Button {
                    isAlertPresented = true
                } label: {
                    Text("Reset changes")
                }
                .alert("Warning", isPresented: $isAlertPresented) {
                    Button {
                        isAlertPresented = false
                        onReset(true)
                    } label: {
                        Text("Ok")
                    }
                    Button {
                        isAlertPresented = false
                    } label: {
                        Text("Cancel")
                    }
                } message: {
                    Text("All changes made to chords and lyrics will be reset to originally recognized values.\n\nDo you want to continue?")
                }
            }
            .frame(height: 80)
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .popover(isPresented: $showAds) {
            TranspositionAds(showAds: $showAds)
        }
    }
}

struct TranspositionAds: View {
    @Binding var showAds: Bool
    var body: some View {
        VStack {
            Button {
                showAds = false
            } label: {
                Text("Close")
            }
            Text("Chords transposition")
        }
    }
}
