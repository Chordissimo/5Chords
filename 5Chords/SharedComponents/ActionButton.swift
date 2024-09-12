//
//  DeleteAction.swift
//  AmDm AI
//
//  Created by Anton on 30/03/2024.
//

import SwiftUI

struct ActionButton: View {
    var imageName: String?
    var title: String?
    var action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            let imageNameUnwrappred = imageName ?? ""
            let titleUnwrapped = title ?? ""
            
            if imageNameUnwrappred != "" {
                getSafeImage(named: imageNameUnwrappred)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            
            if titleUnwrapped != "" {
                Text(titleUnwrapped)
                    .foregroundStyle(Color.purple)
            }
            
        }.buttonStyle(BorderlessButtonStyle())
    }
}
