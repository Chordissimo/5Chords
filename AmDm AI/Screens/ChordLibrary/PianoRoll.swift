import SwiftUI
import MusicTheory

class ChromaticKey: Identifiable {
    var id = UUID()
    var chromatic: Int // key as a number 0..12 from the chromatic scale
    var key: Int // key number C=0,D=1,E=2,F=3,G=4,A=5,B=6
    var keyName: String
    var accidential: Accidential = .none
    
    enum Accidential: Int {
        case flat = -1
        case none = 0
        case sharp = 1
    }
    
    init(key: Int, accidential: Accidential) {
        if key < 0 || key > 6 {
            print("ChromaticKey: Key \(key) is out of 0...6 range.")
            fatalError()
        }
        self.key = key
        self.accidential = ((key == 3 || key == 6) && accidential == .sharp) || ((key == 0 || key == 3) && accidential == .flat) ? .none : accidential
        self.chromatic = (key <= 2 ? key * 2 : key * 2 - 1) + self.accidential.rawValue
        let acc = accidential == .sharp ? "#" : (accidential == .flat ? "b" : "#")
        self.keyName = ["C","D","E","F","G","A","B"][key] + acc
    }
    
    init(chromatic: Int) {
        if chromatic < 0 || chromatic > 11 {
            print("ChromaticKey: Chromatic index \(chromatic) is out of 0...11 range.")
            fatalError()
        }
        self.chromatic = chromatic
        if chromatic <= 4 {
            self.key = Int(chromatic / 2)
            self.accidential = chromatic % 2 > 0 ? .sharp : .none
        } else {
            self.key = Int((chromatic + 1) / 2)
            self.accidential = (chromatic + 1) % 2 > 0 ? .sharp : .none
        }
        let acc = accidential == .sharp ? "#" : (accidential == .flat ? "b" : "#")
        self.keyName = ["C","D","E","F","G","A","B"][key] + acc
    }
}

class PianoKey: ChromaticKey {
    var finger: Int
    var isPressed: Bool
    var isLeftHand: Bool
    var isWhite: Bool
    
    init(chromatic: Int, isPressed: Bool = true, finger: Int = 0, isLeftHand: Bool = false) {
        self.finger = finger
        self.isWhite = !([1,3,6,8,10].contains(chromatic))
        self.isLeftHand = isLeftHand
        self.isPressed = isPressed
        super.init(chromatic: chromatic)
    }
}

class PianoRollModel {
    var numberOfOctaves: Int
    var keys = [PianoKey]()
    
    init(numberOfOctaves: Int) {
        self.numberOfOctaves = numberOfOctaves
        for _ in 0..<numberOfOctaves {
            for i in 0...11 {
                self.keys.append(PianoKey(chromatic: i))
            }
        }
    }
}

struct ChordVariation: Identifiable {
    var id = UUID()
    var bassTones: [Int]
    var trebleTones: [Int]
}

struct PianoChordView: View {
    var chordTones: [Int]
    var model: PianoRollModel
    var numberOfOctaves: Int = 2
    
