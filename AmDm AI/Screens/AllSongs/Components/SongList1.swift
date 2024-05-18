//
//  SongList1.swift
//  AmDm AI
//
//  Created by Anton on 16/05/2024.
//

import SwiftUI

struct SongList1: View {
//    @Binding var showSearch: Bool
    @ObservedObject var songsList: SongsList
    @State var searchText: String = ""
    
    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                VStack {
                    if $songsList.songs.count == 0 {
                        EmptyListView1()
                    } else {
                        List($songsList.songs, id: \.id) { song in
                            if songsList.showSearch && songsList.songs.firstIndex(of: song.wrappedValue) == 0 {
                                SearchSongView(searchText: $searchText, songsList: songsList)
                                    .listRowBackground(Color.gray5)
                                    .id(0)

                            }
                            if song.isVisible.wrappedValue {
                                RecognizedSongView(songsList: songsList, song: song.wrappedValue)
                                    .id(songsList.songs.firstIndex(of: song.wrappedValue)! + 1)
                                    .padding(.top,5)
                                    .listRowSeparator(.automatic)
                                    .listRowBackground(Color.gray5)
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

struct RecognizedSongView: View {
    @ObservedObject var songsList: SongsList
    @ObservedObject var song: Song
    
    var body: some View {
        VStack(alignment: .leading) {
            if song.isFakeLoaderVisible {
                VStack(alignment: .leading) {
                    HStack {
                        CircularProgressBarView(song: song, songsList: songsList)
                            .frame(width: 60, height: 60)
                        
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Extracting chords and lyrics")
                                .font(.system(size: 18))
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                                .padding(.bottom, 3)
                                .opacityAnimaion()
                            
                            RoundedRectangle(cornerRadius: 4)
                                .frame(width: 40, height: 12)
                                .foregroundColor(.disabledText)
                                .padding(.bottom, 5)
                                .opacityAnimaion()
                            
                            RoundedRectangle(cornerRadius: 4)
                                .frame(width: 140, height: 12)
                                .foregroundColor(.disabledText)
                                .opacityAnimaion()
                        }
                        .padding(.leading, 10)
                    }
                }
            } else {
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
                                .foregroundColor(.gray10)
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
                                songsList.objectWillChange.send()
                            }
                        }
                        .onChange(of: songsList.showSearch) {
                            searchText = ""
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

struct OpacityAnimation: ViewModifier {
    @State private var throb: Bool = false
    func body(content: Content) -> some View {
        ZStack {
            content
                .opacity(throb ? 0.7 : 1)
                .animation(.easeOut(duration: 1.0).repeatForever(), value: throb)
                .onAppear {
                    throb.toggle()
                }
        }
    }
}

extension View {
    func opacityAnimaion() -> some View {
        modifier(OpacityAnimation())
    }
}

struct Glow: ViewModifier {
    @State private var throb: Bool = false
    func body(content: Content) -> some View {
        ZStack {
            content
                .blur(radius: throb ? 5 : 20)
                .animation(.easeOut(duration: 2.0).repeatForever(), value: throb)
                .onAppear {
                    throb.toggle()
                }
            content
        }
    }
}

extension View {
    func glow() -> some View {
        modifier(Glow())
    }
}
