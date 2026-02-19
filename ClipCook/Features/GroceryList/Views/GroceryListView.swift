import SwiftUI

struct GroceryListView: View {
    @State private var viewModel = GroceryViewModel()

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Boodschappenlijst laden...")
            } else if viewModel.items.isEmpty {
                EmptyStateView(
                    icon: "cart",
                    title: "Boodschappenlijst is leeg",
                    message: "Voeg items toe of gebruik 'Naar boodschappenlijst' bij een recept."
                )
            } else {
                List {
                    // Unchecked items
                    if !viewModel.uncheckedItems.isEmpty {
                        Section("Te kopen") {
                            ForEach(viewModel.uncheckedItems) { item in
                                GroceryItemRow(item: item) {
                                    Task { await viewModel.toggleItem(item) }
                                }
                            }
                            .onDelete { offsets in
                                deleteItems(from: viewModel.uncheckedItems, at: offsets)
                            }
                        }
                    }

                    // Checked items
                    if !viewModel.checkedItems.isEmpty {
                        Section("Afgevinkt") {
                            ForEach(viewModel.checkedItems) { item in
                                GroceryItemRow(item: item) {
                                    Task { await viewModel.toggleItem(item) }
                                }
                            }
                            .onDelete { offsets in
                                deleteItems(from: viewModel.checkedItems, at: offsets)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Boodschappen")
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                HStack {
                    TextField("Item toevoegen...", text: $viewModel.newItemName)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit {
                            Task { await viewModel.addItem() }
                        }

                    Button {
                        Task { await viewModel.addItem() }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                    .disabled(viewModel.newItemName.isEmpty)
                }
            }
        }
        .onAppear {
            viewModel.startListening()
        }
        .onDisappear {
            viewModel.stopListening()
        }
    }

    private func deleteItems(from items: [GroceryItem], at offsets: IndexSet) {
        for index in offsets {
            let item = items[index]
            Task { await viewModel.deleteItem(item) }
        }
    }
}

struct GroceryItemRow: View {
    let item: GroceryItem
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack {
                Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(item.isChecked ? .green : .secondary)

                VStack(alignment: .leading) {
                    Text(item.name)
                        .strikethrough(item.isChecked)
                        .foregroundStyle(item.isChecked ? .secondary : .primary)

                    if let amount = item.amount, let unit = item.unit {
                        Text("\(amount) \(unit)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        GroceryListView()
    }
}
