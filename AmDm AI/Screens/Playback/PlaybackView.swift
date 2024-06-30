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
    @State var model = IntervalModel()
    @State var isPlaying: Bool = true
    @State var currentTime: TimeInterval = 0.0
    @StateObject var player = UniPlayer()
    @State var currentTimeframeIndex: Int = -1
    @State var currentChordIndex: Int = -1
    @State var bottomPanelHieght: CGFloat = LyricsViewModelConstants.minBottomPanelHeight
    @State var isMoreShapesPopupPresented: Bool = false
    @State var isRenamePopupVisible: Bool = false
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
                                } message: {
                                    Text("Please enter your username and password.")
                                }
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
                                                self.player.jumpTo(miliseconds: self.model.chords[self.currentChordIndex < 0 ? 0 : self.currentChordIndex].chord.start) {
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
                                .lineLimit(2)
                            Text(self.song.songType.rawValue + " • " + dateToString(self.song.created))
                                .font(.system(size: 14))
                                .foregroundStyle(.white)
                                .opacity(0.6)
                        }
                        .padding(.vertical, 10)
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
                                                        let chord = interval.chord.chord == "N" ? "" : interval.chord.chord
                                                        HStack(spacing: 0) {
                                                            VStack {
                                                                Text(chord)
                                                                    .font(.system(size: lyricsfontSize))
                                                                    .fontWeight(chordIndex == self.currentChordIndex ? .bold : .semibold)
                                                                    .foregroundStyle(chordIndex == self.currentChordIndex ? .progressCircle : .white)
                                                                Spacer()
                                                                Text(words)
                                                                    .font(.system(size: self.lyricsfontSize))
                                                                    .lineLimit(interval.limitLines)
                                                                    .foregroundStyle(chordIndex == self.currentChordIndex ? .progressCircle : .white)
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
                            if self.currentChordIndex >= 0 && self.isPlaybackPanelMaximized {
                                if isMoreShapesPopupPresented {
                                    MoreShapesView(isMoreShapesPopupPresented: $isMoreShapesPopupPresented, uiChord: self.model.chords[currentChordIndex].chord.uiChord)
                                } else {
                                    ChordShapesView(chords: model.chords, currentChordIndex: self.$currentChordIndex)
                                }
                            }
                            
                            /// MARK: playback controls
                            if !self.isMoreShapesPopupPresented {
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
                                                    .foregroundStyle(currentChordIndex <= 0 ? .secondaryText : .white)
                                            }
                                            .disabled(currentChordIndex <= 0)
                                        }
                                        .frame(width: 25, height: 30)
                                        
                                        Spacer()
                                        VStack {
                                            Button {
                                                if self.player.isPlaying {
                                                    self.player.pause()
                                                } else {
                                                    self.player.jumpTo(miliseconds: self.model.chords[self.currentChordIndex < 0 ? 0 : self.currentChordIndex].chord.start) {
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
                                                    .foregroundStyle(.white)
                                                    .foregroundStyle(!self.player.isReady ? .secondaryText : .white)
                                            }
                                            .disabled(!self.player.isReady)
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
                                                    .foregroundStyle(currentChordIndex == self.model.chords.count - 1 ? .secondaryText : .white)
                                            }
                                            .disabled(currentChordIndex == self.model.chords.count - 1)
                                        }
                                        .frame(width: 25, height: 30)
                                        Spacer()
                                    }
                                    .padding(.bottom, 20)
                                    .padding(.top, 5)
                                }
                            }
                        }
                        .frame(width: width, height: bottomPanelHieght)
                        .padding(.bottom, geometry.safeAreaInsets.bottom)
                        .background(Color.customDarkGray)
                        .clipShape(.rect(cornerRadius: 16))
                        .gesture(
                            DragGesture().onChanged { value in
                                if !self.isMoreShapesPopupPresented {
                                    if self.currentChordIndex >= 0 {
                                        self.isPlaybackPanelMaximized = value.translation.height <= 0
                                        withAnimation(.easeInOut(duration: 0.1)) {
                                            self.bottomPanelHieght = value.translation.height <= 0 ? LyricsViewModelConstants.maxBottomPanelHeight : LyricsViewModelConstants.minBottomPanelHeight
                                        }
                                    }
                                }
                            }
                        )

                        HStack {
                            Spacer()
                            if !self.player.isPlaying && self.currentChordIndex >= 0 && self.isPlaybackPanelMaximized {
                                Button {
                                    isMoreShapesPopupPresented.toggle()
                                } label: {
                                    Image(systemName: self.isMoreShapesPopupPresented ? "chevron.down" : "book.fill")
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
                    .onChange(of: isMoreShapesPopupPresented) { _, _ in
                        withAnimation(.easeInOut(duration: 0.1)) {
                            self.bottomPanelHieght = isMoreShapesPopupPresented ? LyricsViewModelConstants.moreShapesPanelHeight : LyricsViewModelConstants.maxBottomPanelHeight
                        }
                    }
                }
            }
            .ignoresSafeArea()
            .navigationBarBackButtonHidden(true)
            .onAppear {
                self.model.createTimeframes(song: song, maxWidth: floor(width * 0.9), fontSize: lyricsfontSize)
                self.player.prepareToPlay(song: song)
                self.songName = song.name
            }
            .onDisappear {
                if self.song.songType != .youtube {
                    self.player.pause()
                }
            }
        }
        .padding(0)
    }
}


