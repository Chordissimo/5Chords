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

struct PianoRoll: View {
    var numberOfOctaves: Int
    var chordTones: [Int]
    var model: PianoRollModel
    
    init(numberOfOctaves: Int, chordTones: [Int]) {
        self.numberOfOctaves = numberOfOctaves
        self.chordTones = chordTones
        self.model = PianoRollModel(numberOfOctaves: numberOfOctaves)
    }
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .top)) {
            GeometryReader { geometry in
                let whiteHeight = geometry.size.height
                let whiteHorizontalSpacing = geometry.size.width * 0.01
                let whiteWidth = (geometry.size.width - (whiteHorizontalSpacing * CGFloat(numberOfOctaves))) / CGFloat(numberOfOctaves * 7)
                
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


#Preview {
    PianoRoll(numberOfOctaves: 2, chordTones: [2,6,9,12])
        .frame(width: 300, height: 100)
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
