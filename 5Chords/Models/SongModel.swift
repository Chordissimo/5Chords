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
import SwiftyChords

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

struct LyricsViewModelConstants {
    static let chordHeight = 135.0
    static let chordWidth = 135.0 / 6 * 5
    static let videoPlayerHeight = 120.0
    static let videoPlayerWidth = 180.0
    static let maxBottomPanelHeight = 250.0
    static let minBottomPanelHeight = 110.0
    static let moreShapesPanelHeight = 350.0
    static let lyricsfontSize: CGFloat = 16.0
    static let minScreenWidth: CGFloat = 250.0
    static let padding: CGFloat = 20.0
    static let spacing: CGFloat = 5.0
    static let minChordWidth: CGFloat = 50.0
}

struct Word: Identifiable, Hashable {
    static func == (lhs: Word, rhs: Word) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
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
        hasher.combine(id)
    }
        
    var id = UUID()
    var start: Int
    var words: String
    var uiChord: UIChord? = nil
    var limitLines: Int = 1
    var width: CGFloat = 0.0
}

struct Timeframe: Identifiable, Hashable {
    static func == (lhs: Timeframe, rhs: Timeframe) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var id = UUID()
    var start: Int
    var intervals: [Int] = []
    var width: CGFloat = 0.0
    var limit: Bool = false
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
    @Published var intervals: [Interval] = []
    @Published var timeframes: [Timeframe] = []
    @Published var hideLyrics: Bool = false
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
    
