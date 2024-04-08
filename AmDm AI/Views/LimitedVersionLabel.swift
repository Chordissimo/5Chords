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
        ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
            Color.clear.ignoresSafeArea()
            if isLimitedVersion {
                Text("Limited version")
                    .foregroundStyle(.customGray)
                    .padding(.bottom, 15)
            }
        }.ignoresSafeArea()
    }
}

#Preview {
    LimitedVersionLabel(isLimitedVersion: true)
}
