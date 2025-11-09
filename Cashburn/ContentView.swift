//
//  ContentView.swift
//  Cashburn
//
//  Created by Alexandre on 09/11/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Subscription.name) private var subscriptions: [Subscription]
    @State private var showingAddSubscription = false
    @State private var subscriptionToEdit: Subscription?
    @State private var showingSettings = false
    @AppStorage("currencyCode") private var currencyCode = "USD"

    private var totalMonthlyCost: Double {
        subscriptions.reduce(0) { $0 + $1.monthlyCost }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Subscriptions List with integrated header
                if subscriptions.isEmpty {
                    VStack(spacing: 24) {
                        Spacer()

                        // Total Cashburn Header
                        VStack(spacing: 8) {
                            Text("Monthly Cashburn")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                            Text(totalMonthlyCost, format: .currency(code: currencyCode))
                                .font(.system(size: 56, weight: .bold, design: .rounded))
                                .contentTransition(.numericText())
                        }

                        Spacer().frame(height: 40)

                        ContentUnavailableView(
                            "No Subscriptions",
                            systemImage: "list.bullet.rectangle",
                            description: Text("Add your first subscription to track your monthly cashburn")
                        )

                        Spacer()
                    }
                } else {
                    List {
                        // Header section - just a simple title
                        Section {
                            Text("Monthly Subscriptions")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .textCase(.uppercase)
                                .tracking(0.5)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 16)
                                .padding(.top, 12)
                                .padding(.bottom, 8)
                                .listRowBackground(Color.clear)
                                .listRowInsets(EdgeInsets())
                                .listRowSeparator(.hidden)
                        }

                        // Subscriptions section - clean list without separators
                        Section {
                            ForEach(subscriptions) { subscription in
                                SubscriptionRow(subscription: subscription, currencyCode: currencyCode)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        subscriptionToEdit = subscription
                                    }
                                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                                    .listRowSeparator(.hidden)
                                    .listRowBackground(Color.clear)
                            }
                            .onDelete(perform: deleteSubscriptions)
                        }

                        // Total section - clear visual break and emphasis
                        Section {
                            VStack(spacing: 0) {
                                // Separator before total
                                Rectangle()
                                    .fill(Color.primary.opacity(0.3))
                                    .frame(height: 1)
                                    .padding(.horizontal, 16)
                                    .padding(.top, 8)

                                // Total row
                                HStack {
                                    Text("Monthly Total")
                                        .font(.headline)
                                        .fontWeight(.semibold)

                                    Spacer()

                                    Text(totalMonthlyCost, format: .currency(code: currencyCode))
                                        .font(.system(.title2, design: .rounded))
                                        .fontWeight(.bold)
                                        .contentTransition(.numericText())
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 16)
                            }
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets())
                            .listRowSeparator(.hidden)
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .background(.clear)
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button(action: { showingSettings = true }) {
                        Label("Settings", systemImage: "gearshape")
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddSubscription = true }) {
                        Label("Add Subscription", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSubscription) {
                SubscriptionFormView(subscription: nil)
            }
            .sheet(item: $subscriptionToEdit) { subscription in
                SubscriptionFormView(subscription: subscription)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
    }

    private func deleteSubscriptions(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(subscriptions[index])
        }
    }
}

struct SubscriptionRow: View {
    let subscription: Subscription
    let currencyCode: String

    var body: some View {
        HStack(spacing: 16) {
            Text(subscription.name)
                .font(.body)
                .fontWeight(.medium)

            Spacer()

            Text(subscription.monthlyCost, format: .currency(code: currencyCode))
                .font(.system(.body, design: .monospaced))
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Subscription.self, inMemory: true)
}