struct ChordShapesView: View {
    var chords: [ChordShape] = []
    @Binding var currentChordIndex: Int

    var body: some View {
        VStack {
            HStack(alignment: .center) {
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(chords, id: \.self) { chord in
                                if let key = chord.chord.uiChord?.key, let suffix = chord.chord.uiChord?.suffix {
                                    HStack {
                                        chord.shape
                                            .frame(width: LyricsViewModelConstants.chordWidth, height: LyricsViewModelConstants.chordHeight)
                                        
                                        VStack(alignment: .center, spacing: 10) {
                                            Text(key.display.symbol + suffix.display.symbolized)
                                                .foregroundStyle(.white)
                                                .font(.system(size: 30))
                                                .fontWeight(.semibold)
                                            Text(key.display.accessible + suffix.display.accessible)
                                                .foregroundStyle(.white)
                                                .font(.system(size: 16))
                                                .lineLimit(2)
                                        }
                                        .frame(width: LyricsViewModelConstants.chordWidth, height: LyricsViewModelConstants.chordHeight)
                                    }
                                    .id(chords.firstIndex(where: { $0.chord == chord.chord })!)
                                    .scrollTransition(.animated, axis: .horizontal) { content, phase in
                                        content
                                            .opacity(phase.isIdentity ? 1.0 : 0.6)
                                            .scaleEffect(phase.isIdentity ? 1.0 : 0.6)
                                    }
                                }
                            }
                        }
                    }
                    .scrollDisabled(true)
                    .frame(width: LyricsViewModelConstants.chordWidth * 2, height: LyricsViewModelConstants.chordHeight)
                    .onChange(of: currentChordIndex) { _, newIndex in
                        withAnimation {
                            proxy.scrollTo(newIndex, anchor: .leading)
                        }
                    }
                    .onAppear {
                        if currentChordIndex >= 0 {
                            proxy.scrollTo(currentChordIndex, anchor: .leading)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }

    }
}

struct MoreShapesView: View {
    @Binding var isMoreShapesPopupPresented: Bool
    var uiChord: UIChord?
    let columns = [GridItem(.adaptive(minimum: LyricsViewModelConstants.chordWidth))]
    
    var body: some View {
        VStack {
            if let key = uiChord?.key, let suffix = uiChord?.suffix {
                HStack(alignment: .firstTextBaseline) {
                    Text(key.display.symbol + suffix.display.symbolized)
                        .foregroundStyle(.white)
                        .font(.system(size: 30))
                        .fontWeight(.semibold)
                        
                    Text("  (" + key.display.accessible + suffix.display.accessible + ")")
                        .foregroundStyle(.white)
                        .font(.system(size: 16))
                        .lineLimit(2)
                }
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 0) {
                        ForEach(uiChord!.chordPositions, id: \.self) { position in
                            ShapeLayerView(shapeLayer: createShapeLayer(
                                chordPosition: position,
                                width: LyricsViewModelConstants.chordWidth,
                                height: LyricsViewModelConstants.chordHeight)
                            )
                            .frame(width: LyricsViewModelConstants.chordWidth, height: LyricsViewModelConstants.chordHeight)
                        }
                    }
                    .frame(maxHeight: LyricsViewModelConstants.chordHeight * 2.5)
                    .padding(.horizontal)
                }
            }
        }
        .background(Color.customDarkGray)
    }
}
