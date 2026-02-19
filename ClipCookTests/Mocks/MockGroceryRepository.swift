import Foundation
@testable import ClipCook

/// Mock implementation of GroceryRepositoryProtocol for unit testing.
final class MockGroceryRepository: GroceryRepositoryProtocol {

    // MARK: - Configurable Behavior

    var shouldFail = false
    var mockError: Error = NSError(domain: "test", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock repository error"])
    var mockItems: [GroceryItem] = []

    // MARK: - Call Tracking

    var addItemCallCount = 0
    var toggleItemCallCount = 0
    var deleteItemCallCount = 0
    var addIngredientsCallCount = 0
    var startListeningCallCount = 0
    var stopListeningCallCount = 0
    var lastAddedItem: GroceryItem?
    var lastToggledItemId: String?
    var lastDeletedItemId: String?

    private var onChange: ((Result<[GroceryItem], Error>) -> Void)?

    // MARK: - GroceryRepositoryProtocol

    func addItem(_ item: GroceryItem) async throws -> String {
        addItemCallCount += 1
        lastAddedItem = item
        if shouldFail { throw mockError }
        let id = "mock-item-\(addItemCallCount)"
        var savedItem = item
        savedItem.id = id
        mockItems.append(savedItem)
        onChange?(.success(mockItems))
        return id
    }

    func toggleItem(_ itemId: String, isChecked: Bool) async throws {
        toggleItemCallCount += 1
        lastToggledItemId = itemId
        if shouldFail { throw mockError }
        if let index = mockItems.firstIndex(where: { $0.id == itemId }) {
            mockItems[index].isChecked = isChecked
            onChange?(.success(mockItems))
        }
    }

    func deleteItem(_ itemId: String) async throws {
        deleteItemCallCount += 1
        lastDeletedItemId = itemId
        if shouldFail { throw mockError }
        mockItems.removeAll { $0.id == itemId }
        onChange?(.success(mockItems))
    }

    func addIngredientsFromRecipe(_ ingredients: [Ingredient], recipeId: String) async throws {
        addIngredientsCallCount += 1
        if shouldFail { throw mockError }
        for ingredient in ingredients where !ingredient.name.isEmpty {
            let item = GroceryItem(
                name: ingredient.name,
                amount: ingredient.amount.isEmpty ? nil : ingredient.amount,
                unit: ingredient.unit.isEmpty ? nil : ingredient.unit,
                recipeId: recipeId
            )
            _ = try await addItem(item)
        }
    }

    func startListening(onChange: @escaping (Result<[GroceryItem], Error>) -> Void) {
        startListeningCallCount += 1
        self.onChange = onChange
        if shouldFail {
            onChange(.failure(mockError))
        } else {
            onChange(.success(mockItems))
        }
    }

    func stopListening() {
        stopListeningCallCount += 1
        onChange = nil
    }
}
