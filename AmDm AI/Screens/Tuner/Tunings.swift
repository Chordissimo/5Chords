//
//  Tunings.swift
//  AmDm AI
//
//  Created by Anton on 26/05/2024.
//

import Foundation

enum TuningType {
    case guitarStandard
    case guitarHalfStepDown
    case guitarDropD
    case ukuleleStandard
    case ukuleleAlternative
    case bassStandard
    case bassDropD
}

enum InstrumentType: String {
    case guitar = "Guitar"
    case bass = "Bass"
    case ukulele = "Ukulele"
}

struct Tuning: Identifiable {
    var id = UUID()
    var instrument: InstrumentType = .guitar
    var type: TuningType = .guitarStandard
    var name: String = ""
    var notes: [String] = []
    var frequencies: [Float] = []
}

struct TuningsColection {
    let semitonesFrequencies: [Float] = [
        16.35,17.32,18.35,19.45,20.6,21.83,23.12,24.5,25.96,27.5,29.14,30.87,
        32.7,34.65,36.71,38.89,41.2,43.65,46.25,49,51.91,55,58.27,61.74,
        65.41,69.3,73.42,77.78,82.41,87.31,92.5,98,103.83,110,116.54,123.47,
        130.81,138.59,146.83,155.56,164.81,174.61,185,196,207.65,220,233.08,246.94,
        261.63,277.18,293.66,311.13,329.63,349.23,369.99,392,415.3,440,466.16,493.88,
        523.25,554.37,587.33,622.25,659.25,698.46,739.99,783.99,830.61,880,932.33,932.33,
        1046.5,1108.73,1174.66,1244.51,1318.51,1396.91,1479.98,1567.98,1661.22,1760,1864.66,1975.53,
        2093,2217.46,2349.32,2489.02,2637.02,2793.83,2959.96,3135.96,3322.44,3520,3729.31,3951.07,
        4186.01,4434.92,4698.63,4978.03,5274.04,5587.65,5919.91,6271.93,6644.88,7040,7458.62,7902.13
    ]
    
    let noteNamesWithSharps = ["C", "C♯", "D", "D♯", "E", "F", "F♯", "G", "G♯", "A", "A♯", "B"]
    let noteNamesWithFlats = ["C", "D♭", "D", "E♭", "E", "F", "G♭", "G", "A♭", "A", "B♭", "B"]

    var tunings: [Tuning] = []
    var instruments: [String] = []
    
    init() {
        self.tunings.append(Tuning(
            instrument: .guitar,
            type: .guitarStandard,
            name: "Standard Tuning",
            notes: ["E", "A", "D", "G", "B", "E"],
            frequencies: [82.41, 110.0, 146.83, 196.0, 246.94, 329.63].map { Float($0) }
        ))
        self.tunings.append(Tuning(
            instrument: .guitar,
            type: .guitarHalfStepDown,
            name: "Half Step Down",
            notes: ["E♭", "A♭", "D♭", "G♭", "B♭", "E♭"],
            frequencies: [311.13,233.08,185,138.59,103.83,77.78].map { Float($0) }
        ))
        self.tunings.append(Tuning(
            instrument: .guitar,
            type: .guitarDropD,
            name: "Drop D",
            notes: ["D", "A", "D", "G", "B", "E"],
            frequencies: [73.42, 110.0, 146.83, 196.0, 246.94, 329.63].map { Float($0) }
        ))
        self.tunings.append(Tuning(
            instrument: .ukulele,
            type: .ukuleleStandard,
            name: "Standard",
            notes: ["G", "C", "E", "A"],
            frequencies: [392.0, 261.63, 329.63, 440.0].map { Float($0) }
        ))
        self.tunings.append(Tuning(
            instrument: .ukulele,
            type: .ukuleleStandard,
            name: "Alternative",
            notes: ["D", "G", "B", "E"],
            frequencies: [146.83, 196.0, 246.94, 329.63].map { Float($0) }
        ))
        self.tunings.append(Tuning(
            instrument: .bass,
            type: .bassStandard,
            name: "Standard",
            notes: ["E", "A", "D", "G"],
            frequencies: [41.2, 55.0, 73.42, 98].map { Float($0) }
        ))
        self.tunings.append(Tuning(
            instrument: .bass,
            type: .bassDropD,
            name: "Drop D",
            notes: ["E", "A", "D", "G"],
            frequencies: [36.71, 55.0, 73.42, 98].map { Float($0) }
        ))
        self.instruments = [
            InstrumentType.guitar.rawValue,
            InstrumentType.ukulele.rawValue,
            InstrumentType.bass.rawValue
        ]
    }
    
    func getTuning(_ tuning: TuningType) -> Tuning {
        let t = tunings.filter { $0.type == tuning }
        return t.count > 0 ? t.first! : Tuning()
    }
    
    func getAllTunings(for instrument: InstrumentType) -> [Tuning] {
        let t = tunings.filter { $0.instrument == instrument }
        return t.count > 0 ? t : [Tuning()]
    }
}
