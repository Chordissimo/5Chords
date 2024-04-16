//
//  UserDataModel.swift
//  AmDm AI
//
//  Created by Anton on 06/04/2024.
//

import SwiftUI

struct ListItem: Identifiable {
    let id: Int
    let title: String
    var isExpanded: Bool = false
}

struct SongsListView: View {
    @ObservedObject var songsList: SongsList
    @State var isSongDetailsPresented: Bool = false
    @State var isShareSheetPresented: Bool = false

    
    var body: some View {
        if songsList.songs.count == 0 {
            EmptyListView()
        } else {
            ScrollView {
                ForEach($songsList.songs) { song in
                    ContentCell(song: song, songsList: songsList, isSongDetailsPresented: $isSongDetailsPresented, isShareSheetPresented: $isShareSheetPresented)
                        .body.modifier(ScrollCell())
                        .onTapGesture {
                            if !song.isExpanded.wrappedValue {
                                withAnimation(.linear(duration: 0.2)) {
                                    songsList.expand(song: song.wrappedValue)
                                }
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

struct ContentCell {
    @Binding var song: Song
    @ObservedObject var songsList: SongsList
    @Binding var isSongDetailsPresented: Bool
    @Binding var isShareSheetPresented: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                EditableText(text: $song.name, style: EditableTextDisplayStyle.songTitle, isEditable: song.isExpanded)
                HStack {
                    DateLabel(date: song.created, color: Color.customGray1)
                    Spacer()
                    if !song.isExpanded {
                        Text(formatTime(song.duration))
                            .foregroundStyle(Color.customGray1)
                            .font(.system(size: 15))
                    }
                }
                if song.isExpanded {
                    VStack(alignment: .leading) {
                        HStack {
                            PlaybackSlider(playbackPosition: $song.playbackPosition, duration: $song.duration)
                                .padding(.horizontal, 3)
                        }
                        VStack {
                            Button {
                                isSongDetailsPresented = true
                            } label: {
                                ChordsView(chords: song.chords)
                                    .padding(.vertical, 10)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            .sheet(isPresented: $isSongDetailsPresented, onDismiss: {
                                print(isShareSheetPresented)
                                songDetailsDismissed(isShareSheetPresented)
                            }) {
                                SongDetails(song: $song, isSongDetailsPresented: $isSongDetailsPresented, isShareSheetPresented: $isShareSheetPresented)
                            }
                        }
                        HStack {
                            Share(label: "", content: "Chords for " + song.name)
                            Spacer()
                            PlaybackColtrols()
                            Spacer()
                            ActionButton(systemImageName: "trash") {
                                songsList.del(song: song)
                            }
                            .frame(width: 18)
                        }
                        .padding(.bottom, 10)
                        .padding(.horizontal, 5)
                    }
                }
            }
            Spacer()
        }
        .contentShape(Rectangle())
        .padding(.horizontal,10)
    }
    
    func songDetailsDismissed(_ isShareSheetPresented: Bool) {
        if isShareSheetPresented {
            if let s = songsList.getExpanded() {
                shareSheet("Chords for " + s.name)
            }
        }
    }
}

struct ScrollCell: ViewModifier {
    func body(content: Content) -> some View {
        Group {
            content
            Divider()
                .background(Color.customGray1)
                .padding(.horizontal,10)
        }
    }
}

struct EmptyListView: View {
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
    return ZStack {
        Color.black.ignoresSafeArea()
        SongsListView(songsList: songsList)
    }
}
