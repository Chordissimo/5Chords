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
    
    init(id: String, chord: String, start: Int, end: Int, uiChord: UIChord? = nil) {
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
        default: return nil
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
    
    func getChordString() -> String {
        var result = ""
        if let k = self.key, let s = self.suffix {
            result = k.display.symbol + s.display.short
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
