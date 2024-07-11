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
    @Binding var recordPanelPresented: Bool
    var completion: (Bool) -> Void
    @AppStorage("isLimited") var isLimited: Bool = false
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .top)) {
            RoundedRectangle(cornerRadius: 16)
                .ignoresSafeArea()
                .ignoresSafeArea(.keyboard)
                .frame(maxWidth: .infinity)
                .foregroundColor(Color.customDarkGray)
            
            HStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        timerState = false
                        completion(true)
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .foregroundColor(.gray40)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 22, height: 22)
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 20)
                }
            }
            
            VStack {
                Text(songName)
                    .foregroundStyle(Color.white)
                    .font(.system(size: 24))
                    .padding(.bottom, 20)
                Text(formatTime(duration,precision: TimePrecision.santiseconds))
                    .foregroundStyle(Color.customGray1)
                LiveWaveform(songsList: songsList)
            }
            .ignoresSafeArea()
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
        }
        .overlay {
            if isLimited && recordPanelPresented {
                DurationLimitView(isLimited: isLimited)
                    .offset(x: 0, y: -240)
            }
        }
    }
}
