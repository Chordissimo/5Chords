//
//  Recording.swift
//  AmDm AI
//
//  Created by Marat Zainullin on 13/04/2024.
//

import AVFoundation
import SwiftUI

class RecordingService: NSObject, AVAudioRecorderDelegate, ObservableObject {
    
    @Published var audioRecorder: AVAudioRecorder?
    var recordingURL: URL?
    var recordingCallback: ((URL?, String?, String?) -> Void)?
    var recordingTimeCallback: ((TimeInterval, Float) -> Void)?
    var timer: Timer?
    var startTime: Date?
    var isCanceled: Bool = false

    func startRecording(completion: @escaping (Bool) -> Void) {
        @AppStorage("isLimited") var isLimited: Bool = false
        let appDefaults = AppDefaults()

        AVAudioApplication.requestRecordPermission() { permissionGranted in
            if permissionGranted {
                let audioSession = AVAudioSession.sharedInstance()
                do {
                    try audioSession.setCategory(.playAndRecord, mode: .default)
                    try audioSession.setActive(true)
                    
                    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    let fileName = "\(UUID().uuidString).m4a"
                    self.recordingURL = documentsPath.appendingPathComponent(fileName)
                    
                    let settings = [
                        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                        AVSampleRateKey: 44100,
                        AVNumberOfChannelsKey: 2,
                        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                    ] as [String : Any]
                    
                    self.audioRecorder = try AVAudioRecorder(url: self.recordingURL!, settings: settings)
                    self.audioRecorder?.delegate = self
                    self.audioRecorder?.isMeteringEnabled = true
                    self.audioRecorder?.record(forDuration: isLimited ? Double(appDefaults.LIMITED_DURATION) : Double(appDefaults.MAX_DURATION))
                    
                    self.startTime = Date()
                } catch {
                    print("Error starting recording: \(error.localizedDescription)")
                }
            }
            completion(permissionGranted)            
        }
    }
    
    func stopRecording(cancel: Bool = false) {
        audioRecorder?.stop()
        audioRecorder = nil
        stopTimer()
        isCanceled = cancel
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if self.audioRecorder != nil {
            self.audioRecorder = nil
            stopTimer()
        }
        if !isCanceled {
            recordingCallback?(recordingURL,"","")
        }
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
            let fn = String(url.absoluteString.split(separator: "/").last ?? "")
            let filenameWithExt = fn.removingPercentEncoding ?? fn
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
