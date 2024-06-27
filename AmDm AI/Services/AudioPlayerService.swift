//
//  AudioPlayerService.swift
//  AmDm AI
//
//  Created by Anton on 19/04/2024.
//

import AVFoundation

class Player: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published var isPlaying: Bool = false
    @Published var duration: TimeInterval = 0.0
    @Published var currentTime: TimeInterval = 0.0
    var timer: Timer?
    var audioPlayer: AVAudioPlayer? = nil
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        currentTime = flag ? duration : currentTime
        isPlaying = false
    }
        
    func setupAudio(url: URL) {
        var _url = url
        let isReachable = (try? url.checkResourceIsReachable()) ?? false
        do {
            if !isReachable {
                let filename = String(url.absoluteString.split(separator: "/").last ?? "")
                let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                _url = documentsPath.appendingPathComponent(filename)
            }
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default)
            try audioSession.setActive(true)
            audioPlayer = try AVAudioPlayer(contentsOf: _url)
        } catch {
            print(error)
        }        
        
        guard let player = audioPlayer else { return }
        player.delegate = self
        player.prepareToPlay()
        self.duration = player.duration
    }
    
    func play() {
        guard let player = audioPlayer else { return }
        player.play()
        isPlaying = true
        startTimer()
    }
    
    func stop() {
        guard let player = audioPlayer else { return }
        player.pause()
        isPlaying = false
        stopTimer()
    }
    
    func updateProgress() {
        guard let player = audioPlayer else { return }
        currentTime = isPlaying ? player.currentTime : currentTime
    }
    
    func seekAudio(to time: TimeInterval) {
        guard let player = audioPlayer else { return }
        currentTime = time >= duration ? duration : time
        player.currentTime = currentTime
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            updateProgress()
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
}
