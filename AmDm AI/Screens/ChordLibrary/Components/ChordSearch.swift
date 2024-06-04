//
//  ChordSearch.swift
//  AmDm AI
//
//  Created by Anton on 30/05/2024.
//

import SwiftUI

struct ChordSearchView: View {
    var action: (String) -> Void
    @State var searchText: String = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.gray40)
                .padding(.leading,10)
            TextField("Search", text: $searchText)
                .focused($isFocused)
                .onChange(of: searchText) {
                    action(searchText)
                }
            Spacer()
        }
        .frame(height: 35)
        .background(Color.search)
        .clipShape(.rect(cornerRadius: 10))
    }
}
