//
//  OptionsToggle.swift
//  AmDm AI
//
//  Created by Anton on 30/03/2024.
//

import SwiftUI

struct OptionsToggle: View {
    var body: some View {
        Button {
            print("options toggle tapped")
        } label: {
            Image(systemName: "slider.horizontal.3")
                .resizable()
                .frame(width: 22, height: 22)
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(Color.purple)
        }
    }
}

#Preview {
    OptionsToggle()
}
