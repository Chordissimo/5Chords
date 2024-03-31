//
//  RecordButton.swift
//  AmDm AI
//
//  Created by Anton on 31/03/2024.
//

import SwiftUI

struct RecordButton: View {
    @State var state: Bool = false
    var parentHeight = 0.0
    var action: () -> Void
    
    var body: some View {
        let whiteCircleHeight = parentHeight * 0.7
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
                    state.toggle()
                    action()
                }
            } label: {
                ZStack {
                    Circle()
                        .frame(width: state ? redCircleHeightTapped : redCircleHeight, height: state ? redCircleHeightTapped : redCircleHeight)
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
    func preview() -> Void {
//        print("isTapped")
    }
    return ZStack(alignment: .bottom){
        Color.black.ignoresSafeArea()
        RecordButton(parentHeight: 100) {
            preview()
        }
    }.ignoresSafeArea()
}
