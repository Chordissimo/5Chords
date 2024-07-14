//
//  MusicModel.swift
//  AmDm AI
//
//  Created by Anton on 13/05/2024.
//

import Foundation
import SwiftyChords
import SwiftUI

class APIChord: Codable, Identifiable, Equatable, Hashable {
    static func == (lhs: APIChord, rhs: APIChord) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id);
    }
    
    var chord: String
    var start: Int
    var end: Int
    var uiChord: UIChord?
    var id = UUID().uuidString
    
    enum CodingKeys: String, CodingKey {
        case chord
        case start
        case end
    }
    
    init(id: String = UUID().uuidString, chord: String, start: Int, end: Int, uiChord: UIChord? = nil) {
        self.chord = chord
        self.start = start
        self.end = end
        self.id = id
        if let uiCh = uiChord {
            self.uiChord = uiCh
        } else {
            self.uiChord = UIChord(chord: self.chord)
        }
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.chord = try values.decode(String.self, forKey: .chord)
        self.start = try values.decode(Int.self, forKey: .start)
        self.end = try values.decode(Int.self, forKey: .end)
        self.uiChord = UIChord(chord: self.chord)
    }
}


class UIChord: Identifiable, Hashable {
    static func == (lhs: UIChord, rhs: UIChord) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id);
    }
    
    let id = UUID()
    var key: Chords.Key?
    var suffix: Chords.Suffix?
    var chordPositions: [ChordPosition] = []
    
    init?(chord: String) {
        guard chord != "" && chord != "N" else { return nil }
        var key = ""
        var suffix = ""
        
        if chord.count > 1 {
            key = String(chord.lowercased()[..<chord.index(chord.startIndex, offsetBy: 2)])
            if !["#","b"].contains(key.last!) {
                key = String(key.first!)
            }
            suffix = String(chord.lowercased()[chord.index(chord.startIndex, offsetBy: key.count)...])
        } else {
            key = chord.lowercased()
            suffix = ""
        }
        self.key = getKey(from: key)
        if let s = getSuffix(from: suffix) {
            self.suffix = s
        } else {
            if let slashIndex = suffix.firstIndex(of: "/") {
                let s = String(suffix[..<slashIndex])
                self.suffix = getSuffix(from: s)
            }
        }
        if let key = self.key, let suffix = self.suffix {
            self.chordPositions = Chords.guitar.matching(key: key).matching(suffix: suffix)
        }
    }
    
    init?(key: Chords.Key, suffix: Chords.Suffix) {
        self.key = key
        self.suffix = suffix
        self.chordPositions = Chords.guitar.matching(key: key).matching(suffix: suffix)
    }
    
    private func getKey(from string: String) -> Chords.Key? {
        switch string {
        case "c": return .c
        case "c#": return .cSharp
        case "db": return .dFlat
        case "d": return .d
        case "d#": return .dSharp
        case "eb": return .eFlat
        case "e": return .e
        case "f": return .f
        case "f#": return .fSharp
        case "gb": return .gFlat
        case "g": return .g
        case "g#": return .gSharp
        case "ab": return .aFlat
        case "a": return .a
        case "a#": return .aSharp
        case "bb": return .bFlat
        case "b": return .b
        default: return nil
        }
    }
    
    private func getSuffix(from string: String) -> Chords.Suffix? {
        switch string {
        case "": return .major
        case "m": return .minor
        case "m7b5": return .minorSevenFlatFive
        case "6": return .six
        case "7": return .seven
        case "maj7": return .majorSeven
        case "m7": return .minorSeven
        case "m6": return .minorSix
        case "dim": return .dim
        case "aug": return .aug
        case "min": return .minor
        case "hdim7": return .minorSevenFlatFive
        case "maj6": return .six
        case "min7": return .minorSeven
        case "min6": return .minorSix
        case "/e": return .slashE
        case "/f": return .slashF
        case "/f#": return .slashFSharp
        case "/g": return .slashG
        case "/g#": return .slashGSharp
        case "/a": return .slashA
        case "/bb": return .slashBFlat
        case "/b": return .slashB
        case "/c": return .slashC
        case "/c#" : return .slashCSharp
        case "m/b": return .minorSlashB
        case "m/c": return .minorSlashC
        case "m/c#": return .minorSlashCSharp
        case "/d": return .slashD
        case "m/d": return .minorSlashD
        case "/d#": return .slashDSharp
        case "m/d#": return .minorSlashDSharp
        case "m/e": return .minorSlashE
        case "m/f": return .minorSlashF
        case "m/f#": return .minorSlashFSharp
        case "m/g": return .minorSlashG
        case "m/g#": return .minorSlashGSharp
        case "dim7": return .dimSeven
        case "sus2": return .susTwo
        case "sus4": return .susFour
        case "7sus4": return .sevenSusFour
        case "5": return .five
        case "alt": return .altered
        case "6/9": return .sixNine
        case "7b5": return .sevenFlatFive
        case "aug7": return .augSeven
        case "9": return .nine
        case "9b5": return .nineFlatFive
        case "aug9": return .augNine
        case "m9": return .sevenFlatNine
        case "7#9": return .sevenSharpNine
        case "11": return .eleven
        case "9#11": return .nineSharpEleven
        case "13": return .thirteen
        case "maj7b5": return .majorSevenFlatFive
        case "maj7#5": return .majorSevenSharpFive
        case "7#5": return .sevenSharpFive
        case "maj9": return .majorNine
        case "maj11": return .majorEleven
        case "maj13": return .majorThirteen
        case "m6/9": return .minorSixNine
        case "mmaj7": return .minorMajorSeven
        case "mmaj7b5": return .minorMajorSeventFlatFive
        case "mmaj9": return .minorMajorNine
        case "mmaj11": return .minorMajorEleven
        case "add9": return .addNine
        case "madd9": return .minorAddNine
        default: return nil
        }
    }
    
    private func getSuffixString(from suffix: Chords.Suffix) -> String {
        switch suffix {
        case .major: return ""
        case .minor: return "m"
        case .dim: return "dim"
        case .dimSeven: return "dim7"
        case .susTwo: return "sus2"
        case .susFour: return "sus4"
        case .sevenSusFour: return "7sus4"
        case .five: return "5"
        case .altered: return "alt"
        case .aug: return "aug"
        case .six: return "6"
        case .sixNine: return "6/9"
        case .seven: return "7"
        case .sevenFlatFive: return "7b5"
        case .augSeven: return "aug7"
        case .nine: return "9"
        case .nineFlatFive: return "9b5"
        case .augNine: return "aug9"
        case .sevenFlatNine: return "m9"
        case .sevenSharpNine: return "7#9"
        case .eleven: return "11"
        case .nineSharpEleven: return "9#11"
        case .thirteen: return "13"
        case .majorSeven: return "maj7"
        case .majorSevenFlatFive: return "maj7b5"
        case .majorSevenSharpFive: return "maj7#5"
        case .sevenSharpFive: return "7#5"
        case .majorNine: return "maj9"
        case .majorEleven: return "maj11"
        case .majorThirteen: return "maj13"
        case .minorSix: return "m6"
        case .minorSixNine: return "m6/9"
        case .minorSeven: return "m7"
        case .minorSevenFlatFive: return "m7b5"
        case .minorNine: return "m9"
        case .minorEleven: return "m11"
        case .minorMajorSeven: return "mmaj7"
        case .minorMajorSeventFlatFive: return "mmaj7b5"
        case .minorMajorNine: return "mmaj9"
        case .minorMajorEleven: return "mmaj11"
        case .addNine: return "add9"
        case .minorAddNine: return "madd9"
        case .slashE: return "/e"
        case .slashF: return "/f"
        case .slashFSharp: return "/f#"
        case .slashG: return "/g"
        case .slashGSharp: return "/g#"
        case .slashA: return "/a"
        case .slashBFlat: return "/bb"
        case .slashB: return "/b"
        case .slashC: return "/c"
        case .slashCSharp: return "/c#"
        case .minorSlashB: return "m/b"
        case .minorSlashC: return "m/c"
        case .minorSlashCSharp: return "m/c#"
        case .slashD: return "/d"
        case .minorSlashD: return "m/d"
        case .slashDSharp: return "/d#"
        case .minorSlashDSharp: return "m/d#"
        case .minorSlashE: return "m/e"
        case .minorSlashF: return "m/f"
        case .minorSlashFSharp: return "m/f#"
        case .minorSlashG: return "m/g"
        case .minorSlashGSharp: return "m/g#"
        }
    }

    
    public static func transpose(key: Chords.Key, shift: Int) -> Chords.Key {
        guard shift != 0 else { return key }
        var resultKey: Chords.Key = key
        
        var keys: [Chords.Key] = []
        if [.dFlat, .eFlat, .gFlat, .aFlat, .bFlat].contains(where: {$0 == key}) {
            keys = [.c, .dFlat, .d, .eFlat, .e, .f, .gFlat, .g, .aFlat, .a, .bFlat, .b]
        } else {
            keys = [.c, .cSharp, .d, .dSharp, .e, .f, .fSharp, .g, .gSharp, .a, .aSharp, .b]
        }
        
        let index = keys.firstIndex(where: { $0 == key })! + shift
        
        if index > (keys.count - 1) {
            resultKey = keys[index - keys.count]
        } else if index < 0 {
            resultKey = keys[keys.count + index]
        } else {
            resultKey = keys[index]
        }
        
        return resultKey
    }
    
    func getChordString(flatSharpSymbols: Bool = true) -> String {
        var result = ""
        if let k = self.key, let s = self.suffix {
            if flatSharpSymbols {
                result = k.display.symbol + s.display.short
            } else {
                result = k.rawValue + getSuffixString(from: s)
            }
        }
        return result
    }
}

struct ShapeLayerView: UIViewRepresentable {
    let shapeLayer: CAShapeLayer
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.layer.addSublayer(shapeLayer)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Update shape layer properties if needed
    }
}

func createShapeLayer(chordPosition: ChordPosition, width: CGFloat, height: CGFloat) -> CAShapeLayer {
    var frame: CGRect
    frame = CGRect(x: 0, y: 0, width: width, height: height)
    
    let shapeLayer = chordPosition.chordLayer(
        rect: frame,
        chordName:.init(show: false, key: .symbol, suffix: .symbolized),
        forPrint: false
    )
    
    return shapeLayer
}
