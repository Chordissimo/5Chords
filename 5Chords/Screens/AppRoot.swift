//
//  AppRoot.swift
//  AmDm AI
//
//  Created by Anton on 21/05/2024.
//

import SwiftUI
import SwiftyChords

struct AppRoot: View {
    @State var loadingStage = 0
    @StateObject var store = ProductModel(isMock: false)
    @StateObject var songsList = SongsList()
    @State var productInfoLoaded = false
    @State var showOnboarding = AppDefaults.showOnboarding
    @State var loaderFinished: Bool = false
    
    var body: some View {
        NavigationStack {
            if loadingStage < 3 || !loaderFinished {
                SplashScreen() {
                    loaderFinished = true
                }
            } else {
                if showOnboarding {
                    OnboardingPage1() {
                        AppDefaults.showOnboarding = false
                        withAnimation {
                            showOnboarding = false
                        }
                    }
                } else {
                    AllSongs()
                }
            }
        }
        .onChange(of: store.productInfoLoaded) {
            if store.productInfoLoaded {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    loadingStage += 1
                }
            }
        }
        .onAppear {
            Task {
                await self.store.prepareStore()
            }
            AppDefaults.loadDefaultsFromFirestore() { isSuccess in
                if isSuccess {
//                    AppDefaults.loadChordsJSON(AppDefaults.GUITAR_CHORDS_URL) {
                        loadingStage += 1
//                    }
//                    AppDefaults.loadChordsJSON(AppDefaults.UKULELE_CHORDS_URL) {
                        loadingStage += 1
//                    }
                }
            }
        }
        .environmentObject(store)
        .environmentObject(songsList)
    }
}
