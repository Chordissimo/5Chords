//
//  OptionsToggle.swift
//  AmDm AI
//
//  Created by Anton on 30/03/2024.
//

import SwiftUI

struct ActionsToggle: View {
    var body: some View {
        Image(systemName: "ellipsis.circle")
            .resizable()
            .frame(width: 28, height: 28)
            .aspectRatio(contentMode: .fit)
            .foregroundStyle(Color.purple)
    }
}

#Preview {
    ActionsToggle()
}
