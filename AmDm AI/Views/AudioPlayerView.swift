//
//  PlaybackColtrols.swift
//  AmDm AI
//
//  Created by Anton on 30/03/2024.
//

import SwiftUI

enum PlaybackColtrolsScale: Int {
    case small = 0
    case large = 1
}


struct AudioPlayerView: View {
    var scale: PlaybackColtrolsScale? = .small
    @Binding var song: Song
    @ObservedObject var songsList: SongsList
    @ObservedObject var player: Player
    @State var width : CGFloat = 0
    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            if scale == .large {
                Text(formatTime(player.currentTime, precision: .santiseconds))
                    .foregroundStyle(Color.white)
                    .font(.system(size: 40))
                    .fontWeight(.bold)
            }
            HStack {
                PlaybackSlider(width: $width)
                .onChange(of: player.currentTime) {
                    width = getWidth(ScreenDimentions.maxWidth)
                }
                .onTapGesture { location in
                    player.seekAudio(to: getPlaybackPosition(location.x,ScreenDimentions.maxWidth))
                }
                .gesture(
                    DragGesture()
                        .onChanged({ (value) in
                            if player.isPlaying {
                                player.stop()
                            }
                            player.seekAudio(to: getPlaybackPosition(value.location.x,ScreenDimentions.maxWidth))
                        })
                )
            }
            .frame(height:8)
            
            if scale == .small {
                HStack {
                    Text(formatTime(player.currentTime, precision: .seconds))
                        .foregroundStyle(.customGray1)
                        .font(.system(size: 14))
                    Spacer()
                    Text("-" + formatTime(player.duration - player.currentTime, precision: .seconds))
                        .foregroundStyle(.customGray1)
                        .font(.system(size: 14))
                }
            }
            
            HStack {
                if scale == .small {
                    Share(label: "", content: "Chords for " + song.name)
                }
                Spacer()
                Button {
                    player.seekAudio(to: player.currentTime - 1)
                } label: {
                    Image(systemName: "gobackward.5")
                        .resizable()
                        .frame(width: scale == .large ? 30 : 26, height: scale == .large ? 30 : 26)
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(Color.white)
                }
                
                Button {
                    if player.isPlaying {
                        player.stop()
                    } else {
                        player.play()
                    }
                } label: {
                    Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                        .resizable()
                        .frame(
                            width: scale == .large ? 40 : 28, height: scale == .large ? 40 : 28)
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(Color.white)
                        .padding(EdgeInsets(top: 0, leading: 45, bottom: 0, trailing: 40))
                }
                
                Button {
                    player.seekAudio(to: player.currentTime + 1)
                } label: {
                    Image(systemName: "goforward.5")
                        .resizable()
                        .frame(width: scale == .large ? 30 : 26, height: scale == .large ? 30 : 26)
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(Color.white)
                }
                Spacer()
                if scale == .small {
                    ActionButton(systemImageName: "trash") {
                        songsList.del(song: song)
                    }
                    .frame(width: 18)
                }
            }
            .padding(.vertical, scale == .large ? 50 : 0)
        }
        .onAppear {
            player.setupAudio(url: song.url)
        }
        .onDisappear {
            timer.upstream.connect().cancel()
        }
        .onReceive(timer, perform: { _ in
            player.updateProgress()
        })
    }
    
    private func getPlaybackPosition(_ x: Double, _ maxWidth: Double) -> Double {
        let percent = x / (maxWidth-40)
        return Double(percent) * player.duration
    }
    
    private func getWidth(_ maxWidth: Double) -> Double {
        let value = player.duration > 0 ? player.currentTime / player.duration : 0
        return (maxWidth-40) * CGFloat(value)
    }
}


//#Preview {
//    return ZStack {
//        Color.black
//        HStack {
//            AudioPlayerView(scale: .small)
//        }
//    }
//}
