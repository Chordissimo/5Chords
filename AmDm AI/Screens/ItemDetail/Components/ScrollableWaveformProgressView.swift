//
//  ScrollableWaveformProgressView.swift
//  AmDm AI
//
//  Created by Marat Zainullin on 30/04/2024.
//

import SwiftUI
import Waavform

struct ScrollableWaveformProgressView: View {
    @State private var scrollOffset: CGFloat = 0.0
    private let height: CGFloat = 120
    @State private var position: Int? = 50
    let audioLengthSeconds: Float = 176
    let url: URL = Bundle.main.url(forResource: "splean", withExtension: "mp3")!
    @State var positionSeconds: Float = 12.445
    //    @Binding var isPlaying: Bool
    //    @Binding var positionMilliseconds: Int
    
    var body: some View {
        
        Waavform(
            audio: "test_audio", type: "m4a", viewOnLoad: .scroll
        )
    }
}


#Preview {
    ScrollableWaveformProgressView()
}
