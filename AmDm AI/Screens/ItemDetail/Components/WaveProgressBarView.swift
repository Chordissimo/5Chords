//
//  WaveProgressBarView.swift
//  AmDm AI
//
//  Created by Marat Zainullin on 30/04/2024.
//

import SwiftUI
import DSWaveformImage
import DSWaveformImageViews

struct WaveProgressBarView: View {
    @State var tmpPosition: CGFloat? = nil
    @Binding var globalPosition: Float
    let url: URL
    
    var body: some View {
        GeometryReader { geometry in
            WaveformView(audioURL: url) { shape in
                shape.fill(.white)
                shape.fill(.red).mask(alignment: .leading) {
                    Rectangle().frame(width: geometry.size.width * (tmpPosition ?? CGFloat(globalPosition)))
                }
                
            }
            .frame(width: geometry.size.width, height: 90)
            .gesture(
                DragGesture()
                    .onChanged({ value in
                        tmpPosition = value.location.x / geometry.size.width
                    })
                    .onEnded({ value in
                        guard let position = tmpPosition else {
                            return
                        }
                        globalPosition = Float(position)
                        self.tmpPosition = nil
                    })
            )
            .onTapGesture { location in
                globalPosition = Float(location.x / geometry.size.width)
                self.tmpPosition = nil
            }
        }
    }
}

//#Preview {
//    WaveProgressBarView()
//}
