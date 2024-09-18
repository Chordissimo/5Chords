//
//  EditChordsAds.swift
//  AmDm AI
//
//  Created by Anton on 19/07/2024.
//

import SwiftUI

struct EditChordsAds: View {
    var appDefaults = AppDefaults()
    @State var replay = false
    @StateObject var model = AdsViewModel()
    @State var slideNumber = 1
    @State var hideLyrics = false

    var body: some View {
        let width: CGFloat = AppDefaults.screenWidth * 0.8

        ZStack(alignment: Alignment(horizontal: .center, vertical: .center)) {
            VStack(alignment: .center) {
                Text("Chord and lyrics recognition is done by AI-backed cutting edge technology. However, sometimes you may want to change some of the chords to make it easier for you to play.")
                    .multilineTextAlignment(.center)
                    .padding(20)
                ZStack {
                    VStack {
                        if slideNumber == 1 || slideNumber == 3 {
                            ChordsAndLyricsAds(width: width, model: model, slideNumber: $slideNumber, hideLyrics: $hideLyrics)
                        } else if slideNumber == 2 {
                            SearchChordsAds(width: width)
                        }
                    }
                    .frame(height: 300)
                    
                    if replay {
                        Color.customDarkGray.opacity(0.7)
                        Button {
                            replay = false
                            replayAnimations()
                        } label: {
                            ZStack {
                                Image(systemName: "goforward")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundStyle(.white)
                                    .frame(width: 70, height: 70)
                                Text("Replay")
                                    .foregroundStyle(.white)
                                    .font(.custom(SOFIA, size: 14))
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                }
                Rectangle()
                    .fill(.customDarkGray)
                    .frame(width: width, height: 60)
            }
            .padding(.horizontal, 20)
        }
        .onAppear {
            replayAnimations()
        }
        .onChange(of: slideNumber) { _, slideNumber in
            if slideNumber == 1 {
                model.lines[1].chords[2].lyrics = "  jingle  "
                model.lines[1].chords[2].chord = "G/E"
            } else if slideNumber == 3 {
                model.lines[1].chords[2].lyrics = "jingle bells "
                model.lines[1].chords[2].chord = "Em"
            }
        }

    }
    
    func replayAnimations() {
//        withAnimation {
        slideNumber = 1
//        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            withAnimation {
                slideNumber = 2
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
                withAnimation {
                    slideNumber = 3
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation {
                        replay = true
                    }
                }
            }
        }
    }
}
