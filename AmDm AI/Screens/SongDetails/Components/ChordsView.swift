//
//  Chords.swift
//  AmDm AI
//
//  Created by Anton on 30/03/2024.
//

import SwiftUI
import SwiftyChords

enum ChordDisplayStyle: Int {
    case inline = 0
    case pictogram_large = 1
    case pictogram_small = 2
}

@available(iOS 16.4, *)
struct ChordsView: View {
    var chords = [APIChord]()
    var style: ChordDisplayStyle
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)

    var body: some View {
        switch style {
        case .pictogram_large:
            ScrollView {
                LazyVGrid(columns: columns, spacing: 30) {
                    ForEach(chords) { ch in
                        ShapeLayerView(shapeLayer: createShapeLayer(chordPosition: Chords.guitar.matching(key: ch.uiChord.key).matching(suffix: ch.uiChord.suffix).first!))
                            .frame(width: 100, height: 100)
                    }
                }
            }
            .frame(maxHeight: .infinity)
            .scrollBounceBehavior(.basedOnSize)
        case .pictogram_small:
            ScrollView(.horizontal) {
                HStack {
                    ForEach(chords) { ch in
                        VStack {
                            Text(ch.uiChord.key.display.symbol + ch.uiChord.suffix.display.symbolized)
                                .foregroundStyle(Color.white)
                                .font(.system(size: 15))
                                .fontWeight(.semibold)
                            ShapeLayerView(shapeLayer: createShapeLayer(chordPosition: Chords.guitar.matching(key: ch.uiChord.key).matching(suffix: ch.uiChord.suffix).first!))
                                .frame(width: 50, height: 75)
                        }
                    }
                }
            }
            .frame(maxHeight: .infinity)
            .scrollBounceBehavior(.basedOnSize)
        default:
            ScrollView(.horizontal) {
                HStack {
                    Spacer()
                    ForEach(chords.indices, id: \.self) { index in
                        Text(chords[index].uiChord.key.display.symbol + chords[index].uiChord.suffix.display.symbolized)
                            .foregroundStyle(Color.customGray1)
                            .font(.system(size: 15))
                            .fontWeight(.semibold)
                    }
                    Spacer()
                }.frame(minWidth: UIScreen.main.bounds.width * 0.9)
            }
        }
    }
    
    func createShapeLayer(chordPosition: ChordPosition) -> CAShapeLayer {
        var frame: CGRect
        switch self.style {
        case .pictogram_large:
            frame = CGRect(x: 0, y: 0, width: 100, height: 150)
        case .pictogram_small:
            frame = CGRect(x: 0, y: 0, width: 50, height: 75)
        default:
            frame = CGRect(x: 0, y: 0, width: 0, height: 0) // we're not suppose to even call this method for the inline representation
        }
        
        let shapeLayer = chordPosition.chordLayer(
            rect: frame,
            chordName:.init(show: false, key: .symbol, suffix: .symbolized),
            forPrint: false
        )
    
        return shapeLayer
    }
}

struct ShapeLayerView: UIViewRepresentable {
    let shapeLayer: CAShapeLayer
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.layer.addSublayer(shapeLayer)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Update shape layer properties if needed
    }
}

//#Preview {
//    ZStack {
//        Color.customDarkGray.ignoresSafeArea()
//        VStack {
//            ChordsView(chords: [
//                Chord(key: Chords.Key.a, suffix: Chords.Suffix.minor),
//                Chord(key: Chords.Key.g, suffix: Chords.Suffix.major),
//                Chord(key: Chords.Key.f, suffix: Chords.Suffix.major),
//                Chord(key: Chords.Key.f, suffix: Chords.Suffix.major),
//                Chord(key: Chords.Key.c, suffix: Chords.Suffix.susTwo),
//                Chord(key: Chords.Key.c, suffix: Chords.Suffix.susTwo),
//                Chord(key: Chords.Key.c, suffix: Chords.Suffix.susFour)
//                
//            ])//,style: ChordDisplayStyle.pictogram)
//        }.frame(height: 300).padding()
//    }
//}
