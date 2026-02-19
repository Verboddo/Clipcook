//
//  GroceryViewModelTests.swift
//  ClipCookTests
//
//  Tests for GroceryViewModel CRUD operations with mock repository.
//

import Testing
import Foundation
@testable import ClipCook

@MainActor
struct GroceryViewModelTests {

    // MARK: - Listening

    @Test func startListeningCallsRepository() {
        let mockRepo = MockGroceryRepository()
        let viewModel = GroceryViewModel(repository: mockRepo)

        viewModel.startListening()

        #expect(mockRepo.startListeningCallCount == 1)
        #expect(viewModel.isLoading == false)
    }

    @Test func startListeningReceivesItems() {
        let mockRepo = MockGroceryRepository()
        mockRepo.mockItems = [
            GroceryItem(id: "1", name: "Melk", isChecked: false),
            GroceryItem(id: "2", name: "Brood", isChecked: true)
        ]
        let viewModel = GroceryViewModel(repository: mockRepo)

        viewModel.startListening()

        #expect(viewModel.items.count == 2)
        #expect(viewModel.uncheckedItems.count == 1)
        #expect(viewModel.checkedItems.count == 1)
    }

    @Test func stopListeningCallsRepository() {
        let mockRepo = MockGroceryRepository()
        let viewModel = GroceryViewModel(repository: mockRepo)

        viewModel.stopListening()

        #expect(mockRepo.stopListeningCallCount == 1)
    }

    // MARK: - Add Item

    @Test func addItemCallsRepository() async {
        let mockRepo = MockGroceryRepository()
        let viewModel = GroceryViewModel(repository: mockRepo)
        viewModel.newItemName = "Eieren"

        await viewModel.addItem()

        #expect(mockRepo.addItemCallCount == 1)
        #expect(mockRepo.lastAddedItem?.name == "Eieren")
        #expect(viewModel.newItemName == "", "newItemName should be cleared after adding")
    }

    @Test func addItemWithEmptyNameDoesNothing() async {
        let mockRepo = MockGroceryRepository()
        let viewModel = GroceryViewModel(repository: mockRepo)
        viewModel.newItemName = ""

        await viewModel.addItem()

        #expect(mockRepo.addItemCallCount == 0)
    }

    @Test func addItemHandlesError() async {
        let mockRepo = MockGroceryRepository()
        mockRepo.shouldFail = true
        let viewModel = GroceryViewModel(repository: mockRepo)
        viewModel.newItemName = "Eieren"

        await viewModel.addItem()

        #expect(viewModel.errorMessage != nil)
    }

    // MARK: - Toggle Item

    @Test func toggleItemCallsRepository() async {
        let mockRepo = MockGroceryRepository()
        let viewModel = GroceryViewModel(repository: mockRepo)
        let item = GroceryItem(id: "1", name: "Melk", isChecked: false)

        await viewModel.toggleItem(item)

        #expect(mockRepo.toggleItemCallCount == 1)
        #expect(mockRepo.lastToggledItemId == "1")
    }

    @Test func toggleItemWithoutIdDoesNothing() async {
        let mockRepo = MockGroceryRepository()
        let viewModel = GroceryViewModel(repository: mockRepo)
        let item = GroceryItem(name: "Melk", isChecked: false) // no ID

        await viewModel.toggleItem(item)

        #expect(mockRepo.toggleItemCallCount == 0)
    }

    // MARK: - Delete Item

    @Test func deleteItemCallsRepository() async {
        let mockRepo = MockGroceryRepository()
        let viewModel = GroceryViewModel(repository: mockRepo)
        let item = GroceryItem(id: "1", name: "Melk", isChecked: false)

        await viewModel.deleteItem(item)

        #expect(mockRepo.deleteItemCallCount == 1)
        #expect(mockRepo.lastDeletedItemId == "1")
    }

    // MARK: - Add Ingredients From Recipe

    @Test func addIngredientsFromRecipeCallsRepository() async {
        let mockRepo = MockGroceryRepository()
        let viewModel = GroceryViewModel(repository: mockRepo)
        let ingredients = [
            Ingredient(name: "Spaghetti", amount: "500", unit: "g"),
            Ingredient(name: "Guanciale", amount: "200", unit: "g"),
            Ingredient(name: "", amount: "", unit: "") // Empty - should be skipped
        ]

        await viewModel.addIngredientsFromRecipe(ingredients, recipeId: "recipe-1")

        #expect(mockRepo.addIngredientsCallCount == 1)
        // The mock's addIngredientsFromRecipe calls addItem for each non-empty ingredient
        #expect(mockRepo.addItemCallCount == 2, "Empty ingredient should be skipped")
    }

    // MARK: - Filtered Lists

    @Test func uncheckedItemsFiltersCorrectly() {
        let mockRepo = MockGroceryRepository()
        mockRepo.mockItems = [
            GroceryItem(id: "1", name: "Melk", isChecked: false),
            GroceryItem(id: "2", name: "Brood", isChecked: true),
            GroceryItem(id: "3", name: "Kaas", isChecked: false)
        ]
        let viewModel = GroceryViewModel(repository: mockRepo)

        viewModel.startListening()

        #expect(viewModel.uncheckedItems.count == 2)
        #expect(viewModel.checkedItems.count == 1)
        #expect(viewModel.uncheckedItems.allSatisfy { !$0.isChecked })
        #expect(viewModel.checkedItems.allSatisfy { $0.isChecked })
    }
}
