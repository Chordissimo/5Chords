//
//  Onboarding.swift
//  AmDm AI
//
//  Created by Anton on 20/05/2024.
//

import SwiftUI

struct SplashScreen: View {
    var completion: () -> Void
    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    @State var progress: CGFloat = 0
    let maxWidth = AppDefaults.screenWidth / 3.0 * 2.0
    
    var body: some View {
        ZStack {
            Color.gray5
            Image("five-chords-mobile-app")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: AppDefaults.screenWidth / 4 * 3)
                .clipShape(.circle)
            VStack {
                HStack(spacing: 0) {
                    Text("5")
                        .font(.custom("TitanOne", size: 60))
                        .foregroundStyle(.progressCircle)
                    
                    Text("CHORDS")
                        .font(.custom(SOFIA, size: 38))
                }
                .padding(.top, AppDefaults.topSafeArea + 50)
                
                Text("POWERED BY AI")
                    .font(.custom(SOFIA, size: 12))
                    .foregroundStyle(.secondaryText)
                    .padding(.bottom, AppDefaults.bottomSafeArea + 50)
                
                Spacer()
                
                ZStack(alignment: Alignment(horizontal: .leading, vertical: .center)) {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.gray40)
                        .frame(width: maxWidth, height: 5)
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.progressCircle.opacity(0.7))
                        .frame(width: progress, height: 5)
                }
                .padding(.bottom, AppDefaults.bottomSafeArea + 50)
            }
        }
        .ignoresSafeArea()
        .onReceive(timer) { _ in
            if progress <= maxWidth {
                withAnimation {
                    progress += 1
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    completion()
                }
            }
        }
    }
}
