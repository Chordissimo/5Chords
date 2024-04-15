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
    
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .top)) {
            RoundedRectangle(cornerRadius: 16)
                .ignoresSafeArea()
                .ignoresSafeArea(.keyboard)
                .frame(maxWidth: .infinity)
                .foregroundColor(Color.customDarkGray)
            VStack {
                if timerState {
                    Text(songName)
                        .foregroundStyle(Color.white)
                        .font(.system(size: 18))
                        .transition(.identity)
                        .animation(.linear, value: 0.1)
                    Text(formatTime(duration,precision: TimePrecision.santiseconds))
                        .foregroundStyle(Color.customGray1)
                        .transition(.identity)
                        .animation(.linear, value: 0.1)
                    Text("Recording...")
                        .foregroundStyle(Color.customGray1)
                        .padding(.top, 20)
                        .transition(.identity)
                        .animation(.linear, value: 0.1)
                }
            }
            .ignoresSafeArea()
            .padding()
        }.transition(.move(edge: .bottom))
    }
    
}


#Preview {
    @State var started: Bool = true
    @State var duration: Double = TimeInterval(0)
    return VStack {
        TimerView(timerState: $started, duration: $duration, songName: "New recording")
        Button("stop") {
            started = false
        }
    }
}
