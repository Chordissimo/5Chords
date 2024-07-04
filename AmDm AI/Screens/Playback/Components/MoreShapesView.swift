//
//  MoreShapesView.swift
//  AmDm AI
//
//  Created by Anton on 28/06/2024.
//

import SwiftUI

struct MoreShapesView: View {
    @Binding var isMoreShapesPopupPresented: Bool
    var uiChord: UIChord?
    let columns = [GridItem(.adaptive(minimum: LyricsViewModelConstants.chordWidth))]
    
    var body: some View {
        VStack {
            if let key = uiChord?.key, let suffix = uiChord?.suffix {
                HStack(alignment: .firstTextBaseline) {
                    Text(key.display.symbol + suffix.display.symbolized)
                        .foregroundStyle(.white)
                        .font(.system(size: 30))
                        .fontWeight(.semibold)
                        
                    Text("  (" + key.display.accessible + suffix.display.accessible + ")")
                        .foregroundStyle(.white)
                        .font(.system(size: 16))
                        .lineLimit(2)
                }
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 0) {
                        ForEach(uiChord!.chordPositions, id: \.self) { position in
                            ShapeLayerView(shapeLayer: createShapeLayer(
                                chordPosition: position,
                                width: LyricsViewModelConstants.chordWidth,
                                height: LyricsViewModelConstants.chordHeight)
                            )
                            .frame(width: LyricsViewModelConstants.chordWidth, height: LyricsViewModelConstants.chordHeight)
                        }
                    }
                    .frame(maxHeight: LyricsViewModelConstants.chordHeight * 2.5)
                    .padding(.horizontal)
                }
            }
        }
        .background(Color.customDarkGray)
    }
}
