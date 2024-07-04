//
//  PlaybackView.swift
//  AmDm AI
//
//  Created by Anton on 22/05/2024.
//

import SwiftUI
import YouTubePlayerKit
import SwiftyChords

struct PlaybackView: View {
    @ObservedObject var song: Song
    @ObservedObject var songsList: SongsList
    @AppStorage("isPlaybackPanelMaximized") var isPlaybackPanelMaximized: Bool = true
    @AppStorage("hideLyrics") var hideLyrics: Bool = false
    @StateObject var model = IntervalModel()
    @StateObject var player = UniPlayer()
    @State var currentTimeframeIndex: Int = 0
    @State var currentChordIndex: Int = 0
    @State var bottomPanelHieght: CGFloat = LyricsViewModelConstants.minBottomPanelHeight
    @State var isMoreShapesPopupPresented: Bool = false
    @State var isRenamePopupVisible: Bool = false
    @State var showOptions: Bool = false
    @State var songName: String = ""
    let lyricsfontSize = 16.0
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            
            ZStack {
                Color.gray5
                VStack {
                    VStack {
                        /// MARK: top safe area insets
                        if geometry.safeAreaInsets.top > 0 {
                            Rectangle()
                                .fill(Color.clear)
                                .frame(width: width, height: geometry.safeAreaInsets.top)
                        }
                        ZStack(alignment: Alignment(horizontal: .center, vertical: .top)) {
                            /// MARK: close button
                            HStack {
                                Navbar(
                                    isRenamePopupVisible: $isRenamePopupVisible,
                                    isMoreShapesPopupPresented: $isMoreShapesPopupPresented,
                                    song: song,
                                    songsList: songsList
                                )
                            }
                            .frame(width: width)
                            
                            HStack(alignment: .top, spacing: 0) {
                                /// MARK: youtube player
                                if song.songType == .youtube {
                                    ZStack {
                                        YouTubePlayerView(self.player.youTubePlayer.player) { state in
                                            switch state {
                                            case .idle: ProgressView()
                                            case .ready: EmptyView()
                                            case .error(_): Text(verbatim: "YouTube player couldn't be loaded")
                                            }
                                        }
                                        Color.white.opacity(0.0001)
                                    }
                                    .frame(width: LyricsViewModelConstants.videoPlayerWidth, height: LyricsViewModelConstants.videoPlayerHeight)
                                    .clipShape(.rect(cornerRadius: 16))
                                    .onTapGesture {
                                        if !isMoreShapesPopupPresented {
                                            if self.player.isPlaying {
                                                self.player.pause()
                                            } else {
                                                self.player.jumpTo(miliseconds: self.model.chords[self.currentChordIndex].chord.start) {
                                                    if self.isPlaybackPanelMaximized && self.bottomPanelHieght != LyricsViewModelConstants.maxBottomPanelHeight {
                                                        withAnimation {
                                                            self.bottomPanelHieght = LyricsViewModelConstants.maxBottomPanelHeight
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                } else {
                                    /// MARK: icons for file uploads
                                    if self.song.songType == .youtube {
                                        RoundedRectangle(cornerRadius: 5)
                                            .fill(Color.gray10)
                                            .frame(width: LyricsViewModelConstants.videoPlayerWidth, height: LyricsViewModelConstants.videoPlayerHeight)
                                            .padding(.trailing, 15)
                                    } else if self.song.songType == .recorded {
                                        Image(systemName: "mic.circle.fill")
                                            .resizable()
                                            .frame(width: LyricsViewModelConstants.videoPlayerHeight, height: LyricsViewModelConstants.videoPlayerHeight)
                                            .aspectRatio(contentMode: .fill)
                                            .foregroundColor(.disabledText)
                                            .padding(.trailing, 15)
                                    } else {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 12)
                                                .frame(width: 60, height: 60)
                                                .foregroundColor(.disabledText)
                                            Text(self.song.ext.uppercased())
                                                .fontWeight(.bold)
                                                .font(.system(size: 16))
                                                .foregroundColor(.gray10)
                                        }
                                        .frame(height: LyricsViewModelConstants.videoPlayerHeight)
                                        .padding(.trailing, 15)
                                    }
                                    
                                }
                            }
                            .padding(.top, geometry.safeAreaInsets.top > 0 ? 0 : 20)
                            .frame(width: width)
                        }
                        /// MARK: Song title
                        VStack {
                            Text(self.song.name)
                                .font(.system(size: 20))
                                .fontWeight(.semibold)
                                .multilineTextAlignment(.center)
                            Text(self.song.songType.rawValue + " • " + dateToString(self.song.created))
                                .font(.system(size: 14))
                                .foregroundStyle(.white)
                                .opacity(0.6)
                        }
                        .padding(10)
                    }
                    .frame(width: width)
                    .background {
                        LinearGradient(gradient: Gradient(colors: [.customDarkGray, .gray5]), startPoint: .top, endPoint: .bottom)
                    }
                    
                    Spacer()
                    
                    /// MARK: chords and lyrics
                    VStack {
                        ScrollViewReader { proxy in
                            ScrollView(.vertical, showsIndicators: true) {
                                VStack(alignment: .leading, spacing: 0) {
                                    ForEach(self.model.timeframes, id: \.self) { timeframe in
                                        
                                        let timeframeIndex = self.model.timeframes.firstIndex(where: {$0 == timeframe })!
                                        ZStack(alignment: .leading) {
                                            Rectangle()
                                                .foregroundStyle(.gray20)
                                                .frame(width: width, height: 1)
                                            Text(formatTime(Double(timeframe.start / 1000)))
                                                .font(.system(size: 12))
                                                .foregroundStyle(Color.gray40)
                                                .padding(.trailing, 5)
                                                .background(Color.gray5)
                                        }
                                        .padding(0)
                                        
                                        VStack{
                                            HStack(spacing: 0) {
                                                ForEach(timeframe.intervals, id: \.self) { interval in
                                                    let chordIndex = self.model.chords.firstIndex(where: {$0.chord == interval.chord })!
                                                    VStack(alignment: .leading) {
                                                        let words = interval.words.map { $0.text }.joined()
                                                        let ch = interval.chord.uiChord
                                                        let chord = interval.chord.chord == "N" ? "" : (ch != nil ? ch!.getChordString() : "")
                                                        HStack(spacing: 0) {
                                                            VStack {
                                                                Text(chord)
                                                                    .font(.system(size: lyricsfontSize))
                                                                    .fontWeight(chordIndex == self.currentChordIndex ? .bold : .semibold)
                                                                    .foregroundStyle(chordIndex == self.currentChordIndex ? .progressCircle : .white)
                                                                if !self.model.hideLyrics {
                                                                    Spacer()
                                                                    Text(words)
                                                                        .font(.system(size: self.lyricsfontSize))
                                                                        .lineLimit(interval.limitLines)
                                                                        .foregroundStyle(chordIndex == self.currentChordIndex ? .progressCircle : .white)
                                                                }
                                                            }
                                                            if interval == timeframe.intervals.last {
                                                                Spacer()
                                                            }
                                                        }
                                                    }
                                                    .frame(width: interval == timeframe.intervals.last ? (interval.width + width - timeframe.width) : interval.width)
                                                    .frame(minHeight: 50)
                                                    .padding(.vertical, 5)
                                                    .padding(.horizontal, 0)
                                                    .background(timeframeIndex == self.currentTimeframeIndex ? Color.gray20.opacity(0.3) : Color.gray5)
                                                    .onTapGesture {
                                                        if !self.isMoreShapesPopupPresented {
                                                            self.player.jumpTo(miliseconds: interval.start) {
                                                                if self.isPlaybackPanelMaximized && self.bottomPanelHieght != LyricsViewModelConstants.maxBottomPanelHeight {
                                                                    withAnimation {
                                                                        self.bottomPanelHieght = LyricsViewModelConstants.maxBottomPanelHeight
                                                                        self.currentTimeframeIndex = timeframeIndex
                                                                        self.currentChordIndex = chordIndex
                                                                    }
                                                                    
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        .frame(width: width)
                                        .id(timeframeIndex)
                                    }
                                }
                                .frame(width: width)
                                .onChange(of: self.player.currentTime) { _, newTime in
                                    self.currentTimeframeIndex = model.getTimeframeIndex(time: newTime)
                                    self.currentChordIndex = model.getChordIndex(time: newTime)
                                    withAnimation {
                                        proxy.scrollTo(self.currentTimeframeIndex, anchor: .center)
                                    }
                                }
                            }
                        }
                    }
                    .frame(width: width)
                    
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
                                MoreShapesView(isMoreShapesPopupPresented: $isMoreShapesPopupPresented, uiChord: self.model.chords[currentChordIndex].chord.uiChord)
                            } else {
                                if self.showOptions {
                                    OptionsView(hideLyrics: $model.hideLyrics, initialValue: song.transposition) { oldValue, newValue in
                                        song.transposition = newValue
                                        self.model.createTimeframes(song: song, maxWidth: floor(width * 0.9), fontSize: lyricsfontSize)
                                    }
                                } else if self.isPlaybackPanelMaximized {
                                    ChordShapesView(chords: model.chords, currentChordIndex: self.$currentChordIndex)
                                }
                            }
                            
                            /// MARK: playback controls
                            if !self.isMoreShapesPopupPresented && !self.showOptions {
                                VStack {
                                    VStack {
                                        Text(formatTime(Double(self.player.currentTime / 1000)) + " / " + formatTime(song.duration))
                                            .font(.system(size: 16))
                                            .foregroundStyle(.secondaryText)
                                    }
                                    HStack {
                                        Spacer()
                                        VStack {
                                            Button {
                                                self.showOptions.toggle()
                                                withAnimation(.easeInOut(duration: 0.1)) {
                                                    self.bottomPanelHieght = !self.showOptions ? LyricsViewModelConstants.minBottomPanelHeight : LyricsViewModelConstants.maxBottomPanelHeight
                                                }
                                            } label: {
                                                Image(systemName: "slider.horizontal.2.square")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .foregroundStyle(self.player.isPlaying || self.showOptions ? .secondaryText : .white)
                                            }
                                            .disabled(self.player.isPlaying || self.showOptions)
                                        }
                                        .frame(width: 20, height: 30)
                                        
                                        Spacer()
                                        VStack {
                                            Button {
                                                self.currentChordIndex -= 1
                                                self.currentTimeframeIndex = model.getTimeframeIndex(time: model.chords[currentChordIndex].chord.start)
                                                if self.player.isPlaying {
                                                    self.player.jumpTo(miliseconds: model.chords[currentChordIndex].chord.start)
                                                } else {
                                                    if self.isPlaybackPanelMaximized {
                                                        withAnimation {
                                                            self.bottomPanelHieght = LyricsViewModelConstants.maxBottomPanelHeight
                                                        }
                                                    }
                                                }
                                            } label: {
                                                Image(systemName: "arrow.uturn.left")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .foregroundStyle(currentChordIndex == 0 || self.showOptions ? .secondaryText : .white)
                                            }
                                            .disabled(currentChordIndex == 0 || self.showOptions)
                                        }
                                        .frame(width: 20, height: 30)
                                        
                                        Spacer()
                                        VStack {
                                            Button {
                                                if self.player.isPlaying {
                                                    self.player.pause()
                                                } else {
                                                    self.player.jumpTo(miliseconds: self.model.chords[self.currentChordIndex].chord.start) {
                                                        if self.isPlaybackPanelMaximized {
                                                            withAnimation {
                                                                self.bottomPanelHieght = LyricsViewModelConstants.maxBottomPanelHeight
                                                            }
                                                        }
                                                    }
                                                }
                                            } label: {
                                                Image(systemName: self.player.isPlaying ? "pause.fill" : "play.fill")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .foregroundStyle(!self.player.isReady || self.showOptions ? .secondaryText : .white)
                                            }
                                            .disabled(!self.player.isReady || self.showOptions)
                                        }
                                        .frame(width: 30, height: 30)
                                        .padding(.leading, 5)
                                        
                                        Spacer()
                                        VStack {
                                            Button {
                                                currentChordIndex += 1
                                                currentTimeframeIndex = model.getTimeframeIndex(time: model.chords[currentChordIndex].chord.start)
                                                if self.player.isPlaying {
                                                    self.player.jumpTo(miliseconds: model.chords[currentChordIndex].chord.start)
                                                } else {
                                                    if isPlaybackPanelMaximized {
                                                        withAnimation {
                                                            self.bottomPanelHieght = LyricsViewModelConstants.maxBottomPanelHeight
                                                        }
                                                    }
                                                }
                                            } label: {
                                                Image(systemName: "arrow.uturn.right")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .foregroundStyle(currentChordIndex == self.model.chords.count - 1 || self.showOptions ? .secondaryText : .white)
                                            }
                                            .disabled(currentChordIndex == self.model.chords.count - 1 || self.showOptions)
                                        }
                                        .frame(width: 20, height: 30)
                                        
                                        Spacer()
                                        VStack {
                                            Button {
                                                self.isPlaybackPanelMaximized.toggle()
                                                withAnimation(.easeInOut(duration: 0.1)) {
                                                    self.bottomPanelHieght = self.isPlaybackPanelMaximized ? LyricsViewModelConstants.maxBottomPanelHeight : LyricsViewModelConstants.minBottomPanelHeight
                                                }
                                            } label: {
                                                Image(systemName: self.isPlaybackPanelMaximized ? "c.square.fill" : "c.square")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .foregroundStyle(self.showOptions ? .secondaryText : .white)
                                            }
                                            .disabled(self.showOptions)
                                        }
                                        .frame(width: 21, height: 30)
                                        
                                        Spacer()
                                    }
                                    .padding(.bottom, 20)
                                    .padding(.top, 5)
                                }
                            }
                        }
                        .frame(width: width, height: self.bottomPanelHieght)
                        .padding(.bottom, geometry.safeAreaInsets.bottom)
                        .background(Color.customDarkGray)
                        .clipShape(.rect(cornerRadius: 16))
                        .gesture(
                            DragGesture().onChanged { value in
                                if !self.isMoreShapesPopupPresented {
                                    self.isPlaybackPanelMaximized = value.translation.height <= 0
                                    withAnimation(.easeInOut(duration: 0.1)) {
                                        self.bottomPanelHieght = value.translation.height <= 0 ? LyricsViewModelConstants.maxBottomPanelHeight : LyricsViewModelConstants.minBottomPanelHeight
                                    }
                                }
                            }
                        )
                        
                        /// MARK: Options close, More shapes buttons
                        HStack {
                            if !self.player.isPlaying && (self.isPlaybackPanelMaximized || self.showOptions) {
                                Spacer()
                                Button {
                                    if self.showOptions {
                                        self.showOptions = false
                                    } else {
                                        self.isMoreShapesPopupPresented.toggle()
                                    }
                                    withAnimation(.easeInOut(duration: 0.1)) {
                                        self.bottomPanelHieght = isMoreShapesPopupPresented ? LyricsViewModelConstants.moreShapesPanelHeight : (self.showOptions || self.isPlaybackPanelMaximized ? LyricsViewModelConstants.maxBottomPanelHeight : LyricsViewModelConstants.minBottomPanelHeight)
                                    }
                                } label: {
                                    Image(systemName: self.isMoreShapesPopupPresented ? "chevron.down" : (self.showOptions ? "xmark.circle.fill" : "book.fill"))
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 22, height: 22)
                                        .foregroundStyle(.secondaryText)
                                }
                                .padding(.trailing, 30)
                                .padding(.top, 20)
                                
                            }
                        }
                        .frame(width: width)

                    }
                }
            }
            .ignoresSafeArea()
            .navigationBarBackButtonHidden(true)
            .onAppear {
                self.model.createTimeframes(song: song, maxWidth: floor(width * 0.9), fontSize: lyricsfontSize)
                self.player.prepareToPlay(song: song)
                self.songName = song.name
                self.bottomPanelHieght = self.isPlaybackPanelMaximized ? LyricsViewModelConstants.maxBottomPanelHeight : LyricsViewModelConstants.minBottomPanelHeight
                self.currentChordIndex = self.model.getFirstChordIndex()
            }
            .onDisappear {
                if self.song.songType != .youtube {
                    self.player.pause()
                }
                self.songsList.databaseService.updateSong(song: song)
                self.song.objectWillChange.send()
            }
        }
        .padding(0)
    }
}
