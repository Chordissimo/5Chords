//
//  SongModel.swift
//  AmDm AI
//
//  Created by Anton on 13/05/2024.
//

import Foundation
import SwiftUI
import Combine
import AVFoundation

enum SongType: String {
    case localFile = "uploaded"
    case youtube = "youtube"
    case recorded = "recorded"
}

enum RecognitionStatus {
    case ok
    case serverError
    case videoTooLong
}

class Song: ObservableObject, Identifiable, Equatable, Hashable {
    static func == (lhs: Song, rhs: Song) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    @Published var name: String
    var url: URL
    var chords: [APIChord]
    var text: [AlignedText]
    var id: String
    var isVisible = true
    var duration: TimeInterval
    var created: Date
    var playbackPosition = 0.0
    var songType: SongType = .recorded
    var ext: String = ""
    var thumbnailUrl: URL = URL(string: "local")!
    var tempo: Float
    var beats: Int = 4
    var bars: [CGFloat] = []
    @Published var isProcessing: Bool = false
    @Published var isFakeLoaderVisible: Bool = false
    @Published private var timer: Timer?
    @Published private var startTime: Date?
    @Published var elapsedTime: TimeInterval = 0
    @Published var progress: Float = 0.0
    @Published var recognitionStatus: RecognitionStatus = .ok
    @Published var transposition: Int = 0
    
    init(id: String, name: String, url: String, duration: TimeInterval, created: Date, chords: [APIChord], text: [AlignedText], tempo: Float, songType: SongType, ext: String = "", isProcessing: Bool = false, isFakeLoaderVisible: Bool = false, thumbnailUrl: String = "", transposition: Int = 0) {
        self.id = id
        self.name = name
        self.url = URL(string: url)!
        self.chords = chords
        self.text = text
        self.duration = duration
        self.created = created
        self.songType = songType
        self.ext = ext
        self.tempo = tempo
        self.isProcessing = isProcessing
        self.isFakeLoaderVisible = isFakeLoaderVisible
        self.transposition = transposition

        if self.songType == .youtube {
            if self.url.absoluteString != "" {
                if thumbnailUrl != "" {
                    self.thumbnailUrl = URL(string: thumbnailUrl)!
                } else {
                    let index = self.url.absoluteString.range(of: "?v=")?.upperBound ?? nil
                    if index != nil {
                        let id = String(self.url.absoluteString[index!...])
                        self.thumbnailUrl = URL(string: "http://img.youtube.com/vi/\(id)/default.jpg")!
                    } else {
                        self.thumbnailUrl = URL(string: "local")!
                    }
                }
            }
        }
    }
    
    func startTimer() {
        self.startTime = Date()
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if let startTime = self.startTime {
                let currentTime = Date()
                self.elapsedTime = currentTime.timeIntervalSince(startTime)
            }
        }
    }
    
    func stopTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }
}

final class SongsList: ObservableObject {    
    @Published var songs: [Song]
    @Published var recordStarted: Bool = false
    @Published var duration: TimeInterval = 0
    @Published var decibelChanges = [Float]()
    @Published var showSearch: Bool = false
    @Published var recognitionInProgress: Bool = false

    let recordingService = RecordingService()
    private let recognitionApiService = RecognitionApiService()
    let databaseService = DatabaseService()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        songs = self.databaseService.getSongs()
        
