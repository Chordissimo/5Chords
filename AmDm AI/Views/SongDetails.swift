//
//  SongPlayback.swift
//  AmDm AI
//
//  Created by Anton on 01/04/2024.
//

import SwiftUI
import SwiftyChords

struct SongDetails: View {
    @Binding var song: SongData
    @Binding var isSongDetailsPresented: Bool
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
    
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
                }.padding(.bottom,30)
                
                ChordsView(chords: song.chords, style: ChordDisplayStyle.pictogram)

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
        }
    }
}


#Preview {
    @State var isSongDetailsPresented: Bool = true
    @State var song = SongData(name: "Back in Black", duration: TimeInterval(60), chords: [
        Chord(key: Chords.Key.e, suffix: Chords.Suffix.major),
        Chord(key: Chords.Key.d, suffix: Chords.Suffix.major),
        Chord(key: Chords.Key.e, suffix: Chords.Suffix.major),
        Chord(key: Chords.Key.d, suffix: Chords.Suffix.major),
        Chord(key: Chords.Key.e, suffix: Chords.Suffix.major),
        Chord(key: Chords.Key.d, suffix: Chords.Suffix.major),
        Chord(key: Chords.Key.a, suffix: Chords.Suffix.major)]
    )
    return SongDetails(song: $song, isSongDetailsPresented: $isSongDetailsPresented)
}



