//
//  Settings.swift
//  AmDm AI
//
//  Created by Anton on 06/04/2024.
//

import SwiftUI

struct Settings: View {
    @Binding var showSettings: Bool
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack {
                Text("Settings")
                    .foregroundStyle(.white)
                Button("Dismiss") {
                    showSettings = false
                }.foregroundColor(.blue)
            }
        }
    }
}

#Preview {
    @State var showSettings = true
    return Settings(showSettings: $showSettings)
}
