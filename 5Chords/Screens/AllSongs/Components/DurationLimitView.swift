//
//  DurationLimitView.swift
//  AmDm AI
//
//  Created by Anton on 11/07/2024.
//

import SwiftUI

struct DurationLimitView: View {
    var isLimited: Bool
    @State var showMessage: Bool = false
    
    var body: some View {
        let limitedMessage = "Recording time is limited to \(AppDefaults.LIMITED_DURATION) minute.\nUpgrade your subscription to increase the limit."
        let subscribedMessage = "Recording time is limited to \(AppDefaults.MAX_DURATION) minutes."
        ZStack {
            if showMessage {
                VStack(spacing: 0) {
                    VStack {
                        Text(isLimited ? limitedMessage : subscribedMessage)
                            .foregroundStyle(Color.gray5)
                            .font(.custom(SOFIA, size: 16))
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .background {
                        Color.white
                    }
                    .clipShape(.rect(cornerRadius: 16))
                    .transition(.opacity)
                    
                    Triangle()
                        .fill(Color.white)
                        .frame(width: 30, height: 15)
                        .rotationEffect(Angle(degrees: 180.0))
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.linear(duration: 0.3)) {
                    showMessage = true
                }
            }
        }

    }
}
