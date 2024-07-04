//
//  CircularProgressBar.swift
//  AmDm AI
//
//  Created by Anton on 17/05/2024.
//

import SwiftUI

//class ProgressTimer: ObservableObject, Equatable {
//    static func == (lhs: ProgressTimer, rhs: ProgressTimer) -> Bool {
//        lhs.id == rhs.id
//    }
//    var id = UUID()
//    private var startTime: Date?
//    @Published private var timer: Timer?
//    @Published var elapsedTime: TimeInterval = 0.0
//    
//    func startTimer() {
//        self.startTime = Date()
//        self.timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
//            guard let self = self else { return }
//            if let startTime = self.startTime {
//                let currentTime = Date()
//                self.elapsedTime = currentTime.timeIntervalSince(startTime)
//            }
//        }
//    }
//    
//    func stopTimer() {
//        self.timer?.invalidate()
//        self.timer = nil
//    }
//}



struct CircularProgressBarView: View {
    @ObservedObject var song: Song
    @ObservedObject var songsList: SongsList
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                ZStack {
                    Circle()
                        .stroke(lineWidth: 2.0)
                        .opacity(0.20)
                        .foregroundColor(.gray)
                    
                    Image("stars")
                        .resizable()
                        .frame(width: 28, height: 28)
                        .foregroundColor(.progressCircle)
                        .glow()
                    
                    Circle()
                        .trim(from: 0.0, to: CGFloat(min(song.progress, 1.0)))
                        .stroke(style: StrokeStyle(lineWidth: 2.0, lineCap: .round, lineJoin: .round))
                        .foregroundColor(.progressCircle)
                        .rotationEffect(Angle(degrees: 270))
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
            .onChange(of: song.elapsedTime) {
                if song.isProcessing {
                    if song.progress <= 0.8 {
                        song.progress = song.progress + 0.0005
                    } else if song.progress > 0.8 && song.progress <= 0.9 {
                        song.progress = song.progress + 0.0001
                    } else if song.progress > 0.9 && song.progress <= 0.95 {
                        song.progress = song.progress + 0.00005
                    }
                }
            }
            .onChange(of: song.isProcessing) {
                if !song.isProcessing {
                    withAnimation(.easeInOut(duration: 1.0)) {
                        song.progress = 1
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            song.isFakeLoaderVisible = false
                        }
                    }
                }
            }

        }
    }
}
