//
//  SongList1.swift
//  AmDm AI
//
//  Created by Anton on 16/05/2024.
//

import SwiftUI

struct SongList: View {
    @ObservedObject var songsList: SongsList
    @State var searchText: String = ""
    @State var focusedField: String = ""
    
    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                VStack {
                    if $songsList.songs.count == 0 {
                        EmptyListView()
                    } else {
                        List($songsList.songs, id: \.id) { song in
                            if songsList.showSearch && songsList.songs.firstIndex(of: song.wrappedValue) == 0 {
                                SearchSongView(searchText: $searchText, songsList: songsList)
                                    .listRowBackground(Color.gray5)
                                    .id(0)
                                
                            }
                            if song.isVisible.wrappedValue {
                                RecognizedSongView(songsList: songsList, song: song.wrappedValue, focusedField: $focusedField)
                                    .padding(.top,5)
                                    .listRowSeparator(.automatic)
                                    .listRowBackground(Color.gray5)
                                    .id(songsList.songs.firstIndex(of: song.wrappedValue)! + 1)
                            }
                        }
                        .scrollIndicators(.hidden)
                        .listStyle(.plain)
                        .onDisappear {
                            songsList.showSearch = false
                        }
                    }
                }
                .onAppear {
                    if $songsList.songs.count > 0 {
                        proxy.scrollTo(1, anchor: .top)
                    }
                }
                .onChange(of: songsList.showSearch) {
                    withAnimation {
                        if songsList.showSearch {
                            proxy.scrollTo(0, anchor: .top)
                        }
                    }
                }
            }
        }
    }
}
