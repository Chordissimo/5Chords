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

class DBInterval: Object {
    @Persisted var id = UUID().uuidString
    @Persisted var start: Int
    @Persisted var chord: String
    @Persisted var words: String
    @Persisted var limitLines: Int
    @Persisted var width: Float
    
    convenience init(id: String = UUID().uuidString, start: Int, chord: String, words: String, limitLines: Int, width: Float) {
        self.init()
        self.id = id
        self.start = start
        self.chord = chord
        self.words = words
        self.limitLines = limitLines
        self.width = width
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
    @Persisted var intervals: List<DBInterval>
    @Persisted var songType: String
    @Persisted var ext: String
    @Persisted var tempo: Float
    @Persisted var thumbnailUrl: String
    @Persisted var isProcessing: Bool
    
    convenience init(name: String, url: String) {
        self.init()
        self.name = name
        self.url = url
    }
}

class DatabaseService {
    var realm: Realm
    
    init() {
        let config = Realm.Configuration(schemaVersion: 2)
//        let config = Realm.Configuration(schemaVersion: 2) { migration, oldSchemaVersion in
//            if oldSchemaVersion < 2 {
//                print("needs updating...")
//            }
//        }
        Realm.Configuration.defaultConfiguration = config
        self.realm = try! Realm()
//        print("Realm location: \(realm.configuration.fileURL!.path)")
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
        
    func createSongStub(id: String, name: String, url: String, duration: TimeInterval, chords: [APIChord], text: [AlignedText], tempo: Float, songType: SongType = .recorded, ext: String, thumbnailUrl: String) -> Song {
        
        let realmChordList = writeChords(chords: chords)
        let realmTextList = writeText(text: text)
        
        let song = SongModel()
        song.id = id
        song.name = name
        song.url = url
        song.duration = duration
        song.chords = realmChordList
        song.text = realmTextList
        song.intervals = List<DBInterval>()
        song.created = Date()
        song.songType = songType.rawValue
        song.tempo = tempo
        song.ext = ext
        song.thumbnailUrl = thumbnailUrl
        song.isProcessing = true
        
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
            isProcessing: song.isProcessing,
            thumbnailUrl: song.thumbnailUrl
        )
    }
    
