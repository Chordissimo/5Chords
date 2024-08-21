//
//  NavigationPrimaryButton.swift
//  AmDm AI
//
//  Created by Anton on 17/07/2024.
//

import SwiftUI

struct NavigationPrimaryButton: View {
    var imageName: String
    @Binding var recordStarted: Bool
    @Binding var duration: TimeInterval
    var durationLimit: Int
    var action: () -> Void
    @State var counter = -1
    @State var throb = false
    @AppStorage("isLimited") var isLimited: Bool = false
    
    var body: some View {
        GeometryReader { geometry  in
            let whiteCircleHeight = geometry.size.height
            let grayCircleHeight = whiteCircleHeight - 2
            let redCircleHeight = grayCircleHeight - 5
            let redSquareHeight = redCircleHeight * 0.5
            let imageHeight = redCircleHeight * 0.6
            let imageLogoWidth = redCircleHeight * 0.6
            
            ZStack {
                Circle()
                    .frame(width: whiteCircleHeight, height: whiteCircleHeight)
                    .foregroundStyle(Color.white)
                Circle()
                    .frame(width: grayCircleHeight, height: grayCircleHeight)
                    .foregroundStyle(Color.customDarkGray)
                Button {
                    withAnimation {
                        action()
                    }
                } label: {
                    ZStack {
                        if !recordStarted {
                            Circle()
                                .frame(width: redCircleHeight, height: redCircleHeight)
                                .foregroundStyle(Color.red)
                                .onAppear {
                                    throb = false
                                    counter = -1
                                }
                            Image(imageName)
                                .resizable()
                                .foregroundColor(.white)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: imageLogoWidth, height: imageHeight)
                                .opacity(0.6)
                                .transition(.scale)
                        } else {
                            RoundedRectangle(cornerRadius: 5)
                                .frame(width: redSquareHeight, height: redSquareHeight)
                                .foregroundStyle(counter == 0 ? Color.secondaryText : Color.red)
                                .opacity(counter > 0 ? 0.5 : 1)
                                .animation(.easeOut(duration: 0.5).repeatCount(18, autoreverses: true), value: throb)
                        }
                    }
                }
                .disabled(counter == 0)
            }
            .clipShape(Rectangle())
            .frame(width: geometry.size.width)
            .onChange(of: duration) { _, _ in
                if duration >= Double(durationLimit - 10) {
                    throb = true
                    counter = Int(Double(durationLimit) - duration)
                }
            }
            .overlay {
                if !isLimited && counter > 0 {
                    DurationLimitView(isLimited: isLimited)
                        .offset(x: 0, y: -320)
                }
            }
        }
    }
}
