//
//  EditChordsAds.swift
//  AmDm AI
//
//  Created by Anton on 19/07/2024.
//

import SwiftUI
import SwiftyChords

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

class EditChordsAdsModel: ObservableObject {
    @Published var lines: [Line] = [
        Line(start: "0:08", chords: [
            Chord(chord: "D", lyrics: "Jingle bell, "),
            Chord(chord: "Dmaj7", lyrics: "Jingle bell, "),
            Chord(chord: "D6", lyrics: "jingle bell "),
            Chord(chord: "D", lyrics: "rock, ")
        ]),
        Line(start: "0:11", chords: [
            Chord(chord: "D6", lyrics: "jingle bells "),
            Chord(chord: "D", lyrics: "swing and "),
            Chord(chord: "G/E", lyrics: "  jingle  "),
            Chord(chord: "A7", lyrics: "ring ")
        ]),
        Line(start: "0:16", chords: [
            Chord(chord: "Em", lyrics: "Snowing an "),
            Chord(chord: "A7", lyrics: "blowing up "),
            Chord(chord: "Em", lyrics: "bushels of "),
            Chord(chord: "A7", lyrics: "fun, ")
        ]),
        Line(start: "0:20", chords: [
            Chord(chord: "A", lyrics: "now the jingle hop "),
            Chord(chord: "Em", lyrics: "has "),
            Chord(chord: "A7", lyrics: "begun ")
        ])
    ]
}

struct EditChordsAds: View {
    var appDefaults = AppDefaults()
    @State var replay = false
    @StateObject var model = EditChordsAdsModel()
    @State var slideNumber = 1

    var body: some View {
        let width: CGFloat = appDefaults.screenWidth * 0.8

        ZStack(alignment: Alignment(horizontal: .center, vertical: .center)) {
            VStack(alignment: .center) {
                Text("Chord and lyrics recognition is done\nby AI-backed cutting edge technology. However, sometimes you may want to change some of the chords to make it easier\nfor you to play. ")
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 20)
                ZStack {
                    VStack {
                        if slideNumber == 1 || slideNumber == 3 {
                            EditChordsAdsSlide1(width: width, model: model, slideNumber: $slideNumber)
                        } else if slideNumber == 2 {
                            EditChordsAdsSlide2(width: width)
                        }
                    }
                    .frame(height: 300)
                    
                    if replay {
                        Color.customDarkGray.opacity(0.7)
                        Button {
                            replay = false
                            replayAnimations()
                        } label: {
                            ZStack {
                                Image(systemName: "goforward")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundStyle(.white)
                                    .frame(width: 70, height: 70)
                                Text("Replay")
                                    .foregroundStyle(.white)
                                    .font(.system(size: 14))
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                }
                Rectangle()
                    .fill(.customDarkGray)
                    .frame(width: width, height: 60)
            }
            .padding(.horizontal, 20)
        }
        .onAppear {
            replayAnimations()
        }
        .onChange(of: slideNumber) { _, slideNumber in
            if slideNumber == 1 {
                model.lines[1].chords[2].lyrics = "  jingle  "
                model.lines[1].chords[2].chord = "G/E"
//                print(slideNumber,model.lines[1].chords[2].chord,model.lines[1].chords[2].lyrics)
            } else if slideNumber == 3 {
                model.lines[1].chords[2].lyrics = "jingle bells "
                model.lines[1].chords[2].chord = "Em"
//                print(slideNumber,model.lines[1].chords[2].chord,model.lines[1].chords[2].lyrics)
            }
        }

    }
    
    func replayAnimations() {
//        withAnimation {
        slideNumber = 1
//        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            withAnimation {
                slideNumber = 2
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
                withAnimation {
                    slideNumber = 3
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation {
                        replay = true
                    }
                }
            }
        }
    }
}


