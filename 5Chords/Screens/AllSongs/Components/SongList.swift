//
//  SongList1.swift
//  AmDm AI
//
//  Created by Anton on 16/05/2024.
//

import SwiftUI

struct SongList: View {
    @ObservedObject var songsList: SongsList
    @Binding var youtubeSearchUrl: String
    @Binding var youtubeViewPresented: Bool
    @State var searchText: String = ""
    @State var showSearchYoutube: Bool = false
    
    var body: some View {
        ScrollViewReader { proxy in
            ZStack {
                VStack {
                    if $songsList.songs.count == 0 {
                        if !songsList.recordStarted {
                            EmptyListView()
                        } else {
                            Spacer()
                        }
                    } else {
                        if songsList.showSearch {
                            SearchSongView(searchText: $searchText, showSearch: $songsList.showSearch, songsList: songsList)
                                .padding(.horizontal, 20)
                                .padding(.top, 10)
                        }
                        
                        List($songsList.songs.filter({
                            ($0.wrappedValue.name.localizedCaseInsensitiveContains(searchText) || searchText == "") &&
                            (songsList.showSearch ? !$0.wrappedValue.isProcessing : true)
                        }), id: \.id) { song in
                            VStack {
                                if song.isVisible.wrappedValue {
                                    NavigationLink(destination: PlaybackView(song: song.wrappedValue, songsList: songsList)) {
                                        RecognizedSongView(songsList: songsList, song: song.wrappedValue)
                                            .id(songsList.songs.firstIndex(of: song.wrappedValue) ?? 0 + 1)
                                    }
                                }
                            }
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.gray5)
                        }
                        .scrollIndicators(.hidden)
                        .listStyle(.plain)
                        .onDisappear {
                            songsList.showSearch = false
                            searchText = ""
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
                .onChange(of: searchText) {
                    let searchResults = $songsList.songs.filter({
                        ($0.wrappedValue.name.localizedCaseInsensitiveContains(searchText) || searchText == "") &&
                        (songsList.showSearch ? !$0.wrappedValue.isProcessing : true)
                    }).count
                    showSearchYoutube = searchResults == 0 && searchText != ""
                }
                
                if showSearchYoutube {
                    VStack {
                        Button {
                            let query = searchText.addingPercentEncoding(withAllowedCharacters: .afURLQueryAllowed) ?? ""
                            youtubeSearchUrl = "https://www.youtube.com/results?search_query=\(query)"
                            youtubeViewPresented = true
                            searchText = ""
                            songsList.showSearch = false
                        } label: {
                            Text("Search Youtube™ for \"\(searchText)\"")
                                .font(.system(size: 16))
                                .foregroundStyle(.purple)
                                .padding(.top, 150)
                        }
                        Spacer()
                    }
                }
            }
        }
    }
}
