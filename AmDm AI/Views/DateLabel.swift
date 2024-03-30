//
//  DateLabel.swift
//  AmDm AI
//
//  Created by Anton on 30/03/2024.
//

import SwiftUI

struct DateLabel: View {
    var date: Date
    
    var body: some View {
        Text(dateToString(date: date))
            .foregroundStyle(Color.white)
    }
    
    private func dateToString(date: Date) -> String {
        let calendar = Calendar.current
        let daysBetween = calendar.dateComponents([.day], from: date, to: Date()).day
        
        if daysBetween == 0 {
            return date.formatted(date: .omitted, time: .shortened)
        } else if daysBetween == 1 {
            return "Yesterday"
        } else {
            return date.formatted(date: .abbreviated, time: .omitted)
        }
    }
}

#Preview {
    DateLabel(date: Date())
}
