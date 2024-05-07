//
//  LiveWaveform.swift
//  AmDm AI
//
//  Created by Anton on 07/05/2024.
//

import SwiftUI

struct LiveWaveform: View {
    @ObservedObject var songsList: SongsList
    
    var body: some View {
        VStack {
            ScrollView {
                LazyHStack(spacing: 5) {
                    ForEach(0..<songsList.decibelChanges.count, id: \.self) { i in
                        if songsList.decibelChanges[i] == 0 {
                            Rectangle()
                                .foregroundColor(.gray)
                                .frame(width: 1, height: 1)
                        } else {
                            RoundedRectangle(cornerSize: 5)
                                .foregroundColor(.yellow)
                                .frame(width: 2, height: CGFloat(songsList.decibelChanges[i]))
                        }
                    }
                }
                .frame(height: 80)
                .border(Color.blue, width: 1)
            }

        }

    }
}
