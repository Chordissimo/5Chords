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
    var song: Song
    //    @ObservedObject var songsList: SongsList
    @AppStorage("isPlaybackPanelMaximized") var isPlaybackPanelMaximized: Bool = false
    @State var model = IntervalModel()
    @State var isMuted: Bool = false
    @State var isPlaying: Bool = true
    @StateObject var youTubePlayer = YouTubePlayerService()
    @State var currentTime: TimeInterval = 0.0
    @ObservedObject var player: Player = Player()
    @State var currentTimeframeIndex: Int = -1
    @State var currentChordIndex: Int = -1
    let lyricsfontSize = 16.0
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let videoPlayerHeight = 120.0
            let videoPlayerWidth = 180.0
            let topPanelpadding = 20.0
            let bottomPanelPadding = 20.0
            let maxBottomPanelHeight = 250.0
            let minBottomPanelHeight = 100.0
            let panelCornerRadius = 16.0
            let chordHeight = 135.0
            let chordWidth = chordHeight / 6 * 5

            
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
                                        YouTubePlayerView(self.youTubePlayer.player) { state in
                                            switch state {
                                            case .idle: ProgressView()
                                            case .ready: EmptyView()
                                            case .error(_): Text(verbatim: "YouTube player couldn't be loaded")
                                            }
                                        }
                                        .frame(width: videoPlayerWidth, height: videoPlayerHeight)
                                        .padding(.trailing, 15)
                                        Color.white.opacity(0.0001)
                                    }
                                    .frame(width: videoPlayerWidth, height: videoPlayerHeight)
                                    .clipShape(.rect(cornerRadius: 16))
                                    .onTapGesture {
                                        if self.youTubePlayer.isPlaying {
                                            self.youTubePlayer.pause()
                                        } else {
                                            self.youTubePlayer.play()
                                        }
                                    }
                                } else {
                                    /// MARK: icons for file uploads
                                    if song.songType == .youtube {
                                        RoundedRectangle(cornerRadius: 5)
                                            .fill(Color.gray10)
                                            .frame(width: videoPlayerWidth, height: videoPlayerHeight)
                                            .padding(.trailing, 15)
                                    } else if song.songType == .recorded {
                                        Image(systemName: "mic.circle.fill")
                                            .resizable()
                                            .frame(width: videoPlayerHeight, height: videoPlayerHeight)
                                            .aspectRatio(contentMode: .fill)
                                            .foregroundColor(.disabledText)
                                            .padding(.trailing, 15)
                                    } else {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 12)
                                                .frame(width: 60, height: 60)
                                                .foregroundColor(.disabledText)
                                            Text(song.ext.uppercased())
                                                .fontWeight(.bold)
                                                .font(.system(size: 16))
                                                .foregroundColor(.gray10)
                                        }
                                        .frame(height: videoPlayerHeight)
                                        .padding(.trailing, 15)
                                    }
                                    
                                }
                            }
                            .padding(.top, geometry.safeAreaInsets.top > 0 ? 0 : topPanelpadding)
                            .frame(width: width)
                        }
                        /// MARK: Song title
                        VStack {
                            Text(song.name)
                                .font(.system(size: 20))
                                .fontWeight(.semibold)
                                .lineLimit(2)
                            Text(song.songType.rawValue + " • " + dateToString(song.created))
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
                    
                    VStack {
                        /// MARK: chords and lyrics
                        ScrollViewReader { proxy in
                            ScrollView(.vertical, showsIndicators: true) {
                                VStack(alignment: .leading, spacing: 0) {
                                    ForEach(model.timeframes, id:\.self) { timeframe in
                                        let timeframeIndex = model.timeframes.firstIndex(where: {$0 == timeframe })!
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
                                                    let chordIndex = model.chords.firstIndex(where: {$0 == interval.chord })!
                                                    VStack(alignment: .leading) {
                                                        let words = interval.words.map { $0.text }.joined()
                                                        let chord = interval.chord.chord == "N" ? "" : interval.chord.chord
                                                        HStack(spacing: 0) {
                                                            VStack {
                                                                Text(chord)
                                                                    .font(.system(size: lyricsfontSize))
                                                                    .fontWeight(chordIndex == currentChordIndex ? .bold : .semibold)
                                                                    .foregroundStyle(chordIndex == currentChordIndex ? .progressCircle : .white)
                                                                Spacer()
                                                                Text(words)
                                                                    .font(.system(size: lyricsfontSize))
                                                                    .lineLimit(interval.limitLines)
                                                                    .foregroundStyle(chordIndex == currentChordIndex ? .progressCircle : .white)
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
                                                    .background(timeframeIndex == currentTimeframeIndex ? Color.gray20.opacity(0.3) : Color.gray5)
                                                    .onTapGesture {
                                                        currentTimeframeIndex = timeframeIndex
                                                        currentChordIndex = chordIndex
                                                        self.youTubePlayer.jumpTo(miliseconds: interval.start)
                                                    }
                                                }
                                            }
                                        }
                                        .frame(width: width)
                                        .id(timeframeIndex)
                                    }
                                }
                                .frame(width: width)
                                .onChange(of: self.youTubePlayer.currentTime) { _, newTime in
                                    currentTimeframeIndex = model.getTimeframeIndex(time: newTime)
                                    currentChordIndex = model.getChordIndex(time: newTime)
                                    withAnimation {
                                        proxy.scrollTo(currentTimeframeIndex, anchor: .center)
                                    }
                                }
                            }
                        }
                    }
                    .frame(width: width)
                    
                    /// MARK: Bottom panel
                    VStack(spacing: 0) {
                        VStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.secondaryText)
                                .frame(width: 30, height: 5)
                        }
                        .padding(.vertical, 8)
                        .gesture(
                            DragGesture().onChanged { value in
//                                viewState = value.translation
                                print(value.translation.height)
                            }
                            .onEnded { value in
                                print(isPlaybackPanelMaximized,value.location.y)
                                if isPlaybackPanelMaximized && value.location.y < 0 {
                                // ...
                                } else if isPlaybackPanelMaximized && value.location.y >= 0 {
                                    isPlaybackPanelMaximized = false
                                } else if !isPlaybackPanelMaximized && value.location.y < 0 {
                                    isPlaybackPanelMaximized = true
                                    if currentTimeframeIndex < 0 && currentChordIndex < 0 {
                                        currentTimeframeIndex = 0
                                        currentChordIndex = 0
                                    }
                                }
                            }
                        )
                        
                        if currentChordIndex >= 0 && isPlaybackPanelMaximized {
                            Spacer()
                            VStack {
                                HStack(alignment: .center) {
                                    ScrollViewReader { proxy in
                                        ScrollView(.horizontal, showsIndicators: false) {
                                            HStack {
                                                ForEach(model.chords, id: \.self) { chord in
                                                    if let key = chord.uiChord?.key, let suffix = chord.uiChord?.suffix {
                                                        let chordPosition = Chords.guitar.matching(key: key).matching(suffix: suffix).first!
                                                        HStack {
                                                            ShapeLayerView(shapeLayer: createShapeLayer(
                                                                chordPosition: chordPosition,
                                                                width: chordWidth,
                                                                height: chordHeight
                                                            ))
                                                            .frame(width: chordWidth, height: chordHeight)
                                                            
                                                            VStack {
                                                                Text(key.display.symbol + suffix.display.symbolized)
                                                                    .foregroundStyle(.white)
                                                                    .font(.system(size: 50))
                                                                    .fontWeight(.semibold)
                                                                    .padding(.bottom, 10)
                                                                Text(key.display.accessible + suffix.display.accessible)
                                                                    .foregroundStyle(.white)
                                                                    .font(.system(size: 18))
                                                                    .lineLimit(2)
                                                            }
                                                            .frame(width: chordWidth, height: chordHeight)
                                                        }
                                                        .id(model.chords.firstIndex(where: { $0 == chord })!)
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
                                        .frame(width: chordWidth * 2, height: chordHeight)
                                        .onChange(of: currentChordIndex) { _, newIndex in
                                            withAnimation {
                                                proxy.scrollTo(newIndex, anchor: .leading)
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, bottomPanelPadding)
                            }
                        }
                                                
                        VStack {
                            VStack {
                                Text(formatTime(Double(self.youTubePlayer.currentTime / 1000)) + " / " + formatTime(song.duration))
                                    .font(.system(size: 16))
                                    .foregroundStyle(.secondaryText)
                            }
                            HStack {
                                Spacer()
                                VStack {
                                    Button {
                                        currentChordIndex -= 1
                                        currentTimeframeIndex = model.getTimeframeIndex(time: model.chords[currentChordIndex].start)
                                        if self.youTubePlayer.isPlaying {
                                            self.youTubePlayer.jumpTo(miliseconds: model.chords[currentChordIndex].start)
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
                                        if self.youTubePlayer.isPlaying {
                                            self.youTubePlayer.pause()
                                        } else {
                                            self.youTubePlayer.jumpTo(miliseconds: model.chords[currentChordIndex < 0 ? 0 : currentChordIndex].start)
                                        }
                                    } label: {
                                        Image(systemName: self.youTubePlayer.isPlaying ? "pause.fill" : "play.fill")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .foregroundStyle(.white)
                                    }
                                    .disabled(!self.youTubePlayer.isReady)
                                }
                                .frame(width: 30, height: 30)
                                .padding(.leading, 5)

                                Spacer()
                                VStack {
                                    Button {
                                        currentChordIndex += 1
                                        currentTimeframeIndex = model.getTimeframeIndex(time: model.chords[currentChordIndex].start)
                                        if self.youTubePlayer.isPlaying {
                                            self.youTubePlayer.jumpTo(miliseconds: model.chords[currentChordIndex].start)
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
                    .frame(width: width, height: isPlaybackPanelMaximized && currentChordIndex >= 0 ? maxBottomPanelHeight : minBottomPanelHeight)
                    .padding(.bottom, geometry.safeAreaInsets.bottom)
                    .background(Color.customDarkGray)
                    .clipShape(.rect(cornerRadius: panelCornerRadius))
                }
            }
            .ignoresSafeArea()
            .navigationBarBackButtonHidden(true)
            .onAppear {
                self.model.createTimeframes(song: song, maxWidth: floor(width * 0.9), fontSize: lyricsfontSize)
                if song.songType == .youtube {
                    self.youTubePlayer.prepareToPlay(url: song.url.absoluteString)
                }
            }
        }
        .padding(0)
    }
}
