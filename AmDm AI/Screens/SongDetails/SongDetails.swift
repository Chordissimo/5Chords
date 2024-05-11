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
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
    
    var body: some View {
        ZStack {
            Color.customDarkGray.ignoresSafeArea()
            VStack {
//                HStack {
//                    ActionButton(imageName: "chevron.left", title: "Back") {
//                        isSongDetailsPresented = false
//                    }
//                    .frame(height: 25)
//                    .padding()
//                    Spacer()
//                }
                VStack(alignment: .center) {
                    Text(song.name)
                        .font(.system(size: 18))
                        .foregroundStyle(.white)
                        .fontWeight(.semibold)
                    Text(dateToString(song.created) + "   " + formatTime(song.duration))
                        .foregroundStyle(.customGray1)
                }.padding(.bottom,30)
                
                ChordsView(chords: song.chords, style: .pictogram_large)

                PlaybackTimelineView(url: song.url)
                    .frame(height: 130)

                // AudioPlayerView(scale: .large, song: $song, songsList: songsList)
                //     .padding(.horizontal,20)
                
            }
        }
    }
}

