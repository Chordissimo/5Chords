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
    @ObservedObject var songsList: SongsList
    var songName: String
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .top)) {
            RoundedRectangle(cornerRadius: 16)
                .ignoresSafeArea()
                .ignoresSafeArea(.keyboard)
                .frame(maxWidth: .infinity)
                .foregroundColor(Color.customDarkGray)
            if timerState {
                VStack {
                    Text(songName)
                        .foregroundStyle(Color.white)
                        .font(.system(size: 24))
                        .padding(.bottom, 20)
                    Text(formatTime(duration,precision: TimePrecision.santiseconds))
                        .foregroundStyle(Color.customGray1)
                    LiveWaveform(songsList: songsList)
                }
                .transition(.asymmetric(insertion: .opacity, removal: .identity))
                .ignoresSafeArea()
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
            }
            
        }
    }
    
}
