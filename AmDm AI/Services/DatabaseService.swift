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
    
    convenience init(chord: String, timeSeconds: Double) {
        self.init()
        self.chord = chord
        self.timeSeconds = timeSeconds
    }
}


class SongModel: Object {
    @Persisted var id = UUID().uuidString
    @Persisted var name: String
    @Persisted var url: String
    @Persisted var chords: List<ChordModel>
    
    
    convenience init(name: String, url: String) {
        self.init()
        self.name = name
        self.url = url
    }
}


class DatabaseService {
    lazy var realm = try! Realm()
    
    func writeSong(name: String, url: String, chords: [Chord1]) {
        
        var dbChords = chords.map { ch in ChordModel(chord: ch.chord, timeSeconds: ch.timeSeconds) }
        
        try! realm.write {
            realm.add(dbChords)
        }
        
        let realmChordList = List<ChordModel>()
        realmChordList.append(objectsIn: dbChords)
        
        var song = SongModel()
        song.name = name
        song.url = url
        song.chords = realmChordList
        
        try! realm.write {
            realm.add(song)
        }
    }
    
    
    func getSongs() -> [Song1] {
        return realm.objects(SongModel.self).map { Song1(name: $0.name, url: $0.url, chrds: $0.chords.map{ Chord1(chord: $0.chord, timeSeconds: $0.timeSeconds ) }) }
    }
}
