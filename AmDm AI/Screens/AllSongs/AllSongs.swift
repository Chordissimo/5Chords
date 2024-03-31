//
//  AllSongsView.swift
//  AmDm AI
//
//  Created by Anton on 25/03/2024.
//

import SwiftUI

struct AllSongs: View {
    @State var recordStarted: Bool = false
    @State var bottomSheetVisible = false
    @Environment(\.modelContext) private var modelContext
    @State var user = User()
    @State var YTtext: String = ""
    
    @ObservedObject var songsList = SongsList()
    
    
    var body: some View {
        GeometryReader { geometry in
            let windowHeight = geometry.size.height
            NavigationStack {
                ZStack {
                    Color.black.ignoresSafeArea()
                    VStack {
                        ScrollView {
                            VStack {
                                YTlink(text: $YTtext)
                            }
                            .padding(.top,5)
                            .padding(.bottom, 10)
                            .padding(.trailing, 20)
                            SongsListView(songsList: _songsList)
                        }
                        
                        VStack {
                            ZStack(alignment: .bottom) {
                                RoundedRectangle(cornerRadius: recordStarted ? 16 : 0)
                                    .ignoresSafeArea()
                                    .ignoresSafeArea(.keyboard)
                                    .frame(height: recordStarted ? windowHeight * 0.25 : windowHeight * 0.1)
                                    .frame(maxWidth: .infinity)
                                    .foregroundColor(Color.customDarkGray)
                                    .zIndex(0)
                                
                                VStack {
                                    if recordStarted {
                                        TimerView(timerState: $recordStarted)
                                            .padding(.top, 20)
                                            .transition(.asymmetric(insertion: AnyTransition.move(edge: .bottom).combined(with: .opacity), removal: AnyTransition.move(edge: .top).combined(with: .opacity).animation(.easeOut(duration: 0.1))))

                                    }
                                    Spacer()
                                    RecordButton(parentHeight: windowHeight * 0.1) {
                                        recordStarted.toggle()
                                        if(recordStarted == false) {
                                            songsList.add()
                                        }
                                    }
                                }
                                .frame(height: recordStarted ? windowHeight * 0.25 : windowHeight * 0.1)
                            }
                        }
                    }
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
