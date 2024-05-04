//
//  ItemDetailView.swift
//  AmDm AI
//
//  Created by Marat Zainullin on 30/04/2024.
//

import SwiftUI


struct ItemDetailView: View {
    @State var position: Float = 0
    @ObservedObject var viewModel: ItemDetailViewModel
    
    init(song: Song) {
        self.viewModel = ItemDetailViewModel(song: song)
    }
    
    var body: some View {
        WaveProgressBarView(globalPosition: $position, url: viewModel.url)
    }
}
        
#Preview {
    ItemDetailView(song: Song(id: "ss", name: "Test", url: Bundle.main.url(forResource: "splean", withExtension: "mp3")!.absoluteString, duration: 222, created: Date.now, chords: [], text: [], tempo: 200, songType: .localFile))
}
