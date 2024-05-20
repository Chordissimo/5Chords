//
//  Int.swift
//  AmDm AI
//
//  Created by Marat Zainullin on 30/04/2024.
//

import Foundation

extension Int {
    func secondsToTimeString() -> String {
        let minutes = self / 60
        let seconds = self % 60
        let timeString = String(format: "%02d:%02d", minutes, seconds)
        return timeString
    }
}
