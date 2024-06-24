//
//  LyricsViewModel.swift
//  AmDm AI
//
//  Created by Anton on 19/06/2024.
//

import Foundation
import SwiftUI

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
}

class IntervalModel {
    var timeframes: [Timeframe] = []
    
    func createTimeframes(song: Song, maxWidth: CGFloat, fontSize: CGFloat) {
        guard song.chords.count > 0 && maxWidth > 0 && fontSize > 0 else { return }
        
        let intervals = createIntervals(song: song, maxWidth: maxWidth, fontSize: fontSize)
        var line: [Interval] = []
        var width: Double = 0

        for interval in intervals {
            width += getWidth(for: interval, with: fontSize)
            if width > maxWidth {
                self.timeframes.append(Timeframe(start: line.first!.start, intervals: line))
                line = []
                width = getWidth(for: interval, with: fontSize)
            }
            line.append(interval)
        }
        if line.count > 0 {
            self.timeframes.append(Timeframe(start: line.first!.start, intervals: line))
        }
    }
    
    private func createIntervals(song: Song, maxWidth: CGFloat, fontSize: CGFloat) -> [Interval] {
        guard song.chords.count > 0 else { return [] }

        let compactedWords = compactWords(words: song.text)
        var result: [Interval] = []
        
        if compactedWords.count > 0 {
            let firstWord = compactedWords.first!
            if firstWord.start < song.chords.first!.start {
                let chord = APIChord(id: UUID().uuidString, chord: "N", start: 0, end: song.chords.first!.start)
                let words = compactedWords.filter {
                    $0.start < song.chords.first!.start
                }
                result.append(Interval(start: 0, words: words, chord: chord))
            }
        }
        
        for i in 0..<song.chords.count {
            let timeAdjustment = song.chords[i].start == 0 ? 0 : 0
            let words = compactedWords.filter {
                var condition = false
                if i == song.chords.count - 1 {
                    condition = $0.start >= song.chords[i].start - timeAdjustment
                } else {
                    condition = $0.start >= song.chords[i].start - timeAdjustment && $0.start < song.chords[i + 1].start - timeAdjustment
                }
                return condition
            }
            var interval = Interval(start: song.chords[i].start - timeAdjustment, words: words, chord: song.chords[i])
            let lineWidth = getWidth(for: interval, with: fontSize)
            interval.limitLines = Int(ceil(lineWidth / maxWidth))
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
}

