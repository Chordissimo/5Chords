//
//  YouTubePlayerService.swift
//  AmDm AI
//
//  Created by Anton on 24/06/2024.
//

import Foundation
import YouTubePlayerKit
import Combine

class YouTubePlayerService: ObservableObject {
    var player = YouTubePlayer()
    @Published var currentTime: Int = 0
    @Published var isPlaying: Bool = false
    @Published var isReady: Bool = false
//    var cancellables = Set<AnyCancellable>()
    
    func prepareToPlay(url: String) {
        var id = ""
        if let urlComponent = URLComponents(string: url) {
            id = urlComponent.queryItems?.first(where: { $0.name == "v" })?.value ?? ""
        }
        self.player.source = .video(id: id)
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
        self.player.configuration = configuration
//        subscribe()
    }
    
//    func subscribe() {
//        self.player
//            .currentTimePublisher()
//            .sink { time in
//                self.currentTime = Int(time.value * 1000)
//            }
//            .store(in: &self.cancellables)
//        self.player
//            .statePublisher
//            .sink { playerState in
//                self.isReady = playerState.isIdle || playerState.isReady
//            }
//            .store(in: &self.cancellables)
//    }
    
    func play(completion: @escaping () -> Void = {}) {
        player.play() { _ in
            self.isPlaying = true
            completion()
        }
    }
    
    func pause() {
        player.pause() { _ in
            self.isPlaying = false
        }
    }
    
    func jumpTo(miliseconds: Int, completion: @escaping () -> Void = {}) {
        let target = Measurement(value: Double(miliseconds), unit: UnitDuration.milliseconds)
        player.seek(to: target, allowSeekAhead: true) { _ in
            self.player.play()
            self.isPlaying = true
            completion()
        }
    }
    
}
