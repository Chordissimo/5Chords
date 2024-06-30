//
//  AudioPlayerService.swift
//  AmDm AI
//
//  Created by Anton on 19/04/2024.
//

import AVFoundation
import SwiftUI

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
    
    func setupAudio(url: URL) -> Bool {
//        @AppStorage("fileBookmark") var fileBookmark: Data?
        var _url = url
        
        let isReachable = (try? url.checkResourceIsReachable()) ?? false
//        let exists = FileManager.default.fileExists(atPath: url.absoluteString)
//        print("original url:",isReachable,exists,url)
        
        do {
            if !isReachable {
                let filename = String(url.absoluteString.split(separator: "/").last ?? "")
                let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                _url = documentsPath.appendingPathComponent(filename)
//                let a = (try? _url.checkResourceIsReachable()) ?? false
//                let exists1 = FileManager.default.fileExists(atPath: _url.absoluteString)
//                print("modify url:",a,exists1,_url)
//                if !a {
//                    var s = true
//                    _url = try URL(resolvingBookmarkData: fileBookmark!, options: .withoutImplicitStartAccessing, relativeTo: nil, bookmarkDataIsStale: &s)
//                    let b = (try? _url.checkResourceIsReachable()) ?? false
//                    let exists2 = FileManager.default.fileExists(atPath: _url.absoluteString)
//                    print("bookmarl url:",b,exists2,_url)
//                }
            }
//            let audioSession = AVAudioSession.sharedInstance()
//            try audioSession.setCategory(.playback, mode: .default)
//            try audioSession.setActive(true)
            self.audioPlayer = try AVAudioPlayer(contentsOf: _url)
        } catch {
            print("Audio player init:", error)
        }
        guard let player = self.audioPlayer else { return false }
        player.delegate = self
        player.prepareToPlay()
        self.duration = player.duration
        return true
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
        if currentTime == duration {
            stop()
        }
    }
    
    func seekAudio(to time: TimeInterval) {
        guard let player = audioPlayer else { return }
        currentTime = time >= duration ? duration : time
        player.currentTime = currentTime
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            updateProgress()
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
}