    func updateSongName(song: Song) {
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

    func updateSong(song: Song) {
        let songSearchResults = realm.objects(SongModel.self).filter { s in
            s.id == song.id
        }
        
        guard songSearchResults.count > 0 else { return }
        
        let realmIntervalsList = List<DBInterval>()
        let intervalsList = song.intervals.map { $0.id.uuidString }
        let intervalsSearchResults = realm.objects(DBInterval.self).filter { intervalsList.contains($0.id) }
        realmIntervalsList.append(objectsIn: song.intervals.map {
            let chord = $0.uiChord?.getChordString(flatSharpSymbols: false) ?? "N"
            return DBInterval(
                id: $0.id.uuidString,
                start: $0.start,
                chord: chord,
                words: $0.words,
                limitLines: $0.limitLines,
                width: Float($0.width)
            )
        })
        
        let realmTextList = List<AlignedTextModel>()
        let textList = song.intervals.map { $0.id.uuidString }
        let textSearchResults = realm.objects(AlignedTextModel.self).filter { textList.contains($0.id) }
        realmTextList.append(objectsIn: song.text.map { t in
            AlignedTextModel(
                id: t.id,
                text: t.text,
                start: t.start,
                end: t.end
            )
        })
        
        let realmChordList = List<ChordModel>()
        let chordsList = song.intervals.map { $0.id.uuidString }
        let chordsSearchResults = realm.objects(ChordModel.self).filter { chordsList.contains($0.id) }
        realmChordList.append(objectsIn: song.chords.map { ch in
            ChordModel(
                id: ch.id,
                chord: ch.chord,
                start: ch.start,
                end: ch.end
            )
        })

                
        if let songObj = songSearchResults.first {
            try! realm.write {
                if intervalsSearchResults.count > 0 {
                    realm.delete(intervalsSearchResults)
                }
                if textSearchResults.count > 0 {
                    realm.delete(textSearchResults)
                }
                if chordsSearchResults.count > 0 {
                    realm.delete(chordsSearchResults)
                }
            }
            
            try! realm.write {
                songObj.name = song.name
                songObj.url = song.url.absoluteString
                songObj.duration = song.duration
                songObj.created = song.created
                songObj.tempo = song.tempo
                songObj.songType = song.songType.rawValue
                songObj.ext = song.ext
                songObj.isProcessing = song.isProcessing
                songObj.intervals = realmIntervalsList
                songObj.text = realmTextList
                songObj.chords = realmChordList
            }
        }
    }

    
    func updateIntervals(song: Song) {
        let songSearchResults = realm.objects(SongModel.self).filter { s in
            s.id == song.id
        }
        let realmIntervalsList = List<DBInterval>()
        realmIntervalsList.append(objectsIn: song.intervals.map {
            let chord = $0.uiChord?.getChordString(flatSharpSymbols: false) ?? "N"
            return DBInterval(
                id: $0.id.uuidString,
                start: $0.start,
                chord: chord,
                words: $0.words,
                limitLines: $0.limitLines,
                width: Float($0.width)
            )
        })
        
        if realmIntervalsList.count > 0 {
            let realm = try! Realm()
            let intervalsList = song.intervals.map { $0.id.uuidString }
            let intervalsSearchResults = realm.objects(DBInterval.self).filter { intervalsList.contains($0.id) }
            if let songObj = songSearchResults.first {
                try! realm.write {
                    if intervalsSearchResults.count > 0 {
                        realm.delete(intervalsSearchResults)
                    }
                    songObj.intervals = realmIntervalsList
                }
            }
        }
    }
    
    func readIntervals(dbIntervals: List<DBInterval>) -> [Interval] {
        var intervals: [Interval] = []
        for dbInterval in dbIntervals {
            intervals.append(Interval(
                id: .init(uuidString: dbInterval.id)!,
                start: dbInterval.start,
                words: dbInterval.words,
                uiChord: UIChord(chord: dbInterval.chord),
                limitLines: dbInterval.limitLines,
                width: CGFloat(dbInterval.width)
            ))
        }
        return intervals
    }

    
    func deleteSong(song: Song) {
        let songSearchResults = realm.objects(SongModel.self).filter { s in
            s.id == song.id
        }
        let realm = try! Realm()
        if let songObj = songSearchResults.first {
            let chordList = song.chords.map { $0.id }
            let chordSearchResults = realm.objects(ChordModel.self).filter { chordList.contains($0.id) }
            if chordSearchResults.count > 0 {
                try! realm.write {
                    realm.delete(chordSearchResults)
                }
            }

            let textList = song.text.map { $0.id }
            let textSearchResults = realm.objects(AlignedTextModel.self).filter { textList.contains($0.id) }
            if textSearchResults.count > 0 {
                try! realm.write {
                    realm.delete(textSearchResults)
                }
            }

            let intervalsList = song.intervals.map { $0.id.uuidString }
            let intervalsSearchResults = realm.objects(DBInterval.self).filter { intervalsList.contains($0.id) }
            if intervalsSearchResults.count > 0 {
                try! realm.write {
                    realm.delete(intervalsSearchResults)
                }
            }
            
            try! realm.write {
                realm.delete(songObj)
            }
        }
    }
    
    func getSongs() -> [Song] {
        let recognitionApiService = RecognitionApiService()
        return realm.objects(SongModel.self).sorted { s1, s2 in
            return s1.created >= s2.created
        }
        .map {
            let intervals = self.readIntervals(dbIntervals: $0.intervals)
            var song = Song(
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
                text: $0.text.sorted { x1, x2 in x1.start ?? 0 < x2.start ?? 0 }.map {
                    AlignedText(
                        id: $0.id,
                        text: $0.text,
                        start: $0.start,
                        end: $0.end
                    )
                },
                intervals: intervals,
                tempo: $0.tempo,
                songType: $0.songType == "uploaded" ? .localFile : ($0.songType == "recorded" ? .recorded : .youtube),
                ext: $0.ext,
                isProcessing: $0.isProcessing,
                isFakeLoaderVisible: $0.isProcessing,
                thumbnailUrl: $0.thumbnailUrl
            )

            if song.isProcessing {
                song.startTimer()
                recognitionApiService.getUnfinished(songId: song.id) { result in
                    switch result {
                    case .success(let response):
                        if response.found! {
                            if response.completed! {
                                SongsList.recognitionSuccess(song: &song, response: response)
                                song.stopTimer()
                                self.updateSong(song: song)
                            }
                        } else {
                            if song.songType == .youtube {
                                recognitionApiService.recognizeAudioFromYoutube(url: song.url.absoluteString, songId: song.id) { result in
                                    switch result {
                                    case .success(let response):
                                        SongsList.recognitionSuccess(song: &song, response: response)
                                        song.stopTimer()
                                        self.updateSong(song: song)
                                        
                                    case .failure(let failure):
                                        song.stopTimer()
                                        song.recognitionStatus = .serverError
                                        print("youtube, not found, ApiError",failure)
                                    }
                                }
                            } else {
                                recognitionApiService.recognizeAudio(url: song.url, songId: song.id) { result in
                                    switch result {
                                    case .success(let response):
                                        SongsList.recognitionSuccess(song: &song, response: response)
                                        song.stopTimer()
                                        self.updateSong(song: song)

                                    case .failure(let failure):
                                        song.stopTimer()
                                        song.recognitionStatus = .serverError
                                        print("upload, not found, ApiError",failure)
                                    }
                                }
                            }
                        }
                    case .failure(let failure):
                        song.stopTimer()
                        song.recognitionStatus = .serverError
                        print("processing: ApiError",failure)
                    }
                }
            }
            return song
        }
    }
}
