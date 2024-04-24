//
//  SongPlayback.swift
//  AmDm AI
//
//  Created by Anton on 01/04/2024.
//

import SwiftUI
import SwiftyChords

struct SongDetails: View {
    @Binding var song: Song
    @ObservedObject var songsList: SongsList
    @Binding var isSongDetailsPresented: Bool
    @Binding var isShareSheetPresented: Bool
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
    
    var body: some View {
        ZStack {
            Color.customDarkGray.ignoresSafeArea()
            VStack {
                HStack {
                    ActionButton(systemImageName: "square.and.arrow.up") {
                        isSongDetailsPresented = false
                        isShareSheetPresented = true
                    }
                    .frame(width:20)
                    .foregroundColor(.purple)
                    .padding()

                    Spacer()
                    ActionButton(systemImageName: "xmark.circle.fill") {
                        isSongDetailsPresented = false
                        isShareSheetPresented = false
                    }
                    .frame(height: 25)
                    .foregroundColor(.customGray)
                    .padding()
                }
                VStack(alignment: .center) {
                    Text(song.name)
                        .font(.system(size: 18))
                        .foregroundStyle(.white)
                        .fontWeight(.semibold)
                    Text(dateToString(song.created) + "   " + formatTime(song.duration))
                        .foregroundStyle(.customGray1)
                }.padding(.bottom,30)
                
                ChordsView(chords: song.chords, style: .pictogram_large)

                AudioPlayerView(scale: .large, song: $song, songsList: songsList)
                    .padding(.horizontal,20)
                
            }
        }
    }
}

