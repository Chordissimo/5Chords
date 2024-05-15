//
//  MusicModel.swift
//  AmDm AI
//
//  Created by Anton on 13/05/2024.
//

import Foundation
import SwiftyChords

class APIChord: Codable, Identifiable {
    var chord: String
    var start: Int
    var end: Int
    var uiChord: UIChord {
        if chord.uppercased() != "N" {
            let parts = chord.uppercased().split(separator: ":")
            return UIChord(
                key: UIChord.getKey(from: String(parts[0].lowercased()))!,
                suffix: String(parts[1]) == "MIN" ? Chords.Suffix.minor : Chords.Suffix.major
            )
        }
        return UIChord(key: .a, suffix: .minor) // fix this !!!
    }
    var id = UUID().uuidString
    
    enum CodingKeys: String, CodingKey {
        case chord
        case start
        case end
    }
    
    init(id: String, chord: String, start: Int, end: Int) {
        self.chord = chord
        self.start = start
        self.end = end
        self.id = id
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        chord = try values.decode(String.self, forKey: .chord)
        start = try values.decode(Int.self, forKey: .start)
        end = try values.decode(Int.self, forKey: .end)
    }
}


struct UIChord: Identifiable, Hashable {
    let id = UUID()
    var guitarChord: GuitarChord
    var pianoChord: Chord
    var key: Chords.Key
    var suffix: Chords.Suffix

    init(key: String, suffix: String) {
        self.guitarChord = GuitarChord(key: key, suffix: suffix)
    }

    static func getKey(from string: String) -> Chords.Key? {
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
}

struct GuitarChord {
    var root: Chords.Key
    var suffix: Chords.Suffix
    var chordCollection: [ChordPosition]

    init(root: String, suffix: String) {
        self.root = getRoot(key: root)
        self.suffix = getSuffix(suffix: suffix)
        self.chordCollection = Chords.guitar.matching(key: self.root).matching(suffix: self.suffix)
    }

    private func getRoot(from key: String) -> Chords.Key? {
        return Chords.Key.allCases.filter { $0.rawValue.lowercased() == key.lowercased() }.first!
    }

    private func getSuffix(from suffix: String) -> Chords.Suffix {
        return Chords.Suffix.allCases.filter { $0.rawValue.lowercased() == suffix.lowercased() }.first!
    }
}

struct PianoChord {
    var root: Key
    var accidential: Accidental
    var chord: Chord

    init(root: String) {
        self.root = Key(value: getRoot(root: root))
        self.accidential = Accidental(value: getAccidental(root: root))
    }

    private func getRoot(root: String) -> String {
        guard let key = root.map { String($0) } else { return "" }
        return key.count > 0 ? key[0].lowercased() : ""
    }

    private func getAccidental(root: String) -> String {
        guard let accidental = root.map { String($0) } else { return "" }
        return key.count >= 2 ? key[1].lowercased() : ""
    }
    
    // let m13 = ChordType(
    //     third: .minor,
    //     seventh: .dominant,
    //     extensions: [
    //         ChordExtensionType(type: .thirteenth)
    //     ]
    // )
    // let cm13 = Chord(type: m13, key: Key(type: .c))
}
