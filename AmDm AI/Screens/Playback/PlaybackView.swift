////
////  PlaybackView.swift
////  AmDm AI
////
////  Created by Anton on 22/05/2024.
////
//
import SwiftUI
import YouTubePlayerKit
import SwiftyChords

struct PlaybackView: View {
    @ObservedObject var song: Song
    @ObservedObject var songsList: SongsList
    @AppStorage("isPlaybackPanelMaximized") var isPlaybackPanelMaximized: Bool = true
    @AppStorage("isLimited") var isLimited: Bool = false
    @StateObject var player = UniPlayer()
    @State var currentTimeframeIndex: Int = 0
    @State var currentChordIndex: Int = 0
    @State var bottomPanelHieght: CGFloat = LyricsViewModelConstants.minBottomPanelHeight
    @State var isMoreShapesPopupPresented: Bool = false
    @State var isRenamePopupVisible: Bool = false
    @State var showOptions: Bool = false
    @State var songName: String = ""
//    @State var showEditChords = false
//    @State var showEditChordsAds = false
//    @State var showPaywall = false
    let lyricsfontSize = LyricsViewModelConstants.lyricsfontSize
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            if width > 0 {
                ZStack {
                    Color.gray5
                    VStack {
                        TopPanel(
                            song: song,
                            songsList: songsList,
                            player: player,
                            isRenamePopupVisible: $isRenamePopupVisible,
                            isMoreShapesPopupPresented: $isMoreShapesPopupPresented,
                            currentChordIndex: $currentChordIndex,
                            bottomPanelHieght: $bottomPanelHieght,
                            topInset: geometry.safeAreaInsets.top,
                            width: width
                        )
                        
                        Spacer()
                        
                        /// MARK: chords and lyrics
                        ChordsAndLyrics(
                            song: song,
                            songsList: songsList,
                            player: player,
                            currentChordIndex: $currentChordIndex,
                            currentTimeframeIndex: $currentTimeframeIndex,
                            isMoreShapesPopupPresented: $isMoreShapesPopupPresented,
                            bottomPanelHieght: $bottomPanelHieght,
                            width: width
                        )
                        
                        /// MARK: Bottom panel
                        ZStack(alignment: Alignment(horizontal: .center, vertical: .top)) {
                            VStack(spacing: 0) {
                                VStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.secondaryText)
                                        .frame(width: 30, height: 5)
                                }
                                .padding(.vertical, 8)
                                
                                Spacer()
                                
                                /// MARK: Chord shapes in a scrollview
                                if isMoreShapesPopupPresented {
                                    MoreShapesView(isMoreShapesPopupPresented: $isMoreShapesPopupPresented, uiChord: song.intervals[currentChordIndex].uiChord)
                                } else {
                                    if showOptions {
                                        OptionsView(hideLyrics: $song.hideLyrics, onChangeValue: { transposeUp in
                                            song.transpose(transposeUp: transposeUp)
                                            song.createTimeframes()
                                            songsList.databaseService.updateIntervals(song: song)
                                        }, onReset: { reset in
                                            song.intervals = []
                                            song.createTimeframes()
                                            songsList.databaseService.updateIntervals(song: song)
                                        })
                                    } else if isPlaybackPanelMaximized {
                                        ChordShapesView(song: song, currentChordIndex: $currentChordIndex)
                                    }
                                }
                                
                                /// MARK: playback controls
                                if !isMoreShapesPopupPresented && !showOptions {
                                    PlaybackControls(
                                        player: player,
                                        song: song,
                                        currentChordIndex: $currentChordIndex,
                                        currentTimeframeIndex: $currentTimeframeIndex,
                                        bottomPanelHieght: $bottomPanelHieght,
                                        isPlaybackPanelMaximized: $isPlaybackPanelMaximized,
                                        isMoreShapesPopupPresented: $isMoreShapesPopupPresented,
                                        showOptions: $showOptions
                                    )
                                }
                            }
                            .frame(width: width, height: bottomPanelHieght)
                            .padding(.bottom, geometry.safeAreaInsets.bottom)
                            .background(Color.customDarkGray)
                            .clipShape(.rect(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(.gray20, lineWidth: 1)
                            )
                            .gesture(
                                DragGesture().onChanged { value in
                                    if !isMoreShapesPopupPresented {
                                        isPlaybackPanelMaximized = value.translation.height <= 0
                                        withAnimation(.easeInOut(duration: 0.1)) {
                                            bottomPanelHieght = value.translation.height <= 0 ? LyricsViewModelConstants.maxBottomPanelHeight : LyricsViewModelConstants.minBottomPanelHeight
                                        }
                                    }
                                }
                            )
                            
                            /// MARK: Options close, More shapes buttons
                            if !player.isPlaying && (isPlaybackPanelMaximized || showOptions) {
                                ZStack {
                                    if showOptions {
                                        VStack {
                                            Text(isLimited ? "Premium features" : "Preferences")
                                                .font(.system(size: 16))
                                                .foregroundStyle(.gray40)
                                                .fontWeight(.semibold)
                                                .padding(.top, 20)
                                        }
                                    }
                                    HStack {
                                        Spacer()
                                        Button {
                                            if showOptions {
                                                showOptions = false
                                            } else {
                                                isMoreShapesPopupPresented.toggle()
                                            }
                                            withAnimation(.easeInOut(duration: 0.1)) {
                                                bottomPanelHieght = isMoreShapesPopupPresented ? LyricsViewModelConstants.moreShapesPanelHeight : (showOptions || isPlaybackPanelMaximized ? LyricsViewModelConstants.maxBottomPanelHeight : LyricsViewModelConstants.minBottomPanelHeight)
                                            }
                                        } label: {
                                            Image(systemName: isMoreShapesPopupPresented ? "chevron.down" : (showOptions ? "xmark.circle.fill" : "book.fill"))
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 22, height: 22)
                                                .foregroundStyle(.secondaryText)
                                        }
                                        .padding(.trailing, 30)
                                        .padding(.top, 20)
                                    }
                                    .frame(width: width)
                                }
                            }
                        }
                    }
                }
                .ignoresSafeArea()
                .navigationBarBackButtonHidden(true)
                .onAppear {
                    player.prepareToPlay(song: song)
                    songName = song.name
                    bottomPanelHieght = isPlaybackPanelMaximized ? LyricsViewModelConstants.maxBottomPanelHeight : LyricsViewModelConstants.minBottomPanelHeight
                    currentChordIndex = song.getFirstChordIndex()
                }
                .onDisappear {
                    if song.songType != .youtube {
                        player.pause()
                    }
                }
            }
        }
        .padding(0)
    }
}
