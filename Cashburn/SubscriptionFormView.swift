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

    @State private var name: String = ""
    @State private var monthlyCost: String = ""

    private var isEditing: Bool {
        subscription != nil
    }

    private var isValid: Bool {
        !name.isEmpty && Double(monthlyCost) != nil && Double(monthlyCost)! > 0
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
        guard let cost = Double(monthlyCost) else { return }

        if let subscription {
            subscription.name = name
            subscription.monthlyCost = cost
        } else {
            let newSubscription = Subscription(name: name, monthlyCost: cost)
            modelContext.insert(newSubscription)
        }

        dismiss()
    }
}

#Preview("Add") {
    SubscriptionFormView(subscription: nil)
        .modelContainer(for: Subscription.self, inMemory: true)
}

#Preview("Edit") {
    let subscription = Subscription(name: "GitHub", monthlyCost: 21.00)
    return SubscriptionFormView(subscription: subscription)
        .modelContainer(for: Subscription.self, inMemory: true)
}
