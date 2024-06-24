//
//  PlaybackView.swift
//  AmDm AI
//
//  Created by Anton on 22/05/2024.
//

import SwiftUI
import YouTubePlayerKit

struct PlaybackView: View {
    var song: Song
//    @ObservedObject var songsList: SongsList
    
    @State var model = IntervalModel()
    @State var isMuted: Bool = false
    @State var isPlaying: Bool = true
    @State var youTubePlayer: YouTubePlayer = ""
    @State var currentTime: TimeInterval = 0.0
    @ObservedObject var player: Player = Player()
    let lyricsfontSize = 16.0
            
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let videoPlayerHeight = 80.0
            let videoPlayerWidth = 120.0
            let topPanelpadding = 20.0
            let bottomPanelPadding = 20.0
            let bottomPanelHeight = 250.0
            let panelCornerRadius = 16.0
            
            ZStack {
                Color.gray5
                VStack {
                    VStack {
                        if geometry.safeAreaInsets.top > 0 {
                            Rectangle()
                                .fill(Color.playbackPanel)
                                .frame(width: width, height: geometry.safeAreaInsets.top)
                        }
                        HStack(alignment: .top, spacing: 0) {
                            if song.songType == .youtube {
                                ZStack {
                                    YouTubePlayerView(self.youTubePlayer) { state in
                                        switch state {
                                        case .idle:
                                            ProgressView()
                                        case .ready:
                                            EmptyView()
                                        case .error(_):
                                            Text(verbatim: "YouTube player couldn't be loaded")
                                        }
                                    }
                                    .frame(width: videoPlayerWidth, height: videoPlayerHeight)
                                    .padding(.trailing, 15)
                                    Color.white.opacity(0.0001)
                                }
                                .frame(width: videoPlayerWidth, height: videoPlayerHeight)
                                .onTapGesture {
                                    if self.youTubePlayer.isPlaying {
                                        self.youTubePlayer.pause()
                                    } else {
                                        self.youTubePlayer.play()
                                    }
                                }
                            } else {
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
                            VStack(alignment: .leading) {
                                Text(song.name)
                                    .lineLimit(2)
                                    .truncationMode(.tail)
                                    .fontWeight(.semibold)
                                    .font(.system(size: 16))
                                    .foregroundStyle(.white)
                                
                                Text(formatTime(song.duration))
                                    .font(.system(size: 14))
                                    .foregroundStyle(.white)
                                    .opacity(0.6)
                                Text(song.songType.rawValue + " • " + dateToString(song.created))
                                    .font(.system(size: 14))
                                    .foregroundStyle(.white)
                                    .opacity(0.6)
                            }
                            .frame(height: videoPlayerHeight)

                            Spacer()

                            VStack {
                                Spacer()
                                NavigationLink(destination: AllSongs()) {
                                    Image(systemName: "xmark")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 18, height: 18)
                                        .foregroundStyle(.secondaryText)
                                }
                                Spacer()
                            }
                            .frame(width: 18, height: videoPlayerHeight)
                            .padding(.leading, 3)
                        }
                        .padding(.horizontal, topPanelpadding)
                        .padding(.top, geometry.safeAreaInsets.top > 0 ? 0 : topPanelpadding)
                        .padding(.bottom, topPanelpadding)
                        .frame(width: width)
                    }
                    .frame(width: width)
                    .background(Color.playbackPanel)
                    .cornerRadius(panelCornerRadius)
                    
                    Spacer()

                    VStack {
                        Text(song.name)
                            .font(.system(size: 20))
                            .fontWeight(.semibold)
                        ScrollView(.vertical, showsIndicators: true) {
                            VStack(alignment: .leading) {
                                ForEach(model.timeframes, id:\.self) { timeframe in
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
                                    TimeFrame(timeframe: timeframe, lyricsfontSize: lyricsfontSize)
                                }
                            }.frame(width: width)
                        }
                    }
                    .frame(width: width)
                    
                    VStack {
                        Spacer()
                        VStack {
                            HStack(alignment: .center) {
//                                MetronomeView(bpm: song.tempo, beats: song.beats)
                                
                                Spacer()
                                
                                Rectangle()
                                    .fill(Color.gray5)
                                    .frame(width: 33, height: 50)
                                
                                Spacer()
                                
                                Button {
                                    isMuted.toggle()
                                } label: {
                                    Image(systemName: isMuted ? "speaker" : "speaker.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 26, height: 26)
                                        .foregroundStyle(.secondaryText)
                                }
                            }
                            .padding(.horizontal, bottomPanelPadding)
                            .padding(.vertical, bottomPanelPadding - 10)
                        }
                        VStack {
//                            PlaybackTimelineView(song: song, player: player)
//                                .frame(height: 75)
                        }
                        VStack {
                            HStack(spacing: 20) {
                                Text(formatTime(currentTime) + " / " + formatTime(song.duration))
                                    .font(.system(size: 14))
                                    .foregroundStyle(.white)
                                    .opacity(0.6)
                                Image(systemName: isPlaying ? "play.fill" : "stop.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 18, height: 18)
                                    .foregroundStyle(.secondaryText)
                                Spacer()
                                Image(systemName: "book.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 22, height: 22)
                                    .foregroundStyle(.secondaryText)
                                
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 20)
                        }
                    }
                    .frame(width: width, height: bottomPanelHeight)
                    .padding(.bottom, geometry.safeAreaInsets.bottom)
                    .background(Color.playbackPanel)
                    .cornerRadius(panelCornerRadius)
                }
            }
            .ignoresSafeArea()
            .navigationBarBackButtonHidden(true)
            .task(id: youTubePlayer) {
                if self.song.songType == .youtube {
                    var time = 0.0
                    do {
                        time = try await youTubePlayer.getCurrentTime().value
                    } catch {
                        print(error)
                    }
                    self.currentTime = time
                }
            }
            .onChange(of: player) { _, _ in
                self.currentTime = self.player.currentTime
            }
            .onAppear {
                self.model.createTimeframes(song: song, maxWidth: floor(width * 0.9), fontSize: lyricsfontSize)
                if song.songType == .youtube {
                    self.prepareToPlay()
                }
            }
        }
        .padding(0)
    }
    
    private func prepareToPlay() {
        if song.songType == .youtube {
            let id = String(song.url.absoluteString.split(separator: "=").last!)
            self.youTubePlayer.source = .video(id: id)
            let configuration = YouTubePlayer.Configuration(
                automaticallyAdjustsContentInsets: false,
                allowsPictureInPictureMediaPlayback: false,
                autoPlay: false,
                showCaptions: false,
                showControls: false,
                keyboardControlsDisabled: true,
                enableJavaScriptAPI: false,
                showFullscreenButton: false,
                showAnnotations: false,
                loopEnabled: false,
                useModestBranding: true,
                playInline: true,
                showRelatedVideos: false
            )
            self.youTubePlayer.configuration = configuration
        }
    }
}


struct TimeFrame: View {
    var timeframe: Timeframe
    var lyricsfontSize: CGFloat
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(timeframe.intervals, id: \.self) { interval in
                VStack(alignment: .leading) {
                    let words = interval.words.map { $0.text }.joined()
                    let chord = interval.chord.chord == "N" ? "" : interval.chord.chord
                    Text(chord)
                        .frame(minWidth: 50)
                        .font(.system(size: lyricsfontSize))
                    Spacer()
                    Text(words)
                        .font(.system(size: lyricsfontSize))
                        .lineLimit(interval.limitLines)
                }
                .frame(minHeight: 50)
                .padding(.bottom, 5)
            }
        }
    }
}
