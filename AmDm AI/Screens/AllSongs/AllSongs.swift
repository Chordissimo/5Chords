//
//  AllSongsView.swift
//  AmDm AI
//
//  Created by Anton on 25/03/2024.
//

import SwiftUI

struct AllSongs: View {
    @State var toggleRecordButton: Bool = false
    @Environment(\.modelContext) private var modelContext
    @State var user = User()
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                VStack {
                    ScrollView {
                        SongView()
                    }
                    VStack {
                        Button {
                            toggleRecordButton = !toggleRecordButton
                        } label: {
                            Image(systemName: toggleRecordButton ? "stop.circle" : "record.circle")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundStyle(Color.red)
                                .frame(width: 80, height: 80)
                        }
                    }
                    .ignoresSafeArea()
                    .frame(height: 150).frame(maxWidth: .infinity)
                    .background(Color.customDarkGray)
                }
                .navigationTitle("All songs")
                .toolbarBackground(Color.black, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarColorScheme(.dark)
                .fullScreenCover(isPresented: $user.accessDisallowed) {
                    Subscription(user: $user)
                }
            }
        }
    }
}

#Preview {
    AllSongs()
}

struct SongView: View {
    @State private var playbackPosition = 0.0
    
    init() {
        let progressCircleConfig = UIImage.SymbolConfiguration(scale: .small)
        let progressCircleColorConfig = UIImage.SymbolConfiguration(hierarchicalColor: UIColor(red: 255, green: 255, blue: 255, alpha: 1))
        let thumbImage = UIImage(systemName: "circle.fill",withConfiguration: progressCircleConfig)?.applyingSymbolConfiguration(progressCircleColorConfig)
        UISlider.appearance().setThumbImage(thumbImage, for: .normal)
    }
    
    var body: some View {
        ForEach(SongList().songs) { song in
            VStack {
                HStack {
                    VStack(alignment: .leading) { //name, date
                        Text(song.name)
                            .foregroundStyle(Color.white)
                            .fontWeight(.semibold)
                            .font(.system(size: 20))
                        Text(dateToString(date: song.created))
                            .foregroundStyle(Color.white)
                    }.padding()
                    
                    
                    Spacer()
                    
                    VStack { //icon
                        Image(systemName: "ellipsis.circle")
                            .resizable()
                            .frame(width: 28, height: 28)
                            .aspectRatio(contentMode: .fit)
                            .foregroundStyle(Color.purple)
                    }
                }
                HStack { //chords
                    ForEach(song.chords) { chord in
                        Text(chord.name)
                            .foregroundStyle(Color.white)
                            .font(.system(size: 14))
                            .fontWeight(.semibold)
                    }
                }
                Slider(value: $playbackPosition).padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                
                HStack { //controls
                    Image(systemName: "slider.horizontal.3")
                        .resizable()
                        .frame(width: 22, height: 22)
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(Color.purple)
                    Spacer()
                    Image(systemName: "gobackward.5")
                        .resizable()
                        .frame(width: 28, height: 28)
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(Color.white)
                    Image(systemName: "play.fill")
                        .resizable()
                        .frame(width: 28, height: 28)
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(Color.white)
                        .padding(EdgeInsets(top: 0, leading: 30, bottom: 0, trailing: 25))
                    Image(systemName: "goforward.5")
                        .resizable()
                        .frame(width: 28, height: 28)
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(Color.white)
                    Spacer()
                    Image(systemName: "trash")
                        .resizable()
                        .frame(width: 22, height: 22)
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(Color.purple)
                }.padding(EdgeInsets(top: 0, leading: 10, bottom: 15, trailing: 10))
                
                Divider().overlay(Color.customGray)
            }
            
        }
    }
}

struct Song: Identifiable, Hashable {
    let id = UUID()
    let created: Date = Date()
    var name: String = "Untitled song"
    var duration: Int = 0
    var chords = [Chord]()
}

struct Chord: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let description: String
    //    let pictogram: ???
}

struct SongList {
    let id = UUID()
    let songs = [
        Song(name: "Stareway to heaven", duration: 100, chords: [
            Chord(name: "Am", description: "A minor"),
            Chord(name: "G", description: "G major"),
            Chord(name: "F", description: "F major"),
            Chord(name: "Fmaj7", description: "F major 7"),
            Chord(name: "Dsus2", description: "D suspended 2"),
            Chord(name: "Dsus4", description: "D suspended 4"),
            Chord(name: "Csus2", description: "C suspended 2"),
            Chord(name: "Csus4", description: "C suspended 4")]
            ),
        Song(name: "Back in Black", duration: 60, chords: [
            Chord(name: "E", description: "E minor"),
            Chord(name: "D", description: "D major"),
            Chord(name: "A", description: "A major")]
            )
        
    ]
}

func dateToString(date: Date) -> String {
    let calendar = Calendar.current
    let daysBetween = calendar.dateComponents([.day], from: date, to: Date()).day
    
    if daysBetween == 0 {
        return date.formatted(date: .omitted, time: .shortened)
    } else if daysBetween == 1 {
        return "Yesterday"
    } else {
        return date.formatted(date: .abbreviated, time: .omitted)
    }
}
