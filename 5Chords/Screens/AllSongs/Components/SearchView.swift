//
//  SearchView.swift
//  AmDm AI
//
//  Created by Anton on 20/05/2024.
//

import SwiftUI

struct SearchSongView: View {
    @Binding var searchText: String
    @Binding var showSearch: Bool
    @ObservedObject var songsList: SongsList
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack {
            HStack { // field and icons
                Image(systemName: "magnifyingglass")
                    .padding(.leading,10)
                
                TextField("Search", text: $searchText)
//                    .onChange(of: searchText) {
//                        if searchText == "" {
//                            songsList.searchResults = songsList.songs
//                        } else {
//                            songsList.searchResults = songsList.songs.filter({ $0.name.contains(searchText) })
//                        }
//                        songsList.filterSongs(searchText: searchText)
//                        songsList.objectWillChange.send()
//                    }
                    .focused($isFocused)
                    .onAppear {
                        isFocused = true
                    }
                
                Image(systemName: "delete.left")
                    .foregroundColor(searchText != "" ? .secondaryText : .clear)
                    .onTapGesture {
                        searchText = ""
                        songsList.objectWillChange.send()
                    }
                    .padding(.trailing,10)
            }
            .frame(height: 35)
            .background(Color.search)
            .clipShape(.rect(cornerRadius: 10))
            
            Text("Cancel")
                .foregroundStyle(.white)
                .onTapGesture {
                    showSearch = false
                    searchText = ""
                    songsList.objectWillChange.send()
                }
        }
        .padding(.vertical, 10)
    }
}
