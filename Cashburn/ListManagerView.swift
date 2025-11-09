//
//  ListManagerView.swift
//  Cashburn
//
//  Created by Alexandre on 09/11/2025.
//

import SwiftUI
import SwiftData

struct ListManagerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \SubscriptionList.name) private var lists: [SubscriptionList]
    @Binding var selectedList: SubscriptionList?

    @State private var newListName = ""
    @State private var editingList: SubscriptionList?
    @State private var editingName = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    ForEach(lists) { list in
                        HStack {
                            if editingList?.id == list.id {
                                TextField("List name", text: $editingName)
                                    .textFieldStyle(.plain)
                                    .onSubmit {
                                        saveEdit()
                                    }

                                Button("Save") {
                                    saveEdit()
                                }
                                .buttonStyle(.borderless)
                            } else {
                                Text(list.name)
                                    .font(.body)

                                Spacer()

                                Button(action: {
                                    editingList = list
                                    editingName = list.name
                                }) {
                                    Image(systemName: "pencil")
                                }
                                .buttonStyle(.borderless)

                                Button(action: {
                                    deleteList(list)
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundStyle(.red)
                                }
                                .buttonStyle(.borderless)
                                .disabled(lists.count == 1)
                            }
                        }
                    }
                } header: {
                    Text("Your Lists")
                }

                Section {
                    HStack {
                        TextField("New list name", text: $newListName)
                            .textFieldStyle(.plain)
                            .onSubmit {
                                addList()
                            }

                        Button(action: addList) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(.green)
                        }
                        .buttonStyle(.borderless)
                        .disabled(newListName.isEmpty)
                    }
                } header: {
                    Text("Add New List")
                }
            }
            .formStyle(.grouped)
            .scrollContentBackground(.hidden)
            .navigationTitle("Manage Lists")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .frame(minWidth: 400, minHeight: 300)
    }

    private func addList() {
        guard !newListName.isEmpty else { return }

        let newList = SubscriptionList(name: newListName)
        modelContext.insert(newList)

        if selectedList == nil {
            selectedList = newList
        }

        newListName = ""
    }

    private func saveEdit() {
        guard let editingList, !editingName.isEmpty else { return }

        editingList.name = editingName
        self.editingList = nil
        editingName = ""
    }

    private func deleteList(_ list: SubscriptionList) {
        // Don't allow deleting the last list
        guard lists.count > 1 else { return }

        // If deleting the selected list, select another one
        if selectedList?.id == list.id {
            selectedList = lists.first { $0.id != list.id }
        }

        modelContext.delete(list)
    }
}

#Preview {
    ListManagerView(selectedList: .constant(nil))
        .modelContainer(for: SubscriptionList.self, inMemory: true)
}
