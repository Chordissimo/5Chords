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
    @AppStorage("isLimited") var isLimited: Bool = false
    
    
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
                    .font(.system(size: 20))
                    .fontWeight(.semibold)
                    .fontWidth(.expanded)
                    .foregroundStyle(.white)
                HStack {
                    Image(systemName: "crown.fill")
                        .resizable()
                        .foregroundColor(.grad2)
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 20)
                    Text("Premium feature")
                        .font(.system(size: 18))
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 20)
            }
            
            ScrollView(.vertical) {
                content
            }
            
            Spacer()
            
            if isLimited {
                Button {
                    showAds = false
                    showPaywall = true
                } label: {
                    Text("Upgrade to Premium")
                        .fontWeight(.semibold)
                        .font(.system(size: 20))
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




struct TranspositionAds: View {
    var body: some View {
        Text("Chords transposition")
    }
}

