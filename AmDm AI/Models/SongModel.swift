//
//  SongModel.swift
//  AmDm AI
//
//  Created by Anton on 13/05/2024.
//

import Foundation
import SwiftUI
import Combine

enum SongType: String {
    case localFile = "localFile"
    case youtube = "youtube"
    case recorded = "recorded"
}

struct Song: Identifiable, Equatable {
    static func == (lhs: Song, rhs: Song) -> Bool {
        lhs.id == rhs.id
    }
    
    var name: String
    var url: URL
    var chords: [APIChord]
    var text: [AlignedText]
    var id: String
    var isExpanded = false
    var duration: TimeInterval
    var created: Date
    var playbackPosition = 0.0
    var songType: SongType = .recorded
    var tempo: Float
    
    init(id: String, name: String, url: String, duration: TimeInterval, created: Date, chords: [APIChord], text: [AlignedText], tempo: Float, songType: SongType) {
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

final class SongsList: ObservableObject {
    @Published var songs: [Song]
    
    @Published var recordStarted: Bool = false
    @Published var duration: TimeInterval = 0
    @Published var decibelChanges = [Float]()
    
    private let recordingService = RecordingService()
    private let recognitionApiService = RecognitionApiService()
     let databaseService = DatabaseService()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        songs = self.databaseService.getSongs()
        
        recordingService.recordingCallback = { [weak self] url in
            guard let self = self else { return }
            guard let url = url else { return }
            self.recognitionApiService.recognizeAudio(url: url) { result in
                switch result {
                case .success(let response):
                    let song = self.databaseService.writeSong(
                        name: self.getNewSongName(),
                        url: url.absoluteString,
                        duration: self.duration,
                        chords: response.chords,
                        text: response.text ?? [],
                        tempo: response.tempo,
                        songType: .recorded
                    )
                    self.songs.insert(song, at: 0)
                    self.expand(song: song)
                case .failure(let failure):
                    print(failure)
                }
            }
        }
        
        recordingService.recordingTimeCallback = { [weak self] time, signal in
            guard let self = self else { return }
            self.duration = time
            if Int(time * 100) % 5 == 0 {
                if self.decibelChanges.count > Int(UIScreen.main.bounds.width / 2) - 20 {
                    self.decibelChanges.remove(at: 0)
                }
                if self.decibelChanges.count > 0 && self.decibelChanges.last! != 0 {
                    self.decibelChanges.append(0)
                } else {
                    self.decibelChanges.append(max(1,min(signal,120)))
                }
            }
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
        recognitionApiService.recognizeAudioFromYoutube(url: resultUrl) { result  in
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
        decibelChanges = [Float]()
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
