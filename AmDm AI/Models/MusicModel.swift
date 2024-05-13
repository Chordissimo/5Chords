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
    var key: Chords.Key
    var suffix: Chords.Suffix
    
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
