//
//  SettingsView.swift
//  Cashburn
//
//  Created by Alexandre on 09/11/2025.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("currencyCode") private var currencyCode = "USD"
    @Environment(\.dismiss) private var dismiss

    private let currencies = [
        ("USD", "US Dollar", "$"),
        ("EUR", "Euro", "€"),
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Currency", selection: $currencyCode) {
                        ForEach(currencies, id: \.0) { code, name, symbol in
                            HStack {
                                Text(name)
                                Spacer()
                                Text(symbol)
                                    .foregroundStyle(.secondary)
                                    .font(.system(.body, design: .monospaced))
                            }
                            .tag(code)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                } header: {
                    Text("Display Currency")
                } footer: {
                    Text("Select the currency to display your subscription costs")
                }
            }
            .formStyle(.grouped)
            .scrollContentBackground(.hidden)
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .frame(minWidth: 500, minHeight: 400)
    }
}

#Preview {
    SettingsView()
}
