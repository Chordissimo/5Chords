//
//  EditChordsView.swift
//  AmDm AI
//
//  Created by Anton on 12/07/2024.
//

import SwiftUI
import SwiftyChords

struct EditChordsView: View {
    @State var searchText: String = ""
    var lyrics: String
    var completion: (Chords.Key?,Chords.Suffix?,String?) -> Void
    @State var newLyrics: String = ""
    @State var showSearchResults = true
    @State var chords: [ChordPosition] = []
    @State var model = ChordLibraryModel()
    @State var selectedKey: Chords.Key? = nil
    @State var selectedSuffix: Chords.Suffix? = nil
//    @FocusState var focus: Bool
        
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    completion(nil,nil,nil)
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
//            TextField(lyrics, text: $newLyrics)
//                .focused($focus)
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
                completion(selectedKey, selectedSuffix, newLyrics)
            } label: {
                Text("Save")
                    .fontWeight(.semibold)
                    .font(.system(size: 20))
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
            newLyrics = lyrics
            if searchText != "" {
                model.searchChords(searchString: searchText)
            }
        }
    }
}
