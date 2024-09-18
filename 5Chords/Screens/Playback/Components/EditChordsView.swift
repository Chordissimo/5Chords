//
//  EditChordsView.swift
//  AmDm AI
//
//  Created by Anton on 12/07/2024.
//

import SwiftUI
import SwiftyChords

struct EditChordsView: View {
    @ObservedObject var song: Song
    @Binding var currentChordIndex: Int
    @State var searchText: String = ""
    var completion: (_ isCanceled: Bool, _ selectedKey: Chords.Key?,_ selectedSuffix: Chords.Suffix?,_ newLyrics: String?) -> Void
    @State var newLyrics: String = ""
    @State var showSearchResults = true
    @State var chords: [ChordPosition] = []
    @State var model = ChordLibraryModel()
    @State var selectedKey: Chords.Key? = nil
    @State var selectedSuffix: Chords.Suffix? = nil
        
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    completion(true,nil,nil,nil)
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .foregroundColor(.gray40)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                }
                .padding(.trailing, 20)
            }
            .padding(.vertical, 20)
            
            ChordSearchView(model: model, chords: $chords, showSearchResults: $showSearchResults, searchText: $searchText)
            
            if showSearchResults {
                ChordSuffixes(model: model) { selectedKey, selectedSuffix in
                    self.selectedKey = selectedKey
                    self.selectedSuffix = selectedSuffix
                }
            }
            VStack {
                TextEditor(text: $newLyrics)
            }
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.gray30, lineWidth: 1)
            )
            .clipShape(.rect(cornerRadius: 16))
            .padding()
            .frame(height: 150)

            Spacer()
            
            Button {
                if searchText == "" {
                    selectedKey = nil
                    selectedSuffix = nil
                }
                completion(false, selectedKey, selectedSuffix, newLyrics)
            } label: {
                Text("Save")
                    .fontWeight(.semibold)
                    .font(.custom(SOFIA, size: 20))
                    .padding(20)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.black)
                    .background(.white, in: Capsule())
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 20)
        }
        .onAppear {
            showSearchResults = true
            newLyrics = song.intervals[currentChordIndex].words
            if let chord = song.intervals[currentChordIndex].uiChord {
                selectedKey = chord.key
                selectedSuffix = chord.suffix
                searchText = chord.getChordString(flatSharpSymbols: false)
                model.searchChordsBy(key: selectedKey!, groups: [chord.getChordGroup()])
            } else {
                model.searchChordsBy(searchString: searchText)
            }
        }
    }
}
