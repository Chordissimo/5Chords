//
//  MatrixRain.swift
//  AmDm AI
//
//  Created by Anton on 03/09/2024.
//

import SwiftUI

//let constant = "394857349587329ksjdfnvsl98rhtljkbvscv78sft2h34jrbkjhb"
let constant = ["6","7","9","11","♭","♯","sus²","⁷sus⁴","dim","6/9","aug⁷","A♭","B","Cm","D","Em","F","G♯","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"]

struct MatrixRain: View {
    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height
            HStack(spacing: 10) {
                ForEach(1...Int(width / 25), id: \.self) { _ in
                    RainCharacters(height: height)
                }
            }
        }
    }
}

struct RainCharacters: View {
    var height: CGFloat
    @State var startAnimation: Bool = false
    @State var random: Int = 0
    
    var body: some View {
        let randomHeight: CGFloat = .random(in: (height / 2)...height)
        VStack(spacing: 10) {
            ForEach(0..<constant.count, id: \.self) { index in
                let character = Array(constant)[getRandomIndex(index: index)]
                Text(String(character))
                    .foregroundStyle(.gray40)
                    .font(.custom(SOFIA, size: 14))
                    .frame(width: 30)
            }
        }
        .mask(alignment: .top) {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors:[
                            .clear,
                            .black.opacity(0.1),
                            .black.opacity(0.2),
                            .black.opacity(0.3),
                            .black.opacity(0.5),
                            .black.opacity(0.7),
                            .black
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: height / 2)
                .offset(y: startAnimation ? height : -randomHeight)
        }
        .onAppear {
            withAnimation(.linear(duration: 5).delay(.random(in: 0...5)).repeatForever(autoreverses: false)) {
                startAnimation = true
            }
        }
        .onReceive(Timer.publish(every: 0.2, on: .main, in: .common).autoconnect()) { _ in
            random = Int.random(in: 0..<constant.count)
        }
    }
    
    func getRandomIndex(index: Int) -> Int {
        let max = constant.count - 1
        if (index + self.random) > max {
            if (index - self.random) < 0 {
                return index
            }
            return index - self.random
        } else {
            return index + self.random
        }
    }
}
 


#Preview {
    MatrixRain()
}