struct EditChordsAdsSlide1: View {
    var width: CGFloat
    @State var isPresented = false
    @State var showCircle = false
    @State var blink = false
    @ObservedObject var model: EditChordsAdsModel
    @Binding var slideNumber: Int
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ForEach(model.lines, id: \.self) { line in
                    let lineWidth = CGFloat(Array(line.chords.map { self.getWidth(for: $0) }).reduce(0, +))
                    let intervalPaddingWidth = (width - lineWidth - LyricsViewModelConstants.padding) / 2
                    let timeframeIndex = model.lines.firstIndex(where: { $0 == line })!
                    
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
                                    if showCircle && isBold && slideNumber == 1 {
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
                                    .opacity(blink && isBold ? 0.5 : 1)
                                    .frame(width: finalChordWidth)
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
    
    func getWidth(for chord: Chord) -> CGFloat {
        let textSize = ceil(chord.lyrics.size(withAttributes: [.font: UIFont.systemFont(ofSize: LyricsViewModelConstants.lyricsfontSize)]).width)
        let chordSize = ceil(chord.chord.size(withAttributes: [.font: UIFont.systemFont(ofSize: LyricsViewModelConstants.lyricsfontSize, weight: .semibold)]).width)
        return (textSize > 0 ? max(textSize,chordSize) : max(chordSize,LyricsViewModelConstants.minChordWidth)) + LyricsViewModelConstants.spacing
    }

}


struct EditChordsAdsSlide2: View {
    var width: CGFloat
    @ObservedObject var model = ChordLibraryModel()
    @State var chords: [ChordPosition] = []
    @State var showSearchResults: Bool = true
    @State var searchText: String = ""
    @State var selectedChord: ChordSearchResults = ChordSearchResults()
    @State var isPressed = false
    @State var adjustLyrics = "jingle      "
    @State var showLyrics = false
    @State var showLyricsPopover = false

    var body: some View {
        ZStack {
            VStack {
                if !showLyrics {
                    VStack {
                        ChordSearchView(model: model, chords: $chords, showSearchResults: $showSearchResults, searchText: $searchText)
                            .frame(width: width)
                        
                        if showSearchResults {
                            ScrollView(showsIndicators: false) {
                                WrappingHStack(alignment: .center) {
                                    ForEach(model.chordSearchResults, id: \.self) { chord in
                                        let isSelected = chord.key == selectedChord.key && chord.suffix == selectedChord.suffix
                                        Text("\(chord.key.display.symbol)\(chord.suffix.display.symbolized)")
                                            .foregroundStyle(.white)
                                            .frame(height: 20)
                                            .padding(.vertical, 10)
                                            .padding(.horizontal)
                                            .background {
                                                RoundedRectangle(cornerRadius: 10)
                                                    .fill(isSelected ? Color.gray20 : Color.clear)
                                            }
                                            .overlay {
                                                if isSelected {
                                                    ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
                                                        Triangle()
                                                            .frame(width: 20, height: 10)
                                                            .padding(.bottom, 60)
                                                            .offset(x: -50, y: 0)
                                                        Text("Choose a chord")
                                                            .frame(width: 170, height: 60)
                                                            .foregroundStyle(.black)
                                                            .background(.white)
                                                            .presentationCompactAdaptation(.popover)
                                                            .clipShape(.rect(cornerRadius: 12))
                                                    }
                                                    .offset(x: 50, y: 60)
                                                    .frame(height: 70)
                                                }
                                            }
                                    }
                                }
                            }
                            .frame(width: width, height: 250)
                        }
                    }
                    .transition(.push(from: .bottom))
                } else {
                    VStack {
                        ZStack(alignment: Alignment(horizontal: .leading, vertical: .top)) {
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.gray20)
                            Text(adjustLyrics)
                                .padding(20)
                                .overlay {
                                    if showLyricsPopover {
                                        ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
                                            Triangle()
                                                .frame(width: 20, height: 10)
                                                .padding(.bottom, 50)
                                                .offset(x: -50, y: 0)
                                            Text("Edit lyrics if needed.")
                                                .frame(width: 170, height: 50)
                                                .foregroundStyle(.black)
                                                .background(.white)
                                                .presentationCompactAdaptation(.popover)
                                                .clipShape(.rect(cornerRadius: 12))
                                        }
                                        .offset(x: 50, y: 50)
                                        .frame(height: 70)
                                    }
                                }
                        }
                        .padding(.bottom, 20)
                        .frame(height: 170)
                        
                        Text("Save")
                            .fontWeight(.semibold)
                            .font(.system(size: 20))
                            .padding(20)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.black)
                            .background(isPressed ? .gray40 : .white, in: Capsule())
                        
                        Spacer()
                    }
                    .frame(width: width, height: 300)
                    .transition(.push(from: .bottom))
                }
            }
            .background {
                Color.customDarkGray
            }
            Color.gray20.opacity(0.001)
        }
        .frame(width: width, height: 300)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                searchText = "E"
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    searchText = "Em"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        withAnimation {
                            selectedChord = ChordSearchResults(key: .e, suffix: .minor)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            withAnimation {
                                showLyrics = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                adjustLyrics = "jingle b"
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    adjustLyrics += "e"
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        adjustLyrics += "l"
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                            adjustLyrics += "l"
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                adjustLyrics += "s"
                                                withAnimation {
                                                    showLyricsPopover = true
                                                }
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                                    isPressed = true
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                        withAnimation {
                                                            isPressed = false
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
