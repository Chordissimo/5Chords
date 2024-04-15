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
                ZStack {
                    Color.black.ignoresSafeArea()
                    VStack {
                        //Youtube link
                        VStack {
                            YTlink(songsList: _songsList)
                        }
                        .padding(.top,5)
                        .padding(.bottom, 10)
                        .padding(.trailing, 20)
                        
                        //List of recordings
                        SongsListView(songsList: songsList)
                        
                        //Record button
                        VStack {
                            ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
                                if songsList.recordStarted {
                                    TimerView(timerState: $songsList.recordStarted, duration: $songsList.duration, songName: songsList.getNewSongName())
                                        .padding(.top, 20)
                                        .frame(height: windowHeight * 0.3)
                                }
                                Rectangle()
                                    .ignoresSafeArea()
                                    .ignoresSafeArea(.keyboard)
                                    .frame(height: windowHeight * 0.1)
                                    .frame(maxWidth: .infinity)
                                    .foregroundColor(Color.customDarkGray)
                                
                                
                                LimitedVersionLabel(isLimitedVersion: user.subscriptionPlanId == 0)
                                
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
                    }
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
        }.edgesIgnoringSafeArea(.bottom)
    }
}


#Preview {
    AllSongs()
}
