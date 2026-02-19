import Foundation
import OSLog

private let logger = Logger(subsystem: "com.clipcook.app", category: "GroceryViewModel")

@Observable
final class GroceryViewModel {
    var items: [GroceryItem] = []
    var isLoading = false
    var errorMessage: String?
    var newItemName = ""

    private let repository: GroceryRepositoryProtocol

    init(repository: GroceryRepositoryProtocol = GroceryRepository()) {
        self.repository = repository
    }

    var uncheckedItems: [GroceryItem] {
        items.filter { !$0.isChecked }
    }

    var checkedItems: [GroceryItem] {
        items.filter { $0.isChecked }
    }

    // MARK: - Listening

    func startListening() {
        isLoading = true
        repository.startListening { [weak self] result in
            guard let self else { return }
            self.isLoading = false
            switch result {
            case .success(let items):
                self.items = items
                self.errorMessage = nil
            case .failure(let error):
                self.errorMessage = error.localizedDescription
                logger.error("Grocery listening error: \(error.localizedDescription)")
            }
        }
    }

    func stopListening() {
        repository.stopListening()
    }

    // MARK: - Actions

    func addItem() async {
        guard !newItemName.isEmpty else { return }
        let item = GroceryItem(name: newItemName)
        do {
            _ = try await repository.addItem(item)
            newItemName = ""
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
            logger.error("Add grocery item error: \(error.localizedDescription)")
        }
    }

    func toggleItem(_ item: GroceryItem) async {
        guard let itemId = item.id else { return }
        do {
            try await repository.toggleItem(itemId, isChecked: !item.isChecked)
        } catch {
            errorMessage = error.localizedDescription
            logger.error("Toggle grocery item error: \(error.localizedDescription)")
        }
    }

    func deleteItem(_ item: GroceryItem) async {
        guard let itemId = item.id else { return }
        do {
            try await repository.deleteItem(itemId)
        } catch {
            errorMessage = error.localizedDescription
            logger.error("Delete grocery item error: \(error.localizedDescription)")
        }
    }

    func addIngredientsFromRecipe(_ ingredients: [Ingredient], recipeId: String) async {
        do {
            try await repository.addIngredientsFromRecipe(ingredients, recipeId: recipeId)
        } catch {
            errorMessage = error.localizedDescription
            logger.error("Add ingredients error: \(error.localizedDescription)")
        }
    }
}
