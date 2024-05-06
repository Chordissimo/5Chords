//
//  PlaybackSlider.swift
//  AmDm AI
//
//  Created by Anton on 30/03/2024.
//

import SwiftUI

struct PlaybackSlider: View {
    @Binding var width: CGFloat
        
    var body: some View {
        ZStack(alignment: .leading) {
            Capsule().fill(Color.customGray).frame(height: 4)
            Capsule().fill(Color.white).frame(width: width, height: 4)
            Circle()
                .frame(width: 8)
                .foregroundColor(.white)
                .position(x: width,y: 4)
        }
    }
}

#Preview {
    @State var width = UIScreen.main.bounds.width
    return ZStack(alignment: Alignment(horizontal: .center, vertical: .center)) {
        Color.black.ignoresSafeArea()
        PlaybackSlider(width: $width)
    }
}
