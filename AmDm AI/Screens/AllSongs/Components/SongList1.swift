//
//  SongList1.swift
//  AmDm AI
//
//  Created by Anton on 16/05/2024.
//

import SwiftUI

struct SongList1: View {
    @Binding var showSearch: Bool
    @ObservedObject var songsList: SongsList
    @State var searchText: String = ""
    
    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                VStack {
                    if $songsList.songs.count == 0 {
                        EmptyListView1()
                    } else {
                        List($songsList.songs) { song in
                            if showSearch && songsList.songs.firstIndex(of: song.wrappedValue) == 0 {
                                SearchSongView(searchText: $searchText, songsList: songsList)
                                    .listRowBackground(Color.gray5)
                                    .id(0)
//                                    .onDisappear {
//                                        showSearch = false
//                                    }
                            }
                            if song.isVisible.wrappedValue {
                                if song.isProcessing.wrappedValue {
                                    ProcessingSongView(song: song)
                                        .id(songsList.songs.firstIndex(of: song.wrappedValue)! + 1)
                                        .padding(.top,5)
                                        .listRowSeparator(.automatic)
                                        .listRowBackground(Color.gray5)
                                } else {
                                    RecognizedSongView(songsList: songsList, song: song)
                                        .id(songsList.songs.firstIndex(of: song.wrappedValue)! + 1)
                                        .padding(.top,5)
                                        .listRowSeparator(.automatic)
                                        .listRowBackground(Color.gray5)
                                    //                NavigationLink(destination: DetailView(item: item)) {
                                    //                }
                                }
                            }
                        }
                        .scrollIndicators(.hidden)
                        .listStyle(.plain)
                        .onDisappear {
                            showSearch = false
                        }
                    }
                }
                .onAppear {
                    if $songsList.songs.count > 0 {
                        proxy.scrollTo(1, anchor: .top)
                    }
                }
                .onChange(of: showSearch) {
                    withAnimation {
                        if showSearch {
                            proxy.scrollTo(0, anchor: .top)
                        }
                    }
                }
            }
        }
    }
}

struct RecognizedSongView: View {
    @ObservedObject var songsList: SongsList
    @Binding var song: Song
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                if song.songType == .youtube && song.thumbnailUrl.absoluteString != "" {
                    AsyncImage(url: URL(string: song.thumbnailUrl.absoluteString)) { image in
                        image
                            .frame(width: 60, height: 60)
                            .clipShape(.rect(cornerRadius: 12))
                    } placeholder: {
                        Color.gray5.frame(width: 60, height: 60)
                    }
                    
                } else if song.songType == .recorded {
                    Image(systemName: "mic.circle.fill")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .aspectRatio(contentMode: .fill)
                        .foregroundColor(.disabledText)
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .frame(width: 60, height: 60)
                            .foregroundColor(.disabledText)
                        Text("MP3")
                            .font(.system(size: 16))
                            .foregroundColor(.secondaryText)
                    }
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    EditableText(text: $song.name, isEditable: true)
                    
                    Text(formatTime(song.duration, precision: .seconds))
                        .font(.system(size: 14))
                        .fontWeight(.bold)
                        .foregroundStyle(.secondaryText)
                    
                    Text(song.songType.rawValue + " · " + dateToString(song.created))
                        .font(.system(size: 14))
                        .fontWeight(.regular)
                        .foregroundStyle(.disabledText)
                }
                .padding(.leading, 10)
            }
            .swipeActions(allowsFullSwipe: false) {
                Button(role: .destructive) {
                    withAnimation {
                        songsList.del(song: song)
                    }
                } label: {
                    Label("Delete", systemImage: "trash.fill")
                }
            }
        }
    }
}


struct ProcessingSongView: View {
    @Binding var song: Song
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                CircularProgressBarView(song: $song)
                    .frame(width: 60, height: 60)
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(formatTime(song.duration, precision: .seconds))
                        .font(.system(size: 18))
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                    
                    Rectangle()
                        .frame(width: 30, height: 14)
                        .foregroundColor(.disabledText)

                    Rectangle()
                        .frame(width: 30, height: 14)
                        .foregroundColor(.disabledText)
                }
                .padding(.leading, 10)
            }
        }
    }
}



struct SearchSongView: View {
    @Binding var searchText: String
    @ObservedObject var songsList: SongsList
    
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

struct EmptyListView1: View {
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
                    Text("No Recents")
                        .foregroundStyle(Color.white)
                        .font(.system(size: 28))
                        .fontWeight(.bold)
                    Text("Songs and recordings will appear here.")
                        .foregroundStyle(Color.customGray1)
                }
            }
            .frame(maxHeight: .infinity)
        }
    }
}
