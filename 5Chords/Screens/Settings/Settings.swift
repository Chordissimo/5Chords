//
//  Settings.swift
//  AmDm AI
//
//  Created by Anton on 06/04/2024.
//

import SwiftUI

struct Settings: View {
    @Binding var showSettings: Bool
    var action: (Bool) -> Void
    @Environment(\.openURL) var openURL
    @State var tapCounter = 0
    @State var lastTapTime = Date()
    @State var unlocked = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                VStack {
                    List {
                        Button {
                            showSettings = false
                            action(true)
                        } label: {
                            HStack {
                                Text("My subscription")
                                Spacer()
                                Image(systemName: "dollarsign.circle")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 20)
                                    .foregroundColor(.gray30)
                            }
                        }
                        .foregroundStyle(.white)
                        
                        Button {
                            openURL(URL(string: AppDefaults.PRIVACY_LINK)!)
                        } label: {
                            HStack {
                                Text("Privacy policy")
                                Spacer()
                                Image(systemName: "arrow.up.forward.square")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 18)
                                    .foregroundColor(.gray30)
                            }
                        }
                        .foregroundStyle(.white)
                        
                        Button {
                            openURL(URL(string: AppDefaults.TERMS_LINK)!)
                        } label: {
                            HStack {
                                Text("Terms of use")
                                Spacer()
                                Image(systemName: "arrow.up.forward.square")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 18)
                                    .foregroundColor(.gray30)
                            }
                        }
                        .foregroundStyle(.white)
                        
                        Button {
                            openURL(URL(string: AppDefaults.CONTACT_US_LINK)!)
                        } label: {
                            HStack {
                                Text("Support")
                                Spacer()
                                Image(systemName: "questionmark.circle")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 18)
                                    .foregroundColor(.gray30)
                            }
                        }
                        .foregroundStyle(.white)
                    }
                    Spacer()
                    Rectangle()
                        .fill(Color.black)
                        .frame(width: AppDefaults.screenWidth, height: 50)
                        .onTapGesture {
                            if AppDefaults.isLimited && !AppDefaults.godMode {
                                if tapCounter >= 7 {
                                    tapCounter = 0
                                    AppDefaults.isLimited = false
                                    AppDefaults.godMode = true
                                    unlocked = true
                                } else {
                                    tapCounter = Date().timeIntervalSinceReferenceDate - lastTapTime.timeIntervalSinceReferenceDate < 2 ? tapCounter + 1 : 0
                                    lastTapTime = Date()
                                }
                            }
                        }
                }
            }
            .navigationTitle("Settings" + (unlocked ? " - God Mode" : ""))
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    ActionButton(imageName: "xmark.circle.fill") {
                        showSettings = false
                    }
                    .frame(height: 25)
                    .foregroundColor(.customGray)
                }
            }
            .onAppear {
                unlocked = AppDefaults.godMode
            }
        }
    }
}
