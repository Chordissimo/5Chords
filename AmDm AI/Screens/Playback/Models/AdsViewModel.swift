//
//  AdsViewModel.swift
//  AmDm AI
//
//  Created by Anton on 21/07/2024.
//

import Foundation
import SwiftUI

struct Chord: Identifiable, Hashable {
    static func == (lhs: Chord, rhs: Chord) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    var id = UUID()
    var chord: String
    var lyrics: String
}

struct Line: Identifiable, Hashable {
    static func == (lhs: Line, rhs: Line) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    var id = UUID()
    var start: String
    var chords: [Chord]
}

enum AdType {
    case editChords, hideLyrics, transposition
}

class AdsViewModel: ObservableObject {
    @Published var lines: [Line] = [
        Line(start: "0:08", chords: [
            Chord(chord: "D", lyrics: "Jingle bell, "),
            Chord(chord: "Dmaj7", lyrics: "Jingle bell, "),
            Chord(chord: "D6", lyrics: "jingle bell "),
            Chord(chord: "D", lyrics: "rock, ")
        ]),
        Line(start: "0:11", chords: [
            Chord(chord: "D6", lyrics: "jingle bells "),
            Chord(chord: "D", lyrics: "swing and "),
            Chord(chord: "G/E", lyrics: "  jingle  "),
            Chord(chord: "A7", lyrics: "ring ")
        ]),
        Line(start: "0:16", chords: [
            Chord(chord: "Em", lyrics: "Snowing an "),
            Chord(chord: "A7", lyrics: "blowing up "),
            Chord(chord: "Em", lyrics: "bushels of "),
            Chord(chord: "A7", lyrics: "fun, ")
        ]),
        Line(start: "0:20", chords: [
            Chord(chord: "A", lyrics: "now the jingle hop "),
            Chord(chord: "Em", lyrics: "has "),
            Chord(chord: "A7", lyrics: "begun ")
        ])
    ]
    
    public static func getWidth(for chord: Chord) -> CGFloat {
        let textSize = ceil(chord.lyrics.size(withAttributes: [.font: UIFont.systemFont(ofSize: LyricsViewModelConstants.lyricsfontSize)]).width)
        let chordSize = ceil(chord.chord.size(withAttributes: [.font: UIFont.systemFont(ofSize: LyricsViewModelConstants.lyricsfontSize, weight: .semibold)]).width)
        return (textSize > 0 ? max(textSize,chordSize) : max(chordSize,LyricsViewModelConstants.minChordWidth)) + LyricsViewModelConstants.spacing
    }
}
