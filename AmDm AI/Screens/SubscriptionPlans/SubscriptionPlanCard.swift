//
//  SubscriptionPlanCard.swift
//  AmDm AI
//
//  Created by Anton on 25/03/2024.
//

import SwiftUI

struct SubscriptionPlanCard: View {
    let title: String
    let description: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .stroke(Color.white, style: StrokeStyle(lineWidth: 1.0))
                .fill()
            
            VStack {
                Text(title)
                    .font(.largeTitle)
                    .foregroundStyle(.white)
                
                Text(description)
                    .font(.title)
                    .foregroundStyle(.white)
            }
            .padding(20)
            .multilineTextAlignment(.center)
        }
        .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10))
        .frame(height: 150)
    }
}

#Preview {
    SubscriptionPlanCard(title: "Title", description: "Description")
}
