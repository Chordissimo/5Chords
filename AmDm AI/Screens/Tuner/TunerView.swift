//
//  TunerView.swift
//  AmDm AI
//
//  Created by Anton on 11/05/2024.
//

import SwiftUI

struct TunerView: View {
    @Binding var isTunerPresented: Bool
    @StateObject var tunerModel = TunerModel(tuningType: .guitarStandard)
    @State var showString: Int = 0
    @State var leftIndicator: CGFloat = 1
    @State var rightIndicator: CGFloat = 1
    @State var selectedInstrument: Int = 0
    @State var selectedTuning: Int = 0

    var body: some View {
        VStack {
            GeometryReader { geometry in
                let smallSegmentHeight = geometry.size.height * 0.04
                let tallSegmentHeight = geometry.size.height * 0.07
                let guitarImageOriginalHeight = 737.0
                let guitarScaleFactor = geometry.size.height * 0.6 / guitarImageOriginalHeight
                let tunerSegmentsSpacing = (geometry.size.width - 31) / 30

                ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
                    Color.gray5

                    VStack {
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
                            HStack {
                                ForEach($tunerModel.tuningsCollection.instruments.wrappedValue, id: \.self) { instrument in
                                    Button {
                                        selectedInstrument = tunerModel.tuningsCollection.instruments.firstIndex(of: instrument)!
                                    } label: {
                                        VStack {
                                            Text(instrument.uppercased())
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
                        VStack {
                            ScrollView(.horizontal) {
                                LazyHStack {
                                    ForEach($tunerModel.tuningsCollection.tunings.wrappedValue) { tuning in
                                        if tuning.instrument.rawValue == tunerModel.tuningsCollection.instruments[selectedInstrument] {
                                            Text(tuning.name)
                                        }
                                    }
                                }
                            }
                            .defaultScrollAnchor(.center)
                            .frame(height: 50)
                        }

                        VStack {
                            Image(systemName: "triangle.fill")
                                .resizable()
                                .foregroundColor(.progressCircle)
                                .rotationEffect(Angle(degrees: 180))
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 28, height: 28)
                        }
                        
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
                        .overlay {
                            if tunerModel.data.distance != 0 {
                                HStack(spacing: 0) {
                                    HStack {
                                        Spacer()
                                        Rectangle()
                                            .fill(tunerModel.data.distance < 0 ? Color.progressCircle.opacity(0.1) : Color.clear)
                                            .frame(width: leftIndicator, height: tallSegmentHeight)
                                    }
                                    .frame(width: geometry.size.width / 2)
                                    HStack {
                                        Rectangle()
                                            .fill(tunerModel.data.distance > 0 ? Color.progressCircle.opacity(0.1) : Color.clear)
                                            .frame(width: rightIndicator, height: tallSegmentHeight)
                                        Spacer()
                                    }
                                    .frame(width: geometry.size.width / 2)
                                }
                            }
                        }
                        VStack {
                            Text("\(tunerModel.data.stringName)")
                                .font(.system(size: 50))
                                .fontWeight(.semibold)
                        }
                        Spacer()
                    }
                    
                    if tunerModel.data.stringIndex < 0 {
                        Image("Guitar").scaleEffect(guitarScaleFactor, anchor: .bottom)
                            .frame(width: geometry.size.width)
                    } else {
                        Image("g\(tunerModel.data.stringIndex)").scaleEffect(guitarScaleFactor, anchor: .bottom)
                            .frame(width: geometry.size.width)
                    }
                }
                .ignoresSafeArea()
                .onAppear {
//                    tunerModel.selfTest()
                    tunerModel.start()
                }
                .onDisappear {
                    tunerModel.stop()
                }
                .onChange(of: tunerModel.data) { oldValue, newValue in
                    let percentage = newValue.semitoneRange > abs(newValue.distance) ? newValue.semitoneRange / Float(geometry.size.width) / 2 : 1
                    let step = newValue.semitoneRange > 0 ? Float(geometry.size.width) / 2 / newValue.semitoneRange : 0
                    if newValue.semitoneRange > abs(newValue.distance) && step > 0 {
                        if newValue.distance < 0 {
                            leftIndicator = CGFloat(abs(newValue.distance) * step)
                            rightIndicator = 1
                        } else {
                            rightIndicator = CGFloat(newValue.distance * step)
                            leftIndicator = 1
                        }
                    }
                }
            }
        }
    }
}
