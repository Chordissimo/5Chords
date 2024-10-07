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
    var id = UUID().uuidString
    
    enum CodingKeys: String, CodingKey {
        case chord
        case start
        case end
    }
    
    init(id: String = UUID().uuidString, chord: String, start: Int, end: Int) {
        self.chord = chord
        self.start = start
        self.end = end
        self.id = id
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.chord = try values.decode(String.self, forKey: .chord)
        self.start = try values.decode(Int.self, forKey: .start)
        self.end = try values.decode(Int.self, forKey: .end)
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
    
    func updateChord(newKey: Chords.Key, newSuffix: Chords.Suffix) {
        self.key = newKey
        self.suffix = newSuffix
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
        case "": return ._major
        case "m": return ._minor
        case "m7b5": return ._m7b5
        case "6": return ._6
        case "7": return ._7
        case "maj7": return ._maj7
        case "m7": return ._m7
        case "m6": return ._m6
        case "dim": return ._dim
        case "aug": return ._aug
        case "min": return ._minor
        case "hdim7": return ._m7b5
//        case "maj6": return ._maj6
        case "min7": return ._m7
        case "min6": return ._m6
        case "/e": return ._overE
        case "/f": return ._overF
        case "/f#": return ._overFSharp
        case "/g": return ._overG
        case "/g#": return ._overGSharp
        case "/a": return ._overA
        case "/bb": return ._overASharp
        case "/b": return ._overB
        case "/c": return ._overC
        case "/c#" : return ._overCSharp
        case "m/b": return ._mOverB
        case "m/c": return ._mOverC
        case "m/c#": return ._mOverCSharp
        case "/d": return ._overD
        case "m/d": return ._mOverD
        case "/d#": return ._overDSharp
        case "m/d#": return ._mOverDSharp
        case "m/e": return ._mOverE
        case "m/f": return ._mOverF
        case "m/f#": return ._mOverFSharp
        case "m/g": return ._mOverG
        case "m/g#": return ._mOverGSharp
        case "dim7": return ._dim7
        case "sus2": return ._sus2
        case "sus4": return ._sus4
        case "7sus4": return ._7sus4
        case "5": return ._5
        case "alt": return ._7b9
        case "6/9": return ._6add9
        case "7b5": return ._7b5
        case "aug7": return ._aug7
        case "9": return ._9
        case "9b5": return ._9b5
        case "aug9": return ._aug9
        case "m9": return ._m9
        case "7#9": return ._7sharp9
        case "11": return ._11
        case "9#11": return ._9sharp11
        case "13": return ._13
        case "maj7b5": return ._maj7b5
        case "maj7#5": return ._maj7sharp5
        case "7#5": return ._7sharp5
        case "maj9": return ._maj9
        case "maj11": return ._maj11
        case "maj13": return ._maj13
        case "m6/9": return ._m6add9
        case "mmaj7": return ._mMaj7
        case "mmaj7b5": return ._mMaj7b5
        case "mmaj9": return ._mMaj9
        case "mmaj11": return ._mMaj11
        case "add9": return ._add9
        case "madd9": return ._m6add9
        default: return nil
        }
    }
    
    func transpose(shift: Int) {
        guard shift != 0 && self.key != nil else { return }
        var resultKey: Chords.Key = self.key!
        
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
        
        self.key = resultKey
    }
    
    func getChordString(flatSharpSymbols: Bool = true) -> String {
        var result = ""
        if let k = self.key, let s = self.suffix {
            if flatSharpSymbols {
                if s == ._major {
                    result = k.display.symbol
                } else if s == ._minor {
                    result = k.display.symbol + "m"
                } else {
                    result = k.display.symbol + s.display.symbolized
                }
            } else {
                if s == ._major {
                    result = k.rawValue
                } else if s == ._minor {
                    result = k.rawValue + "m"
                } else {
                    result = k.display.symbol + s.rawValue
                }
            }
        }
        return result
    }
    
    func renderShape(positionIndex: Int) -> ShapeLayerView? {
        guard self.chordPositions.count > 0 && positionIndex >= 0 else { return nil }
        return ShapeLayerView(shapeLayer: createShapeLayer(
            chordPosition: self.chordPositions[positionIndex],
            width: LyricsViewModelConstants.chordWidth,
            height: LyricsViewModelConstants.chordHeight
        ))
    }
    
}

struct ShapeLayerView: UIViewRepresentable {
    let shapeLayer: CAShapeLayer
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.layer.addSublayer(shapeLayer)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

func createShapeLayer(chordPosition: ChordPosition, width: CGFloat, height: CGFloat) -> CAShapeLayer {
    var frame: CGRect
    frame = CGRect(x: 0, y: 0, width: width, height: height)
    
    let shapeLayer = chordPosition.chordLayer(
        rect: frame,
        chordName: .init(show: false, key: .symbol, suffix: .symbolized),
        forPrint: false
    )
    
    return shapeLayer
}
