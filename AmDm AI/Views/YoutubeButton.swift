//
//  SwiftUIView.swift
//  AmDm AI
//
//  Created by Anton on 21/04/2024.
//

import SwiftUI

struct YoutubeButton: View {
    var action: () -> Void
    
    var body: some View {
        GeometryReader { geometry  in
            let whiteCircleHeight = 59.0
//            let whiteCircleHeight = geometry.size.height * 0.65
            let grayCircleHeight = whiteCircleHeight - 5
            let redCircleHeight = grayCircleHeight - 5
            let ytLogoHeight = redCircleHeight * 0.4
            let ytLogoWidth = redCircleHeight * 0.5
            
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
                            .frame(width: redCircleHeight, height: redCircleHeight)
                            .foregroundStyle(Color.red)
                        Image("youtube.custom")
                            .resizable()
                            .frame(width: ytLogoWidth, height: ytLogoHeight)
                            .foregroundColor(.white)
                            .opacity(0.6)
                            .aspectRatio(contentMode: .fit)
                    }
                }
            }
            .frame(width: geometry.size.width)
        }
    }
}

#Preview {
    YoutubeButton() {
        print("Clicked")
    }
}
