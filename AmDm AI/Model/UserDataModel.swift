//
//  UserDataModel.swift
//  AmDm AI
//
//  Created by Anton on 25/03/2024.
//

import Foundation
import SwiftData

@Model
final class User {
    var registrationDate: Date?
    var subscriptionPlanId: Int
    
    init() {
        self.subscriptionPlanId = -1
    }
    
    func selectPlan(registrationDate: Date, subscriptionPlanId: Int) {
        self.registrationDate = registrationDate
        self.subscriptionPlanId = subscriptionPlanId
    }
    
}

struct SubscriptionPlan: Identifiable, Hashable {
    let id = UUID()
    let planId: Int
    let title: String
    let description: String
    let price: Float
}

struct MockData {
    static let plans = [
        SubscriptionPlan(planId: 0, title: "Plan A", description: "Description", price: 0.0),
        SubscriptionPlan(planId: 1, title: "Plan B", description: "Description", price: 4.99),
        SubscriptionPlan(planId: 2, title: "Plan C", description: "Description", price: 9.99)
    ]
}


