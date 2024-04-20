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

@Model
final class User {
    var registrationDate: Date?
    var subscriptionPlanId: Int = -1
    var accessDisallowed: Bool = true
    
    init() {}
    
    func selectPlan(registrationDate: Date, subscriptionPlanId: Int) {
        self.registrationDate = registrationDate
        self.subscriptionPlanId = subscriptionPlanId
        self.accessDisallowed = false
    }
    
}

struct ScreenDimentions {
    static var maxHeight = 0.0
    static var maxWidth = 0.0
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
        case "C": return .c
        case "C#": return .cSharp
        case "Db": return .dFlat
        case "D": return .d
        case "D#": return .dSharp
        case "Eb": return .eFlat
        case "E": return .e
        case "F": return .f
        case "F#": return .fSharp
        case "Gb": return .gFlat
        case "G": return .g
        case "G#": return .gSharp
        case "Ab": return .aFlat
        case "A": return .a
        case "A#": return .aSharp
        case "Bb": return .bFlat
        case "B": return .b
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
    var id: String
    var isExpanded = false
    var duration: TimeInterval
    var created: Date
    var playbackPosition = 0.0
    
    init(id: String, name: String, url: String, duration: TimeInterval, created: Date, chords: [Chord]) {
        self.id = id
        self.name = name
        self.url = URL(string: url)!
        self.chords = chords
        self.duration = duration
        self.created = created
    }
}


class Chord: Codable, Identifiable {
    var chord: String
    var timeSeconds: Double
    var uiChord: UIChord {
        if chord.uppercased() != "N" {
            let parts = chord.uppercased().split(separator: ":")
            return UIChord(
                key: UIChord.getKey(from: String(parts[0]))!,
                suffix: String(parts[1]) == "MIN" ? Chords.Suffix.minor : Chords.Suffix.major
            )
        }
        return UIChord(key: .a, suffix: .minor) // fix this !!!
    }
    var id = UUID().uuidString
    
    enum CodingKeys: String, CodingKey {
        case chord
        case timeSeconds = "time_seconds"
    }
    
    init(id: String, chord: String, timeSeconds: Double) {
        self.chord = chord
        self.timeSeconds = timeSeconds
        self.id = id
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        chord = try values.decode(String.self, forKey: .chord)
        timeSeconds = try values.decode(Double.self, forKey: .timeSeconds)
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
                    let song = self.databaseService.writeSong(name: self.getNewSongName(), url: url.absoluteString, duration: self.duration, chords: response.chords)
                    self.songs.insert(song, at: 0)
                    self.expand(song: song)
                case .failure(let failure):
                    print(failure)
                }
            }
            print("mtag", url)
        }
        
        recordingService.recordingTimeCallback = { [weak self] time in
            guard let self = self else { return }
            self.duration = time
        }
        
        $songs
            .sink { [weak self] value in
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
