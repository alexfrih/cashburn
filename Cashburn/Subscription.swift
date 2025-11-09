//
//  Subscription.swift
//  Cashburn
//
//  Created by Alexandre on 09/11/2025.
//

import Foundation
import SwiftData

@Model
final class Subscription {
    var name: String
    var monthlyCost: Double
    var createdAt: Date

    var list: SubscriptionList?

    init(name: String, monthlyCost: Double, list: SubscriptionList? = nil) {
        self.name = name
        self.monthlyCost = monthlyCost
        self.createdAt = Date()
        self.list = list
    }
}
