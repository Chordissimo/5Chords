//
//  PlaybackControls.swift
//  AmDm AI
//
//  Created by Anton on 16/07/2024.
//

import SwiftUI

struct PlaybackControls: View {
    @ObservedObject var player: UniPlayer
    @ObservedObject var song: Song
    @Binding var currentChordIndex: Int
    @Binding var currentTimeframeIndex: Int
    @Binding var bottomPanelHieght: CGFloat
    @Binding var isMoreShapesPopupPresented: Bool
    @Binding var showOptions: Bool
    @Binding var noChordsFound: Bool

    var body: some View {
        VStack {
            VStack {
                Text(formatTime(Double(player.currentTime / 1000)) + " / " + formatTime(song.duration))
                    .font(.system( size: 16))
                    .foregroundStyle(.secondaryText)
            }
            HStack {
                Spacer()
                VStack {
                    Button {
                        showOptions.toggle()
                        withAnimation(.easeInOut(duration: 0.1)) {
                            bottomPanelHieght = !showOptions ? LyricsViewModelConstants.minBottomPanelHeight : LyricsViewModelConstants.maxBottomPanelHeight
                        }
                    } label: {
                        if AppDefaults.isLimited && !song.isDemo {
                            Image("logo3")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30)
                                .opacityAnimaion()
                                .glow()
                        } else {
                            Image(systemName: "slider.horizontal.2.square")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundStyle(player.isPlaying || showOptions ? .secondaryText : .white)
                        }
                    }
                    .disabled(player.isPlaying || showOptions)
                }
                .frame(width: 20, height: 30)
                
                Spacer()
                VStack {
                    Button {
                        currentChordIndex -= 1
                        currentTimeframeIndex = song.getTimeframeIndex(time: song.intervals[currentChordIndex].start)
                        if player.isPlaying {
                            player.jumpTo(miliseconds: song.intervals[currentChordIndex].start)
                        } else {
                            if AppDefaults.isPlaybackPanelMaximized {
                                withAnimation {
                                    bottomPanelHieght = LyricsViewModelConstants.maxBottomPanelHeight
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.uturn.left")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundStyle(currentChordIndex == 0 || showOptions ? .secondaryText : .white)
                    }
                    .disabled(currentChordIndex == 0 || showOptions)
                }
                .frame(width: 20, height: 30)
                
                Spacer()
                VStack {
                    Button {
                        if player.isPlaying {
                            player.pause()
                        } else {
                            player.jumpTo(miliseconds: song.intervals[currentChordIndex].start) {
                                if AppDefaults.isPlaybackPanelMaximized {
                                    withAnimation {
                                        bottomPanelHieght = LyricsViewModelConstants.maxBottomPanelHeight
                                    }
                                }
                            }
                        }
                    } label: {
                        Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundStyle(!player.isReady || showOptions ? .secondaryText : .white)
                    }
                    .disabled(!player.isReady || showOptions)
                }
                .frame(width: 30, height: 30)
                .padding(.leading, 5)
                
                Spacer()
                VStack {
                    Button {
                        currentChordIndex += 1
                        currentTimeframeIndex = song.getTimeframeIndex(time: song.intervals[currentChordIndex].start)
                        if player.isPlaying {
                            player.jumpTo(miliseconds: song.intervals[currentChordIndex].start)
                        } else {
                            if AppDefaults.isPlaybackPanelMaximized {
                                withAnimation {
                                    bottomPanelHieght = LyricsViewModelConstants.maxBottomPanelHeight
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.uturn.right")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundStyle(currentChordIndex == song.intervals.count - 1 || showOptions ? .secondaryText : .white)
                    }
                    .disabled(currentChordIndex == song.intervals.count - 1 || showOptions)
                }
                .frame(width: 20, height: 30)
                
                Spacer()
                VStack {
                    Button {
                        AppDefaults.isPlaybackPanelMaximized.toggle()
                        withAnimation(.easeInOut(duration: 0.1)) {
                            bottomPanelHieght = AppDefaults.isPlaybackPanelMaximized ? LyricsViewModelConstants.maxBottomPanelHeight : LyricsViewModelConstants.minBottomPanelHeight
                        }
                    } label: {
                        Image(systemName: AppDefaults.isPlaybackPanelMaximized ? "c.square.fill" : "c.square")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundStyle(showOptions || noChordsFound ? .secondaryText : .white)
                    }
                    .disabled(showOptions || noChordsFound)
                }
                .frame(width: 21, height: 30)
                
                Spacer()
            }
            .padding(.bottom, 20)
            .padding(.top, 5)
        }

    }
}
