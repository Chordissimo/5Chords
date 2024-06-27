//
//  LyricsViewModel.swift
//  AmDm AI
//
//  Created by Anton on 19/06/2024.
//

import Foundation
import SwiftUI
import SwiftyChords

struct LyricsViewModelConstants {
    static let chordHeight = 135.0
    static let chordWidth = 135.0 / 6 * 5
    static let videoPlayerHeight = 120.0
    static let videoPlayerWidth = 180.0
    static let maxBottomPanelHeight = 250.0
    static let minBottomPanelHeight = 110.0
}

struct Word: Identifiable, Hashable {
    static func == (lhs: Word, rhs: Word) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id);
    }
    var id = UUID()
    var start: Int
    var text: String
}

struct ChordShape: Identifiable, Hashable {
    static func == (lhs: ChordShape, rhs: ChordShape) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id);
    }

    var id = UUID()
    var chord: APIChord
    var shape: ShapeLayerView?
}

struct Interval: Identifiable, Hashable {
    static func == (lhs: Interval, rhs: Interval) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id);
    }
    
    var id = UUID()
    var start: Int
    var words: [Word] = []
    var chord: APIChord
    var limitLines: Int = 1
    var width: CGFloat = 0.0
}

struct Timeframe: Identifiable, Hashable {
    static func == (lhs: Timeframe, rhs: Timeframe) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id);
    }
    
    var id = UUID()
    var start: Int
    var intervals: [Interval] = []
    var width: CGFloat = 0.0
}

class IntervalModel {
    var timeframes: [Timeframe] = []
    var chords: [ChordShape] = []
    
    func createTimeframes(song: Song, maxWidth: CGFloat, fontSize: CGFloat) {
        guard song.chords.count > 0 && maxWidth > 0 && fontSize > 0 else { return }
        
        let intervals = createIntervals(song: song, maxWidth: maxWidth, fontSize: fontSize)
        var line: [Interval] = []
        var width: Double = 0
        
        for interval in intervals {
            width += interval.width
            if width > maxWidth {
                self.timeframes.append(Timeframe(start: line.first!.start, intervals: line, width: width - interval.width))
                line = []
                width = interval.width
            }
            line.append(interval)
            if let uiChord = interval.chord.uiChord {
                if uiChord.chordPositions.count > 0 {
                    let position = uiChord.chordPositions.first!
                    self.chords.append(ChordShape(
                        chord: interval.chord,
                        shape: ShapeLayerView(shapeLayer: createShapeLayer(chordPosition: position, width: LyricsViewModelConstants.chordWidth, height: LyricsViewModelConstants.chordHeight))
                        )
                    )
                } else {
                    self.chords.append(ChordShape(chord: interval.chord))
                }
            } else {
                self.chords.append(ChordShape(chord: interval.chord))
            }
        }
        if line.count > 0 {
            self.timeframes.append(Timeframe(start: line.first!.start, intervals: line, width: width))
        }
    }
    
    private func createIntervals(song: Song, maxWidth: CGFloat, fontSize: CGFloat) -> [Interval] {
        guard song.chords.count > 0 else { return [] }
        
        let compactedWords = compactWords(words: song.text)
        let adjustedChords = adjustChordStartTime(chords: song.chords, adjustment: -1000)
        var result: [Interval] = []
        
        if compactedWords.count > 0 {
            let firstWord = compactedWords.first!
            if firstWord.start < song.chords.first!.start {
                let chord = APIChord(id: UUID().uuidString, chord: "N", start: 0, end: song.chords.first!.start > 0 ? song.chords.first!.start : 0)
                let words = compactedWords.filter {
                    $0.start < song.chords.first!.start
                }
                result.append(Interval(start: 0, words: words, chord: chord))
            }
        }
        
        for i in 0..<adjustedChords.count {
            let words = compactedWords.filter {
                var condition = false
                if i == song.chords.count - 1 {
                    condition = $0.start >= adjustedChords[i].start
                } else {
                    condition = $0.start >= adjustedChords[i].start && $0.start < adjustedChords[i + 1].start
                }
                return condition
            }
            var interval = Interval(start: adjustedChords[i].start, words: words, chord: adjustedChords[i])
            let intervalWidth = getWidth(for: interval, with: fontSize)
            interval.limitLines = Int(ceil(intervalWidth / maxWidth))
            interval.width = intervalWidth > maxWidth ? maxWidth : max(50, intervalWidth)
            result.append(interval)
        }
        
        return compactIntervals(intervals: result)
    }
    
    private func getWidth(for interval: Interval, with fontSize: CGFloat) -> CGFloat {
        let textSize = ceil(interval.words.map { $0.text }.joined().size(withAttributes: [.font: UIFont.systemFont(ofSize: fontSize)]).width)
        let chordSize = ceil(interval.chord.chord.size(withAttributes: [.font: UIFont.systemFont(ofSize: fontSize)]).width)
        return max(textSize,textSize == 0 ? max(chordSize,50) : chordSize)
    }
    
    private func compactIntervals(intervals: [Interval]) -> [Interval] {
        guard intervals.count > 0 else { return [] }
        var result: [Interval] = []
        
        for interval in intervals {
            if !(interval.chord.chord == "N" && interval.words.count == 0) {
                result.append(interval)
            }
        }
        
        return result
    }
    
    private func compactWords(words: [AlignedText]) -> [Word] {
        guard words.count > 0 else { return [] }
        
        var result: [Word] = []
        let s = words.first!.start ?? -1
        var word = Word(start: s < 0 ? 0 : s, text: words.first!.text)
        
        for i in 1..<words.count {
            let start = words[i].start ?? -1
            if i == 0 {
                word = Word(start: start < 0 ? 0 : start, text: words.first!.text)
            } else {
                if start < 0 {
                    word.text += words[i].text
                } else {
                    result.append(word)
                    word = Word(start: start, text: words[i].text)
                }
            }
        }
        
        let index = result.firstIndex(where: { $0.id == word.id })
        if index == nil {
            result.append(word)
        }
        
        return result
    }
    
    func adjustChordStartTime(chords: [APIChord], adjustment: Int) -> [APIChord] {
        guard adjustment != 0 && chords.count > 0 else { return chords }

        var result: [APIChord] = []
        for chord in chords {
            chord.start = (chord.start + adjustment) < 0 ? 0 : (chord.start + adjustment)
            chord.end = (chord.end + adjustment) < 0 ? 0 : (chord.end + adjustment)
            result.append(chord)
        }
        return result
    }
    
    func getTimeframeIndex(time: Int) -> Int {
        let filteredTimeframes = self.timeframes.filter { return $0.start <= time }
        return filteredTimeframes.count > 0 ? self.timeframes.firstIndex(of: filteredTimeframes.last!)! : -1
    }

    func getChordIndex(time: Int) -> Int {
        let filteredChords = self.chords.filter { return $0.chord.start < time }
        return filteredChords.count > 0 ? self.chords.firstIndex(of: filteredChords.last!)! : -1
    }

}

