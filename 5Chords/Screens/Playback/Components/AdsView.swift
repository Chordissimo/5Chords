//
//  AdsView.swift
//  AmDm AI
//
//  Created by Anton on 16/07/2024.
//

import SwiftUI

struct AdsView<Content: View>: View {
    @Binding var showAds: Bool
    @Binding var showPaywall: Bool
    var title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    showAds = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .foregroundColor(.gray40)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                }
                .padding(.trailing, 20)
            }
            .padding(.top, 20)
            
            VStack {
                Text(title)
                    .multilineTextAlignment(.center)
                    .font(.custom(SOFIA, size: 20))
                    .fontWeight(.semibold)
                    .fontWidth(.expanded)
                    .foregroundStyle(.white)
                HStack {
                    Image("logo3")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 20)
                    Text("Premium feature")
                        .font(.custom(SOFIA, size: 18))
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 20)
            }
            
            ScrollView(.vertical) {
                content
            }
            
            Spacer()
            
            if AppDefaults.isLimited {
                Button {
                    showAds = false
                    showPaywall = true
                } label: {
                    Text("Upgrade to Premium")
                        .fontWeight(.semibold)
                        .font(.custom(SOFIA, size: 20))
                        .padding(20)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.black)
                        .background(.progressCircle, in: Capsule())
                }
                .padding(20)
            }
        }
    }
}
