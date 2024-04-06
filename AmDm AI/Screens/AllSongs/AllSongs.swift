//
//  AllSongsView.swift
//  AmDm AI
//
//  Created by Anton on 25/03/2024.
//

import SwiftUI

struct AllSongs: View {
    @State var recordStarted: Bool = false
    @Environment(\.modelContext) private var modelContext
    @State var user = User()
    @State var duration: TimeInterval = 0
    @State var runsCount: Int = 0
    
    @ObservedObject var songsList = SongsList()
    
    
    var body: some View {
        let maxDuration = user.subscriptionPlanId == 0 ? 15.0 : 0.0
        
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
                                RoundedRectangle(cornerRadius: recordStarted ? 16 : 0)
                                    .ignoresSafeArea()
                                    .ignoresSafeArea(.keyboard)
                                    .frame(height: recordStarted ? windowHeight * 0.25 : windowHeight * 0.1)
                                    .frame(maxWidth: .infinity)
                                    .foregroundColor(Color.customDarkGray)
                                
                                RecordButton(height: windowHeight * 0.1, recordStarted: $recordStarted) {
                                    if (user.subscriptionPlanId == 0 && runsCount < 3) || user.subscriptionPlanId > 0 {
                                        recordStarted.toggle()
                                        if recordStarted == false {
                                            songsList.add(duration: duration)
                                            duration = TimeInterval(0)
                                            runsCount = runsCount < 3 ? runsCount + 1 : runsCount
                                        }
                                    } else {
                                        user.accessDisallowed = true
                                    }
                                }
                                VStack {
                                    if recordStarted {
                                        TimerView(timerState: $recordStarted, duration: $duration, maxDuration: maxDuration, songName: songsList.getNewSongName())
                                            .padding(.top, 20)
                                            .onReceive(NotificationCenter.default.publisher(for: Notification.Name.autoStop)) { obj in
                                                songsList.add(duration: duration)
                                                duration = TimeInterval(0)
                                                runsCount = runsCount < 3 ? runsCount + 1 : runsCount
                                            }
                                    }

                                    Spacer()
                                    if user.subscriptionPlanId == 0 {
                                        Text("Limited version")
                                            .foregroundStyle(.customGray)
                                            .padding(.bottom,5)
                                    }
                                }
                                .ignoresSafeArea(.all, edges: .bottom)
                                .frame(height: recordStarted ? windowHeight * 0.25 : windowHeight * 0.1)
                            }
                        }
                    }
                }
                .navigationBarItems(
                    leading:
                        ActionButton(systemImageName: "slider.horizontal.3") {
                            print("Left tapped")
                        }
                        .foregroundColor(.purple)
                    , trailing:
                        ActionButton(title: "Upload") {
                            print("Upload tapped")
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
            }
        }
    }
}


#Preview {
    AllSongs()
}
