//
//  PlaybackColtrols.swift
//  AmDm AI
//
//  Created by Anton on 30/03/2024.
//

import SwiftUI

enum PlaybackColtrolsScale: Int {
    case small = 0
    case large = 1
}

struct PlaybackColtrols: View {
    var scale: PlaybackColtrolsScale? = PlaybackColtrolsScale.small
    var body: some View {
        Image(systemName: "gobackward.5")
            .resizable()
            .frame(width: scale == PlaybackColtrolsScale.large ? 50 : 26, height: scale == PlaybackColtrolsScale.large ? 50 : 26)
            .aspectRatio(contentMode: .fit)
            .foregroundStyle(Color.white)
        Image(systemName: "play.fill")
            .resizable()
            .frame(width: scale == PlaybackColtrolsScale.large ? 50 : 28, height: scale == PlaybackColtrolsScale.large ? 50 : 28)
            .aspectRatio(contentMode: .fit)
            .foregroundStyle(Color.white)
            .padding(EdgeInsets(top: 0, leading: 30, bottom: 0, trailing: 25))
        Image(systemName: "goforward.5")
            .resizable()
            .frame(width: scale == PlaybackColtrolsScale.large ? 50 : 26, height: scale == PlaybackColtrolsScale.large ? 50 : 26)
            .aspectRatio(contentMode: .fit)
            .foregroundStyle(Color.white)
    }
}

#Preview {
    return ZStack {
        Color.black
        HStack {
            PlaybackColtrols(scale: .large)
        }
    }
}
