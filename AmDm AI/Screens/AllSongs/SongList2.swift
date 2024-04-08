//
//  SongsList.swift
//  AmDm AI
//
//  Created by Anton on 30/03/2024.
//

import SwiftUI

struct SongsListView2: View {
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
            .transition(.identity)
            .onTapGesture {
                withAnimation(.smooth) {
                    songsList.expand(song: song)
                }
            }
        } else {
            ExpandedListItem(song: $song, songsList: songsList)
                .transition(.asymmetric(
                    insertion: .move(edge: .top),
                    removal: .identity))
        }
    }
}

struct ExpandedListItem: View {
    @Binding var song: SongData
    @ObservedObject var songsList: SongsList
    @State var isSongDetailsPresented: Bool = false
    @State var isShareSheetPresented: Bool = false
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 0) {
                //Title
                EditableText(text: $song.name, style: EditableTextDisplayStyle.songTitle, isEditable: true)
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
                    isSongDetailsPresented.toggle()
                } label: {
                    ChordsView(chords: song.chords)
                }.buttonStyle(BorderlessButtonStyle())
            }
            .padding(.top, 5)
            .padding(.bottom, 7)
            .sheet(isPresented: $isSongDetailsPresented, onDismiss: {
                songDetailsDismissed(isShareSheetPresented)
            }) {
                SongDetails(song: $song, isSongDetailsPresented: $isSongDetailsPresented, isShareSheetPresented: $isShareSheetPresented)
            }
            
            HStack {
                // controls
                Share(label: "", content: "Chords for " + song.name)
                
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
        .border(Color.blue, width: 1)
    }
    
    func songDetailsDismissed(_ isShareSheetPresented: Bool) {
        if !isShareSheetPresented {
            if let s = songsList.getExpanded() {
                shareSheet("Chords for " + s.name)
            }
        }
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
        SongsListView2(songsList: _songsList)
    }
}
