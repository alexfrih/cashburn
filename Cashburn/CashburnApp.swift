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
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 400, minHeight: 500)
        }
        .modelContainer(for: Subscription.self)
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
    }
}
