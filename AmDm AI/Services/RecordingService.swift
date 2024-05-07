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
    var recordingCallback: ((URL?) -> Void)?
    var recordingTimeCallback: ((TimeInterval, Float) -> Void)?
    var timer: Timer?
    var startTime: Date?


    func startRecording() {
        // print("matg", "startRecording")
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
        recordingCallback?(recordingURL)
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            if let startTime = self.startTime {
                let currentTime = Date()
                let elapsedTime = currentTime.timeIntervalSince(startTime)
                self.audioRecorder?.updateMeters()
//                let dec = (self.audioRecorder?.peakPower(forChannel: 0))! + 160
//                print(dec)
//                print((self.audioRecorder?.peakPower(forChannel: 0))!,(self.audioRecorder?.averagePower(forChannel: 0))!)
                self.recordingTimeCallback?(elapsedTime, (self.audioRecorder?.peakPower(forChannel: 0))!)
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
