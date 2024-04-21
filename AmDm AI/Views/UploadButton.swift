//
//  UploadButton.swift
//  AmDm AI
//
//  Created by Anton on 21/04/2024.
//

import SwiftUI

struct UploadButton: View {
    var action: () -> Void
    
    var body: some View {
        GeometryReader { geometry  in
            let whiteCircleHeight = geometry.size.height * 0.65
            let grayCircleHeight = whiteCircleHeight - 5
            let redCircleHeight = grayCircleHeight - 5
            let uploadHeight = redCircleHeight * 0.4
            let uploadWidth = redCircleHeight * 0.5
            
            ZStack {
                Circle()
                    .frame(width: whiteCircleHeight, height: whiteCircleHeight)
                    .foregroundStyle(Color.white)
                Circle()
                    .frame(width: grayCircleHeight, height: grayCircleHeight)
                    .foregroundStyle(Color.customDarkGray)
                
                Button {
                    withAnimation {
                        action()
                    }
                } label: {
                    ZStack {
                        Circle()
                            .frame(width: redCircleHeight, height: redCircleHeight)
                            .foregroundStyle(Color.red)
                        Image(systemName: "folder.fill")
                            .resizable()
                            .foregroundColor(.white.opacity(0.6))
                            .frame(width: uploadWidth, height: uploadHeight)
                            .aspectRatio(contentMode: .fit)
                    }
                }
            }
            .frame(width: geometry.size.width)
        }
    }
}

#Preview {
    UploadButton() {
        print("upload tapped")
    }
}
