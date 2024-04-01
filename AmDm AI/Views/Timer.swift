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
    @State private var timer: Timer?
    @State private var elapsedTime: TimeInterval = 0
    @State private var isTimerRunning = false
    
    var body: some View {
        VStack {
            if timerState {
                Text("\(formatTime(elapsedTime))")
                    .foregroundStyle(Color.customGray1)
                Text("Recording...")
                    .foregroundStyle(Color.customGray1)
                    .padding(.top, 20)
            }
        }.onAppear() {
            if timerState {
                timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                    elapsedTime += 1
                }
                isTimerRunning = true
            }
        }.onDisappear() {
            timer?.invalidate()
            timer = nil
            isTimerRunning = false
            elapsedTime = 0
        }
    }
        
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}


#Preview {
    @State var started: Bool = false
    return VStack {
        TimerView(timerState: $started)
    }
}
