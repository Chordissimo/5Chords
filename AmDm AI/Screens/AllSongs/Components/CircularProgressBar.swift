//
//  CircularProgressBar.swift
//  AmDm AI
//
//  Created by Anton on 17/05/2024.
//

import SwiftUI

struct CircularProgressBar: View {
    @Binding var progress: Float
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 20.0)
                .opacity(0.20)
                .foregroundColor(.gray)
            Circle()
                .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 12.0, lineCap: .round, lineJoin: .round))
                .rotationEffect(Angle(degrees: 270))
        }
    }
}


struct CircularProgressBarView: View {
    @Binding var song: Song
    @State var progress: Float = 0.0
    @State var timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack {
            CircularProgressBar(progress: $progress)
//                .frame(width: 160, height: 160)
                .padding(20)
                .onReceive(timer, perform: { _ in
                    withAnimation(.easeInOut(duration: 1.0)) {
                        if song.isProcessing {
                            progress = progress <= 0.9 ? progress + 0.1 : progress
                        } else {
                            progress = 1
                        }
                    }
                })
        }
    }
}