        recordingService.recordingCallback = { [weak self] url, songName, ext in
            guard let self = self else { return }
            guard let url = url else { return }
            guard let songName = songName else { return }
            guard let ext = ext else { return }
            @AppStorage("isLimited") var isLimited: Bool = false
            @AppStorage("songCounter") var songCounter: Int = 0
            self.recordStarted = false

            let song = Song(
                id: UUID().uuidString,
                name: songName == "" ? self.getNewSongName() : songName,
                url: url.absoluteString,
                duration: 0.0,
                created: Date(),
                chords: [],
                text: [],
                tempo: 0,
                songType: songName == "" ? .recorded : .localFile,
                ext: ext,
                isProcessing: true,
                isFakeLoaderVisible: true
            )
            song.startTimer()
            self.songs.insert(song, at: 0)
            songCounter = isLimited ? songCounter + 1 : songCounter
            self.objectWillChange.send()
            
            self.recognitionApiService.recognizeAudio(url: url) { result in
                let i = self.getSongIndexByID(id: song.id)
                switch result {
                case .success(let response):
                    let dbSong = self.databaseService.writeSong(
                        id: song.id,
                        name: songName == "" ? self.getNewSongName() : songName,
                        url: song.url.absoluteString,
                        duration: TimeInterval(response.duration),
                        chords: response.chords,
                        text: response.text ?? [],
                        tempo: response.tempo,
                        songType: songName == "" ? .recorded : .localFile,
                        ext: ext,
                        thumbnailUrl: "",
                        transposition: 0
                    )
                    self.songs[i].name = dbSong.name
                    self.songs[i].duration = dbSong.duration
                    self.songs[i].chords = dbSong.chords
                    self.songs[i].text = dbSong.text
                    self.songs[i].tempo = dbSong.tempo
                    self.songs[i].isProcessing = false
                    self.songs[i].stopTimer()
                    self.recognitionInProgress = false
                    self.objectWillChange.send()

                case .failure(let failure):
                    self.songs[i].recognitionStatus = .serverError
                    self.recognitionInProgress = false
                    self.objectWillChange.send()
                    print("API failure: ",failure)
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
    }
    
    func processYoutubeVideo(by resultUrl: String, title: String, thumbnailUrl: String) {
        @AppStorage("isLimited") var isLimited: Bool = false
        @AppStorage("songCounter") var songCounter: Int = 0

        let song = Song(
            id: UUID().uuidString,
            name: title,
            url: resultUrl,
            duration: 0.0,
            created: Date(),
            chords: [],
            text: [],
            tempo: 0,
            songType: .youtube,
            isProcessing: true,
            isFakeLoaderVisible: true,
            thumbnailUrl: thumbnailUrl
        )
        song.startTimer()
        self.songs.insert(song, at: 0)
        songCounter = isLimited ? songCounter + 1 : songCounter
        self.objectWillChange.send()
        
        recognitionApiService.recognizeAudioFromYoutube(url: resultUrl) { result  in
            let i = self.getSongIndexByID(id: song.id)
            switch result {
            case .success(let response):
                let dbSong = self.databaseService.writeSong(
                    id: song.id,
                    name: title == "" ? self.getNewSongName() : title,
                    url: song.url.absoluteString,
                    duration: TimeInterval(response.duration),
                    chords: response.chords,
                    text: response.text ?? [],
                    tempo: response.tempo,
                    songType: .youtube,
                    ext: "",
                    thumbnailUrl: thumbnailUrl,
                    transposition: 0
                )
                self.songs[i].name = dbSong.name
                self.songs[i].duration = dbSong.duration
                self.songs[i].chords = dbSong.chords
                self.songs[i].text = dbSong.text
                self.songs[i].tempo = dbSong.tempo
                self.songs[i].isProcessing = false
                self.songs[i].stopTimer()
                self.recognitionInProgress = false
                self.objectWillChange.send()

            case .failure(let failure):
                self.songs[i].recognitionStatus = .serverError
                self.recognitionInProgress = false
                self.objectWillChange.send()
                print("API failure: ",failure)
            }
        }
    }
    
    func startRecording(conmpletion: @escaping (Bool) -> Void) {
        recordingService.startRecording() { permissionGranted in
            conmpletion(permissionGranted)
        }
    }
    
    func stopRecording(cancel: Bool = false) {
        recordingService.stopRecording(cancel: cancel)
        recordStarted = false
    }
    
    func importFile(url: URL) {
        self.recordingService.importFile(url: url)
    }
    
    func getDurationFromFile(url: URL, completion: @escaping (Double) -> Void) async throws {
        let asset = AVURLAsset(url: URL(fileURLWithPath: url.absoluteString))
        do {
            let duration = try await asset.load(.duration)
            completion(Double(CMTimeGetSeconds(duration)))
        } catch {
            print(error)
        }
    }
    
    func getSongIndexByID(id: String) -> Int {
        let s = songs.filter { song in
            song.id == id
        }
        return s.count > 0 ? Int(songs.firstIndex(of: s[0])!) : -1
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
            
            if song.songType != .youtube {
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
    }
    
    func filterSongs(searchText: String) {
        for i in songs.indices {
            songs[i].isVisible = searchText == "" ? true : songs[i].name.contains(searchText)
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
