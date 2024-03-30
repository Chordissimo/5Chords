//
//  PlaybackSlider.swift
//  AmDm AI
//
//  Created by Anton on 30/03/2024.
//

import SwiftUI

struct PlaybackSlider: View {
    @Binding private var playbackPosition: Double
    
    init(playbackPosition: Binding<Double>) {
        self._playbackPosition = playbackPosition
    }
    
    var body: some View {
        Slider(value: $playbackPosition).padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
    }
}

#Preview {
    @State var playbackPosition = 0.0
    return PlaybackSlider(playbackPosition: $playbackPosition)
}
