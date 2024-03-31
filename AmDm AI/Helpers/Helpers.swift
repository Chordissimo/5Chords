//
//  Helpers.swift
//  AmDm AI
//
//  Created by Anton on 30/03/2024.
//

import Foundation

func dateToString(date: Date) -> String {
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

func formattedDuration(seconds: Int) -> String {
    let hours = seconds / 3600
    let minutes = (seconds % 3600) / 60
    let remainingSeconds = seconds % 60
    
    var formattedDuration = ""

    if hours > 0 {
        if hours >= 10 {
            formattedDuration += "\(hours):"
        } else if hours < 10 && hours != 0 {
            formattedDuration += "0\(hours):"
        } else {
            formattedDuration += "00:"
        }
    }
    
    if minutes >= 10 {
        formattedDuration += "\(minutes):"
    } else if minutes < 10 && minutes != 0 {
        formattedDuration += "0\(minutes):"
    } else {
        formattedDuration += "00:"
    }
    
    if remainingSeconds >= 10 {
        formattedDuration += "\(remainingSeconds)"
    } else if remainingSeconds < 10 && remainingSeconds != 0 {
        formattedDuration += "0\(remainingSeconds)"
    } else {
        formattedDuration += "00"
    }
    
    return formattedDuration
}
