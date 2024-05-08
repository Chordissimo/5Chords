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
        GeometryReader { geometry in
            VStack(alignment: .trailing) {
                HStack(spacing: 0) {
                    ForEach(0..<songsList.decibelChanges.count, id: \.self) { i in
                        if songsList.decibelChanges[i] == 0 {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 2, height: 1)
                        } else {
                            RoundedRectangle(cornerRadius: 3)
                                .foregroundColor(.yellow)
                                .frame(width: 2, height: CGFloat(songsList.decibelChanges[i]))
                        }
                    }
                }
                .frame(width: geometry.size.width, height: 120, alignment: .trailing)
                //                                .border(Color.blue, width: 1)
            }
        }
    }
}
