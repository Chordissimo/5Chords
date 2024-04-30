//
//  Helpers.swift
//  AmDm AI
//
//  Created by Anton on 30/03/2024.
//

import Foundation
import SwiftUI

enum TimePrecision: Int {
    case milliseconds = 0
    case santiseconds = 1
    case seconds = 2
}

func dateToString(_ date: Date) -> String {
    let calendar = Calendar.current
    let daysBetween = calendar.dateComponents([.day], from: date, to: Date()).day
    let dateFormatter = DateFormatter()
    
    if daysBetween == 0 {
        dateFormatter.dateFormat = "hh:mm a"
        return dateFormatter.string(from: date)
    } else if daysBetween == 1 {
        return "Yesterday"
    } else {
        dateFormatter.dateFormat = "MMMd"
        return date.formatted(date: .abbreviated, time: .omitted)
    }
}

func formatTime(_ time: TimeInterval, precision: TimePrecision? = TimePrecision.seconds) -> String {
    let minutes = Int(time) / 60
    let seconds = Int(time) % 60
    let santiseconds = Int(((time - Double(minutes * 60) - Double(seconds)) * 100).rounded())
    let milliseconds = Int(((time - Double(minutes * 60) - Double(seconds)) * 1000).rounded())
    
    if let p = precision {
        if p == TimePrecision.milliseconds {
            return String(format: "%02d:%02d.%03d", minutes, seconds, milliseconds)
        } else if p == TimePrecision.santiseconds {
            return String(format: "%02d:%02d.%02d", minutes, seconds, santiseconds)
        }
    }
    return String(format: "%02d:%02d", minutes, seconds)
}

func getSafeImage(named: String) -> Image {
    if UIImage(named: named) != nil {
        return Image(named)
    } else if UIImage(systemName: named) != nil {
        return Image(systemName: named)
    } else {
        return Image(systemName: "questionmark")
    }
}
