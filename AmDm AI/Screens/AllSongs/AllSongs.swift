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
    @ObservedObject var songsList = SongsList()
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                VStack(spacing: 0) {
                    
                    ScrollView {
                        SongsListView(songsList: _songsList)
                    }
                    
                    VStack(spacing: 0)  {
                        Button {
                            toggleRecordButton.toggle()
                            if(toggleRecordButton == false) {
                                songsList.add()
                            }
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
                .navigationBarItems(
                    leading:
                        ActionButton(systemImageName: "chevron.left") {
                            print("Left tapped")
                        },
                    trailing:
                        ActionButton(title: "Edit") {
                            print("Edit tapped")
                        }
                )
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
