import Foundation
@testable import ClipCook

/// Mock implementation of RecipeRepositoryProtocol for unit testing.
final class MockRecipeRepository: RecipeRepositoryProtocol {

    // MARK: - Configurable Behavior

    var shouldFail = false
    var mockError: Error = NSError(domain: "test", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock repository error"])
    var mockRecipes: [Recipe] = []

    // MARK: - Call Tracking

    var addRecipeCallCount = 0
    var updateRecipeCallCount = 0
    var deleteRecipeCallCount = 0
    var startListeningCallCount = 0
    var stopListeningCallCount = 0
    var lastAddedRecipe: Recipe?
    var lastUpdatedRecipe: Recipe?
    var lastDeletedRecipeId: String?

    private var onChange: ((Result<[Recipe], Error>) -> Void)?

    // MARK: - RecipeRepositoryProtocol

    func addRecipe(_ recipe: Recipe) async throws -> String {
        addRecipeCallCount += 1
        lastAddedRecipe = recipe
        if shouldFail { throw mockError }
        let id = "mock-recipe-\(addRecipeCallCount)"
        var savedRecipe = recipe
        savedRecipe.id = id
        mockRecipes.append(savedRecipe)
        onChange?(.success(mockRecipes))
        return id
    }

    func updateRecipe(_ recipe: Recipe) async throws {
        updateRecipeCallCount += 1
        lastUpdatedRecipe = recipe
        if shouldFail { throw mockError }
        if let index = mockRecipes.firstIndex(where: { $0.id == recipe.id }) {
            mockRecipes[index] = recipe
            onChange?(.success(mockRecipes))
        }
    }

    func deleteRecipe(_ recipeId: String) async throws {
        deleteRecipeCallCount += 1
        lastDeletedRecipeId = recipeId
        if shouldFail { throw mockError }
        mockRecipes.removeAll { $0.id == recipeId }
        onChange?(.success(mockRecipes))
    }

    func startListening(onChange: @escaping (Result<[Recipe], Error>) -> Void) {
        startListeningCallCount += 1
        self.onChange = onChange
        if shouldFail {
            onChange(.failure(mockError))
        } else {
            onChange(.success(mockRecipes))
        }
    }

    func stopListening() {
        stopListeningCallCount += 1
        onChange = nil
    }
}
