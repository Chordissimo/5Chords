//
//  EditChordsAds.swift
//  AmDm AI
//
//  Created by Anton on 19/07/2024.
//

import SwiftUI
import UIKit

struct Chord: Identifiable, Hashable {
    static func == (lhs: Chord, rhs: Chord) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    var id = UUID()
    var chord: String
    var lyrics: String
}

struct Line: Identifiable, Hashable {
    static func == (lhs: Line, rhs: Line) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    var id = UUID()
    var start: String
    var chords: [Chord]
}

struct EditChordsAds: View {
    var lines: [Line] = [
        Line(start: "0:08", chords: [
            Chord(chord: "D", lyrics: "Jingle bell, "),
            Chord(chord: "Dmaj7", lyrics: "Jingle bell, "),
            Chord(chord: "D6", lyrics: "jingle bell "),
            Chord(chord: "D", lyrics: "rock, ")
        ]),
        Line(start: "0:11", chords: [
            Chord(chord: "D6", lyrics: "jingle bells "),
            Chord(chord: "D", lyrics: "swing and "),
            Chord(chord: "Em", lyrics: "jingle bells "),
            Chord(chord: "A7", lyrics: "ring ")
        ]),
        Line(start: "0:16", chords: [
            Chord(chord: "G/E", lyrics: "Snowing an "),
            Chord(chord: "A7", lyrics: "blowing up "),
            Chord(chord: "Em", lyrics: "bushels of "),
            Chord(chord: "A7", lyrics: "fun, ")
        ]),
        Line(start: "0:20", chords: [
            Chord(chord: "A", lyrics: "now the jingle hop "),
            Chord(chord: "Em", lyrics: "has "),
            Chord(chord: "A7", lyrics: "begun ")
        ]),
    ]
    var appDefaults = AppDefaults()
    @State var slideNumber = 1
    let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        let width: CGFloat = appDefaults.screenWidth * 0.8
        ZStack(alignment: Alignment(horizontal: .center, vertical: .center)) {
            VStack(alignment: .center) {
                Text("Chord and lyrics recognition is done\nby AI-backed cutting edge technology. However, sometimes you may want to change some of the chords to make it easier for you to play. ")
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 30)

                VStack {
                    if slideNumber == 1 {
                        EditChordsAdsSlide1(lines: lines, width: width)
                    } else if slideNumber == 2 {
                        Text("Slide 2")
                    } else if slideNumber == 3 {
                        Text("Slide 3")
                    }
                }
                HStack {
                    ForEach(1...3, id: \.self) { index in
                        Circle()
                            .fill(slideNumber == index ? Color.white : Color.gray40)
                            .frame(width: 6, height: 6)
                    }
                }
            }
            .padding(.horizontal, 20)
            .onReceive(timer) { _ in
                slideNumber = slideNumber == 3 ? 1 : slideNumber + 1
            }
        }
    }
    
}


struct EditChordsAdsSlide1: View {
    var lines: [Line]
    var width: CGFloat
    @State var isPresented = false
    @State var showCircle = false

    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ForEach(lines, id: \.self) { line in
                    let lineWidth = CGFloat(Array(line.chords.map { self.getWidth(for: $0) }).reduce(0, +))
                    let intervalPaddingWidth = (width - lineWidth - LyricsViewModelConstants.padding) / 2
                    let timeframeIndex = lines.firstIndex(where: { $0 == line })!
                    
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .foregroundStyle(.gray20)
                            .frame(height: 1)
                        Text(line.start)
                            .font(.system(size: 12))
                            .foregroundStyle(Color.gray40)
                            .padding(.horizontal, 5)
                    }
                    .zIndex( -1)
                    
                    VStack {
                        HStack(spacing: 0) {
                            ForEach(line.chords, id: \.self) { chord in
                                let isBold = timeframeIndex == 1 && line.chords.firstIndex(where: { $0 == chord })! == 2
                                let chordWidth = getWidth(for: chord)
                                let chordIndex = line.chords.firstIndex(where: { $0 == chord })!
                                let finalChordWidth = chordIndex == 0 || chordIndex == (line.chords.count - 1) ?
                                (line.chords.count == 1 ? (width - LyricsViewModelConstants.padding) : (chordWidth + intervalPaddingWidth)) :
                                chordWidth
                                
                                ZStack {
                                    if showCircle && isBold {
                                        Circle()
                                            .foregroundStyle(.white)
                                            .opacity(0.1)
                                            .frame(width: 55, height: 55)
                                            .transition(.scale)
                                    }
                                    VStack {
                                        Text(chord.chord)
                                            .font(.system(size: LyricsViewModelConstants.lyricsfontSize))
                                            .fontWeight(isBold ? .bold : .semibold)
                                            .foregroundStyle(isBold ? .progressCircle : .white)
                                            .padding(.horizontal, 0)
                                        Spacer()
                                        Text(chord.lyrics)
                                            .font(.system(size: LyricsViewModelConstants.lyricsfontSize))
                                            .foregroundStyle(isBold ? .progressCircle : .white)
                                            .padding(.horizontal, 0)
                                    }
                                    .frame(width: finalChordWidth)
                                    .padding(.vertical,5)
                                    .padding(.leading, chordIndex == 0 || line.chords.count == 1 ? intervalPaddingWidth : 0)
                                    .padding(.trailing, chordIndex == line.chords.count - 1 || line.chords.count == 1 ? intervalPaddingWidth : 0)
                                    .overlay {
                                        if isPresented && isBold {
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation(.linear(duration: 0.3)) {
                        showCircle = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        withAnimation {
                            isPresented = true
                        }
                    }
                }
            }

        }
    }
    
    func getWidth(for chord: Chord) -> CGFloat {
        let textSize = ceil(chord.lyrics.size(withAttributes: [.font: UIFont.systemFont(ofSize: LyricsViewModelConstants.lyricsfontSize)]).width)
        let chordSize = ceil(chord.chord.size(withAttributes: [.font: UIFont.systemFont(ofSize: LyricsViewModelConstants.lyricsfontSize, weight: .semibold)]).width)
        return (textSize > 0 ? max(textSize,chordSize) : max(chordSize,LyricsViewModelConstants.minChordWidth)) + LyricsViewModelConstants.spacing
    }

}


//                Image("EditChords1")
//
//                Text("Select the another chord to replace the original chord")
//                    .multilineTextAlignment(.center)
//                Image("EditChords2")
//
//                Text("Edit the lyrics if needed and tap Save." )
//                    .multilineTextAlignment(.center)
//                Image("EditChords3")


