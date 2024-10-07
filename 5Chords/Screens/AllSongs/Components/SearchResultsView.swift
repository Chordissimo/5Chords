//
//  SearchResultsView.swift
//  5Chords
//
//  Created by Anton on 04/10/2024.
//

import SwiftUI

struct SearchResultsView: View {
    @ObservedObject var songsList: SongsList
    @Binding var youtubeSearchUrl: String
    @Binding var youtubeViewPresented: Bool
    @State var searchText: String = ""
    @State var found = false
    @State var showBackButton = false
    @State var showSearchYoutube = false
    @FocusState var isFocused: Bool
    @State var isLoading = false
    @State var showPaywall: Bool = false
    
    var body: some View {
        VStack {
            SearchSongView(songsList: songsList, searchText: $searchText, isFocused: _isFocused) {
                if searchText == "" {
                    songsList.dbSearchResults = []
                    showSearchYoutube = false
                } else if searchText.count >= 2 {
                    isLoading = true
                    songsList.find(searchString: searchText, skip: 0) { result in
                        isLoading = false
                        found = result
                        showSearchYoutube = !found
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            if songsList.dbSearchResults.count == 0 && isLoading {
                VStack {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(.circular)
                    Spacer()
                }
                .frame(width: AppDefaults.screenWidth)
            } else {
                ScrollView {
                    if searchText == "" && songsList.dbSearchResults.count == 0 {
                        EmptyInitialView()
                    } else if searchText != "" && showSearchYoutube {
                        EmptySearchResultsView(
                            songsList: songsList,
                            youtubeSearchUrl: $youtubeSearchUrl,
                            youtubeViewPresented: $youtubeViewPresented,
                            searchText: $searchText
                        )
                    } else {
                        LazyVStack(alignment: .leading, spacing: 10, pinnedViews: [.sectionHeaders]) {
                            ForEach(songsList.dbSearchResults, id: \.self) { video in
                                let index = songsList.dbSearchResults.firstIndex(where: { $0.id == video.id }) ?? 0
                                SearchResultSong(songsList: songsList, showPaywall: $showPaywall, video: video, index: index)
                                    .onAppear {
                                        if index == songsList.dbSearchResults.count - 1 && songsList.dbSearchResults.count >= 20 && found {
                                            isLoading = true
                                            songsList.find(searchString: searchText, skip: songsList.dbSearchResults.count) { result in
                                                isLoading = false
                                                found = result
                                            }
                                        }
                                    }
                                if index == songsList.dbSearchResults.count - 1 {
                                    if isLoading {
                                        VStack {
                                            ProgressView()
                                                .progressViewStyle(.circular)
                                        }
                                        .frame(width: AppDefaults.screenWidth)
                                    } else {
                                        VStack {
                                            Spacer()
                                            Button {
                                                let query = searchText.addingPercentEncoding(withAllowedCharacters: .afURLQueryAllowed) ?? ""
                                                youtubeSearchUrl = "https://www.youtube.com/results?search_query=\(query)"
                                                youtubeViewPresented = true
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                    searchText = ""
                                                    songsList.showSearch = false
                                                }
                                            } label: {
                                                Text("Search Youtube™ for \"\(searchText)\"")
                                                    .font(.system(size: 16))
                                                    .foregroundStyle(.purple)
                                            }
                                            Spacer()
                                        }
                                        .frame(width: AppDefaults.screenWidth)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.bottom, AppDefaults.bottomSafeArea)
            }
            Spacer()
        }
        .edgesIgnoringSafeArea(.bottom)
        .background(Color.gray5)
        .onAppear {
            songsList.dbSearchResults = []
        }
        .fullScreenCover(isPresented: $showPaywall) {
            Paywall(showPaywall: $showPaywall) {
                if !AppDefaults.isLimited {
                    songsList.rebuildTimeframes()
                }
            }
        }
    }
}

struct SearchResultSong: View {
    @ObservedObject var songsList: SongsList
    @Binding var showPaywall: Bool
    var video: Video
    var index: Int
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 20) {
                AsyncImage(url: URL(string: video.thumbnail)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 90, height: 90, alignment: .center)
                } placeholder: {
                    Color.gray5.frame(width: 60, height: 60)
                }
                .frame(width: 60, height: 60, alignment: .center)
                .clipShape(.rect(cornerRadius: 12))
                
                VStack {
                    Text(video.title)
                        .foregroundStyle(Color.white)
                        .fontWeight(.semibold)
                        .font(.system(size: 16))
                        .lineLimit(2)
                }
                Spacer()
                if index < songsList.dbSearchResults.count {
                    Button {
                        if AppDefaults.isLimited && AppDefaults.songCounter >= AppDefaults.LIMITED_NUMBER_OF_SONGS {
                            showPaywall = true
                        } else {
                            if !songsList.dbSearchResults[index].isAdded {
                                songsList.recognitionInProgress = true
                                songsList.processYoutubeVideo(by: video.url, title: video.title, thumbnailUrl: video.thumbnail)
                                songsList.dbSearchResults[index].isAdded = true
                            }
                        }
                    } label: {
                        if !songsList.dbSearchResults[index].isAdded {
                            Image(systemName: "plus.square")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundStyle(Color.gray40)
                                .frame(height: 20)
                        } else {
                            if let _ = songsList.songs.filter({ $0.url.absoluteString == video.url && $0.isProcessing }).first {
                                ProgressView()
                                    .progressViewStyle(.circular)
                            } else {
                                Image(systemName: "checkmark.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundStyle(Color.progressCircle)
                                    .frame(height: 20)
                            }
                        }
                    }
                    .disabled(songsList.recognitionInProgress)
                }
            }
            Divider()
        }
        .padding(.horizontal, 20)
    }
}

struct EmptySearchResultsView: View {
    @ObservedObject var songsList: SongsList
    @Binding var youtubeSearchUrl: String
    @Binding var youtubeViewPresented: Bool
    @Binding var searchText: String
    
    var body: some View {
        ZStack {
            VStack {
                Image(systemName: "music.quarternote.3")
                    .resizable()
                    .foregroundColor(Color.secondaryText)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
                    .padding()
                VStack {
                    Text("Seems like we don't have\nwhat you are looking for.")
                        .foregroundStyle(Color.customGray1)
                        .multilineTextAlignment(.center)
                    Button {
                        let query = searchText.addingPercentEncoding(withAllowedCharacters: .afURLQueryAllowed) ?? ""
                        youtubeSearchUrl = "https://www.youtube.com/results?search_query=\(query)"
                        youtubeViewPresented = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            searchText = ""
                            songsList.showSearch = false
                        }
                    } label: {
                        Text("Search Youtube™ for \"\(searchText)\"")
                            .font(.system(size: 16))
                            .foregroundStyle(.purple)
                            .padding(.top, 30)
                    }
                    Spacer()
                }
            }
            .frame(maxHeight: .infinity)
        }
    }
}

struct EmptyInitialView: View {
    var body: some View {
        ZStack {
            VStack {
                Image(systemName: "music.quarternote.3")
                    .resizable()
                    .foregroundColor(Color.secondaryText)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
                    .padding()
                VStack {
                    Text("Try searching 5Chords collection.")
                        .foregroundStyle(Color.customGray1)
                        .multilineTextAlignment(.center)
                    Spacer()
                }
            }
            .frame(maxHeight: .infinity)
        }
    }
}
