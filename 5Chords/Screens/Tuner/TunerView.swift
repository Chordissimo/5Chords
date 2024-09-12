//
//  TunerView.swift
//  AmDm AI
//
//  Created by Anton on 11/05/2024.
//

import SwiftUI

struct TunerView: View {
    @Binding var isTunerPresented: Bool
    @ObservedObject var tunerModel = TunerModel(tuningType: .guitarStandard)
    @State var showString: Int = 0
    @State var leftIndicator: CGFloat = 1
    @State var rightIndicator: CGFloat = 1
    @State var selectedInstrument: Int = 0
    @State var selectedTuning: Int = 0
    @State var actualImageHeight: CGFloat = 0
    @State var actualImageWidth: CGFloat = 0

    var body: some View {
        VStack {
            GeometryReader { geometry in
                let smallSegmentHeight = geometry.size.height * 0.04
                let tallSegmentHeight = geometry.size.height * 0.07
                let instrumentImageOriginalWidth = 412.0
                let scaleFactor = geometry.size.width * 0.6 / instrumentImageOriginalWidth
                let tunerSegmentsSpacing = (geometry.size.width - 31) / 30

                ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
                    Color.gray5
                    
                    VStack {
                        // Close button on top
                        HStack {
                            Spacer()
                            Button {
                                isTunerPresented = false
                            } label: {
                                Image(systemName: "xmark")
                                    .resizable()
                                    .foregroundColor(.gray40)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)
                            }
                            .padding(.top, geometry.safeAreaInsets.top + 20)
                            .padding(.trailing, 20)
                            .padding(.bottom, 5)
                        }
                        
                        VStack {
                            // Instruments menu
                            HStack {
                                ForEach(tunerModel.tuningsCollection.instruments, id: \.self) { instrument in
                                    Button {
                                        selectedInstrument = tunerModel.tuningsCollection.instruments.firstIndex(of: instrument)!
                                        
                                        let tunings = tunerModel.tuningsCollection.tunings.filter { $0.instrumentType == tunerModel.tuningsCollection.instruments[selectedInstrument].instrumentType }

                                        selectedTuning = tunings.count > 0 ? tunerModel.tuningsCollection.tunings.firstIndex(where: { $0 == tunings[0] })! : 0
                                        
                                        tunerModel.switchTuning(tuningIndex: selectedTuning)
                                    } label: {
                                        VStack {
                                            Text(instrument.name.uppercased())
                                                .font(.system(size: 14))
                                                .fontWeight(.semibold)
                                                .fontWidth(.expanded)
                                                .foregroundStyle(.white)
                                                .padding(.horizontal, 20)
                                                .padding(.vertical, 15)
                                        }
                                        .background(selectedInstrument == tunerModel.tuningsCollection.instruments.firstIndex(of: instrument)! ? Color.gray20 : Color.clear)
                                        .clipShape(RoundedRectangle(cornerRadius: 30))
                                    }
                                }
                            }
                            .frame(height: 50)
                        }
                        
                        // Tunings menu
                        VStack {
                            let tunings = tunerModel.tuningsCollection.tunings.filter { $0.instrumentType == tunerModel.tuningsCollection.instruments[selectedInstrument].instrumentType }

                            if tunings.count > 0 && tunings.count <= 3 {
                                TuningsMenuView(tunerModel: tunerModel, selectedInstrument: $selectedInstrument, selectedTuning: $selectedTuning)
                                    .frame(height: 50)
                            } else {
                                ScrollView(.horizontal) {
                                    TuningsMenuView(tunerModel: tunerModel, selectedInstrument: $selectedInstrument, selectedTuning: $selectedTuning)
                                }
                                .scrollIndicators(.hidden)
                                .frame(height: 50)
                            }
                        }.padding(.bottom, 10)

                        // Tuning scale: center indicator
                        VStack {
                            Image(systemName: "triangle.fill")
                                .resizable()
                                .foregroundColor(.progressCircle)
                                .rotationEffect(Angle(degrees: 180))
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 28, height: 28)
                        }
                        
                        // Tuning scale: segments
                        ZStack {
                            VStack {
                                HStack(spacing: tunerSegmentsSpacing) {
                                    ForEach(tunerModel.scaleIntervals, id: \.self) { interval in
                                        Rectangle()
                                            .frame(width: 1, height: interval % 5 == 0 ? tallSegmentHeight : smallSegmentHeight)
                                            .foregroundColor(.secondaryText)
                                            .id(interval)
                                    }
                                }
                            }
                            HStack(spacing: 0) {
                                HStack {
                                    Spacer()
                                    Rectangle()
                                        .fill(Color.progressCircle.opacity(0.1))
                                        .frame(width: leftIndicator, height: tallSegmentHeight)
                                }
                                .frame(width: geometry.size.width / 2)
                                HStack {
                                    Rectangle()
                                        .fill(Color.progressCircle.opacity(0.1))
                                        .frame(width: rightIndicator, height: tallSegmentHeight)
                                    Spacer()
                                }
                                .frame(width: geometry.size.width / 2)
                            }

                        }
                        
                        // Tuneup, tune down, and checkmark
                        VStack {
                            let percentageDiff = abs(tunerModel.data.distance) / (tunerModel.data.semitoneRange / 2)
                            let segmentWeight = ((tunerModel.data.semitoneRange / 2) / 15) / (tunerModel.data.semitoneRange / 2)
                            ZStack {
                                HStack(spacing: 0) {
                                    Text("Tune up")
                                        .font(.system(size: 16))
                                        .foregroundStyle(tunerModel.data.distance < 0 && percentageDiff > segmentWeight / 2 ? .white : .clear)
                                        .frame(width: geometry.size.width / 2, alignment: .center)
                                                                        
                                    Text("Tune down")
                                        .font(.system(size: 16))
                                        .foregroundStyle(tunerModel.data.distance > 0 && percentageDiff > segmentWeight / 2 ? .white : .clear)
                                        .frame(width: geometry.size.width / 2, alignment: .center)
                                }
                                
                                Image(systemName: "checkmark")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 30)
                                    .foregroundStyle(percentageDiff <= segmentWeight / 2 ? .progressCircle : .clear)
                            }
                        }
                        
                        Spacer()
                    }
                    
