//
//  ChordSearch.swift
//  AmDm AI
//
//  Created by Anton on 30/05/2024.
//

import SwiftUI
import SwiftyChords

struct ChordSearchView: View {
    @ObservedObject var model: ChordLibraryModel
    @Binding var chords: [ChordPosition]
    @Binding var showSearchResults: Bool
    @Binding var searchText: String
    @FocusState var isFocused: Bool
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.gray40)
                    .padding(.leading,10)
                TextField("Search", text: $searchText)
                    .focused($isFocused)
                    .onChange(of: searchText) {
                        model.searchChordsBy(searchString: searchText)
                        if chords.count > 0 {
                            chords = []
                        }
                    }
                if searchText != "" {
                    Button {
                        searchText = ""
                        chords = []
                        model.clearSearchResults()
                    } label: {
                        Image(systemName: "delete.left")
                            .foregroundColor(.secondaryText)
                    }
                    .padding(.trailing,10)
                }
                Spacer()
            }
            .frame(height: 35)
            .background(Color.search)
            .clipShape(.rect(cornerRadius: 10))
            .onTapGesture {
                if !showSearchResults {
                    showSearchResults = true
                    chords = []
                    model.clearSearchResults()
                }
            }
        }
        .padding(.horizontal,20)
    }
}
