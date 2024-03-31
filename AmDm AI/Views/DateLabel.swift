//
//  DateLabel.swift
//  AmDm AI
//
//  Created by Anton on 30/03/2024.
//

import SwiftUI

struct DateLabel: View {
    var date: Date
    var color: Color?
    
    var body: some View {
        Text(dateToString(date: date))
            .foregroundStyle(color ?? Color.white)
            .font(.system(size: 15))
    }
}

#Preview {
    DateLabel(date: Date(), color: Color.black)
}
