//
//  AllSongsView.swift
//  AmDm AI
//
//  Created by Anton on 25/03/2024.
//

import SwiftUI

struct AllSongs: View {
    
    @Environment(\.modelContext) private var modelContext
    @State var user = User()
    @State var runsCount: Int = 0
    @State var showSettings = false
    @State var showUpload = false
    @ObservedObject var songsList = SongsList()
    
    
    var body: some View {
        
        GeometryReader { geometry in
            let windowHeight = geometry.size.height
            NavigationStack {
                ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
                    Color.black.ignoresSafeArea()
                    VStack {
                        VStack { // Youtube
                            YTlink(songsList: _songsList)
                                .padding(EdgeInsets(top: 5, leading: 0, bottom: 10, trailing: 20))
                            Spacer()
                            SongsListView(songsList: songsList)
                        }
                        VStack {
                            Color.white
                        }
                        .ignoresSafeArea()
                        .frame(height: windowHeight * 0.1)
                    }
                    VStack { // recording panel with timer
                        if songsList.recordStarted {
                            Color.white.opacity(0.01)
                            VStack {
                                TimerView(timerState: $songsList.recordStarted, duration: $songsList.duration, songName: songsList.getNewSongName())
                                    .padding(.top, 20)
                                    .frame(height: windowHeight * 0.3)
                            }
                            .transition(.move(edge: .bottom))
                            .ignoresSafeArea()
                            .frame(height: windowHeight * 0.3)
                        }
                    }
                    
                    VStack { // record button
                        ZStack {
                            Color.customDarkGray
                            RecordButton(height: windowHeight * 0.1, recordStarted: $songsList.recordStarted) {
                                if songsList.recordStarted {
                                    songsList.stopRecording()
                                } else {
                                    songsList.startRecording()
                                }
                            }
                            .padding(.bottom, 12)
                        }
                    }
                    .ignoresSafeArea()
                    .frame(height: windowHeight * 0.1)
                    
                    VStack { // limited version notice
                        LimitedVersionLabel(isLimitedVersion: user.subscriptionPlanId == 0)
                    }
                    .ignoresSafeArea()
                }
                .onAppear {
                    ScreenDimentions.maxWidth = geometry.size.width
                }
                .navigationBarItems(
                    leading:
                        ActionButton(systemImageName: "slider.horizontal.3") {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            }
                        }
                        .foregroundColor(.purple)
                    , trailing:
                        ActionButton(title: "Upload") {
                            showUpload = true
                        }
                )
                .ignoresSafeArea(.keyboard)
                .navigationTitle("All songs")
                .toolbarBackground(Color.black, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarColorScheme(.dark)
                .fullScreenCover(isPresented: $user.accessDisallowed) {
                    Subscription(user: $user)
                }
                .fullScreenCover(isPresented: $showSettings) {
                    Settings(showSettings: $showSettings)
                        .animation(.easeInOut(duration: 2), value: showSettings)
                }
                .fileImporter(
                    isPresented: $showUpload,
                    allowedContentTypes: [.plainText]
                ) { result in
                    switch result {
                    case .success(let file):
                        print(file.absoluteString)
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}


#Preview {
    AllSongs()
}
