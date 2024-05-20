//
//  Recording.swift
//  AmDm AI
//
//  Created by Marat Zainullin on 13/04/2024.
//

import AVFoundation

class RecordingService: NSObject, AVAudioRecorderDelegate {
    
    var audioRecorder: AVAudioRecorder?
    var recordingURL: URL?
    var recordingCallback: ((URL?, String?, String?) -> Void)?
    var recordingTimeCallback: ((TimeInterval, Float) -> Void)?
    var timer: Timer?
    var startTime: Date?


    func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
            
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileName = "\(UUID().uuidString).m4a"
            recordingURL = documentsPath.appendingPathComponent(fileName)
            
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 2,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ] as [String : Any]
            
            audioRecorder = try AVAudioRecorder(url: recordingURL!, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            
            startTime = Date()
            startTimer()
        } catch {
            print("Error starting recording: \(error.localizedDescription)")
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
        stopTimer()
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        recordingCallback?(recordingURL,"","")
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            if let startTime = self.startTime {
                let currentTime = Date()
                let elapsedTime = currentTime.timeIntervalSince(startTime)
                self.audioRecorder?.updateMeters()
                let dec = (self.audioRecorder?.averagePower(forChannel: 0))!
                self.recordingTimeCallback?(elapsedTime, pow(10.0, dec / 20.0) * 500)
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func importFile(url: URL) {
        var _url: URL
        var result: Bool = true
        var songName: String = ""
        var ext: String = ""
        do {
            let filenameWithExt = String(url.absoluteString.split(separator: "/").last ?? "")
            songName = String(filenameWithExt.split(separator: ".").first ?? "")
            ext = String(filenameWithExt.split(separator: ".").last ?? "")
            let filename = UUID().uuidString
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            _url = documentsPath.appendingPathComponent(filename + "." + ext)
            try FileManager.default.copyItem(at: url, to: _url)
        } catch {
            print(error)
            result = false
        }
        if result {
            recordingCallback?(_url, songName, ext)
        }
    }
}
