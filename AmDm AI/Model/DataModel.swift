//
//  UserDataModel.swift
//  AmDm AI
//
//  Created by Anton on 25/03/2024.
//

import Foundation
import SwiftData
import SwiftyChords
import Combine


enum SongType {
    case localFile
    case youtube
    
    func toString() -> String {
        switch self {
        case .localFile:
            return "localFile"
        case .youtube:
            return "youtube"
        }
    }
}

final class User: ObservableObject {
    var registrationDate: Date?
    var subscriptionPlanId: Int = 0
    var accessDisallowed: Bool = false
    
    init() {}
    
    func selectPlan(registrationDate: Date, subscriptionPlanId: Int) {
        self.registrationDate = registrationDate
        self.subscriptionPlanId = subscriptionPlanId
        self.accessDisallowed = false
    }
    
}


struct SubscriptionPlan: Identifiable, Hashable {
    let id = UUID()
    let planId: Int
    let title: String
    let description: String
    let price: Float
}

struct MockData: Hashable {
    static let plans = [
        SubscriptionPlan(planId: 0, title: "Limited version", description: "Description", price: 0.0),
        SubscriptionPlan(planId: 1, title: "Plan A", description: "Description", price: 1.0),
        SubscriptionPlan(planId: 2, title: "Plan B", description: "Description", price: 4.99),
        SubscriptionPlan(planId: 3, title: "Plan C", description: "Description", price: 9.99)
    ]
}

struct UIChord: Identifiable, Hashable {
    let id = UUID()
    var key: Chords.Key
    var suffix: Chords.Suffix
    
    static func getKey(from string: String) -> Chords.Key? {
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
}


struct Song: Identifiable, Equatable {
    static func == (lhs: Song, rhs: Song) -> Bool {
        lhs.id == rhs.id
    }
    
    var name: String
    var url: URL
    var chords: [Chord]
    var text: [AlignedText]
    var id: String
    var isExpanded = false
    var duration: TimeInterval
    var created: Date
    var playbackPosition = 0.0
    var songType: SongType = .localFile
    var tempo: Float
    
    init(id: String, name: String, url: String, duration: TimeInterval, created: Date, chords: [Chord], text: [AlignedText], tempo: Float, songType: SongType = .localFile) {
        self.id = id
        self.name = name
        self.url = URL(string: url)!
        self.chords = chords
        self.text = text
        self.duration = duration
        self.created = created
        self.songType = songType
        self.tempo = tempo
    }
}


class AlignedText: Codable, Identifiable {
    var text: String
    var start: Int?
    var end: Int?
    var id = UUID().uuidString
    
    enum CodingKeys: String, CodingKey {
        case text
        case start
        case end
    }
    
    init(id: String, text: String, start: Int?, end: Int?) {
        self.text = text
        self.start = start
        self.end = end
        self.id = id
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        text = try values.decode(String.self, forKey: .text)
        start = try? values.decode(Int.self, forKey: .start)
        end = try? values.decode(Int.self, forKey: .end)
    }
}


class Chord: Codable, Identifiable {
    var chord: String
    var start: Int
    var end: Int
    var uiChord: UIChord {
        if chord.uppercased() != "N" {
            let parts = chord.uppercased().split(separator: ":")
            return UIChord(
                key: UIChord.getKey(from: String(parts[0].lowercased()))!,
                suffix: String(parts[1]) == "MIN" ? Chords.Suffix.minor : Chords.Suffix.major
            )
        }
        return UIChord(key: .a, suffix: .minor) // fix this !!!
    }
    var id = UUID().uuidString
    
    enum CodingKeys: String, CodingKey {
        case chord
        case start
        case end
    }
    
    init(id: String, chord: String, start: Int, end: Int) {
        self.chord = chord
        self.start = start
        self.end = end
        self.id = id
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        chord = try values.decode(String.self, forKey: .chord)
        start = try values.decode(Int.self, forKey: .start)
        end = try values.decode(Int.self, forKey: .end)
    }
}


final class SongsList: ObservableObject {
    @Published var songs: [Song]
    
    @Published var recordStarted: Bool = false
    @Published var duration: TimeInterval = 0
    
    private let recordingService = RecordingService()
    private let recognitioaApiService = RecognitionApiService()
    private let databaseService = DatabaseService()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        songs = self.databaseService.getSongs()
        
        recordingService.recordingCallback = { [weak self] url in
            guard let self = self else { return }
            guard let url = url else { return }
            self.recognitioaApiService.recognizeAudio(url: url) { result in
                switch result {
                case .success(let response):
                    let song = self.databaseService.writeSong(
                        name: self.getNewSongName(),
                        url: url.absoluteString,
                        duration: self.duration,
                        chords: response.chords,
                        text: response.text ?? [],
                        tempo: response.tempo
                    )
                    self.songs.insert(song, at: 0)
                    self.expand(song: song)
                case .failure(let failure):
                    print(failure)
                }
            }
        }
        
        recordingService.recordingTimeCallback = { [weak self] time in
            guard let self = self else { return }
            self.duration = time
        }
        
        $songs
            .sink { [weak self] value in
                // don't need to do anything in case new song is added, i.e. value.count > self?.songs.count
                if value.count == self?.songs.count {
                    for i in value.indices {
                        if value[i].name != self?.songs[i].name {
                            self?.databaseService.updateSong(song: value[i])
                        }
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    func processYoutubeVideo(by resultUrl: String) {
        recognitioaApiService.recognizeAudioFromYoutube(url: resultUrl) { result  in
            switch result {
            case .success(let response):
                let song = self.databaseService.writeSong(
                    name: self.getNewSongName(),
                    url: resultUrl,
                    duration: self.duration,
                    chords: response.chords,
                    text: response.text ?? [],
                    tempo: response.tempo,
                    songType: .youtube
                )
                self.songs.insert(song, at: 0)
                self.expand(song: song)
            case .failure(let failure):
                print(failure)
            }
        }
    }
    
    func startRecording() {
        recordingService.startRecording()
        recordStarted = true
    }
    
    func stopRecording() {
        recordingService.stopRecording()
        recordStarted = false
    }
    
    func getNewSongName() -> String {
        let songs = self.songs.filter { s in
            s.name.contains("New recording")
        }
        if songs.isEmpty {
            return "New recording"
        } else {
            return "New recording " + String(songs.count)
        }
    }
        
    func del(song: Song) {
        if let i = self.songs.firstIndex(of: song) {
            self.databaseService.deleteSong(song: song)
            self.songs.remove(at: i)

            var _url = song.url
            let isReachable = (try? song.url.checkResourceIsReachable()) ?? false
            do {
                if !isReachable {
                    let filename = String(song.url.absoluteString.split(separator: "/").last ?? "")
                    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    _url = documentsPath.appendingPathComponent(filename)
                }
                try FileManager.default.removeItem(at: _url)
            } catch {
                print(error)
            }
        }
    }
    
    func expand(index: Int) {
        for i in songs.indices {
            songs[i].isExpanded = i == index
        }
    }
    
    func expand(song: Song) {
        for i in songs.indices {
            songs[i].isExpanded = songs[i] == song
        }
    }
    
    func getExpanded() -> Song? {
        if let i = self.songs.firstIndex(where: { $0.isExpanded == true }) {
            return self.songs[i]
        } else {
            return nil
        }
    }
    
}
