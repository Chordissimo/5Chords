//
//  ActionsToggle.swift
//  AmDm AI
//
//  Created by Anton on 31/03/2024.
//

import SwiftUI

struct ActionsToggle: View {
    var body: some View {
        Image(systemName: "ellipsis.circle")
            .resizable()
            .frame(width: 20, height: 20)
            .aspectRatio(contentMode: .fit)
            .foregroundStyle(Color.purple)
    }
}

#Preview {
    return ZStack {
        Color.black
        ActionsToggle()
    }
}
