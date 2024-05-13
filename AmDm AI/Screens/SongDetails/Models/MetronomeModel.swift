//
//  MetronomeModel.swift
//  AmDm AI
//
//  Created by Anton on 12/05/2024.
//

import Foundation
import AVFoundation

class MetronomeModel: ObservableObject {
    var bpm: Double?
    var beats: Int?
    @Published var beatCounter: Int = -1
    var timer: Timer?
    @Published var isStarted = false
    private var firstBeatSound = SystemSoundID(1105) //1104, 1105, 1306
    private var beatSound = SystemSoundID(1104)
    
    func stop() {
        timer?.invalidate()
        timer = nil
        beatCounter = -1
        self.isStarted = false
    }
    
    func start(bpm: Double, beats: Int) {
        self.bpm = bpm
        self.beats = beats
        self.isStarted = true
        timer = Timer.scheduledTimer(withTimeInterval: 60 / self.bpm!, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            beatCounter = beatCounter < beats - 1 ? beatCounter + 1 : 0
            AudioServicesPlaySystemSound(beatCounter == 0 ? firstBeatSound : beatSound)
        }
    }
}
