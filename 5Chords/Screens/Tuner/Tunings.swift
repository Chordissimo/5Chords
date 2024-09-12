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

struct Instrument: Identifiable, Equatable, Hashable {
    var id = UUID()
    var name: String = "Guitar"
    var imageAssets: [String] = []
    var noteLabelOffsets: [CGFloat] = []
    var instrumentType: InstrumentType = .guitar
}

struct StringNote: Identifiable, Equatable, Hashable {
    var name: String = ""
    var frequency: Float
    var id: Int
}

struct Tuning: Identifiable, Equatable {
    var id = UUID()
    var instrumentType: InstrumentType = .guitar
    var type: TuningType = .guitarStandard
    var name: String = ""
    var notes: [StringNote] = []
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
    var instruments: [Instrument] = []
    
    init() {
        self.tunings.append(Tuning(
            instrumentType: .guitar,
            type: .guitarStandard,
            name: "Standard Tuning",
            notes: [
                StringNote(name: "E", frequency: 82.41, id: 0),
                StringNote(name: "A", frequency: 110.0, id: 1),
                StringNote(name: "D", frequency: 146.83, id: 2),
                StringNote(name: "G", frequency: 196.0, id: 3),
                StringNote(name: "B", frequency: 246.94, id: 4),
                StringNote(name: "E", frequency: 329.63, id: 5)
            ]
        ))
        self.tunings.append(Tuning(
            instrumentType: .guitar,
            type: .guitarHalfStepDown,
            name: "Half Step Down",
            notes: [
                StringNote(name: "E♭", frequency: 311.13, id: 0),
                StringNote(name: "A♭", frequency: 233.08, id: 1),
                StringNote(name: "D♭", frequency: 185, id: 2),
                StringNote(name: "G♭", frequency: 138.59, id: 3),
                StringNote(name: "B♭", frequency: 103.83, id: 4),
                StringNote(name: "E♭", frequency: 77.78, id: 5)
            ]
        ))
        self.tunings.append(Tuning(
            instrumentType: .guitar,
            type: .guitarDropD,
            name: "Drop D",
            notes: [
                StringNote(name: "D", frequency: 73.42, id: 0),
                StringNote(name: "A", frequency: 110.0, id: 1),
                StringNote(name: "D", frequency: 146.83, id: 2),
                StringNote(name: "G", frequency: 196.0, id: 3),
                StringNote(name: "B", frequency: 246.94, id: 4),
                StringNote(name: "E", frequency: 329.63, id: 5)
            ]
        ))
        self.tunings.append(Tuning(
            instrumentType: .ukulele,
            type: .ukuleleStandard,
            name: "Standard",
            notes: [
                StringNote(name: "G", frequency: 392.0, id: 0),
                StringNote(name: "C", frequency: 261.63, id: 1),
                StringNote(name: "E", frequency: 329.63, id: 2),
                StringNote(name: "A", frequency: 440.0, id: 3)
            ]
        ))
        self.tunings.append(Tuning(
            instrumentType: .ukulele,
            type: .ukuleleAlternative,
            name: "Alternative",
            notes: [
                StringNote(name: "D", frequency: 146.83, id: 0),
                StringNote(name: "G", frequency: 196.0, id: 1),
                StringNote(name: "B", frequency: 246.94, id: 2),
                StringNote(name: "E", frequency: 329.63, id: 3)
            ]
        ))
        self.tunings.append(Tuning(
            instrumentType: .bass,
            type: .bassStandard,
            name: "Standard",
            notes: [
                StringNote(name: "E", frequency: 41.2, id: 0),
                StringNote(name: "A", frequency: 55.0, id: 1),
                StringNote(name: "D", frequency: 73.42, id: 2),
                StringNote(name: "G", frequency: 98, id: 3)
            ]
        ))
        self.tunings.append(Tuning(
            instrumentType: .bass,
            type: .bassDropD,
            name: "Drop D",
            notes: [
                StringNote(name: "D", frequency: 36.71, id: 0),
                StringNote(name: "A", frequency: 55.0, id: 1),
                StringNote(name: "D", frequency: 73.42, id: 2),
                StringNote(name: "G", frequency: 98, id: 3)
            ]
        ))
        
        self.instruments = [
            Instrument(
                name: "Guitar",
                imageAssets: ["Guitar","g1","g2","g3","g4","g5","g6"],
                noteLabelOffsets: [0.597,0.424,0.25,0.25,0.424,0.597],
                instrumentType: .guitar
            ),
            Instrument(
                name: "Ukulele",
                imageAssets: ["Ukulele","u1","u2","u3","u4"],
                noteLabelOffsets: [0.548,0.272,0.272,0.548],
                instrumentType: .ukulele
            ),
            Instrument(
                name: "Bass",
                imageAssets: ["Bass","b1","b2","b3","b4"],
                noteLabelOffsets: [0.478,0.199,0.285,0.517],
                instrumentType: .bass
            )
        ]
    }
    
    func getTuning(_ tuning: TuningType) -> Tuning {
        let t = tunings.filter { $0.type == tuning }
        return t.count > 0 ? t.first! : Tuning()
    }
    
    func getAllTunings(for instrumentType: InstrumentType) -> [Tuning] {
        let t = tunings.filter { $0.instrumentType == instrumentType }
        return t.count > 0 ? t : [Tuning()]
    }
    
    func getInstrumentBy(type instrumentType: InstrumentType) -> Instrument {
        let i = instruments.filter { $0.instrumentType == instrumentType }
        return i.count > 0 ? i.first! : Instrument()
    }
    
}
