//
//  RecordButton.swift
//  AmDm AI
//
//  Created by Anton on 31/03/2024.
//

import SwiftUI

struct RecordButton: View {
    var height: Double
    @Binding var recordStarted: Bool
    var action: () -> Void
    
    var body: some View {
        let whiteCircleHeight = height * 0.7
        let grayCircleHeight = whiteCircleHeight - 5
        let redCircleHeight = grayCircleHeight - 5
        let redSquareHeight = redCircleHeight * 0.5
        let redCircleHeightTapped = redSquareHeight - 5
        
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
                    Circle()
                        .frame(width: recordStarted ? redCircleHeightTapped : redCircleHeight, height: recordStarted ? redCircleHeightTapped : redCircleHeight)
                        .foregroundStyle(Color.red)
                    
                    RoundedRectangle(cornerRadius: 5)
                        .frame(width: redSquareHeight, height: redSquareHeight)
                        .foregroundStyle(Color.red)
                }
            }
        }
        .clipShape(Rectangle())
    }
}

#Preview {
    @State var recordStarted = false
    func preview() -> Void {
        //        print("isTapped")
    }
    return ZStack {
        Color.black.ignoresSafeArea()
        VStack {
            RecordButton(height: 100, recordStarted: $recordStarted) {
                preview()
            }
        }.frame(height: 100).border(Color.white, width: 1)
    }
    
}
