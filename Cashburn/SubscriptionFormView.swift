//
//  SubscriptionFormView.swift
//  Cashburn
//
//  Created by Alexandre on 09/11/2025.
//

import SwiftUI
import SwiftData

struct SubscriptionFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @AppStorage("currencyCode") private var currencyCode = "USD"

    let subscription: Subscription?
    let currentList: SubscriptionList?

    @State private var name: String = ""
    @State private var monthlyCost: String = ""

    private var isEditing: Bool {
        subscription != nil
    }

    private var isValid: Bool {
        !name.isEmpty && parseAmount(monthlyCost) != nil && parseAmount(monthlyCost)! > 0
    }

    // Parse amount handling both comma and dot as decimal separator
    private func parseAmount(_ text: String) -> Double? {
        // Replace comma with dot for parsing
        let normalized = text.replacingOccurrences(of: ",", with: ".")
        return Double(normalized)
    }

    private var currencySymbol: String {
        let locale = Locale(identifier: "en_US")
        return locale.localizedString(forCurrencyCode: currencyCode) ?? currencyCode
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $name)
                        .textFieldStyle(.plain)
                        .font(.body)

                    HStack {
                        Text(currencyCode)
                            .foregroundStyle(.secondary)
                            .font(.system(.body, design: .monospaced))
                            .fontWeight(.medium)
                        TextField("0.00", text: $monthlyCost)
                            .textFieldStyle(.plain)
                            .font(.body)
                            .onChange(of: monthlyCost) { oldValue, newValue in
                                // Allow only numbers, dots, and commas
                                let filtered = newValue.filter { "0123456789.,".contains($0) }
                                if filtered != newValue {
                                    monthlyCost = filtered
                                }
                            }
                    }
                } header: {
                    Text("Subscription Details")
                } footer: {
                    Text("Enter the monthly cost for this subscription in \(currencyCode)")
                        .font(.caption)
                }
            }
            .formStyle(.grouped)
            .scrollContentBackground(.hidden)
            .navigationTitle(isEditing ? "Edit Subscription" : "New Subscription")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Save" : "Add") {
                        saveSubscription()
                    }
                    .disabled(!isValid)
                }
            }
            .onAppear {
                if let subscription {
                    name = subscription.name
                    monthlyCost = String(format: "%.2f", subscription.monthlyCost)
                }
            }
        }
        .frame(minWidth: 400, minHeight: 300)
    }

    private func saveSubscription() {
        guard let cost = parseAmount(monthlyCost) else { return }

        if let subscription {
            subscription.name = name
            subscription.monthlyCost = cost
        } else {
            let newSubscription = Subscription(name: name, monthlyCost: cost, list: currentList)
            modelContext.insert(newSubscription)
        }

        dismiss()
    }
}

#Preview("Add") {
    SubscriptionFormView(subscription: nil, currentList: nil)
        .modelContainer(for: Subscription.self, inMemory: true)
}

#Preview("Edit") {
    let subscription = Subscription(name: "GitHub", monthlyCost: 21.00)
    return SubscriptionFormView(subscription: subscription, currentList: nil)
        .modelContainer(for: Subscription.self, inMemory: true)
}
