//
//  Onboarding.swift
//  AmDm AI
//
//  Created by Anton on 20/05/2024.
//

import SwiftUI

struct SplashScreen: View {
    var body: some View {
        ZStack {
            Color.gray5
            VStack {
                Image("logo")
                    .padding(.bottom, 50)
                HStack(spacing: 0) {
                    Text("PRO")
                        .fontWeight(.semibold)
                        .fontWidth(.expanded)
                        .font(.system(size: 38))
                        .foregroundStyle(.progressCircle)
                    Text("CHORDS")
                        .fontWeight(.semibold)
                        .fontWidth(.expanded)
                        .font(.system(size: 38))
                }
                Text("POWERED BY AI")
                    .fontWeight(.semibold)
                    .fontWidth(.expanded)
                    .foregroundStyle(.secondaryText)
                    .font(.system(size: 11))
            }
        }
        .ignoresSafeArea()
    }
}
