import SwiftUI
import MusicTheory

class PianoKey(): Indentifiable {
    var id = UUID()
    var key: Int //number of the key in the chromatic scale where C=0
    var finger: Int
    var isPressed: Bool
    var isLeftHand: Bool
    var isWhite: Bool

    init(key: Int, isPressed: Bool = true, finger: Int = 0, isLeftHand: Bool = false) {
        precondition([0..11].contains(key),"Piano roll: Key \(key) is out of range.")
        self.key = key // the key number in the to octave chromatic scale from C1=0 to B2=23
        self.finger = finger
        self.isWhite = [1,3,6,8,10].contains(self.key)
        self.isLeftHand = isLeftHand
        self.isPressed = isPressed
    }
}

class PianoRollModel() {
    var chord: [Int]
    private var keys: [PianoKey]
    private var rightHandFingerLayout: [Int]
    private var leftHandFingerLayout: [Int]

    init(chord: [Int) {
        self.chord = chord.sorted()
        self.sortedKeys = MusicTheory.Chord.Keys
        switch self.chord.count {
            case 1:
                rightHandFingerLayout = [1]
                leftHandFingerLayout = [1]
            case 2:
                rightHandFingerLayout = [1]
                let distance = chord[1] - chord[0]
                if distance <= 4 {
                    leftHandFingerLayout = [1,2]
                } else if distance > 4 && distance < 10 {
                    rightHandFingerLayout = [1,4]
                } else {
                    rightHandFingerLayout = [1,5]
                }
            case 3:
                rightHandFingerLayout = [1]
                leftHandFingerLayout = [1,3,5]
            case 4:
                rightHandFingerLayout = [1]
                leftHandFingerLayout = [1,3,5]
            
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

    var body: some View {
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
