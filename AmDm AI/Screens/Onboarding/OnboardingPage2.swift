//
//  OnboardingPage4.swift
//  AmDm AI
//
//  Created by Anton on 20/05/2024.
//

import SwiftUI
import SwiftyChords

struct OnboardingChords: Identifiable {
    var id = UUID().uuidString
    var key: Chords.Key
    var suffix: Chords.Suffix
}

struct OnboardingPage2: View {
    @AppStorage("showOnboarding") private var showOnboarding: Bool = true
    @State var animationStage = 0
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 1)
    var chords = [OnboardingChords]()
    var tunerSegments = Array(0..<100)
    @State var showPaywall = false
    
    init() {
        var _chords = [[Any]]()
        _chords.append([Chords.Key.a, Chords.Suffix.seven])
        _chords.append([Chords.Key.c, Chords.Suffix.minor])
        _chords.append([Chords.Key.d, Chords.Suffix.nineFlatFive])
        _chords.append([Chords.Key.g, Chords.Suffix.addNine])
        _chords.append([Chords.Key.f, Chords.Suffix.majorSeven])
        for _ in 0..<10 {
            for ch in _chords {
                let k = ch[0]
                let s = ch[1]
                self.chords.append(OnboardingChords(key: k as! Chords.Key, suffix: s as! Chords.Suffix))
            }
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            let imageWidth = geometry.size.width - 80
            let imageHeight = geometry.size.height * 0.6
            let chordWidth = (geometry.size.width) / 5 - 5
            let chordHeight = chordWidth / 2 * 3
            let tunerSegmentsSpacing = (geometry.size.width - 31) / 30
            let smallSegmentHeight = geometry.size.height * 0.04
            let tallSegmentHeight = geometry.size.height * 0.07
            
            ZStack {
                Color.gray5
                if animationStage >= 1 {
                    VStack(spacing: 20) {
                        if animationStage < 3 {
                            VStack {
                                Image(systemName: "book.fill")
                                    .resizable()
                                    .foregroundColor(.gray30)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 60, height: 60)
                                    .padding(.top, 60)
                                Text("CHORD TABS")
                                    .fontWeight(.semibold)
                                    .fontWidth(.expanded)
                                    .font(.system(size: 30))
                                VStack {
                                    Text("Explore different options")
                                        .fontWeight(.semibold)
                                        .font(.system(size: 16))
                                        .foregroundStyle(.secondaryText)
                                    Text("of playing any chord.")
                                        .fontWeight(.semibold)
                                        .font(.system(size: 16))
                                        .foregroundStyle(.secondaryText)
                                }
                            }
                        }
                        
                        if animationStage == 2 {
                            VStack {
                                ScrollViewReader { proxy in
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack {
                                            ForEach(chords) { ch in
                                                VStack {
                                                    Text(ch.key.display.symbol + ch.suffix.display.symbolized)
                                                        .foregroundStyle(Color.white)
                                                        .font(.system(size: 15))
                                                    ShapeLayerView(shapeLayer: createShapeLayer(chordPosition: Chords.guitar.matching(key: ch.key).matching(suffix: ch.suffix).first!, width: chordWidth, height: chordHeight))
                                                        .frame(width: chordWidth, height: chordHeight)
                                                }
                                                .id(ch.id)
                                            }
                                        }
                                    }
                                    .scrollDisabled(true)
                                    .onAppear {
                                        withAnimation {
                                            proxy.scrollTo(chords[chords.count - 1].id, anchor: .trailing)
                                        }
                                    }
                                }
                            }
                        }
                        
                        if animationStage == 3 {
                            VStack {
                                Image("custom.tuningfork.2")
                                    .resizable()
                                    .foregroundColor(.gray30)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 60, height: 60)
                                    .padding(.top, 60)
                                Text("TUNER")
                                    .fontWeight(.semibold)
                                    .fontWidth(.expanded)
                                    .font(.system(size: 30))
                                VStack {
                                    Text("Stay in tune")
                                        .fontWeight(.semibold)
                                        .font(.system(size: 16))
                                        .foregroundStyle(.secondaryText)
                                    Text("with our easy-to-use chromatic tuner")
                                        .fontWeight(.semibold)
                                        .font(.system(size: 16))
                                        .foregroundStyle(.secondaryText)
                                }
                            }
                            .transition(.push(from: .trailing))

                            VStack {
                                ZStack {
                                    ScrollViewReader { proxy in
                                        ScrollView(.horizontal, showsIndicators: false) {
                                            HStack(spacing: tunerSegmentsSpacing) {
                                                ForEach(tunerSegments, id: \.self) { s in
                                                    Rectangle()
                                                        .frame(width: 1, height: s % 5 == 0 ? tallSegmentHeight : smallSegmentHeight)
                                                        .foregroundColor(s >= 50 ? .clear : .secondaryText)
                                                        .id(s)
                                                }
                                            }
                                        }
                                        .padding(0)
                                        .onAppear {
                                            proxy.scrollTo(tunerSegments.last, anchor: .trailing)
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                                withAnimation {
                                                    proxy.scrollTo(tunerSegments.first, anchor: .leading)
                                                }
                                            }
                                        }
                                    }

                                    Spacer()
                                    
                                    VStack {
                                        Image(systemName: "triangle.fill")
                                            .resizable()
                                            .foregroundColor(.progressCircle)
                                            .rotationEffect(Angle(degrees: 180))
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 28, height: 28)
                                        RoundedRectangle(cornerRadius: 4)
                                            .foregroundColor(.progressCircle)
                                            .frame(width: 4, height: tallSegmentHeight)
                                            .padding(.vertical, 10)
                                        Image(systemName: "checkmark")
                                            .resizable()
                                            .foregroundColor(.progressCircle)
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 28, height: 28)
                                    }
                                }
                            }
                        }

                        Spacer()
                    }
                    .transition(.push(from: .top))
                    VStack {
                        Spacer()
                        Image("Guitar")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: imageWidth, height: imageHeight)
                    }
                    .transition(.push(from: .bottom))
                }
                VStack {
                    Spacer()
                    if animationStage == 3 {
                        NavigationLink(destination: AllSongs()) {
//                            NextButton()
                            Text("Next")
                                .fontWeight(.semibold)
                                .font(.system(size: 20))
                                .padding(20)
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.black)
//                                .frame(height: 50)
                                .background(.progressCircle, in: Capsule())
                                .padding(20)
                                .padding(.bottom, geometry.safeAreaInsets.bottom)
                        }
                        
                    } else {
                        Button {
                            if animationStage == 2 {
                                withAnimation(.bouncy(duration: 0.7)) {
                                    animationStage = 3
                                    showOnboarding = false
                                }
                            }
                        } label: {
//                            NextButton()
                            Text("Next")
                                .fontWeight(.semibold)
                                .font(.system(size: 20))
                                .padding(20)
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.black)
//                                .frame(height: 50)
                                .background(.progressCircle, in: Capsule())
                                .padding(20)
                                .padding(.bottom, geometry.safeAreaInsets.bottom)
                        }
                    }
                }
            }
            .ignoresSafeArea()
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.bouncy(duration: 0.7)) {
                        animationStage = 1
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        animationStage = 2
                    }
                }
            }
        }
    }
    
}
    
//struct NextButton: View {
//    var body: some View {
//        ZStack {
//            Color.clear.frame(height: 150)
//            Circle()
//                .foregroundColor(.white)
//                .frame(height: 60)
//            Image(systemName: "arrow.right")
//                .resizable()
//                .frame(width: 25, height: 20)
//                .foregroundColor(.gray5)
//        }
//    }
//}
