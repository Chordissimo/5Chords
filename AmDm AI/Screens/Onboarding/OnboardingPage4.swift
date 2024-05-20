//
//  OnboardingPage5.swift
//  AmDm AI
//
//  Created by Anton on 20/05/2024.
//

import SwiftUI

struct OnboardingPage4: View {
    var body: some View {
        GeometryReader { geometry in
            let imageWidth = geometry.size.width - 80
            let imageHeight = geometry.size.height * 0.6
            
            ZStack {
                Color.gray5
                VStack(spacing: 20) {
                    Image("custom.tuningfork.2")
                        .resizable()
                        .foregroundColor(.gray30)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .opacity(0.6)
                        .padding(.top, 100)
                    Text("TUNER")
                        .fontWeight(.semibold)
                        .fontWidth(.expanded)
                        .font(.system(size: 30))
                    Image("TunerBalance")
                        .resizable()
                        .frame(width: geometry.size.width * 2, height: 100)
                        .aspectRatio(contentMode: .fit)
                        .border(Color.white, width: 1)
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
    OnboardingPage4()
}
