//
//  PlaybackSlider.swift
//  AmDm AI
//
//  Created by Anton on 30/03/2024.
//

import SwiftUI

struct PlaybackSlider: View {
    @Binding private var playbackPosition: Double
    @Binding private var duration: Int
    @State var startLabel: String
    @State var finishLabel: String
    
    init(playbackPosition: Binding<Double>, duration: Binding<Int>) {
        self._playbackPosition = playbackPosition
        self._duration = duration
        self.startLabel = "0:00"
        self.finishLabel = "0:00"
        
        let thumbImage = UIImage(named: "custom.circle")
        UISlider.appearance().setThumbImage(thumbImage, for: .normal)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Slider(value: $playbackPosition, in: 0...Double(duration), step: 1)
                .tint(Color.customGray1)
            
            HStack(spacing: 0) {
                Text(startLabel)
                    .foregroundStyle(Color.customGray1)
                    .font(.system(size: 12))
                Spacer()
                Text(finishLabel)
                    .foregroundStyle(Color.customGray1)
                    .font(.system(size: 12))
            } .padding(EdgeInsets(top: -10, leading: 0, bottom: 0, trailing: 0))

        }.onAppear() {
            finishLabel = formattedDuration(seconds: duration)
        }
    }
}

#Preview {
    @State var playbackPosition = 0.0
    @State var duration = 75
    return ZStack(alignment: Alignment(horizontal: .center, vertical: .center)) {
        Color.black.ignoresSafeArea()
        PlaybackSlider(playbackPosition: $playbackPosition,duration: $duration)
    }
}
