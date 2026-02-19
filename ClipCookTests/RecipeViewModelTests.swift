//
//  RecipeViewModelTests.swift
//  ClipCookTests
//
//  Tests for RecipeViewModel CRUD operations with mock repository.
//

import Testing
import Foundation
@testable import ClipCook

@MainActor
struct RecipeViewModelTests {

    // MARK: - Listening

    @Test func startListeningCallsRepository() {
        let mockRepo = MockRecipeRepository()
        let viewModel = RecipeViewModel(repository: mockRepo)

        viewModel.startListening()

        #expect(mockRepo.startListeningCallCount == 1)
        #expect(viewModel.isLoading == false)
    }

    @Test func startListeningReceivesRecipes() {
        let mockRepo = MockRecipeRepository()
        mockRepo.mockRecipes = [
            Recipe(id: "1", title: "Pasta Carbonara", sourceType: .web),
            Recipe(id: "2", title: "Caesar Salad", sourceType: .instagram)
        ]
        let viewModel = RecipeViewModel(repository: mockRepo)

        viewModel.startListening()

        #expect(viewModel.recipes.count == 2)
        #expect(viewModel.recipes[0].title == "Pasta Carbonara")
        #expect(viewModel.recipes[1].title == "Caesar Salad")
        #expect(viewModel.errorMessage == nil)
    }

    @Test func startListeningHandlesError() {
        let mockRepo = MockRecipeRepository()
        mockRepo.shouldFail = true
        let viewModel = RecipeViewModel(repository: mockRepo)

        viewModel.startListening()

        #expect(viewModel.errorMessage != nil)
    }

    @Test func stopListeningCallsRepository() {
        let mockRepo = MockRecipeRepository()
        let viewModel = RecipeViewModel(repository: mockRepo)

        viewModel.stopListening()

        #expect(mockRepo.stopListeningCallCount == 1)
    }

    // MARK: - Add Recipe

    @Test func addRecipeCallsRepository() async {
        let mockRepo = MockRecipeRepository()
        let viewModel = RecipeViewModel(repository: mockRepo)
        let recipe = Recipe(title: "New Recipe", sourceType: .manual)

        await viewModel.addRecipe(recipe)

        #expect(mockRepo.addRecipeCallCount == 1)
        #expect(mockRepo.lastAddedRecipe?.title == "New Recipe")
        #expect(viewModel.errorMessage == nil)
    }

    @Test func addRecipeHandlesError() async {
        let mockRepo = MockRecipeRepository()
        mockRepo.shouldFail = true
        let viewModel = RecipeViewModel(repository: mockRepo)
        let recipe = Recipe(title: "New Recipe", sourceType: .manual)

        await viewModel.addRecipe(recipe)

        #expect(viewModel.errorMessage != nil)
    }

    // MARK: - Update Recipe

    @Test func updateRecipeCallsRepository() async {
        let mockRepo = MockRecipeRepository()
        let viewModel = RecipeViewModel(repository: mockRepo)
        let recipe = Recipe(id: "1", title: "Updated Recipe", sourceType: .manual)

        await viewModel.updateRecipe(recipe)

        #expect(mockRepo.updateRecipeCallCount == 1)
        #expect(mockRepo.lastUpdatedRecipe?.title == "Updated Recipe")
        #expect(viewModel.errorMessage == nil)
    }

    @Test func updateRecipeHandlesError() async {
        let mockRepo = MockRecipeRepository()
        mockRepo.shouldFail = true
        let viewModel = RecipeViewModel(repository: mockRepo)
        let recipe = Recipe(id: "1", title: "Updated Recipe", sourceType: .manual)

        await viewModel.updateRecipe(recipe)

        #expect(viewModel.errorMessage != nil)
    }

    // MARK: - Delete Recipe

    @Test func deleteRecipeCallsRepository() async {
        let mockRepo = MockRecipeRepository()
        let viewModel = RecipeViewModel(repository: mockRepo)

        await viewModel.deleteRecipe("recipe-1")

        #expect(mockRepo.deleteRecipeCallCount == 1)
        #expect(mockRepo.lastDeletedRecipeId == "recipe-1")
        #expect(viewModel.errorMessage == nil)
    }

    @Test func deleteRecipeHandlesError() async {
        let mockRepo = MockRecipeRepository()
        mockRepo.shouldFail = true
        let viewModel = RecipeViewModel(repository: mockRepo)

        await viewModel.deleteRecipe("recipe-1")

        #expect(viewModel.errorMessage != nil)
    }

    // MARK: - Integration: Listener updates after CRUD

    @Test func addRecipeUpdatesListenerRecipes() async {
        let mockRepo = MockRecipeRepository()
        let viewModel = RecipeViewModel(repository: mockRepo)

        viewModel.startListening()
        #expect(viewModel.recipes.count == 0)

        await viewModel.addRecipe(Recipe(title: "First Recipe", sourceType: .manual))

        #expect(viewModel.recipes.count == 1)
        #expect(viewModel.recipes.first?.title == "First Recipe")
    }

    @Test func deleteRecipeRemovesFromList() async {
        let mockRepo = MockRecipeRepository()
        mockRepo.mockRecipes = [
            Recipe(id: "1", title: "Recipe 1", sourceType: .manual),
            Recipe(id: "2", title: "Recipe 2", sourceType: .manual)
        ]
        let viewModel = RecipeViewModel(repository: mockRepo)

        viewModel.startListening()
        #expect(viewModel.recipes.count == 2)

        await viewModel.deleteRecipe("1")

        #expect(viewModel.recipes.count == 1)
        #expect(viewModel.recipes.first?.title == "Recipe 2")
    }
}
