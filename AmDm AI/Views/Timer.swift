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
    var maxDuration: Double
    var songName: String
    
    @State private var timer: Timer?
    @State private var isTimerRunning = false
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .top)) {
            RoundedRectangle(cornerRadius: 16)
                .ignoresSafeArea()
                .ignoresSafeArea(.keyboard)
                .frame(height: .infinity)
                .frame(maxWidth: .infinity)
                .foregroundColor(Color.customDarkGray)
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
            }
            .ignoresSafeArea()
            .padding()
            .onAppear() {
                if timerState {
                    timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
                        duration += 0.01
                        if maxDuration > 0 {
                            if duration >= 15 {
                                stopTimer()
                                withAnimation {
                                    timerState.toggle()
                                }
                                NotificationCenter.default.post(name: Notification.Name.autoStop, object: nil)
                            }
                        }
                    }
                    isTimerRunning = true
                }
            }.onDisappear() {
                stopTimer()
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        isTimerRunning = false
    }
}

extension Notification.Name {
    static let autoStop = Notification.Name("autoStop")
}


#Preview {
    @State var started: Bool = true
    @State var duration: Double = TimeInterval(0)
    return VStack {
        TimerView(timerState: $started, duration: $duration, maxDuration: 15, songName: "New recording")
        Button("stop") {
            started = false
        }
    }
}
