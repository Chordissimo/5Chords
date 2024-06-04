//
//  ChordLibrary.swift
//  AmDm AI
//
//  Created by Anton on 30/05/2024.
//

import SwiftUI
import SwiftyChords

struct ChordLibrary: View {
    @Binding var isLibraryPresented: Bool
    @State var selectedMajor: Int = -1
    @State var selectedMinor: Int = -1
    @State var chords: [ChordPosition] = []
    @State var showMoreShapes: Bool = false
    @State var showSearchResults: Bool = false
    @ObservedObject var model = ChordLibraryModel()
    @State var searchText: String = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .top)) {
            GeometryReader { geometry in
                let twoThirdsScreenHeight = geometry.size.height / 3 * 2
                let oneThirdsScreenHeight = geometry.size.height / 3
                let circleOf5thSize = geometry.size.height * 0.4
                let chordHeight = oneThirdsScreenHeight * 0.65
                let chordWidth = chordHeight / 6 * 5
                
                VStack(spacing: 0) {
                    VStack(spacing: 20) {
                        // Close and back buttons on top
                        HStack {
                            VStack {
                                if showMoreShapes || showSearchResults {
                                    Button {
                                        searchText = ""
                                        isFocused = false
                                        chords = []
                                        withAnimation(.linear(duration: 0.2)) {
                                            selectedMajor = -1
                                            selectedMinor = -1
                                            showMoreShapes = false
                                            showSearchResults = false
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                                model.clearSearchResults()
                                            }
                                        }
                                        
                                    } label: {
                                        Image(systemName: "chevron.left")
                                            .resizable()
                                            .foregroundColor(.gray40)
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 20, height: 20)
                                    }
                                    .padding(.horizontal,20)
                                }
                            }
                            Spacer()
                            Button {
                                isLibraryPresented = false
                            } label: {
                                Image(systemName: "xmark")
                                    .resizable()
                                    .foregroundColor(.gray40)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)
                            }
                            .padding(.trailing, 20)
                        }
                        
                        // Titile
                        VStack {
                            Text("GUITAR CHORD SHAPES")
                                .font(.system(size: 20))
                                .fontWeight(.semibold)
                                .fontWidth(.expanded)
                                .foregroundStyle(.white)
                        }
                        
                        // Search field
                        VStack {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundStyle(.gray40)
                                    .padding(.leading,10)
                                TextField("Search", text: $searchText)
                                    .focused($isFocused)
                                    .onChange(of: searchText) {
                                        model.searchChords(searchString: searchText)
                                        if chords.count > 0 {
                                            chords = []
                                        }
                                    }
                                if searchText != "" {
                                    Button {
                                        searchText = ""
                                        chords = []
                                        model.clearSearchResults()
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.secondaryText)
                                    }
                                    .padding(.trailing,10)
                                }
                                Spacer()
                            }
                            .frame(height: 35)
                            .background(Color.search)
                            .clipShape(.rect(cornerRadius: 10))
