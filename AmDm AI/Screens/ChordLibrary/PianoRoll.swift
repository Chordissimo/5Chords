import SwiftUI
import MusicTheory

class PianoKey(): Indentifiable {
    var id = UUID()
    var key: Int //number of the key in the chromatic scale where C=0
    var finger: Int
    var isLeftHand: Bool
    var isWhite: Bool 
    

    init(key: Int, finger: Int = 0, isLeftHand: Bool = false) {
        precondition([0..11].contains(key),"Piano roll: Key \(key) is out of range.")
        self.key = key
        self.finger = finger
        self.isWhite = [1,3,6,8,10].contains(self.key)
        self.isLeftHand = isLeftHand
    }
}

class PianoRollModel() {
    var chord: MusicTheory.Chord
    private var keys: [PianoKey]
    private var rightHandFingerLayout: [Int]
    private var leftHandFingerLayout: [Int]
    private var sortedKeys: [Int]

    init(chord: MusicTheory.Chord) {
        self.chord = chord
        self.sortedKeys = MusicTheory.Chord.Keys
        switch self.chord.Keys.count {
            case 2:
                rightHandFingerLayout = [1]
                leftHandFingerLayout = []
            case 3
        }
        for i in 0..<11 {
            self.keys.append(PianoKey[id: i])
        }
        for i in 0..<11 {
            self.keys.append(PianoKey[id: i])
        }
    }
}



struct PianoRoll: View {
    var numberOfOctaves: Int

    var body: som View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .top)) {
            GeometryReader { geometry in
                let whiteHeight = geometry.size.height
                let whiteHorizontalSpacing = Int(geometry.size.width * 0.01)
                let whiteWidth = Int((geometry.size.width - whiteHorizontalSpacing * numberOfOctaves) / numberOfOctaves)
                
                let blackHeight = Int(whiteHeight * 0.7)
                let blackWidth = Int(whiteWidth * 0.5)
                let blackHorizontalSpacing = blackWidth
                let blackOffset = whiteWidth - Int(blackWidth / 2)

                HStack(spacing: 0) {
                    ForEach(1..<14, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 5)
                            .foregroundColor(.white)
                            .frame(width: whiteWidth, height: whiteHeight)
                            .padding(.trailing, whiteHorizontalSpacing)
                    }
                }
                HStack(spacing: 0) {
                    ForEach(1..<10, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor([3 ? .clear : .black)
                            .frame(width: blackWidth, height: blackHeight)
                            .padding(.trailing, blackHorizontalSpacing)
                    }
                }
            }
        }
    }
}