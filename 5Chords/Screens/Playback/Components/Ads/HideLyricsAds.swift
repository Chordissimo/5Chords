//
//  HideLyricsAds.swift
//  AmDm AI
//
//  Created by Anton on 21/07/2024.
//

import SwiftUI

struct HideLyricsAds: View {
    @StateObject var model = AdsViewModel()
    @State var slideNumber = 1
    @State var hideLyrics = false
    let timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()

    var body: some View {
        let width: CGFloat = AppDefaults.screenWidth * 0.8
        
        ZStack {
            VStack {
                Text("Sometimes you may want just to see chords and hide the lyrics. To do that just tap the toggle switch in the Preferences.")
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
                            UnevenRoundedRectangle(topLeadingRadius: 16, topTrailingRadius: 16)
                                .fill(Color.gray20)
                                .frame(width: width, height: 70)
                                
                            HStack {
                                Text("Hide lyrics")
                                    .font(.system( size: 16))
                                    .foregroundStyle(.white)
                                    .fontWeight(.semibold)
                                Toggle("",isOn: $hideLyrics)
                                    .labelsHidden()
                            }
                            .frame(width: 150, height: 70)
                            
                            Color.white.opacity(0.001)
                        }
                    }
                    .padding(.top, 30)
                    .frame(width: 150, height: 80)
                }
            }
        }
        .onReceive(timer) { input in
            withAnimation {
                hideLyrics.toggle()
            }
        }
    }
}
