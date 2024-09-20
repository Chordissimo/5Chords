//
//  TopPanel.swift
//  AmDm AI
//
//  Created by Anton on 16/07/2024.
//

import SwiftUI
import YouTubePlayerKit

struct TopPanel: View {
    @ObservedObject var song: Song
    @ObservedObject var songsList: SongsList
    @ObservedObject var player: UniPlayer
    @Binding var isRenamePopupVisible: Bool
    @Binding var isMoreShapesPopupPresented: Bool
    @Binding var currentChordIndex: Int
    @Binding var bottomPanelHieght: CGFloat
    var topInset: CGFloat
    var width: CGFloat

    var body: some View {
        VStack {
            /// MARK: top safe area insets
            if topInset > 0 {
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: width, height: topInset)
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
                            YouTubePlayerView(player.youTubePlayer.player) { state in
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
                                if player.isPlaying {
                                    player.pause()
                                } else {
                                    if song.timeframes.count > 0 {
                                        player.jumpTo(miliseconds: song.intervals[currentChordIndex].start) {
                                            if AppDefaults.isPlaybackPanelMaximized && bottomPanelHieght != LyricsViewModelConstants.maxBottomPanelHeight {
                                                withAnimation {
                                                    bottomPanelHieght = LyricsViewModelConstants.maxBottomPanelHeight
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        /// MARK: icons for file uploads
                        if song.songType == .youtube {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color.gray10)
                                .frame(width: LyricsViewModelConstants.videoPlayerWidth, height: LyricsViewModelConstants.videoPlayerHeight)
                                .padding(.trailing, 15)
                        } else if song.songType == .recorded {
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
                                Text(song.ext.uppercased())
                                    .fontWeight(.bold)
                                    .font(.system( size: 16))
                                    .foregroundColor(.gray10)
                            }
                            .frame(height: LyricsViewModelConstants.videoPlayerHeight)
                            .padding(.trailing, 15)
                        }
                    }
                }
                .padding(.top, topInset > 0 ? 0 : 20)
                .frame(width: width)
            }
            /// MARK: Song title
            VStack {
                Text(song.name)
                    .font(.system( size: 20))
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                Text(song.songType.rawValue + " • " + dateToString(song.created))
                    .font(.system( size: 14))
                    .foregroundStyle(.white)
                    .opacity(0.6)
            }
            .padding(10)
        }
        .frame(width: width)
        .background {
            LinearGradient(gradient: Gradient(colors: [.customDarkGray, .gray5]), startPoint: .top, endPoint: .bottom)
        }
    }
}