    init(bassTones: [Int], trebleTones: [Int]) {
        self.model = PianoRollModel(numberOfOctaves: 2)
        self.chordTones = bassTones + trebleTones.map { return $0 + 12}
    }
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .top)) {
            GeometryReader { geometry in
                let whiteHeight = geometry.size.height
                let whiteHorizontalSpacing = geometry.size.width * 0.01
                let whiteWidth = (geometry.size.width - 50 - (whiteHorizontalSpacing * CGFloat(numberOfOctaves))) / CGFloat(numberOfOctaves * 7)
                
                let blackHeight = whiteHeight * 0.7
                let blackWidth = whiteWidth * 0.5
                let blackHorizontalSpacing = blackWidth + whiteHorizontalSpacing
                let blackOffset = whiteWidth - blackWidth / 2 + whiteHorizontalSpacing / 2
                
                
                HStack(spacing: 0) {
                    ForEach(0..<model.keys.count, id: \.self) { i in
                        if(model.keys[i].isWhite) {
                            Rectangle()
                                .foregroundColor(chordTones.contains(i) ? .green : .white)
                                .frame(width: whiteWidth, height: whiteHeight)
                                .clipShape(
                                    .rect(
                                        topLeadingRadius: 0,
                                        bottomLeadingRadius: 5,
                                        bottomTrailingRadius: 5,
                                        topTrailingRadius: 0,
                                        style: .circular
                                    )
                                )
                                .padding(.trailing, whiteHorizontalSpacing)
                        }
                    }
                }
                
                HStack(spacing: 0) {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: blackOffset, height: blackHeight)

                    ForEach(1..<model.keys.count, id: \.self) { i in
                        if !model.keys[i].isWhite {
                           Rectangle()
                                .foregroundColor(chordTones.contains(i) ? .green : .black)
                                .frame(width: blackWidth, height: blackHeight)
                                .clipShape(
                                    .rect(
                                        topLeadingRadius: 0,
                                        bottomLeadingRadius: 3,
                                        bottomTrailingRadius: 3,
                                        topTrailingRadius: 0,
                                        style: .circular
                                    )
                                )
                                .padding(.trailing, blackHorizontalSpacing)
                        }
                        if [0,4,12,16].contains(i) {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: blackWidth, height: blackHeight)
                                .padding(.trailing, blackHorizontalSpacing)
                        }
                    }
                }
            }
        }
    }
}

struct PianoChordVariationsView: View {
    var chord: Chord
    var chordVariations: [ChordVariation]
    
    init(chord: Chord) {
        self.chord = chord
        
        var tones = chord.keys.map { $0.type.rawValue }.sorted()
        let bassTonesCount = tones.count % 2 == 0 ? tones.count / 2 : (tones.count - 1) / 2
        tones.remove(at: 0)
        var result = [ChordVariation]()
        
        var bassTones = combine(lists: [Array(tones[..<(bassTonesCount - 1)]), Array(tones[(bassTonesCount - 1)...])])
        for b in bassTones {
            let t = tones.filter { !b.contains($0)}
            var bb = b
            bb.insert(chord.key.type.rawValue, at: 0)
            result.append(ChordVariation(bassTones: bb, trebleTones: t))
        }
        self.chordVariations = result
    }
    
    var body: some View {
        ZStack {
            ScrollView(.vertical) {
                VStack {
                    ForEach(chordVariations) { ch in
                        PianoChordView(bassTones: ch.bassTones, trebleTones: ch.trebleTones)
                            .frame(width: 250, height: 70)
                    }
                }
            }
        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .padding()
    }
}


#Preview {
    let m13 = ChordType(
      third: .minor,
      seventh: .dominant,
      extensions: [
        ChordExtensionType(type: .thirteenth)
      ])
    let cm13 = Chord(type: m13, key: Key(type: .c))
    return PianoChordVariationsView(chord: cm13)
}

//    private var rightHandFingerLayout: [Int]
//    private var leftHandFingerLayout: [Int]


//        self.rightHandFingerLayout = []
//        self.leftHandFingerLayout = []
//        switch self.chordKeys.count {
//        case 1:
//            self.rightHandFingerLayout = [1]
//            self.leftHandFingerLayout = [1]
//        case 2:
//            self.rightHandFingerLayout = [1]
//            let distance = self.chordKeys[1] - self.chordKeys[0]
//
//            if distance <= 4 {
//                self.leftHandFingerLayout = [1,2]
//            } else if distance > 4 && distance < 10 {
//                self.rightHandFingerLayout = [1,4]
//            } else {
//                self.rightHandFingerLayout = [1,5]
//            }
//
//        case 3:
//            self.rightHandFingerLayout = [1]
//            self.leftHandFingerLayout = [1,3,5]
//        case 4:
//            self.rightHandFingerLayout = [1]
//            self.leftHandFingerLayout = [1,3,5]
//        default:
//            self.rightHandFingerLayout = []
//            self.leftHandFingerLayout = []
//        }
