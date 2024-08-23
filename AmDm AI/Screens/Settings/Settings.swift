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
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
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
                        openURL(URL(string: "https://aichords.pro/privacy-policy/")!)
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
                        openURL(URL(string: "https://aichords.pro/terms-of-use/")!)
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
                }
                
            }
            .navigationTitle("Settings")
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
        }
    }
}
