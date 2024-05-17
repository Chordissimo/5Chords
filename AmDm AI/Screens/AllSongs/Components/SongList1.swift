//
//  SongList1.swift
//  AmDm AI
//
//  Created by Anton on 16/05/2024.
//

import SwiftUI

struct SongList1: View {
    @ObservedObject var songsList: SongsList

    var body: some View {
        NavigationStack {
            List($songsList.songs) { song in
                VStack(alignment: .leading) {
                    HStack {
                        if song.songType.wrappedValue == .youtube && song.thumbnailUrl.wrappedValue.absoluteString != "" {
                            AsyncImage(url: URL(string: song.thumbnailUrl.wrappedValue.absoluteString)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 60, height: 60)
                                    .clipShape(.rect(cornerRadius: 12))
                            } placeholder: {
                                Color.gray5
                            }
                            
                        } else {
                            Image(song.songType.wrappedValue == .localFile ? "test.image" : "custom.mic.circle.fill")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .aspectRatio(contentMode: .fill)
                        }
                        
                        VStack(alignment: .leading, spacing: 0) {
                            EditableText(text: song.name, isEditable: true)
                            
                            Text(formatTime(song.duration.wrappedValue, precision: .seconds))
                                .font(.system(size: 14))
                                .fontWeight(.bold)
                                .foregroundStyle(.prochordsLightGray)
                            
                            Text(song.songType.wrappedValue.rawValue + " · " + dateToString(song.created.wrappedValue))
                                .font(.system(size: 14))
                                .fontWeight(.regular)
                                .foregroundStyle(.prochordsDarkGray)
                        }
                    }
                    .swipeActions(allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            print("Delete")
                        } label: {
                            Label("Delete", systemImage: "trash.fill")
                        }
                    }
                }
                .padding(.top,5)
                .listRowSeparator(.automatic)
                .listRowBackground(Color.gray5)
//                NavigationLink(destination: DetailView(item: item)) {
//                }
            }
            .listStyle(.plain)
        }
    }
}
