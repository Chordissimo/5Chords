//
//  UpgradeButton.swift
//  AmDm AI
//
//  Created by Anton on 21/07/2024.
//

import SwiftUI

struct UpgradeButton: View {
    var content: () -> any View
    var action: () -> Void
    var body: some View {
        Button {
            action()
        } label: {
            ZStack {
                HStack {
                    Image(systemName: "crown.fill")
                        .resizable()
                        .foregroundColor(.grad2)
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 20)
                    Spacer()
                }
                .padding(.horizontal, 20)
                
                AnyView(content())
            }
            .frame(height: 60)
            .frame(maxWidth: .infinity)
            .background(.progressCircle, in: Capsule())
        }
    }
}
