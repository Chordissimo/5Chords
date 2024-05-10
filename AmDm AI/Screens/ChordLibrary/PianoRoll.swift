import SwiftUI
import MusicTheory

class ChromaticKey: Int, Identifiable, Equatable {
    var id = UUID()
    var chromatic: Int // key as a number 0..12 from the chromatic scale
    var key: Int // key number C=0,D=1,E=2,F=3,G=4,A=5,B=6
    var keyName: String
    var accidential: Accidential = .none

    Enum Accidential: Int {
        case flat = -1
        case none = 0
        case sharp = 1
    }
    
    init(key: Int, accidential: Accidenttial) {
        preconditions([0..6).contains(key)
        self.key = key
        self.accidential = ((key == 3 || key == 6) && accidential == .sharp) || ((key == 0 || key == 3) && accidential == .flat) ? .none : accidential
        self.chromatic = (key <= 2 ? key * 2 : key * 2 - 1) + self.accidential.rawValue
        self.keyName = ["C","D","E","F","G","A","B"][key] + self.accidental == .sharp ? "#" : (self.accidental == .flat ? "b" : ")
    }
                      
    init(chromatic: Int) {
        precondition(![0..11].contains(chromatic),"ChromaticKey: Key \(key) is out of range.")
        self.chromatic = chromatic
        if chromatic <= 4 {
            self.key = Int(chromatic / 2)
            self.accidential = chromatic % 2 > 0 ? .sharp : .none
        } else {
            self.key = Int((chromatic + 1) / 2)
            self.accidential = (chromatic + 1) % 2 > 0 ? .sharp : .none
        }
        self.keyName = ["C","D","E","F","G","A","B"][key] + self.accidental == .sharp ? "#" : (self.accidental == .flat ? "b" : ")
    }
}

class PianoKey(): Indentifiable {
    var id = UUID()
    var key: ChromaticKey
    var finger: Int
    var isPressed: Bool
    var isLeftHand: Bool
    var isWhite: Bool

    init(chromatic: Int, isPressed: Bool = true, finger: Int = 0, isLeftHand: Bool = false) {
        precondition(![0..23].contains(chromatic),"PianoKey: Chromatic key \(key) is out of range.")
        self.key = ChromaticKey(chromatic: chromatic)
        self.finger = finger
        self.isWhite = ![1,3,6,8,10,13,15,18,20,22].contains(self.key)
        self.isLeftHand = isLeftHand
        self.isPressed = isPressed
    }    
}

class PianoRollModel() {
    var root: Int // root key of the chord as a number 0..12 from the chromatic scale
    var chordKeys: [Int] // array of chord keys as numbers 0..23 from 2 octave chromatic scale
    private var keys: [PianoKey]
    private var rightHandFingerLayout: [Int]
    private var leftHandFingerLayout: [Int]

    init(root: Int, chordKeys: [Int) {
        precondition(![0..23].contains(root),"PianoRollModel: Root rey \(key) is out of range.")
        precondition(chordKeys.count < 23 && chordKeys.filter { $0 < 0 || $0 > 23 }.count == 0,"PianoRollModel: Root rey \(key) is out of range.")
        self.chordKeys = Array(Set(chordKeys))
        self.root = root
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
        for i in 0..<23 {
            self.keys.append(key: PianoKey[id: i], isPressed: self.chordKeys.contains(i)
        }
    }
}


struct PianoRoll: View {
    var numberOfOctaves: Int
    var model: PianoRollModel([0,2,4,6])

    var body: some View {
        let whites = model.keys.filter{ $0.isWhite }
        let blacks = model.keys.filter{ !$0.isWhite }

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
                    ForEach(whites, id: \.self) { key in
                        RoundedRectangle(cornerRadius: 5)
                            .foregroundColor(.white)
                            .frame(width: whiteWidth, height: whiteHeight)
                            .padding(.trailing, whiteHorizontalSpacing)
                    }
                }

                HStack(spacing: 0) {
                    ForEach(whites, id: \.self) { key in
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(.black)
                            .frame(width: blackWidth, height: blackHeight)
                            .padding(.trailing, blackHorizontalSpacing)
                        if [3,10,13,22].contains(key.key) {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(.cleat)
                                .frame(width: blackWidth, height: blackHeight)
                                .padding(.trailing, blackHorizontalSpacing)
                        }
                    }
                }
            }
        }
    }
}
