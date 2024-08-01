//
//  ChordsAndLyrics.swift
//  AmDm AI
//
//  Created by Anton on 16/07/2024.
//

import SwiftUI

struct ChordsAndLyrics: View {
    @AppStorage("isLimited") var isLimited: Bool = false
    @AppStorage("isPlaybackPanelMaximized") var isPlaybackPanelMaximized: Bool = true
    @ObservedObject var song: Song
    @ObservedObject var songsList: SongsList
    @ObservedObject var player: UniPlayer
    @Binding var currentChordIndex: Int
    @Binding var currentTimeframeIndex: Int
    @Binding var isMoreShapesPopupPresented: Bool
    @Binding var bottomPanelHieght: CGFloat
    var width: CGFloat
    @State var showPaywall = false
    @State var showEditChordsAds: Bool = false
    @State var showEditChords: Bool = false

    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(song.timeframes, id: \.self) { timeframe in
                            let timeframeIndex = song.timeframes.firstIndex(where: {$0 == timeframe })!
                            let first = timeframe.intervals.first!
                            let last = timeframe.intervals.last!
                            let timeframeWidth = CGFloat(Array(song.intervals[first...last]).map { $0.width }.reduce(0, +))
                            let intervalPaddingWidth = (width - timeframeWidth - LyricsViewModelConstants.padding) / 2
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
                                    ForEach(timeframe.intervals, id: \.self) { chordIndex in
                                        let interval = song.intervals[chordIndex]
                                        let intervalIndex = timeframe.intervals.firstIndex(where: { $0 == chordIndex })
                                        let chord = interval.uiChord == nil ? "" : interval.uiChord!.getChordString()
                                        let intervalWidth = intervalIndex == 0 || intervalIndex == (timeframe.intervals.count - 1) ?
                                        (timeframe.intervals.count == 1 ? (width - LyricsViewModelConstants.padding) : (interval.width + intervalPaddingWidth)) :
                                        interval.width
                                        
                                        if chord != "" || interval.words != "" {
                                            VStack {
                                                VStack {
                                                    Text(chord)
                                                        .font(.system(size: LyricsViewModelConstants.lyricsfontSize))
                                                        .fontWeight(chordIndex == currentChordIndex ? .bold : .semibold)
                                                        .foregroundStyle(chordIndex == currentChordIndex ? .progressCircle : .white)
                                                        .padding(.horizontal, 0)
                                                    if !song.hideLyrics {
                                                        Spacer()
                                                        Text(interval.words)
                                                            .font(.system(size: LyricsViewModelConstants.lyricsfontSize))
                                                            .lineLimit(interval.limitLines)
                                                            .multilineTextAlignment(.center)
                                                            .foregroundStyle(chordIndex == currentChordIndex ? .progressCircle : .white)
                                                            .padding(.horizontal, 0)
                                                    }
                                                }
                                                .padding(.leading, intervalIndex == 0 || timeframe.intervals.count == 1 ? intervalPaddingWidth : 0)
                                                .padding(.trailing, intervalIndex == timeframe.intervals.count - 1 || timeframe.intervals.count == 1 ? intervalPaddingWidth : 0)
                                            }
                                            .padding(.vertical, 5)
                                            .frame(width: intervalWidth)
                                            .frame(minHeight: 50)
                                            .background(Color.gray5.opacity(0.001))
                                            .onTapGesture {
                                                if !isMoreShapesPopupPresented {
                                                    player.jumpTo(miliseconds: interval.start) {
                                                        if isPlaybackPanelMaximized && bottomPanelHieght != LyricsViewModelConstants.maxBottomPanelHeight {
                                                            withAnimation {
                                                                bottomPanelHieght = LyricsViewModelConstants.maxBottomPanelHeight
                                                                currentTimeframeIndex = timeframeIndex
                                                                currentChordIndex = chordIndex
                                                            }
                                                            
                                                        }
                                                    }
                                                }
                                            }
                                            .onLongPressGesture {
                                                if isLimited {
                                                    showEditChordsAds = true
                                                } else {
                                                    currentChordIndex = chordIndex
                                                    currentTimeframeIndex = timeframeIndex
                                                    showEditChords = true
                                                }
                                            }
                                        }
                                    }
                                }
                                .frame(width: width )
                                .background(timeframeIndex == currentTimeframeIndex ? Color.gray20.opacity(0.3) : Color.gray5)
                            }
                            .frame(width: width)
                            .overlay {
                                if isLimited && song.timeframes.last!.id == timeframe.id {
                                    LinearGradient(gradient: Gradient(colors: [.clear, .gray5]), startPoint: .top, endPoint: .bottom)
                                }
                            }
                            .id(timeframeIndex)
                        }
                        if isLimited {
                            VStack {
                                UpgradeButton(content: {
                                    VStack {
                                        Text("Upgrade to Premium")
                                            .font(.system(size: 20))
                                            .foregroundStyle(.black)
                                            .fontWeight(.semibold)
                                        Text("for more chords and lyrics")
                                            .font(.system(size: 16))
                                            .fontWeight(.semibold)
                                            .foregroundStyle(.gray10)
                                    }
                                }, action: {
                                    showPaywall = true
                                })
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 20)
                        }
                    }
                    .onChange(of: player.currentTime) { _, newTime in
                        currentTimeframeIndex = song.getTimeframeIndex(time: newTime)
                        currentChordIndex = song.getChordIndex(time: newTime)
                        withAnimation {
                            proxy.scrollTo(currentTimeframeIndex, anchor: .center)
                        }
                    }
                }
            }
        }
        .frame(width: width)
        .fullScreenCover(isPresented: $showPaywall) {  Paywall(showPaywall: $showPaywall)  }
        .popover(isPresented: $showEditChordsAds) {
            AdsView(showAds: $showEditChordsAds, showPaywall: $showPaywall, title: "EDITING CHORDS", content: {
                EditChordsAds()
            })
        }
        .popover(isPresented: $showEditChords) {
            EditChordsView(song: song, currentChordIndex: $currentChordIndex) { isCanceled, selectedKey, selectedSuffix, newLyrics in
                if !isCanceled {
                    if let key = selectedKey, let suffix = selectedSuffix {
                        song.intervals[currentChordIndex].uiChord = UIChord(key: key, suffix: suffix)
                    } else {
                        song.intervals[currentChordIndex].uiChord = nil
                    }
                    song.intervals[currentChordIndex].words = newLyrics ?? ""
                    song.createTimeframes()
                    songsList.databaseService.updateIntervals(song: song)
                }
                showEditChords = false
            }
        }
    }
}
