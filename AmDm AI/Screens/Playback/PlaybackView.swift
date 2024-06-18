//
//  PlaybackView.swift
//  AmDm AI
//
//  Created by Anton on 22/05/2024.
//

import SwiftUI
import YouTubePlayerKit

struct LyricsLine: Identifiable {
    var id: String
    var text: String
    var start: Int
    var end: Int
    var chords: [APIChord]
}

class LyricsViewModel: ObservableObject {
    @Published var lines: [LyricsLine] = []
    
    init(song: Song) {
        if song.text.count > 0 {
            var result: [APIChord] = []
            for line in song.text {
                if let start = line.start, let end = line.end {
                    for chord in song.chords {
                        if chord.start >= start && chord.end <= end {
                            result.append(chord)
                        }
                    }
                    self.lines.append(LyricsLine(id: line.id, text: line.text, start: start, end: end, chords: result))
                }
            }
        }
    }
}

struct PlaybackView: View {
    @ObservedObject var song: Song
    @ObservedObject var songsList: SongsList
    
    @State var isMuted: Bool = false
    @State var isPlaying: Bool = true
    @State var youTubePlayer: YouTubePlayer = ""
    @State var currentTime: TimeInterval = 0.0
    @ObservedObject var player: Player = Player()
    @ObservedObject var lyricsModel: LyricsViewModel
    
    init(song: Song, songsList: SongsList) {
        self.song = song
        self.songsList = songsList
        self.lyricsModel = LyricsViewModel(song: song)
    }
        
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
                    
                    VStack(alignment: .leading) {
//                        List(lyricsModel.lines) { line in
//                            VStack {
////                                Text(chords)
////                                    .listRowBackground(Color.gray5)
////                                    .listRowSeparator(.hidden)
//                                Text(line.text.wrappedValue)
//                                    .listRowBackground(Color.gray5)
//                                    .listRowSeparator(.hidden)
//                            }
//                            .id(line.start.wrappedValue)
//                        }
//                        .listStyle(.plain)
                    }
                    .frame(width: width)
                    
                    VStack {
                        Spacer()
                        VStack {
                            HStack(alignment: .center) {
                                MetronomeView(bpm: $song.tempo, beats: $song.beats)
                                
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
                            PlaybackTimelineView(song: song, player: player)
                                .frame(height: 75)
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
    
    private func getChordsBetween(start: Int, end: Int) -> [APIChord] {
        guard start >= 0 && end > 0 else { return [] }
        var result: [APIChord] = []
        for chord in self.song.chords {
            if chord.start >= start && chord.end <= end {
                result.append(chord)
            }
            if chord.start > end {
                break
            }
        }
        return result
    }
}
