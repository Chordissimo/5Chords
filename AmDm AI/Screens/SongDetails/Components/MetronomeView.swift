//
//  MetronomeView.swift
//  AmDm AI
//
//  Created by Anton on 12/05/2024.
//

import SwiftUI

struct MetronomeView: View {
    @Binding var bpm: Double
    @Binding var beats: Int
    @ObservedObject var metronome = MetronomeModel()
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    if metronome.isStarted {
                        metronome.stop()
                    } else {
                        metronome.start(bpm: bpm, beats: beats)
                    }
                } label: {
                    Image(systemName: metronome.isStarted ? "metronome.fill" : "metronome")
                        .frame(height: 18)
                        .aspectRatio(contentMode: .fit)
                }
                .padding(.trailing, 10)
                ForEach(0..<beats, id: \.self) { beat in
                    ZStack {
                        Circle()
                            .frame(height: 5)
                            .foregroundColor(metronome.beatCounter == beat ? .white : .customGray)
                    }
                }
            }
        }
    }
}

#Preview {
    @State var bpm = 120.0
    @State var beats = 4
    return MetronomeView(bpm: $bpm, beats: $beats)
}
