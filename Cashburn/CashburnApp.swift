//
//  CashburnApp.swift
//  Cashburn
//
//  Created by Alexandre on 09/11/2025.
//

import SwiftUI
import SwiftData

@main
struct CashburnApp: App {
    let container: ModelContainer

    init() {
        do {
            let schema = Schema([Subscription.self, SubscriptionList.self])
            let modelConfiguration = ModelConfiguration(schema: schema)
            container = try ModelContainer(for: schema, configurations: [modelConfiguration])

            // Migrate existing subscriptions to a default list
            migrateExistingSubscriptions()
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 400, minHeight: 500)
        }
        .modelContainer(container)
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
    }

    @MainActor
    private func migrateExistingSubscriptions() {
        let context = container.mainContext

        // Check if migration is needed
        let listDescriptor = FetchDescriptor<SubscriptionList>()
        let subscriptionDescriptor = FetchDescriptor<Subscription>()

        do {
            let existingLists = try context.fetch(listDescriptor)
            let existingSubscriptions = try context.fetch(subscriptionDescriptor)

            // If there are subscriptions without lists, create a default list
            let orphanedSubscriptions = existingSubscriptions.filter { $0.list == nil }

            if !orphanedSubscriptions.isEmpty && existingLists.isEmpty {
                let defaultList = SubscriptionList(name: "Personal")
                context.insert(defaultList)

                for subscription in orphanedSubscriptions {
                    subscription.list = defaultList
                }

                try context.save()
            }
        } catch {
            print("Migration error: \(error)")
        }
    }
}
