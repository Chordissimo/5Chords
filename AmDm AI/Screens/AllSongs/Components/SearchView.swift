//
//  SearchView.swift
//  AmDm AI
//
//  Created by Anton on 20/05/2024.
//

import SwiftUI

struct SearchSongView: View {
    @Binding var searchText: String
    @ObservedObject var songsList: SongsList
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack {
            ZStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .padding(.leading,10)
                    
                    TextField("Search", text: $searchText)
                        .onChange(of: searchText) {
                            withAnimation {
                                songsList.filterSongs(searchText: searchText)
                                songsList.objectWillChange.send()
                            }
                        }
                        .onChange(of: songsList.showSearch) {
                            searchText = ""
                        }
                        .focused($isFocused)
                        .onAppear {
                            isFocused = true
                        }
                        .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { obj in
                            if let textField = obj.object as? UITextField {
                                textField.selectAll(nil)
                            }
                        }
                    if searchText != "" {
                        Button {
                            searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondaryText)
                        }
                        .padding(.trailing,10)
                    }
                }
                .frame(height: 35)
                .background(Color.search)
                .clipShape(.rect(cornerRadius: 10))
            }
            .padding(.vertical, 10)
        }
    }
}
