//
//  Chords.swift
//  AmDm AI
//
//  Created by Anton on 30/03/2024.
//

import SwiftUI

enum ChordDisplayStyle {
    static let inline = 0
    static let pictogram = 1
}

struct ChordView: View {
    var chords = [Chord]()
    var style: Int? = 0
    
    var body: some View {
        switch style {
        case ChordDisplayStyle.pictogram:
            Text("to be added later")
        default:
            ForEach(chords.indices, id: \.self) { index in
                Text(chords[index].name)
                    .foregroundStyle(Color.customGray1)
                    .font(.system(size: 15))
                    .fontWeight(.semibold)
            }
            
        }
    }
}

#Preview {
    ChordView(chords: [
        Chord(name: "Am", description: "A minor"),
        Chord(name: "G", description: "G major"),
        Chord(name: "F", description: "F major"),
        Chord(name: "Fmaj7", description: "F major 7"),
        Chord(name: "Dsus2", description: "D suspended 2"),
        Chord(name: "Dsus4", description: "D suspended 4"),
        Chord(name: "Csus2", description: "C suspended 2"),
        Chord(name: "Csus4", description: "C suspended 4")
    ])
}
