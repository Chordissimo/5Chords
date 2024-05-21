//
//  AppRoot.swift
//  AmDm AI
//
//  Created by Anton on 21/05/2024.
//

import SwiftUI

struct AppRoot: View {
    @State var showOnboarding = true
    @State var loadingStage = 0
    var body: some View {
        NavigationStack {
            if loadingStage == 0 {
                SplashScreen()
            } else {
                if showOnboarding {
                    OnboardingPage1()
                } else {
                    AllSongs()
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                loadingStage = 1
            }
        }
    }
}

#Preview {
    AppRoot()
}
