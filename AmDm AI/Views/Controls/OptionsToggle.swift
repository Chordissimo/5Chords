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
                .frame(width: 18, height: 18)
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(Color.purple)
        }
    }
}

#Preview {
    return ZStack {
        Color.black
        OptionsToggle()
    }
}
