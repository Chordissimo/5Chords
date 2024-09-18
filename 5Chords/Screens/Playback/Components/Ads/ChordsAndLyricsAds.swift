//
//  ChordsAndLyricsAds.swift
//  AmDm AI
//
//  Created by Anton on 21/07/2024.
//

import SwiftUI

struct ChordsAndLyricsAds: View {
    var adType: AdType = .editChords
    var width: CGFloat
    @ObservedObject var model: AdsViewModel
    @Binding var slideNumber: Int
    @Binding var hideLyrics: Bool
    @State var isPresented = false
    @State var showCircle = false
    @State var blink = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ForEach(model.lines, id: \.self) { line in
                    let lineWidth = CGFloat(Array(line.chords.map { AdsViewModel.getWidth(for: $0) }).reduce(0, +))
                    let intervalPaddingWidth = (width - lineWidth - LyricsViewModelConstants.padding) / 2
                    let timeframeIndex = model.lines.firstIndex(where: { $0 == line })!
                    
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .foregroundStyle(.gray20)
                            .frame(height: 1)
                        Text(line.start)
                            .font(.custom(SOFIA, size: 12))
                            .foregroundStyle(Color.gray40)
                            .padding(.horizontal, 5)
                    }
                    .zIndex( -1)
                    
                    VStack {
                        HStack(spacing: 0) {
                            ForEach(line.chords, id: \.self) { chord in
                                let isBold = timeframeIndex == 1 && line.chords.firstIndex(where: { $0 == chord })! == 2
                                let chordWidth = AdsViewModel.getWidth(for: chord)
                                let chordIndex = line.chords.firstIndex(where: { $0 == chord })!
                                let finalChordWidth = chordIndex == 0 || chordIndex == (line.chords.count - 1) ?
                                (line.chords.count == 1 ? (width - LyricsViewModelConstants.padding) : (chordWidth + intervalPaddingWidth)) :
                                chordWidth
                                
                                ZStack {
                                    if showCircle && isBold && slideNumber == 1 {
                                        Circle()
                                            .foregroundStyle(.white)
                                            .opacity(0.1)
                                            .frame(width: 55, height: 55)
                                            .transition(.scale)
                                    }
                                    VStack {
                                        Text(chord.chord)
                                            .font(.custom(SOFIA, size: LyricsViewModelConstants.lyricsfontSize))
                                            .fontWeight(isBold ? .bold : .semibold)
                                            .foregroundStyle(isBold ? .progressCircle : .white)
                                            .padding(.horizontal, 0)
                                        if !hideLyrics {
                                            Spacer()
                                            Text(chord.lyrics)
                                                .font(.custom(SOFIA, size: LyricsViewModelConstants.lyricsfontSize))
                                                .foregroundStyle(isBold ? .progressCircle : .white)
                                                .padding(.horizontal, 0)
                                        }
                                    }
                                    .opacity(blink && isBold ? 0.5 : 1)
                                    .frame(width: finalChordWidth)
                                    .frame(minHeight: 45)
                                    .padding(.vertical,5)
                                    .padding(.leading, chordIndex == 0 || line.chords.count == 1 ? intervalPaddingWidth : 0)
                                    .padding(.trailing, chordIndex == line.chords.count - 1 || line.chords.count == 1 ? intervalPaddingWidth : 0)
                                    .overlay {
                                        if isPresented && isBold && slideNumber == 1 {
                                            ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
                                                Triangle()
                                                    .frame(width: 20, height: 10)
                                                    .padding(.bottom, 60)
                                                    .offset(x: 50, y: 0)
                                                Text("Long press the chord\nyou want to change")
                                                    .frame(width: 270, height: 60)
                                                    .foregroundStyle(.black)
                                                    .background(.white)
                                                    .presentationCompactAdaptation(.popover)
                                                    .clipShape(.rect(cornerRadius: 12))
                                            }
                                            .offset(x: -50, y: 70)
                                            .frame(height: 70)
                                        }
                                    }
                                }
                            }
                        }
                        .frame(width: width )
                        .background(timeframeIndex == 1 ? Color.gray20.opacity(0.4) : .clear)
                        .padding(.horizontal, 10)
                    }
                    .zIndex(timeframeIndex == 1 ? 1 : -1)
                }
            }
            .padding(10)
            .frame(width: width)
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray20)
            }
            .onAppear {
                replay()
            }
            .onChange(of: slideNumber) { oldValue, newValue in
                if oldValue == 3 && newValue == 1 {
                    replay()
                }
            }
        }
    }

    func replay() {
        if self.adType == .editChords {
            if slideNumber == 1 {
                showCircle = false
                isPresented = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation(.linear(duration: 0.3)) {
                        showCircle = true
                        isPresented = true
                    }
                }
            } else if slideNumber == 3 {
                blink = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.linear(duration: 0.3)) {
                        blink = false
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(.linear(duration: 0.3)) {
                            blink = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation(.linear(duration: 0.3)) {
                                blink = false
                            }
                        }
                    }
                }
            }
        }
    }
}
