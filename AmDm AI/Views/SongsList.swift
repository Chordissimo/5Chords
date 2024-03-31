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
        if songsList.songs.count == 0 {
            VStack {
                Spacer()
                Text("!!").foregroundStyle(Color.white)
                Spacer()
            }.frame(maxHeight: .infinity).border(Color.blue)
        }
        ForEach(songsList.songs.indices, id: \.self) { songIndex in
            VStack {
                if songIndex == 0 {
                    Divider().overlay(Color.customGray)
                }
                if songsList.songs[songIndex].isCompacted {
                    ZStack {
                        Color.black.opacity(0.01) // this is needed for onTapGesture to work
                        HStack(alignment: .top, spacing: 0) {
                            VStack(alignment: .leading, spacing: 0) {
                                //Title
                                Text(songsList.songs[songIndex].name)
                                    .foregroundStyle(Color.white)
                                    .fontWeight(.semibold)
                                    .font(.system(size: 17))
                                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 2, trailing: 0))
                                //Song creation date
                                DateLabel(date: songsList.songs[songIndex].created, color: Color.customGray1)
                            }
                            Spacer()
                            VStack(spacing: 0) {
                                Text(formattedDuration(seconds:songsList.songs[songIndex].duration))
                                    .foregroundStyle(Color.customGray1)
                                    .font(.system(size: 15))
                                    .padding(EdgeInsets(top: 3, leading: 0, bottom: 0, trailing: 0))
                            }
                        }
                        .padding(EdgeInsets(top: 1, leading: 10, bottom: 0, trailing: 20))
                    }
                    .onTapGesture {
                        withAnimation {
                            songsList.expand(index: songIndex)
                        }
                    }
                    
                } else {
                    VStack {
                        HStack(alignment: .center, spacing: 0) {
                            VStack(alignment: .leading, spacing: 0) {
                                //Title
                                EditableText(text: $songsList.songs[songIndex].name, style: EditableTextDisplayStyle.songTitle)
                                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 1, trailing: 0))
                                //Song creation date
                                DateLabel(date: songsList.songs[songIndex].created, color: Color.customGray1)
                                
                            }
                            Spacer()
                            //Actions sheet toggle (circle with 3 dots)
                            ActionsToggle()
                        }
                        .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 20))
                        
                        HStack {
                            //playback progress slider
                            PlaybackSlider(playbackPosition: $songsList.songs[songIndex].playbackPosition, duration: $songsList.songs[songIndex].duration)
                        }
                        .padding(EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 20))
                        
                        HStack {
                            //chords
                            ChordView(chords: songsList.songs[songIndex].chords)
                        }
                        .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 20))
                        
                        HStack {
                            // controls
                            OptionsToggle()
                            Spacer()
                            PlaybackColtrols()
                            Spacer()
                            ActionButton(systemImageName: "trash") {
                                songsList.del(index: songIndex)
                            }.frame(width: 18)
                        }
                        .padding(EdgeInsets(top: 17, leading: 10, bottom: 10, trailing: 20))
                    }
                    
//                    .transition(
//                        .asymmetric(
//                            insertion: AnyTransition.identity.animation(.linear(duration: 0.2)),
//                            removal: AnyTransition.identity.animation(.linear(duration: 0.2))
//                        )
//                    )
                }
                Divider().overlay(Color.customGray)
            }
        }
    }
}

#Preview {
    @ObservedObject var songsList = SongsList()
//    songsList.songs.removeAll()
    return ZStack {
        Color.black.ignoresSafeArea()
        ScrollView {
            SongsListView(songsList: _songsList)
        }
    }
}
