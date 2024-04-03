//
//  Chords.swift
//  AmDm AI
//
//  Created by Anton on 30/03/2024.
//

import SwiftUI
import SwiftyChords

enum ChordDisplayStyle {
    static let inline = 0
    static let pictogram = 1
}

struct ChordsView: View {
    var chords = [Chord]()
    var style: Int? = 0
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)

    
    var body: some View {
        switch style {
        case ChordDisplayStyle.pictogram:
            ScrollView {
                LazyVGrid(columns: columns, spacing: 30) {
                    ForEach(chords) { chord in
                        ShapeLayerView(shapeLayer: createShapeLayer(chordPosition: Chords.guitar.matching(key: chord.key).matching(suffix: chord.suffix).first!))
                            .frame(width: 100, height: 100)
                    }
                }
            }.frame(maxHeight: .infinity).scrollBounceBehavior(.basedOnSize)
        default:
            ScrollView(.horizontal) {
                HStack {
                    Spacer()
                    ForEach(chords.indices, id: \.self) { index in
                        Text(chords[index].key.display.symbol + chords[index].suffix.display.symbolized)
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
        let frame = CGRect(x: 0, y: 0, width: 100, height: 150)
        let shapeLayer = chordPosition.chordLayer(
            rect: frame,
            chordName:.init(show: true, key: .symbol, suffix: .symbolized), 
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

#Preview {
    ZStack {
        Color.customDarkGray.ignoresSafeArea()
        VStack {
            ChordsView(chords: [
                Chord(key: Chords.Key.a, suffix: Chords.Suffix.minor),
                Chord(key: Chords.Key.g, suffix: Chords.Suffix.major),
                Chord(key: Chords.Key.f, suffix: Chords.Suffix.major),
                Chord(key: Chords.Key.f, suffix: Chords.Suffix.major),
                Chord(key: Chords.Key.c, suffix: Chords.Suffix.susTwo),
                Chord(key: Chords.Key.c, suffix: Chords.Suffix.susTwo),
                Chord(key: Chords.Key.c, suffix: Chords.Suffix.susFour)
                
            ])//,style: ChordDisplayStyle.pictogram)
        }.frame(height: 300).padding()
    }
}
