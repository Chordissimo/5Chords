//
//  DeleteAction.swift
//  AmDm AI
//
//  Created by Anton on 30/03/2024.
//

import SwiftUI

struct ActionButton: View {
    var systemImageName: String?
    var title: String?
    var action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            if let systemImageNameUnwrappred = systemImageName {
                Image(systemName: systemImageNameUnwrappred)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                if let titleUnwrapped = title {
                    Text(titleUnwrapped)
                        .foregroundStyle(Color.purple)
                } else {
                    Text("No label")
                        .foregroundStyle(Color.purple)
                }
            }
        }.buttonStyle(BorderlessButtonStyle())
    }
}

#Preview {
    func preview() -> Void {
        print("Tapped")
    }
    return ActionButton(systemImageName: "trash", action: preview)
        .frame(width: 20)
}

