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
    @StateObject var player = UniPlayer()
    @State var currentTimeframeIndex: Int = 0
    @State var currentChordIndex: Int = 0
    @State var bottomPanelHieght: CGFloat = LyricsViewModelConstants.minBottomPanelHeight
    @State var isMoreShapesPopupPresented: Bool = false
    @State var isRenamePopupVisible: Bool = false
    @State var showOptions: Bool = false
    @State var songName: String = ""
    let lyricsfontSize = LyricsViewModelConstants.lyricsfontSize
    @State var showError = false
    @State var noChordsFound = false
    
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
                        if song.timeframes.count == 0 {
                            VStack {
                                ZStack(alignment: Alignment(horizontal: .center, vertical: .top)) {
                                    MatrixRain()
                                    VStack {
                                        Text("Extracting chords and lyrics")
                                            .font(.custom(SOFIA, size: 18))
                                            .fontWeight(.semibold)
                                            .foregroundStyle(.white)
                                            .multilineTextAlignment(.center)
                                            .opacityAnimaion()
                                    }
                                    .frame(width: 300, height: 60)
                                    .background {
                                        Color.gray20
                                    }
                                    .clipShape(.rect(cornerRadius: 12))
                                    .padding(.top, 100)
                                }
                                .onChange(of: song.recognitionStatus) {
                                    if song.recognitionStatus == .serverError {
                                        showError = true
                                    }
                                }
                                .alert("Something went wrong", isPresented: $showError) {
                                    Button {
                                        songsList.del(song: song)
                                    } label: {
                                        Text("Ok")
                                    }
                                } message: {
                                    Text("Please try again later.")
                                }
                            }
                        } else {
                            ChordsAndLyrics(
                                song: song,
                                songsList: songsList,
                                player: player,
                                currentChordIndex: $currentChordIndex,
                                currentTimeframeIndex: $currentTimeframeIndex,
                                isMoreShapesPopupPresented: $isMoreShapesPopupPresented,
                                bottomPanelHieght: $bottomPanelHieght,
                                width: width,
                                noChordsFound: $noChordsFound
                            )
                        }
                        
                        if song.timeframes.count > 0 {
                            /// MARK: Bottom panel
                            ZStack(alignment: Alignment(horizontal: .center, vertical: .top)) {
                                VStack(spacing: 0) {
                                    VStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(!showOptions ? Color.secondaryText : Color.clear)
                                            .frame(width: 30, height: 5)
                                    }
                                    .padding(.vertical, 8)
                                    
                                    Spacer()

                                    /// MARK: Chord shapes in a scrollview
                                    if isMoreShapesPopupPresented {
                                        MoreShapesView(isMoreShapesPopupPresented: $isMoreShapesPopupPresented, uiChord: song.intervals[currentChordIndex].uiChord)
                                    } else {
                                        if showOptions {
                                            OptionsView(songsList: songsList, hideLyrics: $song.hideLyrics, showOptions: $showOptions, onChangeValue: { transposeUp in
                                                song.transpose(transposeUp: transposeUp)
                                                song.createTimeframes()
                                                songsList.databaseService.updateIntervals(song: song)
                                            }, onReset: { reset in
                                                song.intervals = []
                                                song.createTimeframes()
                                                songsList.databaseService.updateIntervals(song: song)
                                            })
                                        } else if AppDefaults.isPlaybackPanelMaximized {
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
                                            isMoreShapesPopupPresented: $isMoreShapesPopupPresented,
                                            showOptions: $showOptions,
                                            noChordsFound: $noChordsFound
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
                                    DragGesture().onEnded { value in
                                        if !showOptions && !noChordsFound {
                                            withAnimation(.easeInOut(duration: 0.1)) {
                                                if value.translation.height <= 0 {
                                                    if bottomPanelHieght == LyricsViewModelConstants.maxBottomPanelHeight {
                                                        isMoreShapesPopupPresented = true
                                                        bottomPanelHieght = LyricsViewModelConstants.moreShapesPanelHeight
                                                    } else if bottomPanelHieght == LyricsViewModelConstants.minBottomPanelHeight {
                                                        AppDefaults.isPlaybackPanelMaximized = true
                                                        bottomPanelHieght = LyricsViewModelConstants.maxBottomPanelHeight
                                                    }
                                                } else {
                                                    if bottomPanelHieght == LyricsViewModelConstants.moreShapesPanelHeight {
                                                        isMoreShapesPopupPresented = false
                                                        bottomPanelHieght = LyricsViewModelConstants.maxBottomPanelHeight
                                                    } else if bottomPanelHieght == LyricsViewModelConstants.maxBottomPanelHeight {
                                                        AppDefaults.isPlaybackPanelMaximized = false
                                                        bottomPanelHieght = LyricsViewModelConstants.minBottomPanelHeight
                                                    }
                                                }
                                            }
                                            
                                        }
                                    }
                                )
                                
                                /// MARK: Options close, More shapes buttons
                                if !player.isPlaying && (AppDefaults.isPlaybackPanelMaximized || showOptions) {
                                    ZStack {
                                        if showOptions {
                                            VStack {
                                                Text(AppDefaults.isLimited ? "Premium features" : "Preferences")
                                                    .font(.custom(SOFIA, size: 16))
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
                                                    bottomPanelHieght = isMoreShapesPopupPresented ? LyricsViewModelConstants.moreShapesPanelHeight : (showOptions || AppDefaults.isPlaybackPanelMaximized ? LyricsViewModelConstants.maxBottomPanelHeight : LyricsViewModelConstants.minBottomPanelHeight)
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
                }
                .ignoresSafeArea()
                .navigationBarBackButtonHidden(true)
                .onChange(of: player.currentTime) {
                    if AppDefaults.isLimited && player.currentTime > AppDefaults.LIMITED_DURATION * 1000 + abs(AppDefaults.INTERVAL_START_ADJUSTMENT) {
                        player.pause()
                    }
                }
                .onChange(of: song.isProcessing) { oldValue, newValue in
                    if oldValue && !newValue {
                        if let index = song.getFirstChordIndex() {
                            currentChordIndex = index
                            AppDefaults.isPlaybackPanelMaximized = true
                            noChordsFound = false
                        } else {
                            currentChordIndex = 0
                            AppDefaults.isPlaybackPanelMaximized = false
                            noChordsFound = true
                        }
                    }
                }
                .onChange(of: noChordsFound) { oldValue, newValue in
                    bottomPanelHieght = oldValue && !newValue ? LyricsViewModelConstants.maxBottomPanelHeight : LyricsViewModelConstants.minBottomPanelHeight
                    AppDefaults.isPlaybackPanelMaximized = oldValue && !newValue
                }
                .onAppear {
                    player.prepareToPlay(song: song)
                    songName = song.name
                    bottomPanelHieght = AppDefaults.isPlaybackPanelMaximized ? LyricsViewModelConstants.maxBottomPanelHeight : LyricsViewModelConstants.minBottomPanelHeight
                    if let index = song.getFirstChordIndex() {
                        currentChordIndex = index
                    } else {
                        currentChordIndex = 0
                        AppDefaults.isPlaybackPanelMaximized = false
                        noChordsFound = true
                        bottomPanelHieght = LyricsViewModelConstants.minBottomPanelHeight
                    }
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
