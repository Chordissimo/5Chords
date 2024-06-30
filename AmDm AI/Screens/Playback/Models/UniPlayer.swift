//
//  UniPlayer.swift
//  AmDm AI
//
//  Created by Anton on 27/06/2024.
//

import Foundation
import Combine

class UniPlayer: ObservableObject {
    @Published var currentTime: Int = 0
    @Published var duration: Int = 0
    @Published var isPlaying: Bool = false
    @Published var isReady: Bool = false
    var audioPlayer: Player = Player()
    var youTubePlayer = YouTubePlayerService()
    private var songType: SongType = .youtube
    var cancellables = Set<AnyCancellable>()
    
    func prepareToPlay(song: Song) {
        self.songType = song.songType
        self.duration = Int(song.duration * 1000)
        if self.songType == .youtube {
            self.youTubePlayer.prepareToPlay(url: song.url.absoluteString)
        } else {
            self.isReady = self.audioPlayer.setupAudio(url: song.url)
        }
        subscribe()
    }
    
    func subscribe() {
        if self.songType == .youtube {
            self.youTubePlayer.player
                .currentTimePublisher()
                .sink { time in
                    self.currentTime = Int(time.value * 1000)
                    if self.currentTime == self.duration {
                        self.pause()
                    }
                }
                .store(in: &self.cancellables)
            self.youTubePlayer.player
                .statePublisher
                .sink { playerState in
                    self.isReady = playerState.isIdle || playerState.isReady
                }
                .store(in: &self.cancellables)
            self.youTubePlayer.player
                .playbackStatePublisher
                .sink { value in
                    self.isPlaying = value != .ended && value != .paused && value != .cued
            }
            .store(in: &self.cancellables)
        } else {
            self.audioPlayer.$currentTime.sink { value in
                self.currentTime = Int(value * 1000)
            }
            .store(in: &self.cancellables)
            self.audioPlayer.$isPlaying.sink { value in
                self.isPlaying = value
            }
            .store(in: &self.cancellables)
        }
    }
    
    func play(completion: @escaping () -> Void = {}) {
        if self.songType == .youtube {
            self.youTubePlayer.play(completion: completion)
        } else {
            self.audioPlayer.play()
        }
        self.isPlaying = true
    }
    
    func pause() {
        if self.songType == .youtube {
            self.youTubePlayer.pause()
        } else {
            self.audioPlayer.stop()
        }
        self.isPlaying = false
    }
    
    func jumpTo(miliseconds: Int, completion: @escaping () -> Void = {}) {
        if self.songType == .youtube {
            self.youTubePlayer.jumpTo(miliseconds: miliseconds, completion: completion)
        } else {
            self.audioPlayer.seekAudio(to: Double(miliseconds / 1000))
            self.audioPlayer.play()
            completion()
        }
        self.isPlaying = true
    }
}
