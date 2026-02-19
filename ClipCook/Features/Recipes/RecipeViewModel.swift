import Foundation
import OSLog

private let logger = Logger(subsystem: "com.clipcook.app", category: "RecipeViewModel")

@Observable
final class RecipeViewModel {
    var recipes: [Recipe] = []
    var isLoading = false
    var errorMessage: String?

    private let repository: RecipeRepositoryProtocol

    init(repository: RecipeRepositoryProtocol = RecipeRepository()) {
        self.repository = repository
    }

    // MARK: - Listening

    func startListening() {
        isLoading = true
        repository.startListening { [weak self] result in
            guard let self else { return }
            self.isLoading = false
            switch result {
            case .success(let recipes):
                self.recipes = recipes
                self.errorMessage = nil
            case .failure(let error):
                self.errorMessage = error.localizedDescription
                logger.error("Recipe listening error: \(error.localizedDescription)")
            }
        }
    }

    func stopListening() {
        repository.stopListening()
    }

    // MARK: - CRUD

    func addRecipe(_ recipe: Recipe) async {
        do {
            _ = try await repository.addRecipe(recipe)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
            logger.error("Add recipe error: \(error.localizedDescription)")
        }
    }

    func updateRecipe(_ recipe: Recipe) async {
        do {
            try await repository.updateRecipe(recipe)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
            logger.error("Update recipe error: \(error.localizedDescription)")
        }
    }

    func deleteRecipe(_ recipeId: String) async {
        do {
            try await repository.deleteRecipe(recipeId)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
            logger.error("Delete recipe error: \(error.localizedDescription)")
        }
    }
}
