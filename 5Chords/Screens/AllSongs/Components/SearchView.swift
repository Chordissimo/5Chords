//
//  SearchView.swift
//  AmDm AI
//
//  Created by Anton on 20/05/2024.
//

import SwiftUI

struct SearchSongView: View {
    @ObservedObject var songsList: SongsList
    @Binding var searchText: String
    @FocusState var isFocused: Bool
    var completion: () -> Void
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .padding(.leading,10)
                
                TextField("Search", text: $searchText)
                    .focused($isFocused)
                    .onAppear {
                        isFocused = true
                    }
                    .onSubmit {
                        isFocused = false
                        completion()
                    }
                    .submitLabel(.search)
                
                Image(systemName: "delete.left")
                    .foregroundColor(searchText != "" ? .secondaryText : .clear)
                    .onTapGesture {
                        searchText = ""
                        completion()
                    }
                    .padding(.trailing,10)
            }
            .frame(height: 35)
            .background(Color.search)
            .clipShape(.rect(cornerRadius: 10))
        }
        .padding(.vertical, 10)
    }
}
