//
//  TunerModel.swift
//  AmDm AI
//
//  Created by Anton on 11/05/2024.
//

import Foundation
import AudioKit
import AudioKitEX
import AudioToolbox
import SoundpipeAudioKit

struct TunerData: Equatable {
    var pitch: Float = 0.0
    var amplitude: Float = 0.0
    var noteNameWithSharps = "-"
    var noteNameWithFlats = "-"
    var stringName = ""
    var stringIndex = 0
    var distance: Float = 0.0
    var semitoneRange: Float = 0.0
}

class TunerModel: ObservableObject, HasAudioEngine {
    
    
    @Published var data = TunerData()

    let engine = AudioEngine()
    let mic: AudioEngine.InputNode
    let silence: Fader

    var tracker: PitchTap!
    var tuningsCollection = TuningsColection()
    @Published var tuning: Tuning
    private var flag: Int = 0

    let scaleIntervals = Array(0..<31)

    init(tuningType: TuningType) {
        guard let input = engine.input else { fatalError() }
        self.mic = input
        self.silence = Fader(input, gain: 0)
        self.engine.output = silence
        
        self.tuning = tuningsCollection.getTuning(tuningType)

        tracker = PitchTap(self.mic) { pitch, amp in
            DispatchQueue.main.async {
                if self.flag == 2 {
                    self.update(pitch[0], amp[0])
                    self.flag = 0
                } else {
                    self.flag += 1
                }
            }
        }
        tracker.start()
    }

    func update(_ pitch: AUValue, _ amp: AUValue) {
        // Reduces sensitivity to background noise to prevent random / fluctuating data.
        guard amp > 0.1 else {
            return
        }
        data.pitch = pitch
        data.amplitude = amp

        let stringIdx = tuning.notes.filter { note in
            data.pitch >= note.frequency
        }
        
        let lowerIndex = stringIdx.count == 0 ? 0 : stringIdx.last!.id
        let higherIndex = lowerIndex == tuning.notes.count - 1 ? tuning.notes.count - 1 : lowerIndex + 1
        
        if higherIndex == lowerIndex {
            data.stringName = tuning.notes[lowerIndex].name
            data.stringIndex = lowerIndex + 1
            data.distance = data.pitch - tuning.notes[lowerIndex].frequency
        } else {
            let avg = (tuning.notes[higherIndex].frequency + tuning.notes[lowerIndex].frequency) / 2
            let resultIndex = data.pitch >= avg ? higherIndex : lowerIndex
            data.stringName = tuning.notes[resultIndex].name
            data.stringIndex = resultIndex + 1
            data.distance = data.pitch - tuning.notes[resultIndex].frequency
        }
        
        let semitoneIdx = tuningsCollection.semitonesFrequencies.filter { frequency in
            data.pitch >= frequency
        }
        
        let lowerSemitone = semitoneIdx.count == 0 ? 0 : semitoneIdx.firstIndex(of: semitoneIdx.last!)!
        let higherSemitone = semitoneIdx.count == tuningsCollection.semitonesFrequencies.count ? 0 : lowerSemitone + 1
        
        if higherSemitone != lowerSemitone {
            data.semitoneRange = tuningsCollection.semitonesFrequencies[higherSemitone] - tuningsCollection.semitonesFrequencies[lowerSemitone]
        } else {
            data.semitoneRange = 0
        }
    }
    
    func switchTuning(tuningIndex: Int) {
        self.tuning = self.tuningsCollection.tunings[tuningIndex]
        self.data = TunerData()
    }
    
}
