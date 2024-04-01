//
//  Timer.swift
//  AmDm AI
//
//  Created by Anton on 31/03/2024.
//

import Foundation
import SwiftUI

struct TimerView: View {
    @Binding var timerState: Bool
    @Binding var duration: Double
    var songName: String
    
    @State private var timer: Timer?
//    @State private var elapsedTime: TimeInterval = 0
    @State private var isTimerRunning = false
    
    var body: some View {
        VStack {
            if timerState {
                Text(songName)
                    .foregroundStyle(Color.white)
                    .font(.system(size: 18))
                Text(formatTime(duration,precision: TimePrecision.santiseconds))
                    .foregroundStyle(Color.customGray1)
                Text("Recording...")
                    .foregroundStyle(Color.customGray1)
                    .padding(.top, 20)
            }
        }.onAppear() {
            if timerState {
                timer = Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true) { _ in
                    duration += 0.001
                }
                isTimerRunning = true
            }
        }.onDisappear() {
            timer?.invalidate()
            timer = nil
            isTimerRunning = false
        }
    }
}


#Preview {
    @State var started: Bool = true
    @State var duration: Double = TimeInterval(0)
    return VStack {
        TimerView(timerState: $started, duration: $duration, songName: "New recording")
        Button("stop") {
            print(started)
            started = false
            print(started)
        }
    }
}
