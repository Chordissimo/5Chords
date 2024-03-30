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
        let progressCircleConfig = UIImage.SymbolConfiguration(scale: .small)
        let progressCircleColorConfig = UIImage.SymbolConfiguration(hierarchicalColor: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1))
        let thumbImage = UIImage(systemName: "circle.fill",withConfiguration: progressCircleConfig)?.applyingSymbolConfiguration(progressCircleColorConfig)
        UISlider.appearance().setThumbImage(thumbImage, for: .normal)
        self._songsList = songsList
    }
    
    var body: some View {
        ForEach(songsList.songs.indices, id: \.self) { songIndex in
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        //Title
                        EditableText(text: $songsList.songs[songIndex].name, style: EditableTextDisplayStyle.songTitle)
                        
                        //Song creation date
                        DateLabel(date: songsList.songs[songIndex].created)
                    }.padding()
                    Spacer()
                    VStack {
                        //Actions sheet toggle (circle with 3 dots)
                        ActionsToggle()
                    }
                }
                    
                HStack {
                    //chords
                    ChordView(chords: songsList.songs[songIndex].chords)
                }
                
                HStack {
                    //playback progress slider
                    PlaybackSlider(playbackPosition: $songsList.songs[songIndex].playbackPosition)
                }
                
                HStack {
                    // controls
                    OptionsToggle()
                    Spacer()
                    PlaybackColtrols()
                    Spacer()
                    ActionButton(size: 22, systemImageName: "trash") {
                        songsList.del(index: songIndex)
                    }
                }.padding(EdgeInsets(top: 0, leading: 10, bottom: 15, trailing: 10))
                
                Divider().overlay(Color.customGray)
            }
            
        }
    }
}

#Preview {
    @ObservedObject var songsList = SongsList()
    return SongsListView(songsList: _songsList)
}
