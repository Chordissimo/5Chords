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
    @State var showTranspositionAds = false
    @State var showEditChordsAds = false
    @State var showHideLyricsAds = false
    var onChangeValue: (_ transposeUp: Bool) -> Void
    var onReset: (_ reset: Bool) -> Void
    @AppStorage("isLimited") var isLimited: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            if isLimited {
                Spacer()
                VStack {
                    UpgradeButton(content: {
                        VStack {
                            Text("Transpose chords")
                                .font(.system(size: 20))
                                .foregroundStyle(.black)
                                .fontWeight(.semibold)
                            Text("How it works?")
                                .font(.system(size: 16))
                                .fontWeight(.semibold)
                                .foregroundStyle(.gray10)
                        }
                    }, action: {
                        showTranspositionAds = true
                    })
                    
                    UpgradeButton(content: {
                        VStack {
                            Text("Edit chords")
                                .font(.system(size: 20))
                                .foregroundStyle(.black)
                                .fontWeight(.semibold)
                            Text("How it works?")
                                .font(.system(size: 16))
                                .fontWeight(.semibold)
                                .foregroundStyle(.gray10)
                        }
                    }, action: {
                        showEditChordsAds = true
                    })

                    UpgradeButton(content: {
                        VStack {
                            Text("Show or hide lyrics")
                                .font(.system(size: 20))
                                .foregroundStyle(.black)
                                .fontWeight(.semibold)
                            Text("How it works?")
                                .font(.system(size: 16))
                                .fontWeight(.semibold)
                                .foregroundStyle(.gray10)
                        }
                    }, action: {
                        showHideLyricsAds = true
                    })
                }
            } else {
                VStack {
                    Toggle("Hide lyrics", isOn: $hideLyrics)
                        .font(.system(size: 16))
                        .foregroundStyle(.white)
                        .fontWeight(.semibold)
                }
                .padding(.top, 30)
                .frame(width: 150, height: 80)

                Divider()
                HStack(spacing: 0) {
                    VStack {
                        Button {
                            onChangeValue(true)
                        } label: {
                            Image(systemName: "arrow.up")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 25, height: 25)
                                .foregroundColor(.white)
                        }
                        .disabled(isLimited)
                        .frame(width: 80, height: 40)
                        .background(isLimited ? .progressCircle : .gray30, in: UnevenRoundedRectangle(topLeadingRadius: 16, bottomLeadingRadius: 16))
                    }
                    
                    Button {
                        showTranspositionAds = true
                    } label: {
                        VStack(spacing: 3) {
                            Text("Transpose chords")
                                .font(.system(size: 16))
                                .foregroundStyle(.white)
                                .fontWeight(.semibold)
                            HStack(spacing: 3) {
                                Text("How it works")
                                    .font(.system(size: 14))
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.gray40)
                                Image(systemName: "questionmark.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.gray40)

                            }
                        }
                    }
                    .frame(height: 40)
                    .padding(.horizontal, 20)
                    
                    VStack {
                        Button {
                            onChangeValue(false)
                        } label: {
                            Image(systemName: "arrow.down")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width:25, height: 25)
                                .foregroundColor(.white)
                        }
                    }
                    .disabled(isLimited)
                    .frame(width: 80, height: 40)
                    .background(.gray30, in: UnevenRoundedRectangle(bottomTrailingRadius: 16, topTrailingRadius: 16))
                }
                .frame(height: 80)
            }
            
            if !isLimited {
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
        }
        .padding(.horizontal, 20)
        .popover(isPresented: $showTranspositionAds) {
            AdsView(showAds: $showTranspositionAds, title: "CHORD TRANSPOSITION", content: {
                TranspositionAds()
            }) {
//                showPaywall = true
            }
        }
        .popover(isPresented: $showEditChordsAds) {
            AdsView(showAds: $showEditChordsAds, title: "EDITING CHORDS", content: {
                EditChordsAds()
            }) {
//                showPaywall = true
            }
        }
        .popover(isPresented: $showHideLyricsAds) {
            AdsView(showAds: $showHideLyricsAds, title: "SHOWING AND HIDING LYRICS", content: {
                HideLyricsAds()
            }) {
//                showPaywall = true
            }
        }
    }
}
