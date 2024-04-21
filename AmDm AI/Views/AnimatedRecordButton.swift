//
//  AnimatedRecordButton.swift
//  AmDm AI
//
//  Created by Anton on 21/04/2024.
//

import SwiftUI

struct AnimatedRecordButton: View {
    var body: some View {
        GeometryReader { geometry  in
            let whiteCircleHeight = geometry.size.height * 0.65
            let grayCircleHeight = whiteCircleHeight - 5
            let redCircleHeight = grayCircleHeight - 5
            
            ZStack {
                Circle()
                    .frame(width: whiteCircleHeight, height: whiteCircleHeight)
                    .foregroundStyle(Color.white)
                Circle()
                    .frame(width: grayCircleHeight, height: grayCircleHeight)
                    .foregroundStyle(Color.customDarkGray)
                Circle()
                    .frame(width: redCircleHeight, height: redCircleHeight)
                    .foregroundStyle(Color.red)
            }
            .frame(width: geometry.size.width)
        }
    }
}

#Preview {
    AnimatedRecordButton()
}
