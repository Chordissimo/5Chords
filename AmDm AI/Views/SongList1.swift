//
//  SongsList.swift
//  AmDm AI
//
//  Created by Anton on 30/03/2024.
//

import SwiftUI

struct SongsListView1: View {
    @ObservedObject var songsList: SongsList
    @State var pleaseExpand: Bool = false
    
    init(songsList: ObservedObject<SongsList>) {
        self._songsList = songsList
    }
    
    var body: some View {
        List {
            ForEach($songsList.songs) { song in
                VStack {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(song.name.wrappedValue).foregroundStyle(Color.white).fontWeight(.semibold).font(.system(size: 17)).padding(.top, 1)
                        HStack {
                            DateLabel(date: song.created.wrappedValue, color: Color.customGray1).padding(.top,1)
                            
                            Spacer()
                            
                            if !song.isExpanded.wrappedValue {
                                Text(formatTime(song.duration.wrappedValue)).foregroundStyle(Color.customGray1).font(.system(size: 15)).padding(.top,4)
                            }
                        }
                        .transition(.asymmetric(
                            insertion: AnyTransition.identity,
                            removal: AnyTransition.move(edge: .bottom)))
                    }
                    .background(Color.black)
                    .onTapGesture {
                        withAnimation {
                            songsList.expand(song: song.wrappedValue)
                        }
                    }
                    
                    if song.isExpanded.wrappedValue {
                        Spacer()
                        VStack(alignment: .leading, spacing: 0) {
                            Text("description description description description description description description description description description description description description description").foregroundStyle(.white)
                        }
                        .transition(.asymmetric(
                            insertion: AnyTransition.move(edge: .top),
                            removal: AnyTransition.identity))
                    }

                }
                .background(Color.black)
            }
            .listRowBackground(Color.black)
            .listRowSeparatorTint(.customGray)
        }
        .listStyle(.plain)
        .background(Color.black)
    }
}

extension Notification.Name {
    static let expand = Notification.Name("expand")
}

#Preview {
    @ObservedObject var songsList = SongsList()
    //        songsList.songs.removeAll()
    return ZStack {
        Color.black.ignoresSafeArea()
        SongsListView1(songsList: _songsList)
    }
}
