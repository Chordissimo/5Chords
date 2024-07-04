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
    @Persisted var start: Int
    @Persisted var end: Int
    
    convenience init(id: String, chord: String, start: Int, end: Int) {
        self.init()
        self.id = id
        self.chord = chord
        self.start = start
        self.end = end
    }
}

class AlignedTextModel: Object {
    @Persisted var id = UUID().uuidString
    @Persisted var text: String
    @Persisted var start: Int?
    @Persisted var end: Int?
    
    convenience init(id: String, text: String, start: Int?, end: Int?) {
        self.init()
        self.id = id
        self.text = text
        self.start = start
        self.end = end
    }
}


class SongModel: Object {
    @Persisted var id = UUID().uuidString
    @Persisted var name: String
    @Persisted var url: String
    @Persisted var duration: TimeInterval
    @Persisted var created: Date
    @Persisted var chords: List<ChordModel>
    @Persisted var text: List<AlignedTextModel>
    @Persisted var songType: String
    @Persisted var ext: String
    @Persisted var tempo: Float
    @Persisted var thumbnailUrl: String
    @Persisted var transposition: Int
    
    
    convenience init(name: String, url: String) {
        self.init()
        self.name = name
        self.url = url
    }
}


class DatabaseService {
    lazy var realm = try! Realm()
    
    init() {
//        print("User Realm User file location: \(realm.configuration.fileURL!.path)")
    }
    
    private func writeChords(chords: [APIChord]) -> List<ChordModel> {
        let dbChords = chords.map { ch in
            ChordModel(id: ch.id, chord: ch.chord, start: ch.start, end: ch.end)
        }
        try! realm.write {
            realm.add(dbChords)
        }
        let realmChordList = List<ChordModel>()
        realmChordList.append(objectsIn: dbChords)
        return realmChordList
    }
    
    private func writeText(text: [AlignedText]) -> List<AlignedTextModel> {
        let dbTexts = text.map { ch in
            AlignedTextModel(id: ch.id, text: ch.text, start: ch.start, end: ch.end)
        }
        try! realm.write {
            realm.add(dbTexts)
        }
        let realmTextList = List<AlignedTextModel>()
        realmTextList.append(objectsIn: dbTexts)
        return realmTextList
    }
    
    func writeSong(
        id: String,
        name: String,
        url: String,
        duration: TimeInterval,
        chords: [APIChord],
        text: [AlignedText],
        tempo: Float,
        songType: SongType = .recorded,
        ext: String,
        thumbnailUrl: String,
        transposition: Int
    ) -> Song {
        
        let realmChordList = writeChords(chords: chords)
        let realmTextList = writeText(text: text)
        
        let song = SongModel()
        song.id = id
        song.name = name
        song.url = url
        song.duration = duration
        song.chords = realmChordList
        song.text = realmTextList
        song.created = Date()
        song.songType = songType.rawValue
        song.tempo = tempo
        song.ext = ext
        song.thumbnailUrl = thumbnailUrl
        song.transposition = transposition
        
        try! realm.write {
            realm.add(song)
        }
        
        return Song(
            id: song.id,
            name: song.name,
            url: song.url,
            duration: song.duration,
            created: song.created,
            chords: chords,
            text: text,
            tempo: song.tempo,
            songType: songType,
            ext: song.ext,
            transposition: song.transposition
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
                songObj.transposition = song.transposition
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
                chords: $0.chords.sorted { x1, x2 in x1.start < x2.start }.map {
                    APIChord(
                        id: $0.id,
                        chord: $0.chord,
                        start: $0.start,
                        end: $0.end
                    )
                },
                text:  $0.text.sorted { x1, x2 in x1.start ?? 0 < x2.start ?? 0 }.map {
                    AlignedText(
                        id: $0.id,
                        text: $0.text,
                        start: $0.start,
                        end: $0.end
                    )
                },
                tempo: $0.tempo,
                songType: $0.songType == "uploaded" ? .localFile : ($0.songType == "recorded" ? .recorded : .youtube),
                ext: $0.ext,
                thumbnailUrl: $0.thumbnailUrl,
                transposition: $0.transposition
            )
        }
    }
}
