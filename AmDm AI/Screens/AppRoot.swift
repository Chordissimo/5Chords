//
//  AppRoot.swift
//  AmDm AI
//
//  Created by Anton on 21/05/2024.
//

import SwiftUI

struct AppRoot: View {
    @State var loadingStage = 0
    @AppStorage("showOnboarding") private var showOnboarding: Bool = true
    @StateObject var store = StorekitManager()
    
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                loadingStage = 1
            }
        }
        .environmentObject(store)
    }
}

#Preview {
    AppRoot()
}