    init(id: String, name: String, url: String, duration: TimeInterval, created: Date, chords: [APIChord], text: [AlignedText], intervals: [Interval] = [], tempo: Float, songType: SongType, ext: String = "", isProcessing: Bool = false, isFakeLoaderVisible: Bool = false, thumbnailUrl: String = "", transposition: Int = 0) {
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
        self.intervals = intervals
        self.hideLyrics = hideLyrics
        
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
        self.createTimeframes()
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
    
    func createTimeframes() {
        guard self.chords.count > 0 || self.intervals.count > 0 else { return }
        self.timeframes = []
        let maxWidth = AppDefaults.screenWidth - LyricsViewModelConstants.padding
        
        if self.intervals.count > 0 {
            self.intervals = compactIntervals(intervals: self.intervals, recalcWidth: true)
        } else {
            self.intervals = createIntervals()
        }

        var line: [Interval] = []
        var indices: [Int] = []
        var width: Double = 0

        for interval in self.intervals {
            width += interval.width
            if width > maxWidth {
                let timeframe = Timeframe(start: line.first!.start, intervals: indices, width: width - interval.width)
                self.timeframes.append(timeframe)
                line = []
                indices = []
                width = interval.width
                if AppDefaults.isLimited && timeframe.start > AppDefaults.LIMITED_DURATION * 1000 {
                    self.timeframes[self.timeframes.count - 1].limit = true
                    break
                }
            }
            line.append(interval)
            indices.append(self.intervals.firstIndex(of: interval)!)
        }
        if line.count > 0 {
            self.timeframes.append(Timeframe(start: line.first!.start, intervals: indices, width: width))
        }
    }
        
    private func createIntervals() -> [Interval] {
        guard self.chords.count > 0 else { return [] }
        let compactedWords = compactWords()
        let adjustedChords = adjustChordStartTime(adjustment: AppDefaults.INTERVAL_START_ADJUSTMENT)
        let maxWidth = AppDefaults.screenWidth - LyricsViewModelConstants.padding
        var result: [Interval] = []
        
        if compactedWords.count > 0 {
            let firstWord = compactedWords.first!
            if firstWord.start < self.chords.first!.start {
                let words = compactedWords.filter { $0.start < self.chords.first!.start }.map { $0.text }.joined(separator: " ")
                result.append(Interval(start: 0, words: words))
            }
        }
        
        for i in 0..<adjustedChords.count {
            let words = compactedWords.filter {
                var condition = false
                if i == self.chords.count - 1 {
                    condition = $0.start >= adjustedChords[i].start
                } else {
                    condition = $0.start >= adjustedChords[i].start && $0.start < adjustedChords[i + 1].start
                }
                return condition
            }.map { $0.text }.joined(separator: " ")
            
            let uiChord = UIChord(chord: adjustedChords[i].chord)
            var interval = Interval(start: adjustedChords[i].start, words: words, uiChord: uiChord)
            let intervalWidth = getWidth(for: interval)
            interval.limitLines = Int(ceil(intervalWidth / maxWidth))
            interval.width = min(intervalWidth, maxWidth)
            result.append(interval)
        }
        
        return compactIntervals(intervals: result)
    }
    
    func getWidth(for interval: Interval) -> CGFloat {
        let textSize = ceil(interval.words.size(withAttributes: [.font: UIFont.systemFont(ofSize: LyricsViewModelConstants.lyricsfontSize)]).width)
        var chordSize = 0.0
        if let chord = interval.uiChord {
            chordSize = ceil(chord.getChordString().size(withAttributes: [.font: UIFont.systemFont(ofSize: LyricsViewModelConstants.lyricsfontSize, weight: .semibold)]).width)
        }
        return (textSize > 0 ? max(textSize,chordSize) : max(chordSize,LyricsViewModelConstants.minChordWidth)) + LyricsViewModelConstants.spacing
    }
    
    private func compactIntervals(intervals: [Interval], recalcWidth: Bool = false) -> [Interval] {
        guard intervals.count > 0 else { return [] }
        let maxWidth: CGFloat = AppDefaults.screenWidth - LyricsViewModelConstants.padding
        
        let inter =  intervals.filter({ !($0.uiChord == nil && $0.words.count == 0) }).map {
            var interval = $0
            if recalcWidth {
                let intervalWidth = getWidth(for: interval)
                interval.width = min(intervalWidth, maxWidth)
                interval.limitLines = Int(ceil(intervalWidth / maxWidth))
            }
            return interval
        }
                
        return inter
    }
    
    private func compactWords() -> [Word] {
        guard self.text.count > 0 else { return [] }
        
        var result: [Word] = []
        let s = self.text.first!.start ?? -1
        var word = Word(start: s < 0 ? 0 : s, text: self.text.first!.text)
        
        for i in 1..<self.text.count {
            let start = self.text[i].start ?? -1
            if i == 0 {
                word = Word(start: start < 0 ? 0 : start, text: self.text.first!.text)
            } else {
                if start < 0 {
                    word.text += self.text[i].text
                } else {
                    result.append(word)
                    word = Word(start: start, text: self.text[i].text)
                }
            }
        }
        
        let index = result.firstIndex(where: { $0.id == word.id })
        if index == nil {
            result.append(word)
        }
        
        return result
    }
    
    func adjustChordStartTime(adjustment: Int) -> [APIChord] {
        var result: [APIChord] = []
        for chord in self.chords {
            let start = (chord.start + adjustment) < 0 ? 0 : (chord.start + adjustment)
            let end = (chord.end + adjustment) < 0 ? 0 : (chord.end + adjustment)
            result.append(APIChord(id: chord.id, chord: chord.chord, start: start, end: end))
        }
        return result
    }
    
    func getTimeframeIndex(time: Int) -> Int {
        let filteredTimeframes = self.timeframes.filter { return $0.start <= time }
        return filteredTimeframes.count > 0 ? self.timeframes.firstIndex(of: filteredTimeframes.last!)! : -1
    }

    func getChordIndex(time: Int) -> Int {
        let filteredIntervals = self.intervals.filter { return $0.start < time }
        return filteredIntervals.count > 0 ? self.intervals.firstIndex(of: filteredIntervals.last!)! : -1
    }
    
    func getFirstChordIndex() -> Int? {
        var result: Int? = nil

        if let idx = self.intervals.firstIndex(where: { $0.uiChord != nil }) {
            result = idx
        }

        return result
    }
    
    func transpose(transposeUp: Bool) {
        guard self.intervals.count > 0 else { return }
        for interval in self.intervals {
            if let uiChord = interval.uiChord {
                uiChord.transpose(shift: transposeUp ? 1 : -1)
            }
        }
    }
}

final class SongsList: ObservableObject {    
    @Published var songs: [Song] = []
    @Published var recordStarted: Bool = false
    @Published var duration: TimeInterval = 0
    @Published var decibelChanges = [Float]()
    @Published var showSearch: Bool = false
    @Published var recognitionInProgress: Bool = false