                    // Instrument image
                    let asset = tunerModel.tuningsCollection.instruments[selectedInstrument].imageAssets[tunerModel.data.stringIndex]
                    Image(asset)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: geometry.size.width)
                        .scaleEffect(scaleFactor, anchor: .bottom)
                        .background {
                            GeometryReader { imageGeo in
                                Color.clear.onAppear {
                                    actualImageHeight = imageGeo.size.height
                                    actualImageWidth = imageGeo.size.width
                                }
                                .onChange(of: selectedInstrument) { _, _ in
                                    actualImageHeight = imageGeo.size.height
                                    actualImageWidth = imageGeo.size.width
                                }
                            }
                        }
                    
                    // String labels on sides of insturument image
                    HStack {
                        let stringsCount = tunerModel.tuningsCollection.tunings[selectedTuning].notes.count / 2
                        let leftStrings = tunerModel.tuningsCollection.tunings[selectedTuning].notes[0..<stringsCount]
                        let rightStrings = tunerModel.tuningsCollection.tunings[selectedTuning].notes[stringsCount...]
                        
                        ZStack {
                            ForEach(leftStrings.reversed(), id: \.id) { string in
                                let offsetY = tunerModel.tuningsCollection.instruments[selectedInstrument].noteLabelOffsets[string.id]
                                let posX = (geometry.size.width - actualImageWidth * scaleFactor) / 4
                                let posY = actualImageHeight * offsetY * scaleFactor
                                CircleView(
                                    isSelected: string.id == tunerModel.data.stringIndex - 1,
                                    label: string.name
                                )
                                .offset(x: 0, y: actualImageHeight * scaleFactor / -2 + 25)
                                .position(x: posX, y: posY)
                                .frame(height: 50)
                            }
                        }
                        .frame(width: (geometry.size.width - actualImageWidth * scaleFactor) / 2, height: actualImageHeight * scaleFactor)

                        Spacer()

                        ZStack {
                            ForEach(rightStrings, id: \.id) { string in
                                let offsetY = tunerModel.tuningsCollection.instruments[selectedInstrument].noteLabelOffsets[string.id]
                                let posX = (geometry.size.width - actualImageWidth * scaleFactor) / 4
                                let posY = actualImageHeight * offsetY * scaleFactor
                                CircleView(
                                    isSelected: string.id == tunerModel.data.stringIndex - 1,
                                    label: string.name
                                )
                                .offset(x: 0, y: actualImageHeight * scaleFactor / -2 + 25)
                                .position(x: posX, y: posY)
                                .frame(height: 50)
                            }
                        }
                        .frame(width: (geometry.size.width - actualImageWidth * scaleFactor) / 2, height: actualImageHeight * scaleFactor)
                    }
                    .frame(height: actualImageHeight * scaleFactor)
                }
                .ignoresSafeArea()
                .onAppear {
                    tunerModel.start()
                }
                .onDisappear {
                    tunerModel.stop()
                }
                .onChange(of: tunerModel.data) { _, data in
                    let w = abs(data.distance) >= data.semitoneRange ? Float(geometry.size.width / 2) : (abs(data.distance) / data.semitoneRange) * (Float(geometry.size.width / 2))
                    leftIndicator = data.distance < 0 ? CGFloat(w) : 1
                    rightIndicator = data.distance > 0 ? CGFloat(w) : 1
                }
            }
        }
    }
}

struct TuningsMenuView: View {
    @ObservedObject var tunerModel: TunerModel
    @Binding var selectedInstrument: Int
    @Binding var selectedTuning: Int
    
    var body: some View {
        LazyHStack(spacing: 15) {
            ForEach($tunerModel.tuningsCollection.tunings.wrappedValue) { tuning in
                if tuning.instrumentType == tunerModel.tuningsCollection.instruments[selectedInstrument].instrumentType {
                    let tuningIndex = tunerModel.tuningsCollection.tunings.firstIndex(where: { $0 == tuning })!
                    Button {
                        selectedTuning = tuningIndex
                        tunerModel.switchTuning(tuningIndex: selectedTuning)
                    } label: {
                        Text(tuning.name)
                            .font(.system(size: 14))
                            .fontWeight(.semibold)
                            .foregroundStyle(selectedTuning == tuningIndex ? .white : .gray40)
                    }
                }
            }
        }
    }
}

struct CircleView: View {
    var isSelected: Bool
    var label: String
    
    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(isSelected ? Color.clear : Color.gray40, lineWidth: 2)
                .fill(isSelected ? Color.progressCircle : Color.clear)
                .frame(height: 50)
            Text(label)
                .foregroundStyle(.gray40)
                .font(.system(size: 14))
                .fontWeight(.semibold)
                .fontWidth(.expanded)
        }
    }
}
