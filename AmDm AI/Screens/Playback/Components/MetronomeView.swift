//
//  MetronomeView.swift
//  AmDm AI
//
//  Created by Anton on 12/05/2024.
//

import SwiftUI

struct MetronomeView: View {
    @Binding var bpm: Float
    @Binding var beats: Int
    @State var showBeats: Bool = false
    @ObservedObject private var metronome = MetronomeModel()
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    if metronome.isStarted {
                        metronome.stop()
                    } else {
                        metronome.start(bpm: bpm, beats: beats, accent: false)
                    }
                } label: {
                    VStack {
                        Image(systemName: metronome.isStarted ? "metronome.fill" : "metronome")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .aspectRatio(contentMode: .fit)
                            .foregroundStyle(.secondaryText)
                        Text(String(Int(round(bpm))) + " bpm")
                            .font(.system(size: 14))
                            .foregroundStyle(.secondaryText)
                    }
                }

                if showBeats {
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
}
