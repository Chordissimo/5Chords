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
    @State var showError: Bool = false
    
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
                                .lineLimit(1)
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
                .onChange(of: song.recognitionStatus) {
                    if song.recognitionStatus == .serverError {
                        showError = true
                    }
                }
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
                        Text(song.name)
                            .foregroundStyle(Color.white)
                            .fontWeight(.semibold)
                            .font(.system(size: 18))
                            .lineLimit(1)
                        
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
            Divider()
        }
        .onAppear {
            showError = song.recognitionStatus == .serverError
        }
    }
}
