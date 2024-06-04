//
//  ChordSuffixes.swift
//  AmDm AI
//
//  Created by Anton on 04/06/2024.
//

import SwiftUI
import SwiftyChords

struct ChordSuffixes: View {
    @ObservedObject var model: ChordLibraryModel
    var action: (Chords.Key, Chords.Suffix) -> Void
    @State var selectedChord = ChordSearchResults()
    
    init(model: ChordLibraryModel, action: @escaping (Chords.Key, Chords.Suffix) -> Void) {
        self.model = model
        self.action = action
    }
    
    var body: some View {
        if model.chordSearchResults.count == 0 {
            Text("Hint: Type in a chord name such as Am or C minor.")
                .font(.system(size: 14))
                .foregroundStyle(.gray40)
                .transition(.identity)
        } else {
            ScrollView {
                WrappingHStack(alignment: .center) {
                    ForEach(model.chordSearchResults, id: \.self) { chord in
                        Button {
                            self.selectedChord = chord
                            action(chord.key, chord.suffix)
                        } label: {
                            Text("\(chord.key.display.symbol)\(chord.suffix.display.short)")
                                .foregroundStyle(.white)
                                .frame(height: 20)
                                .padding(.vertical, 10)
                                .padding(.horizontal)
                                .background {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(chord == self.selectedChord ? Color.gray20 : Color.clear)
                                }
                        }
                    }
                }
            }
            .scrollIndicatorsFlash(onAppear: true)
            .onAppear {
                self.selectedChord = model.chordSearchResults.count > 0 ? model.chordSearchResults.first! : self.selectedChord
            }
        }
    }
}
