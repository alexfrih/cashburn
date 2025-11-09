//
//  SubscriptionList.swift
//  Cashburn
//
//  Created by Alexandre on 09/11/2025.
//

import Foundation
import SwiftData

@Model
final class SubscriptionList {
    var name: String
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \Subscription.list)
    var subscriptions: [Subscription] = []

    init(name: String) {
        self.name = name
        self.createdAt = Date()
    }
}
