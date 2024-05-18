////
////  UserDataModel.swift
////  AmDm AI
////
////  Created by Anton on 06/04/2024.
////
//
//import SwiftUI
//
//struct SongsListView: View {
//    @ObservedObject var songsList: SongsList
//    @State var isSongDetailsPresented: Bool = false
//    @State var initialAnimationStep = 0
//    
//    var body: some View {
//        ZStack {
//            if initialAnimationStep == 1 {
//                if !songsList.recordStarted {
//                    EmptyListView()
//                }
//            } else if initialAnimationStep == 2 {
//                ScrollView {
//                    ForEach($songsList.songs) { song in
//                        ContentCell(
//                            song: song,
//                            songsList: songsList,
//                            isSongDetailsPresented: $isSongDetailsPresented
//                        )
//                        .body.modifier(ScrollCell())
//                        .onTapGesture {
//                            if !song.isExpanded.wrappedValue {
//                                withAnimation(.linear(duration: 0.2)) {
//                                    songsList.expand(song: song.wrappedValue)
//                                }
//                            }
//                        }
//                    }
//                    .listRowBackground(Color.black)
//                    .listRowSeparatorTint(.customGray)
//                    .padding(.top, 10)
//                }
//                .transition(.move(edge: .top))
//                .listStyle(.plain)
//                .background(Color.black)
//            }
//        }
//        .onAppear {
//            withAnimation(.snappy) {
//                initialAnimationStep = songsList.songs.count == 0 ? 1 : 2
//            }
//        }
//        .onChange(of: songsList.songs.count, perform: { newValue in
//            withAnimation {
//                initialAnimationStep = newValue == 0 ? 1 : 2
////                isSongDetailsPresented = true
//            }
//        })
//    }
//}
//
//struct ContentCell {
//    @Binding var song: Song
//    @ObservedObject var songsList: SongsList
//    @Binding var isSongDetailsPresented: Bool
//    
//    var body: some View {
//        HStack {
//            VStack(alignment: .leading) {
//                EditableText(text: $song.name, style: EditableTextDisplayStyle.songTitle, isEditable: song.isExpanded)
//                HStack {
//                    DateLabel(date: song.created, color: Color.customGray1)
//                    Spacer()
//                    if !song.isExpanded {
//                        Text(formatTime(song.duration))
//                            .foregroundStyle(Color.customGray1)
//                            .font(.system(size: 15))
//                    } else {
//                        ActionButton(imageName: "trash") {
//                            songsList.del(song: song)
//                        }
//                        .frame(width: 18)
//                    }
//                }
//                if song.isExpanded {
//                    VStack(alignment: .leading) {
//                        VStack {
//                            HStack {
//                                Button {
//                                    isSongDetailsPresented = true
//                                } label: {
//                                    ChordsView(chords: song.chords, style: .pictogram_small)
//                                        .padding(.vertical, 10)
//                                }
//                                .buttonStyle(BorderlessButtonStyle())
//                                
//                                Spacer()
//
//                                Button {
//                                    isSongDetailsPresented = true
//                                } label: {
//                                    Image(systemName: "play.circle")
//                                        .resizable()
//                                        .frame(width: 45, height: 45)
//                                        .foregroundColor(.white)
//                                }
//                                .buttonStyle(BorderlessButtonStyle())
//                            }
//                        }
//                    }
//                    .navigationDestination(isPresented: $isSongDetailsPresented) {
//                        SongDetails(song: $song, songsList: songsList, isSongDetailsPresented: $isSongDetailsPresented)
//                    }
////                    .fullScreenCover(isPresented: $isSongDetailsPresented) {
////                        SongDetails(song: $song, songsList: songsList, isSongDetailsPresented: $isSongDetailsPresented)
////                    }
//                }
//            }
//            Spacer()
//        }
//        .contentShape(Rectangle())
//        .padding(.horizontal,10)
//    }
//}
//
//struct ScrollCell: ViewModifier {
//    func body(content: Content) -> some View {
//        Group {
//            content
//            Divider()
//                .background(Color.customGray1)
//                .padding(.horizontal,10)
//        }
//    }
//}
//
//struct EmptyListView: View {
//    var body: some View {
//        ZStack {
//            VStack {
//                Image(systemName: "waveform.path")
//                    .resizable()
//                    .foregroundColor(Color.customGray1)
//                    .aspectRatio(contentMode: .fit)
//                    .frame(width: 60, height: 60)
//                    .padding()
//                VStack {
//                    Text("No recordings")
//                        .foregroundStyle(Color.white)
//                        .font(.system(size: 28))
//                        .fontWeight(.bold)
//                    Text("Songs you record will appear here.")
//                        .foregroundStyle(Color.customGray1)
//                }
//            }
//            .frame(maxHeight: .infinity)
//        }
//    }
//}
//
//#Preview {
//    @ObservedObject var songsList = SongsList()
//    return ZStack {
//        Color.black.ignoresSafeArea()
//        SongsListView(songsList: songsList)
//    }
//}
