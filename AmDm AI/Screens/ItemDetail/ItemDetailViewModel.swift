//
//  ItemDetailViewModel.swift
//  AmDm AI
//
//  Created by Marat Zainullin on 30/04/2024.
//

import Foundation



class ItemDetailViewModel: ObservableObject {
//    Public properties
    @Published var progress: Float = 0
    var url: URL { return self.song.url }
    
    
//    Private properties
    private let song: Song
    
    
    
    init(song: Song) {
        self.song = song
    }
}
