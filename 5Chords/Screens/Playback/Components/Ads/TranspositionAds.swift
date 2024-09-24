//
//  TranspositionAds.swift
//  AmDm AI
//
//  Created by Anton on 21/07/2024.
//

import SwiftUI

struct TranspositionAds: View {
    @StateObject var model = AdsViewModel()
    @State var slideNumber = 1
    @State var hideLyrics = false
    @State var transposeUp = false
    @State var transposeDown = false
    @State var reset = false
    let timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()

    var body: some View {
        let width: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? AppDefaults.screenWidth * 0.6 : AppDefaults.screenWidth * 0.8
        
        ZStack {
            VStack {
                Text("Many musicians use non-standard tunings to record their songs to make it sound better. The AI-backed recognition model provides chords using the standard tuning which may not be very convenient to play along. And that's where the Transposition feature comes in handy.")
                    .multilineTextAlignment(.center)
                    .padding(20)
                
                ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
                    VStack {
                        ChordsAndLyricsAds(
                            adType: .hideLyrics,
                            width: width,
                            model: model,
                            slideNumber: $slideNumber,
                            hideLyrics: $hideLyrics
                        )
                        .frame(height: 300)
                    }
                    .padding(.bottom, 20)
                    
                    
                    VStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.gray20)
                                .frame(width: width, height: 110)
                            VStack(spacing: 5) {
                                HStack(spacing: 0) {
                                    VStack {
                                        Image(systemName: "arrow.up")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 25, height: 25)
                                            .foregroundColor(transposeUp ? .gray10 : .white)
                                    }
                                    .frame(width: 80, height: 40)
                                    .background(.gray30, in: UnevenRoundedRectangle(topLeadingRadius: 16, bottomLeadingRadius: 16))
                                    
                                    VStack(spacing: 3) {
                                        Text("Transpose\nchords")
                                            .multilineTextAlignment(.center)
                                            .font(.system( size: 16))
                                            .foregroundStyle(.white)
                                            .fontWeight(.semibold)
                                    }
                                    .frame(width: 90, height: 40)
                                    .padding(.horizontal, 20)
                                    
                                    VStack {
                                        Image(systemName: "arrow.down")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 25, height: 25)
                                            .foregroundColor(transposeDown ? .gray10 : .white)
                                    }
                                    .frame(width: 80, height: 40)
                                    .background(.gray30, in: UnevenRoundedRectangle(bottomTrailingRadius: 16, topTrailingRadius: 16))
                                }
                                .frame(height: 50)
                                
                                Divider()
                                
                                Text("Reset changes")
                                    .foregroundStyle(reset ? .gray5 : .purple)
                                    .frame(height: 30)
                            }
                            .frame(width: width - 20)
                        }
                    }
                }
            }
        }
        .onReceive(timer) { input in
            let rnd = Int.random(in: 1..<11)
            if rnd > 5 {
                transposeUp.toggle()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    transposeUp.toggle()
                    model.transpose(transposeUp: true)
                }
            } else if rnd == 5 {
                reset.toggle()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    reset.toggle()
                    model.reset()
                }
            } else {
                transposeDown.toggle()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    transposeDown.toggle()
                    model.transpose(transposeUp: false)
                }
            }
        }
    }

}
