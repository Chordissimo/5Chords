//
//  ChordShapesView.swift
//  AmDm AI
//
//  Created by Anton on 03/07/2024.
//

import SwiftUI

struct ChordShapesView: View {
    @ObservedObject var song: Song
    @Binding var currentChordIndex: Int
    
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(song.intervals, id: \.self) { interval in
                                if let key = interval.uiChord?.key, let suffix = interval.uiChord?.suffix {
                                    HStack {
                                        interval.uiChord?.renderShape(positionIndex: 0)
                                            .frame(width: LyricsViewModelConstants.chordWidth, height: LyricsViewModelConstants.chordHeight)
                                            .id(interval.uiChord!.id)
                                        
                                        VStack(alignment: .center, spacing: 10) {
                                            Text(key.display.symbol + suffix.display.symbolized)
                                                .foregroundStyle(.white)
                                                .font(.system(size: 30))
                                                .fontWeight(.semibold)
                                            Text(key.display.accessible + suffix.display.accessible)
                                                .foregroundStyle(.white)
                                                .font(.system(size: 16))
                                                .lineLimit(2)
                                                .multilineTextAlignment(.center)
                                        }
                                        .frame(width: LyricsViewModelConstants.chordWidth, height: LyricsViewModelConstants.chordHeight)
                                    }
                                    .id(song.intervals.firstIndex(where: { $0 == interval })!)
                                    .scrollTransition(.animated, axis: .horizontal) { content, phase in
                                        content
                                            .opacity(phase.isIdentity ? 1.0 : 0.6)
                                            .scaleEffect(phase.isIdentity ? 1.0 : 0.6)
                                    }
                                }
                            }
                        }
                    }
                    .scrollDisabled(true)
                    .frame(width: LyricsViewModelConstants.chordWidth * 2, height: LyricsViewModelConstants.chordHeight)
                    .onChange(of: currentChordIndex) { _, newIndex in
                        withAnimation {
                            proxy.scrollTo(newIndex, anchor: .leading)
                        }
                    }
                    .onAppear {
                        proxy.scrollTo(currentChordIndex, anchor: .leading)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        
    }
}
