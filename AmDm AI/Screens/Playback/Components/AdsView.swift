//
//  AdsView.swift
//  AmDm AI
//
//  Created by Anton on 16/07/2024.
//

import SwiftUI

struct AdsView: View {
    @Binding var showEditChordsAds: Bool
    var completion: () -> Void
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    showEditChordsAds = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .foregroundColor(.gray40)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                }
                .padding(.trailing, 20)
            }
            .padding(.vertical, 20)
            
            VStack {
                Text("EDIT CHORDS")
                    .font(.system(size: 20))
                    .fontWeight(.semibold)
                    .fontWidth(.expanded)
                    .foregroundStyle(.white)
            }
            
            Spacer()
            
            Button {
                showEditChordsAds = false
                completion()
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
