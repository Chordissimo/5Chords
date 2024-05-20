//
//  OnboardingPage4.swift
//  AmDm AI
//
//  Created by Anton on 20/05/2024.
//

import SwiftUI

struct OnboardingPage3: View {
    var body: some View {
        GeometryReader { geometry in
            let imageWidth = geometry.size.width - 80
            let imageHeight = geometry.size.height * 0.6
            
            ZStack {
                Color.gray5
                VStack(spacing: 20) {
                    Image(systemName: "book.fill")
                        .resizable()
                        .foregroundColor(.gray30)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .padding(.top, 100)
                    Text("CHORD TABS")
                        .fontWeight(.semibold)
                        .fontWidth(.expanded)
                        .font(.system(size: 30))
                    VStack {
                        Text("Explore different options")
                            .fontWeight(.semibold)
                            .font(.system(size: 16))
                            .foregroundStyle(.secondaryText)
                        Text("of playing any chord.")
                            .fontWeight(.semibold)
                            .font(.system(size: 16))
                            .foregroundStyle(.secondaryText)
                    }
                    Spacer()
                }
                VStack {
                    Spacer()
                    Image("Guitar")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: imageWidth, height: imageHeight)
                }
                VStack {
                    Spacer()
                    ZStack {
                        Color.clear.frame(height: 150)
                        Circle()
                            .foregroundColor(.white)
                            .frame(height: 60)
                        Image(systemName: "arrow.right")
                            .resizable()
                            .frame(width: 25, height: 20)
                            .foregroundColor(.gray5)
                    }
                }

            }
            .ignoresSafeArea()
        }
    }
}

#Preview {
    OnboardingPage3()
}