    let recordingService = RecordingService()
    private let recognitionApiService = RecognitionApiService()
    let databaseService = DatabaseService()
    
    init() {
        self.songs = self.databaseService.getSongs()
        
        recordingService.recordingCallback = { [weak self] url, songName, ext in
            guard let self = self else { return }
            guard let url = url else { return }
            guard let songName = songName else { return }
            guard let ext = ext else { return }
            self.recordStarted = false
            
            let song = self.databaseService.createSongStub(
                id: UUID().uuidString,
                name: songName == "" ? self.getNewSongName() : songName,
                url: url.absoluteString,
                duration: 0.0,
                chords: [],
                text: [],
                tempo: 0,
                songType: songName == "" ? .recorded : .localFile,
                ext: ext,
                thumbnailUrl: ""
            )
            
            song.isFakeLoaderVisible = true
            song.startTimer()
            self.songs.insert(song, at: 0)
            self.objectWillChange.send()
            
            self.recognitionApiService.recognizeAudio(url: url, songId: song.id) { result in
                let i = self.getSongIndexByID(id: song.id)
                switch result {
                case .success(let response):
                    SongsList.recognitionSuccess(song: &self.songs[i], response: response)
                    self.songs[i].stopTimer()
                    self.databaseService.updateSong(song: self.songs[i])
                    self.recognitionInProgress = false
                    self.objectWillChange.send()
                    AppDefaults.songCounter = AppDefaults.isLimited ? AppDefaults.songCounter + 1 : AppDefaults.songCounter

                case .failure:
                    self.songs[i].recognitionStatus = .serverError
                    self.recognitionInProgress = false
                    self.objectWillChange.send()
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
        let song = self.databaseService.createSongStub(
            id: UUID().uuidString,
            name: title == "" ? self.getNewSongName() : title,
            url: resultUrl,
            duration: 0.0,
            chords: [],
            text: [],
            tempo: 0,
            songType: .youtube,
            ext: "",
            thumbnailUrl: thumbnailUrl
        )

        song.isFakeLoaderVisible = true
        self.songs.insert(song, at: 0)
        self.songs[0].startTimer()
        self.objectWillChange.send()
        
        recognitionApiService.recognizeAudioFromYoutube(url: resultUrl, songId: song.id) { result  in
            let i = self.getSongIndexByID(id: song.id)
            switch result {
            case .success(let response):
                SongsList.recognitionSuccess(song: &self.songs[i], response: response)
                self.songs[i].stopTimer()

                self.databaseService.updateSong(song: self.songs[i])
                self.recognitionInProgress = false
                self.objectWillChange.send()
                AppDefaults.songCounter = AppDefaults.isLimited ? AppDefaults.songCounter + 1 : AppDefaults.songCounter

            case .failure(let failure):
                self.songs[i].recognitionStatus = .serverError
                self.recognitionInProgress = false
                self.objectWillChange.send()
                print("API failure: ",failure)
            }
        }
    }
    
    static func recognitionSuccess(song: inout Song, response: RecognitionApiService.Response) {
        if let _ = response.result {
            song.duration = TimeInterval(response.result!.duration ?? 0)
            song.chords = response.result!.chords ?? []
            song.text = response.result!.text ?? []
            song.tempo = response.result!.tempo ?? 0
        } else {
            song.duration = TimeInterval(response.duration ?? 0)
            song.chords = response.chords ?? []
            song.text = response.text ?? []
            song.tempo = response.tempo ?? 0
        }
        song.isProcessing = false
        song.isFakeLoaderVisible = false
        song.createTimeframes()
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
    
    func rebuildTimeframes() {
        for i in 0..<self.songs.count {
            if songs[i].timeframes.count > 0 {
                if songs[i].timeframes.last!.limit {
                    songs[i].createTimeframes()
                }
            }
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
