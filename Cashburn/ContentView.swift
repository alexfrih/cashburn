//
//  ContentView.swift
//  Cashburn
//
//  Created by Alexandre on 09/11/2025.
//

import SwiftUI
import SwiftData

enum SubscriptionSortOption: String, CaseIterable {
    case name = "Name"
    case priceAsc = "Price ↑"
    case priceDesc = "Price ↓"
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SubscriptionList.name) private var lists: [SubscriptionList]
    @Query private var allSubscriptions: [Subscription]
    @State private var selectedList: SubscriptionList?
    @State private var showingAddSubscription = false
    @State private var subscriptionToEdit: Subscription?
    @State private var showingSettings = false
    @State private var showingListManager = false
    @State private var sortOption: SubscriptionSortOption = .name
    @State private var subscriptionToDelete: Subscription?
    @State private var showingDeleteConfirmation = false
    @AppStorage("currencyCode") private var currencyCode = "USD"

    private var subscriptions: [Subscription] {
        guard let selectedList else { return [] }
        let filtered = allSubscriptions.filter { $0.list?.id == selectedList.id }

        switch sortOption {
        case .name:
            return filtered.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .priceAsc:
            return filtered.sorted { $0.monthlyCost < $1.monthlyCost }
        case .priceDesc:
            return filtered.sorted { $0.monthlyCost > $1.monthlyCost }
        }
    }

    private var totalMonthlyCost: Double {
        subscriptions.reduce(0) { $0 + $1.monthlyCost }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Segmented control for lists
                if !lists.isEmpty {
                    HStack(spacing: 12) {
                        ForEach(lists) { list in
                            Button(action: { selectedList = list }) {
                                Text(list.name)
                                    .font(.subheadline)
                                    .fontWeight(selectedList?.id == list.id ? .semibold : .regular)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 6)
                                    .background(
                                        selectedList?.id == list.id ?
                                            AnyView(Capsule().fill(Color.accentColor)) :
                                            AnyView(Capsule().fill(Color.secondary.opacity(0.15)))
                                    )
                                    .foregroundStyle(selectedList?.id == list.id ? .white : .primary)
                            }
                            .buttonStyle(.plain)
                        }

                        Spacer()

                        Button(action: { showingListManager = true }) {
                            Image(systemName: "ellipsis.circle")
                                .font(.title3)
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(.ultraThinMaterial)
                }

                Divider()

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
                    VStack(spacing: 0) {
                        // Header section with sort picker
                        HStack {
                            Text("Monthly Subscriptions")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .textCase(.uppercase)
                                .tracking(0.5)

                            Spacer()

                            // Sort picker
                            Menu {
                                ForEach(SubscriptionSortOption.allCases, id: \.self) { option in
                                    Button(action: { sortOption = option }) {
                                        HStack {
                                            Text(option.rawValue)
                                            if sortOption == option {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "arrow.up.arrow.down")
                                        .font(.caption)
                                    Text(sortOption.rawValue)
                                        .font(.caption)
                                }
                                .foregroundStyle(.secondary)
                            }
                            .menuStyle(.borderlessButton)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                        .padding(.bottom, 8)

                        // Scrollable subscriptions list
                        ScrollView {
                            VStack(spacing: 0) {
                                ForEach(subscriptions) { subscription in
                                    SubscriptionRow(
                                        subscription: subscription,
                                        currencyCode: currencyCode,
                                        onDelete: {
                                            subscriptionToDelete = subscription
                                            showingDeleteConfirmation = true
                                        }
                                    )
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        subscriptionToEdit = subscription
                                    }
                                }
                            }
                        }

                        // Total section - fixed at bottom
                        VStack(spacing: 0) {
                            // Separator before total
                            Rectangle()
                                .fill(Color.primary.opacity(0.3))
                                .frame(height: 1)
                                .padding(.horizontal, 16)

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
                            .background(.ultraThinMaterial)
                        }
                    }
                }
            }
            .background(.clear)
            .onAppear {
                if selectedList == nil, let firstList = lists.first {
                    selectedList = firstList
                }
            }
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
                SubscriptionFormView(subscription: nil, currentList: selectedList)
            }
            .sheet(item: $subscriptionToEdit) { subscription in
                SubscriptionFormView(subscription: subscription, currentList: selectedList)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingListManager) {
                ListManagerView(selectedList: $selectedList)
            }
            .alert("Delete Subscription", isPresented: $showingDeleteConfirmation, presenting: subscriptionToDelete) { subscription in
                Button("Cancel", role: .cancel) {
                    subscriptionToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    deleteSubscription(subscription)
                }
            } message: { subscription in
                Text("Are you sure you want to delete \"\(subscription.name)\"? This action cannot be undone.")
            }
        }
    }

    private func deleteSubscription(_ subscription: Subscription) {
        modelContext.delete(subscription)
        subscriptionToDelete = nil
    }
}

struct SubscriptionRow: View {
    let subscription: Subscription
    let currencyCode: String
    let onDelete: () -> Void

    @State private var isHovering = false

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

            // Delete button - visible on hover
            if isHovering {
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundStyle(.red)
                        .font(.body)
                }
                .buttonStyle(.plain)
                .help("Delete subscription")
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .onHover { hovering in
            isHovering = hovering
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Subscription.self, inMemory: true)
}
