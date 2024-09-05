//
//  OptionsView.swift
//  AmDm AI
//
//  Created by Anton on 03/07/2024.
//

import SwiftUI

struct OptionsView: View {
    @ObservedObject var songsList: SongsList
    @Binding var hideLyrics: Bool
    @Binding var showOptions: Bool
    @State var isAlertPresented = false
    @State var showTranspositionAds = false
    @State var showEditChordsAds = false
    @State var showHideLyricsAds = false
    var onChangeValue: (_ transposeUp: Bool) -> Void
    var onReset: (_ reset: Bool) -> Void
    @State var showPaywall = false
    @State var showIsLimited: Bool = AppDefaults.isLimited

    var body: some View {
        VStack(spacing: 0) {
            if showIsLimited {
                Spacer()
                VStack {
                    UpgradeButton(rightIconName: "arrow.up.arrow.down", content: {
                        VStack {
                            Text("Transpose chords")
                                .font(.system(size: 20))
                                .foregroundStyle(.black)
                                .fontWeight(.semibold)
                        }
                    }, action: {
                        showTranspositionAds = true
                    })
                    
                    UpgradeButton(rightIconName: "square.and.pencil", content: {
                        VStack {
                            Text("Edit chords")
                                .font(.system(size: 20))
                                .foregroundStyle(.black)
                                .fontWeight(.semibold)
                        }
                    }, action: {
                        showEditChordsAds = true
                    })

                    UpgradeButton(rightIconName: "eye.slash.fill", content: {
                        VStack {
                            Text("Show or hide lyrics")
                                .font(.system(size: 20))
                                .foregroundStyle(.black)
                                .fontWeight(.semibold)
                        }
                    }, action: {
                        showHideLyricsAds = true
                    })
                }
            } else {
                Divider()
                    .padding(.top, 30)
                HStack {
                    Text("Hide lyrics")
                        .font(.system(size: 16))
                        .foregroundStyle(.white)
                        .fontWeight(.semibold)
                    Toggle("",isOn: $hideLyrics)
                        .labelsHidden()
                }
                .frame(width: 150, height: 60)

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
                        .disabled(showIsLimited)
                        .frame(width: 80, height: 40)
                        .background(.gray30, in: UnevenRoundedRectangle(topLeadingRadius: 16, bottomLeadingRadius: 16))
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
                    .disabled(showIsLimited)
                    .frame(width: 80, height: 40)
                    .background(.gray30, in: UnevenRoundedRectangle(bottomTrailingRadius: 16, topTrailingRadius: 16))
                }
                .frame(height: 60)
            }
            
            if !showIsLimited {
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
                .frame(height: 60)
                Spacer()
            }
        }
        .padding(.horizontal, 20)
        .onAppear {
            showIsLimited = AppDefaults.isLimited
        }
        .popover(isPresented: $showTranspositionAds) {
            AdsView(showAds: $showTranspositionAds, showPaywall: $showPaywall, title: "CHORD TRANSPOSITION", content: {
                TranspositionAds()
            })
        }
        .popover(isPresented: $showEditChordsAds) {
            AdsView(showAds: $showEditChordsAds, showPaywall: $showPaywall, title: "EDITING CHORDS", content: {
                EditChordsAds()
            }) 
        }
        .popover(isPresented: $showHideLyricsAds) {
            AdsView(showAds: $showHideLyricsAds, showPaywall: $showPaywall, title: "SHOWING\nAND HIDING LYRICS", content: {
                HideLyricsAds()
            })
        }
        .fullScreenCover(isPresented: $showPaywall) {
            Paywall(showPaywall: $showPaywall) {
                if showIsLimited && !AppDefaults.isLimited {
                    self.songsList.rebuildTimeframes()
                    showIsLimited = AppDefaults.isLimited
                    showOptions = false
                }
            }
        }
    }
}
