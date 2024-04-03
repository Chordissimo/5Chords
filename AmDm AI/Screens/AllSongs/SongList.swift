//
//  SongsList.swift
//  AmDm AI
//
//  Created by Anton on 30/03/2024.
//

import SwiftUI

struct SongsListView: View {
    @ObservedObject var songsList: SongsList
    
    init(songsList: ObservedObject<SongsList>) {
        self._songsList = songsList
    }
    
    var body: some View {
        if $songsList.songs.count == 0 {
            BlankListView()
        } else {
            List {
                ForEach($songsList.songs) { song in
                    VStack {
                        CollapsedListItem(song: song, songsList: songsList)
                            .onTapGesture {
                                withAnimation(.smooth) {
                                    songsList.expand(song: song.wrappedValue)
                                }
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    songsList.del(song: song.wrappedValue)
                                } label: {
                                    Image(systemName: "trash")
                                }
                            }
                            .swipeActions {
                                Button {
                                    print("options share")
                                } label: {
                                    Image(systemName: "ellipsis")
                                }.tint(.gray)
                            }
                            .swipeActions {
                                Button {
                                    print("share swipe")
                                } label: {
                                    Image(systemName: "square.and.arrow.up")
                                }.tint(.blue)
                            }
                    }
                }
                .listRowBackground(Color.black)
                .listRowSeparatorTint(.customGray)
            }
            .listStyle(.plain)
            .background(Color.black)
        }
    }
}

struct CollapsedListItem: View {
    @Binding var song: SongData
    @ObservedObject var songsList: SongsList
    
    var body: some View {
        if !song.isExpanded {
            HStack(alignment: .top, spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    //Title
                    Text(song.name)
                        .foregroundStyle(Color.white)
                        .fontWeight(.semibold)
                        .font(.system(size: 17))
                        .padding(.top, 1)
                    //Song creation date
                    DateLabel(date: song.created, color: Color.customGray1)
                        .padding(.top,1)
                }
                Spacer()
                VStack(spacing: 0) {
                    Text(formatTime(song.duration))
                        .foregroundStyle(Color.customGray1)
                        .font(.system(size: 15))
                        .padding(.top,4)
                }
            }
            .background(Color.black)
        } else {
            ExpandedListItem(song: $song, songsList: songsList)
        }
    }
}

struct ExpandedListItem: View {
    @Binding var song: SongData
    @ObservedObject var songsList: SongsList
    @State var isSongDetailsPresented: Bool = false
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 0) {
                //Title
                EditableText(text: $song.name, style: EditableTextDisplayStyle.songTitle)
                //Song creation date
                DateLabel(date: song.created, color: Color.customGray1)
            }
            
            HStack {
                //playback progress slider
                PlaybackSlider(playbackPosition: $song.playbackPosition, duration: $song.duration)
            }
            .padding(.leading,2)
            
            //chords
            VStack {
                Button {
                    print("ddd")
                    isSongDetailsPresented.toggle()
                } label: {
//                    HStack {
                        ChordsView(chords: song.chords) 
//                    }

                }.buttonStyle(BorderlessButtonStyle())
            }
            .padding(.top, 5)
            .padding(.bottom, 7)
            .sheet(isPresented: $isSongDetailsPresented) {
                SongDetails(song: $song, isSongDetailsPresented: $isSongDetailsPresented)
            }
            
            HStack {
                // controls
                ActionButton(systemImageName: "ellipsis.circle") {
                    print("options toggle tapped")
                }
                .frame(width: 20)
                
                Spacer()
                
                PlaybackColtrols()
                
                Spacer()
                
                ActionButton(systemImageName: "trash") {
                    songsList.del(song: song)
                }
                .frame(width: 18)
            }
            .padding(.leading,2)
            .padding(.bottom,5)
        }
        //        .transition(
        //            .asymmetric(
        //                insertion: AnyTransition.move(edge: .top),
        //                removal: AnyTransition.identity
        //            )
        //        )
    }
}

struct BlankListView: View {
    var body: some View {
        ZStack {
            VStack {
                Image(systemName: "waveform.path")
                    .resizable()
                    .foregroundColor(Color.customGray1)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
                    .padding()
                Text("No recordings")
                    .foregroundStyle(Color.white)
                    .font(.system(size: 28))
                    .fontWeight(.bold)
                Text("Songs you record will appear here.")
                    .foregroundStyle(Color.customGray1)
            }
            .frame(maxHeight: .infinity)
        }
    }
}

#Preview {
    @ObservedObject var songsList = SongsList()
//        songsList.songs.removeAll()
    return ZStack {
        Color.black.ignoresSafeArea()
        SongsListView(songsList: _songsList)
    }
}
