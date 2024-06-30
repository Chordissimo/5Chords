//
//  MoreShapesView.swift
//  AmDm AI
//
//  Created by Anton on 28/06/2024.
//

import SwiftUI

//struct MoreShapesView: View {
//    @Binding var isMoreShapesPopupPresented: Bool
//    var uiChord: UIChord?
//    let columns = [GridItem(.adaptive(minimum: LyricsViewModelConstants.chordWidth))]
//    
//    var body: some View {
//        VStack {
//            let height = UIScreen.main.bounds.height
//            let width = UIScreen.main.bounds.width
//                VStack {
//                    HStack {
//                        Spacer()
//                        Button {
//                            isMoreShapesPopupPresented = false
//                        } label: {
//                            Image(systemName: "xmark")
//                                .resizable()
//                                .aspectRatio(contentMode: .fit)
//                                .frame(width: 20, height: 20)
//                                .foregroundStyle(.secondaryText)
//                        }
//                        .padding(.trailing, 20)
//                        .padding(.top, 20)
//                    }
//                    .frame(width: width)
//                    
//                    if let key = uiChord?.key, let suffix = uiChord?.suffix {
//                        Text(key.display.symbol + suffix.display.symbolized)
//                            .foregroundStyle(.white)
//                            .font(.system(size: 30))
//                            .fontWeight(.semibold)
//                        Text(key.display.accessible + suffix.display.accessible)
//                            .foregroundStyle(.white)
//                            .font(.system(size: 16))
//                            .lineLimit(2)
//                        ScrollView {
//                            LazyVGrid(columns: columns, spacing: 20) {
//                                ForEach(uiChord!.chordPositions, id: \.self) { position in
//                                    ShapeLayerView(shapeLayer: createShapeLayer(
//                                        chordPosition: position,
//                                        width: LyricsViewModelConstants.chordWidth,
//                                        height: LyricsViewModelConstants.chordHeight)
//                                    )
//                                    .frame(width: LyricsViewModelConstants.chordWidth, height: LyricsViewModelConstants.chordHeight)
//                                }
//                            }
//                            .frame(maxHeight: 300)
//                            .border(.white)
//                            .padding(.horizontal)
//                        }
//                    }
//                }
//                .background(Color.gray5)
//            }
//        
//    }
//}
