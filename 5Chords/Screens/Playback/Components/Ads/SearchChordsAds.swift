//
//  SwiftUIView.swift
//  AmDm AI
//
//  Created by Anton on 21/07/2024.
//

import SwiftUI
import SwiftyChords

struct SearchChordsAds: View {
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
                            .font(.custom(SOFIA, size: 20))
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
