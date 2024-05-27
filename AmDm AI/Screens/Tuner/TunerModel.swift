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
    var stringIndex = -1
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
    var tuning: Tuning

    let scaleIntervals = Array(0..<31)

    init(tuningType: TuningType) {
        guard let input = engine.input else { fatalError() }
        self.mic = input
        self.silence = Fader(input, gain: 0)
        self.engine.output = silence
        
        self.tuning = tuningsCollection.getTuning(tuningType)

        tracker = PitchTap(self.mic) { pitch, amp in
            DispatchQueue.main.async {
                self.update(pitch[0], amp[0])
            }
        }
        tracker.start()
    }

    func update(_ pitch: AUValue, _ amp: AUValue) {
        // Reduces sensitivity to background noise to prevent random / fluctuating data.
        guard amp > 0.05 else { return }

        data.pitch = pitch
        data.amplitude = amp

        let stringIdx = tuning.frequencies.filter { frequency in
            data.pitch >= frequency
        }
        
        let lowerIndex = stringIdx.count == 0 ? 0 : tuning.frequencies.firstIndex(of: stringIdx.last!)!
        let higherIndex = lowerIndex == 5 ? 5 : lowerIndex + 1
        
        if higherIndex == lowerIndex {
            data.stringName = tuning.notes[lowerIndex]
            data.stringIndex = lowerIndex
            data.distance = data.pitch - tuning.frequencies[lowerIndex]
        } else {
            let avg = (tuning.frequencies[higherIndex] + tuning.frequencies[lowerIndex]) / 2
            let resultIndex = data.pitch >= avg ? higherIndex : lowerIndex
            data.stringName = tuning.notes[resultIndex]
            data.stringIndex = resultIndex
            data.distance = data.pitch - tuning.frequencies[resultIndex]
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
    
//    func selfTest() {
//        print("Frequencies:", self.guitarStandardTuning)
//        
//        print("Test 1 -------------------------")
//        self.update(400.00, 1)
//        print("semitoneRange", data.semitoneRange, "expected:", 415.3 - 392)
//        print("distance:", data.distance)

        
        
//        print("pitch:", data.pitch)
//        print("stringName:", data.stringName, "expected: E")
//        print("stringIndex:", data.stringIndex, "expected: 5")
//        print("distance:", data.distance, "expected:", 400 - 329.63)
        
//        print("Test 2 -------------------------")
//        self.update(290.00, 1)
//        print("pitch:", data.pitch)
//        print("stringName:", data.stringName, "expected: E")
//        print("stringIndex:", data.stringIndex, "expected: 5")
//        print("distance:", data.distance, "expected:", 290 - 329.63)
        
//        print("Test 3 -------------------------")
//        self.update(260.00, 1)
//        print("pitch:", data.pitch)
//        print("stringName:", data.stringName, "expected: B")
//        print("stringIndex:", data.stringIndex, "expected: 4")
//        print("distance:", data.distance, "expected:", 260 - 246.94)

//        print("Test 4 -------------------------")
//        self.update(288.285, 1)
//        print("pitch:", data.pitch)
//        print("stringName:", data.stringName, "expected: E")
//        print("stringIndex:", data.stringIndex, "expected: 5")
//        print("distance:", data.distance, "expected:", 288.285 - 329.63)

//        print("Test 5 -------------------------")
//        self.update(109.4, 1)
//        print("pitch:", data.pitch)
//        print("stringName:", data.stringName, "expected: A")
//        print("stringIndex:", data.stringIndex, "expected: 1")
//        print("distance:", data.distance, "expected:", 109.4 - 110.0)
//    }

}
