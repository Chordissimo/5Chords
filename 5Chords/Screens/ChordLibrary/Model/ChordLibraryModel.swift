//
//  ChordLibraryModel.swift
//  AmDm AI
//
//  Created by Anton on 30/05/2024.
//

import Foundation
import SwiftyChords
//import AudioKit

struct ChordSearchResults: Identifiable, Equatable, Hashable {
    var id = UUID()
    var key: Chords.Key = .c
    var suffix: Chords.Suffix = ._major
}

class ChordLibraryModel: ObservableObject {
    let majorKeys =     ["c","g","d","a","e","b","g♭","d♭","a♭","e♭","b♭","f"]
    let majorKeysAlt =  ["" ,"" ,"" ,"" ,"" ,"" ,"f♯","c♯","g♯","d♯","a♯",""]
    let minorKeys =     ["am","em","bm","f♯m","c♯m","g♯m","e♭m","b♭m","fm","cm","gm","dm"]
    let minorKeysAlt =  [""  ,""  ,""  ,"g♭m","d♭m","a♭m","d♯m","a♯m",""  ,""  ,""  ,""]

    @Published var chordSearchResults: [ChordSearchResults] = []
    
    //    let midi = MIDI()
    
    //    func makeMidi() {
    //        midi.openOutput()
    //    }
    //
    //    func destroyMidi() {
    //        midi.closeOutput()
    //    }
    //
    //    func playChord(chord: [Int]) {
    //        guard chord.count > 0 else { return }
    //
    //        let midiNotes = chord.map { MIDINoteNumber(exactly: Float16($0)) }
    //
    //        self.makeMidi()
    //        for note in midiNotes {
    //            midi.sendNoteOnMessage(noteNumber: note!, velocity: 127)
    //        }
    //
    //        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
    //            self.destroyMidi()
    //        }
    //    }
    
    func getChordPositions(selectedMajor: Int = -1, selectedMinor: Int = -1) -> [ChordPosition] {
        var result: [ChordPosition] = []
        
        let chordPositions = Chords.guitar.matching(key: getChordKeyByIndex(selectedMajor: selectedMajor, selectedMinor: selectedMinor))
        
        if chordPositions.count > 0 {
            result = selectedMajor != -1 ? chordPositions.matching(suffix: ._major) : chordPositions.matching(suffix: ._minor)
        }
        
        return result
    }
    
    func getChordKeyByIndex(selectedMajor: Int = -1, selectedMinor: Int = -1) -> Chords.Key {
        var key: String = ""
        
        if selectedMajor != -1 {
            key = majorKeys[selectedMajor]
        } else if selectedMinor != -1 {
            key = minorKeys[selectedMinor]
        }
        
        key = key
            .replacingOccurrences(of: "♭", with: "b", options: .literal, range: nil)
            .replacingOccurrences(of: "♯", with: "#", options: .literal, range: nil)
            .replacingOccurrences(of: "m", with: "", options: .literal, range: nil)
        
        let keys = Chords.Key.allCases.filter { k in
            return k.rawValue.lowercased() == key.lowercased()
        }
        
        return keys.count > 0 ? keys.first! : .c
    }
    
    func searchChordsBy(searchString: String) {
        var chords: [ChordPosition] = []
        var resultChords: [ChordSearchResults] = []
        
        chords = Chords.guitar.filter {
            var result = false
            if searchString.count == 1 {
                result = $0.key.rawValue.lowercased().contains(searchString.lowercased())
            } else {
                let search1 = ($0.key.rawValue.lowercased() + $0.suffix.display.accessible).lowercased().contains(searchString.lowercased())
                let search2 = ($0.key.rawValue.lowercased() + $0.suffix.display.short).lowercased().contains(searchString.lowercased())
                let search3 = ($0.key.display.accessible + $0.suffix.display.accessible).lowercased().contains(searchString.lowercased())
                let search4 = ($0.key.display.accessible + $0.suffix.display.short).lowercased().contains(searchString.lowercased())
                result = search1 || search2 || search3 || search4
            }
            return result
        }
        
        for chord in chords {
            let ch = resultChords.filter { c in
                return c.suffix == chord.suffix && c.key == chord.key
            }
            if ch.count == 0 {
                resultChords.append(ChordSearchResults(key: chord.key, suffix: chord.suffix))
            }
        }
        
        self.chordSearchResults = resultChords
    }
    
    
    func searchChordsBy(key: Chords.Key, groups: [Chords.Group]) {
        var chords: [ChordPosition] = []
        var resultChords: [ChordSearchResults] = []
        
        if groups.count > 0 {
            for group in groups {
                chords = chords + Chords.guitar.matching(key: key).matching(group: group)
            }
        } else {
            chords = Chords.guitar.matching(key: key)
        }
        
        for chord in chords {
            let ch = resultChords.filter { c in
                return c.suffix == chord.suffix
            }
            if ch.count == 0 {
                resultChords.append(ChordSearchResults(key: chord.key, suffix: chord.suffix))
            }
        }
        
        self.chordSearchResults = resultChords
    }
    
    func clearSearchResults() {
        self.chordSearchResults = []
    }
}
