//
//  UpgradeButton.swift
//  AmDm AI
//
//  Created by Anton on 21/07/2024.
//

import SwiftUI

struct UpgradeButton: View {
    var leftIconName: String = "crown.fill"
    var rightIconName: String = ""
    var content: () -> any View
    var action: () -> Void
    var body: some View {
        Button {
            action()
        } label: {
            ZStack {
                HStack {
                    Image(systemName: leftIconName)
                        .resizable()
                        .foregroundColor(.grad2)
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 20)
                    Spacer()
                    if rightIconName != "" {
                        Image(systemName: rightIconName)
                            .resizable()
                            .foregroundColor(.grad2)
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 20)
                    }
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
