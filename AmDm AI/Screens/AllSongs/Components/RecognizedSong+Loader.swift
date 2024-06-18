//
//  RecognizedSong+Loader.swift
//  AmDm AI
//
//  Created by Anton on 20/05/2024.
//

import SwiftUI

struct RecognizedSongView: View {
    @ObservedObject var songsList: SongsList
    @ObservedObject var song: Song
    @Binding var focusedField: String
    
    @FocusState var isFocused: Bool
    @State var songName: String = ""
    @State var showError: Bool = false
    
    init(songsList: SongsList, song: Song, focusedField: Binding<String>) {
        self.songsList = songsList
        self.song = song
        self._focusedField = focusedField
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if song.isFakeLoaderVisible {
                VStack(alignment: .leading) {
                    HStack {
                        CircularProgressBarView(song: song, songsList: songsList)
                            .frame(width: 60, height: 60)
                        
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Extracting chords and lyrics")
                                .font(.system(size: 18))
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                                .padding(.bottom, 3)
                                .opacityAnimaion()
                            
                            RoundedRectangle(cornerRadius: 4)
                                .frame(width: 40, height: 12)
                                .foregroundColor(.disabledText)
                                .padding(.bottom, 5)
                                .opacityAnimaion()
                            
                            RoundedRectangle(cornerRadius: 4)
                                .frame(width: 140, height: 12)
                                .foregroundColor(.disabledText)
                                .opacityAnimaion()
                        }
                        .padding(.leading, 10)
                    }
                }
                .onChange(of: song.recognitionStatus, { oldValue, newValue in
                    if song.recognitionStatus == .serverError {
                        showError = true
                    }
                })
                .alert("Something went wrong", isPresented: $showError) {
                    Button {
                        songsList.del(song: song)
                    } label: {
                        Text("Ok")
                    }
                } message: {
                    Text("Please try again later.")
                }
            } else {
                HStack {
                    if song.songType == .youtube && song.thumbnailUrl.absoluteString != "" {
                        AsyncImage(url: URL(string: song.thumbnailUrl.absoluteString)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 90, height: 90, alignment: .center)
                        } placeholder: {
                            Color.gray5.frame(width: 60, height: 60)
                        }
                        .frame(width: 60, height: 60, alignment: .center)
                        .clipShape(.rect(cornerRadius: 12))
                    } else if song.songType == .recorded {
                        Image(systemName: "mic.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .aspectRatio(contentMode: .fill)
                            .foregroundColor(.disabledText)
                    } else {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .frame(width: 60, height: 60)
                                .foregroundColor(.disabledText)
                            Text(song.ext.uppercased())
                                .fontWeight(.bold)
                                .font(.system(size: 16))
                                .foregroundColor(.gray10)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 0) {
                        TextField(song.name, text: $songName, onEditingChanged: { edit in
                            if edit {
                                focusedField = song.id
                            }
                        })
                        .onSubmit {
                            if songName == "" {
                                songName = song.name
                            } else {
                                song.name = songName
                                songsList.databaseService.updateSong(song: song)
                            }
                        }
                        .foregroundStyle(Color.white)
                        .fontWeight(.semibold)
                        .font(.system(size: 18))
                        .focused($isFocused)
                        .onAppear {
                            self.songName = song.name
                        }
                        .onChange(of: focusedField, { oldValue, newValue in
                            if focusedField != song.id {
                                isFocused = false
                                if songName == "" {
                                    songName = song.name
                                } else {
                                    song.name = songName
                                    songsList.databaseService.updateSong(song: song)
                                }
                            }
                        })
                        .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { obj in
                            if let textField = obj.object as? UITextField {
                                textField.selectAll(nil)
                            }
                        }
                        
                        Text(formatTime(song.duration, precision: .seconds))
                            .font(.system(size: 14))
                            .fontWeight(.bold)
                            .foregroundStyle(.secondaryText)
                        
                        Text(song.songType.rawValue + " · " + dateToString(song.created))
                            .font(.system(size: 14))
                            .fontWeight(.regular)
                            .foregroundStyle(.disabledText)
                    }
                    .padding(.leading, 10)

                }
                .swipeActions(allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        withAnimation {
                            songsList.del(song: song)
                        }
                    } label: {
                        Label("Delete", systemImage: "trash.fill")
                    }
                }
            }
        }
    }
}
