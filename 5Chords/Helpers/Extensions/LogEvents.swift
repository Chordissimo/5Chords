//
//  LogEvents.swift
//  AmDm AI
//
//  Created by Anton on 06/07/2024.
//

import SwiftUI
import Firebase

extension Button {
    func logEvent(screen: String, event: EventID, title: String = "") -> Button {
        print(screen,event,title)
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
          AnalyticsParameterItemID: event.rawValue,
          AnalyticsParameterItemName: title
        ])
        return self
    }
}

enum EventID: String {
    case recognizeFromYoutube = "0"
}
