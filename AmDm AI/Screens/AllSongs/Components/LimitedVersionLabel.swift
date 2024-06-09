//
//  RecordButtonBackground.swift
//  AmDm AI
//
//  Created by Anton on 08/04/2024.
//

import SwiftUI

struct LimitedVersionLabel: View {
    var isLimitedVersion: Bool
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: Alignment(horizontal: .center, vertical: .top)) {
                Color.customDarkGray.ignoresSafeArea()
                //            if isLimitedVersion {
                VStack {
                    Text("Get the unlimited version")
                }
                .frame(width: geometry.size.width, height: 50)
                .background(
                    LinearGradient(gradient: Gradient(colors: [.grad1, .grad2, .grad3]), startPoint: .leading, endPoint: .trailing)
                )
                //            }
            }
            .transition(.move(edge: .bottom))
            .ignoresSafeArea()
        }
    }
}

#Preview {
    LimitedVersionLabel(isLimitedVersion: true)
}
