//
//  SwiftUIView.swift
//  AmDm AI
//
//  Created by Anton on 29/05/2024.
//

import SwiftUI
import SwiftyChords


struct CircleOf5th: View {
    @ObservedObject var model: ChordLibraryModel
    var selectedMajor: Int
    var selectedMinor: Int
    var action: (Int, Int) -> Void
    
    var body: some View {
        GeometryReader { geometry in
            let outerBorderWidth: CGFloat = 2.0
            let strokeLineWidth: CGFloat = (geometry.size.width - outerBorderWidth) * 0.428
            let majorSegmentCircleSize: CGFloat = (geometry.size.width - outerBorderWidth) * 0.571
            let minorSegmentCircleSize: CGFloat = (geometry.size.width - outerBorderWidth) * 0.275
//            let majorLabelFontSize: CGFloat = (geometry.size.width - outerBorderWidth) * 0.063
//            let minorLabelFontSize: CGFloat = (geometry.size.width - outerBorderWidth) * 0.04
            let majorLabelFontSize: CGFloat = (geometry.size.width - outerBorderWidth) * 0.053
            let minorLabelFontSize: CGFloat = (geometry.size.width - outerBorderWidth) * 0.04
//            let logoSize: CGFloat = (geometry.size.width - outerBorderWidth) * 0.143
            let logoSize: CGFloat = (geometry.size.width - outerBorderWidth) * 0.2
            let innerWhiteCircleSize: CGFloat = geometry.size.width * 0.71
            let majorRadius = (geometry.size.width - outerBorderWidth) * 0.428
//            let minorRadius = (geometry.size.width - outerBorderWidth) * 0.257
            let minorRadius = (geometry.size.width - outerBorderWidth) * 0.267


            ZStack {
                Color.gray5
                
                Circle()
                    .fill(Color.white)
                    .frame(width: geometry.size.width, height: geometry.size.height)

                ForEach(0..<12) { index in
                    Circle()
                        .trim(from: 0.001, to: 1/CGFloat(12))
                        .rotation(.degrees(Double(CGFloat(index) * CGFloat(360/12))))
                        .rotation(.degrees(-90 - 360/24))
                        .stroke(
                            Color.progressCircle,
                            style: StrokeStyle(lineWidth: strokeLineWidth, lineCap: .butt)
                        )
                        .saturation(index == selectedMajor ? 0.5 : 1)
                        .frame(width: majorSegmentCircleSize, height: majorSegmentCircleSize)
                    
                }
                
                Circle()
                    .fill(Color.white)
                    .frame(width: innerWhiteCircleSize, height: innerWhiteCircleSize)
                
                ForEach(0..<12) { index in
                    Circle()
                        .trim(from: 0.001, to: 1/CGFloat(12))
                        .rotation(.degrees(Double(CGFloat(index) * CGFloat(360/12))))
                        .rotation(.degrees(-90 - 360/24))
                        .stroke(
                            index == selectedMinor ? Color.gray20 : Color.gray10,
                            style: StrokeStyle(lineWidth: strokeLineWidth, lineCap: .butt)
                        )
                        .saturation(index == selectedMinor ? 0.5 : 1)
                        .frame(width: minorSegmentCircleSize, height: minorSegmentCircleSize)
                    
                }
                
                ForEach(0..<12) { index in
                    let angleRadians = Double(index) * Double.pi / 6
                    let majorOffsetX = majorRadius * Double(sin(CGFloat(angleRadians)))
                    let majorOffsetY = majorRadius * Double(cos(CGFloat(angleRadians))) * -1
                    let minorOffsetX = minorRadius * Double(sin(CGFloat(angleRadians)))
                    let minorOffsetY = minorRadius * Double(cos(CGFloat(angleRadians))) * -1
                    let majorLabel = model.majorKeysAlt[index] != "" ? model.majorKeys[index] + " " + model.majorKeysAlt[index] : model.majorKeys[index]
                    let minorLabel = model.minorKeysAlt[index] != "" ? model.minorKeys[index] + " " + model.minorKeysAlt[index] : model.minorKeys[index]

                    Text(majorLabel)
                        .lineLimit(2)
                        .font(.custom(SOFIA, size: majorLabelFontSize))
                        .fontWidth(.expanded)
                        .foregroundStyle(.gray10)
                        .frame(width: 30)
                        .offset(x: majorOffsetX, y: majorOffsetY)
                        .onTapGesture {
                            action(index, -1)
                        }
                    
                    Text(minorLabel)
                        .lineLimit(2)
                        .font(.custom(SOFIA, size: minorLabelFontSize))
                        .fontWidth(.expanded)
                        .foregroundStyle(.gray40)
                        .frame(width: 35)
                        .offset(x: minorOffsetX, y: minorOffsetY)
                        .onTapGesture {
                            action(-1, index)
                        }
                }
                
                Circle()
                    .fill(Color.progressCircle)
                    .frame(height: logoSize)
                Text("5")
                    .font(.custom("TitanOne", size: 35))
                    .foregroundStyle(.gray10)
                
//                Image("logo3")
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(height: logoSize)
                
            }
            .ignoresSafeArea()
        }
    }
}
