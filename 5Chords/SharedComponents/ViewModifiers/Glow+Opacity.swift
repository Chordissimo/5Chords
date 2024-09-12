//
//  Glow+Opacity.swift
//  AmDm AI
//
//  Created by Anton on 20/05/2024.
//

import SwiftUI

struct OpacityAnimation: ViewModifier {
    @State private var throb: Bool = false
    func body(content: Content) -> some View {
        ZStack {
            content
                .opacity(throb ? 0.7 : 1)
                .animation(.linear(duration: 1.0).repeatForever(), value: throb)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        throb.toggle()
                    }
                }
        }
    }
}

extension View {
    func opacityAnimaion() -> some View {
        modifier(OpacityAnimation())
    }
}

struct Glow: ViewModifier {
    @State private var throb: Bool = false
    func body(content: Content) -> some View {
        ZStack {
            content
                .blur(radius: throb ? 5 : 20)
                .animation(.easeOut(duration: 2.0).repeatForever(), value: throb)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        throb.toggle()
                    }
                }
            content
        }
    }
}

extension View {
    func glow() -> some View {
        modifier(Glow())
    }
}
