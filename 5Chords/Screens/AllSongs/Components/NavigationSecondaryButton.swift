//
//  NavigationSecondaryButton.swift
//  AmDm AI
//
//  Created by Anton on 17/07/2024.
//

import SwiftUI

struct NavigationSecondaryButton: View {
    var imageName: String
    var action: () -> Void
    
    var body: some View {
        GeometryReader { geometry  in
            let whiteCircleHeight = geometry.size.height
            let grayCircleHeight = whiteCircleHeight - 2
            let redCircleHeight = grayCircleHeight - 5
            let imageHeight = redCircleHeight * 0.8
            let imageLogoWidth = redCircleHeight * 0.8
            
            ZStack {
                if imageName == "" {
                    Color.clear
                } else {
                    Circle()
                        .frame(width: whiteCircleHeight, height: whiteCircleHeight)
                        .foregroundStyle(Color.clear)
                    Circle()
                        .frame(width: grayCircleHeight, height: grayCircleHeight)
                        .foregroundStyle(Color.customDarkGray)
                    
                    Button {
                        withAnimation {
                            action()
                        }
                    } label: {
                        ZStack {
                            getSafeImage(named: imageName)
                                .resizable()
                                .foregroundColor(.white)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: imageLogoWidth, height: imageHeight)
                                .opacity(0.6)
                            
                        }
                    }
                }
            }
            .frame(width: geometry.size.width)
        }
    }
}
