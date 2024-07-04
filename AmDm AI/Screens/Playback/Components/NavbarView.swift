//
//  NavbarView.swift
//  AmDm AI
//
//  Created by Anton on 03/07/2024.
//

import SwiftUI

struct Navbar: View {
    @Binding var isRenamePopupVisible: Bool
    @Binding var isMoreShapesPopupPresented: Bool
    @ObservedObject var song: Song
    @ObservedObject var songsList: SongsList
    @State var songName = ""
    
    var body: some View {
        Button {
            isRenamePopupVisible = true
        } label: {
            Image(systemName: "pencil")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 20, height: 20)
                .foregroundStyle(.secondaryText)
                .padding(.leading, 20)
                .padding(.top,5)
        }
        .disabled(isMoreShapesPopupPresented)
        .alert("Rename recording", isPresented: $isRenamePopupVisible) {
            TextField(song.name, text: $songName)
            Button("Save", action: {
                self.song.name = songName
                self.songsList.databaseService.updateSong(song: song)
            })
            Button("Cancel", role: .cancel) { }
        } message: { }
        Spacer()
        NavigationLink(destination: AllSongs()) {
            Image(systemName: "xmark")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 20, height: 20)
                .foregroundStyle(.secondaryText)
                .padding(.trailing, 20)
        }
    }
}
