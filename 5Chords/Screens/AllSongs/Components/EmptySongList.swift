//
//  EmptySongList.swift
//  AmDm AI
//
//  Created by Anton on 20/05/2024.
//

import SwiftUI

struct EmptyListView: View {
    var body: some View {
        ZStack {
            VStack {
                Image(systemName: "music.quarternote.3")
                    .resizable()
                    .foregroundColor(Color.secondaryText)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
                    .padding()
                VStack {
                    Text("No Recents")
                        .foregroundStyle(Color.white)
                        .font(.custom(SOFIA, size: 28))
                        .fontWeight(.bold)
                    Text("Songs and recordings will appear here.")
                        .foregroundStyle(Color.customGray1)
                }
            }
            .frame(maxHeight: .infinity)
        }
    }
}
