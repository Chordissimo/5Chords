//
//  SongPlayback.swift
//  AmDm AI
//
//  Created by Anton on 01/04/2024.
//

import SwiftUI

struct SongDetails: View {
    @Binding var song: SongData
    @Binding var isSongDetailsPresented: Bool
    
    var body: some View {
        ZStack {
            Color.customDarkGray.ignoresSafeArea()
            VStack {
                HStack {
                    Spacer()
                    ActionButton(systemImageName: "xmark.circle.fill") {
                        isSongDetailsPresented = false
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
                }
                Spacer()

                VStack {
                    PlaybackSlider(playbackPosition: $song.playbackPosition, duration: $song.duration)
                }.padding()
                
                VStack {
                    Text("00:00.00")
                        .foregroundStyle(Color.white)
                        .font(.system(size: 40))
                        .fontWeight(.bold)
                }
                
                HStack {
                    PlaybackColtrols(scale: .large).frame(width: 100)
                }.padding()
            }
            .frame(width: .infinity)
        }
    }
}

#Preview {
    @State var isSongDetailsPresented: Bool = true
    @State var song = SongData(name: "Back in Black", duration: TimeInterval(60), chords: [
        Chord(name: "E", description: "E minor"),
        Chord(name: "D", description: "D major"),
        Chord(name: "A", description: "A major")]
    )
    return SongDetails(song: $song, isSongDetailsPresented: $isSongDetailsPresented)
}



