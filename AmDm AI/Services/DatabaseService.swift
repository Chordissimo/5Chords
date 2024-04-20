//
//  DatabaseService.swift
//  AmDm AI
//
//  Created by Marat Zainullin on 13/04/2024.
//

import Foundation
import RealmSwift


class ChordModel: Object {
    @Persisted var id = UUID().uuidString
    @Persisted var chord: String
    @Persisted var timeSeconds: Double
    
    convenience init(id: String, chord: String, timeSeconds: Double) {
        self.init()
        self.id = id
        self.chord = chord
        self.timeSeconds = timeSeconds
    }
}


class SongModel: Object {
    @Persisted var id = UUID().uuidString
    @Persisted var name: String
    @Persisted var url: String
    @Persisted var duration: TimeInterval
    @Persisted var created: Date
    @Persisted var chords: List<ChordModel>
    
    
    convenience init(name: String, url: String) {
        self.init()
        self.name = name
        self.url = url
    }
}


class DatabaseService {
    lazy var realm = try! Realm()
    
    func writeSong(name: String, url: String, duration: TimeInterval, chords: [Chord]) -> Song {
        
        let dbChords = chords.map { ch in
            ChordModel(id: ch.id, chord: ch.chord, timeSeconds: ch.timeSeconds)
        }
        
        try! realm.write {
            realm.add(dbChords)
        }
        
        let realmChordList = List<ChordModel>()
        realmChordList.append(objectsIn: dbChords)
        
        let song = SongModel()
        song.id = UUID().uuidString
        song.name = name
        song.url = url
        song.duration = duration
        song.chords = realmChordList
        song.created = Date()
        
        try! realm.write {
            realm.add(song)
        }
        
        return Song(
            id: song.id,
            name: song.name,
            url: song.url,
            duration: song.duration,
            created: song.created,
            chords: chords
        )
    }
    
    func updateSong(song: Song) {
        let songSearchResults = realm.objects(SongModel.self).filter { s in
            s.id == song.id
        }
        
        let realm = try! Realm()
        if let songObj = songSearchResults.first {
            try! realm.write {
                songObj.name = song.name
            }
        }
    }
    
    func deleteSong(song: Song) {
        let songSearchResults = realm.objects(SongModel.self).filter { s in
            s.id == song.id
        }
        let realm = try! Realm()
        if let songObj = songSearchResults.first {
            let chordList = song.chords.map { ch in
                return ch.id
            }
            let chordSearchResults = realm.objects(ChordModel.self).filter { ch in
                chordList.contains(ch.id)
            }
            if chordSearchResults.count > 0 {
                try! realm.write {
                    realm.delete(chordSearchResults)
                }
            }
            try! realm.write {
                realm.delete(songObj)
            }
        }
    }
    
    func getSongs() -> [Song] {
        return realm.objects(SongModel.self).sorted { s1, s2 in
            return s1.created >= s2.created
        }.map {
            Song(
                id: $0.id,
                name: $0.name,
                url: $0.url,
                duration: $0.duration,
                created: $0.created,
                chords: $0.chords.map {
                    Chord(
                        id: $0.id,
                        chord: $0.chord,
                        timeSeconds: $0.timeSeconds 
                    )
                }
            )
        }
    }
}