//                            ChordSearchView() { searchString in
//                                model.searchChords(searchString: searchString)
//                            }
                            .onTapGesture {
                                if !showSearchResults {
                                    showSearchResults = true
                                }
                            }
                        }
                        .padding(.horizontal,20)
                        .frame(width: geometry.size.width)
                        
                        // search results
                        if showSearchResults {
                            VStack {
                                ChordSuffixes(model: model) { selectedKey, selectedSuffix in
                                    chords = Chords.guitar.matching(key: selectedKey).matching(suffix: selectedSuffix)
                                }
                            }
                        }
                        
                        // Circle of 5th and the list of chord suffixes
                        if !showSearchResults {
                            VStack {
                                if showMoreShapes {
                                    ChordSuffixes(model: model) { selectedKey, selectedSuffix in
                                        chords = Chords.guitar.matching(key: selectedKey).matching(suffix: selectedSuffix)
                                    }
//                                    .transition(.asymmetric(
//                                        insertion: .move(edge: .trailing),
//                                        removal: .move(edge: .trailing))
                                    .transition(.asymmetric(
                                        insertion: .push(from: .trailing),
                                        removal: .push(from: .leading))
                                    )
                                } else {
                                    CircleOf5th(model: model, selectedMajor: selectedMajor, selectedMinor: selectedMinor) { major, minor in
                                        selectedMajor = major
                                        selectedMinor = minor
                                        model.searchChordsBy(
                                            key: model.getChordKeyByIndex(selectedMajor: selectedMajor, selectedMinor: selectedMinor),
                                            groups: selectedMajor != -1 ? [.major, .suspended, .augmented, .other] : [.minor, .diminished, .suspended]
                                        )
                                        chords = Chords.guitar.matching(key: model.chordSearchResults[0].key).matching(suffix: model.chordSearchResults[0].suffix)
                                        withAnimation(.linear(duration: 0.2)) {
                                            showMoreShapes = true
                                        }
                                    }
//                                    .transition(.asymmetric(
//                                        insertion: .move(edge: .leading),
//                                        removal: .move(edge: .leading))
                                    .transition(.asymmetric(
                                        insertion: .push(from: .leading),
                                        removal: .push(from: .trailing))
                                    )
                                    .frame(width: circleOf5thSize, height: circleOf5thSize)
                                }
                            }
                            .frame(width: geometry.size.width, height: circleOf5thSize)
                            .padding(.top,20)
                        }
                        
                        Spacer()
                    }
                    .frame(height: twoThirdsScreenHeight)
                    
                    if !showSearchResults {
                        if selectedMajor < 0 && selectedMinor < 0 {
                            // Hint when no key is selected
                            VStack {
                                ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
                                    Triangle()
                                        .fill(Color.gray20)
                                        .frame(width: 160, height: 75)
                                    
                                    Text("Tap the key to see chord shapes.")
                                        .frame(width: 250, height: 60)
                                        .foregroundStyle(.white)
                                        .opacity(0.7)
                                        .multilineTextAlignment(.center)
                                        .background {
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(Color.gray20)
                                        }
                                }
                            }
                            .transition(.move(edge: .bottom))
                            
                            Spacer()
                            
                        }
                    }
                        // Chord shapes in a scroll view
                        VStack {
                            if chords.count > 0 {
                                Text(chords[0].key.display.symbol + chords[0].suffix.display.short)
                                    .foregroundStyle(.white)
                                    .font(.system(size: 24))
                                    .fontWeight(.semibold)
                                    .padding(.vertical, 15)
                            }
                            ScrollViewReader { proxy in
                                ScrollView(.horizontal) {
                                    HStack(spacing: 0) {
                                        ForEach(chords) { ch in
                                            VStack {
                                                ShapeLayerView(shapeLayer: createShapeLayer(
                                                    chordPosition: ch,
                                                    width: chordWidth,
                                                    height: chordHeight
                                                ))
                                                .frame(width: chordWidth, height: chordHeight)
                                                .scrollTransition(.animated, axis: .horizontal) { content, phase in
                                                    content
                                                        .opacity(phase.isIdentity ? 1.0 : 0.6)
                                                        .scaleEffect(phase.isIdentity ? 1.0 : 0.6)
                                                }
                                            }
                                            .frame(width: geometry.size.width)
                                            .id(chords.firstIndex(of: ch)!)
                                            
                                        }
                                    }
                                }
                                .defaultScrollAnchor(.center)
                                .scrollTargetBehavior(.paging)
                                .frame(height: oneThirdsScreenHeight * 0.75)
                                .scrollIndicators(.hidden)
                                .onAppear {
                                    if chords.count > 0 {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                                            withAnimation {
                                                proxy.scrollTo(0, anchor: .center)
                                            }
                                        }
                                    }
                                }
                                .onChange(of: chords) { _, newValue in
                                    if newValue.count > 0 {
                                        proxy.scrollTo(chords.count - 1, anchor: .center)
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                                            withAnimation {
                                                proxy.scrollTo(0, anchor: .center)
                                            }
                                        }
                                    }
                                }
                            }
                            Spacer()
                        }
                        .frame(height: oneThirdsScreenHeight)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(Color.gray5, ignoresSafeAreaEdges: .vertical)
    }
}


struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        
        return path
    }
}
