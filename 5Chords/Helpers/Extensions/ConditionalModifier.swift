//
//  Untitled.swift
//  5Chords
//
//  Created by Anton on 23/09/2024.
//

import SwiftUI

extension View {
    func apply<V: View>(@ViewBuilder _ block: (Self) -> V) -> V { block(self) }
}
