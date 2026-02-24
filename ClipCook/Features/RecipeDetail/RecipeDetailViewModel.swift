import Foundation

@Observable
final class RecipeDetailViewModel {
    var recipe: Recipe?
    var checkedIngredients: Set<String> = []
    var displayServings: Int = 1
    var showNutrition = false
    var showMenu = false
    var showToast = false
    var toastMessage = ""
    var toastUndoAction: (() -> Void)?

    private let recipeRepo: RecipeRepositoryProtocol

    init(recipeRepo: RecipeRepositoryProtocol = FirestoreRecipeRepository()) {
        self.recipeRepo = recipeRepo
    }

    func loadRecipe(_ id: String) async {
        do {
            recipe = try await recipeRepo.getById(id)
            displayServings = recipe?.servings ?? 1
        } catch {
            print("Failed to load recipe: \(error)")
        }
    }

    func toggleIngredient(_ id: String) {
        if checkedIngredients.contains(id) {
            checkedIngredients.remove(id)
        } else {
            checkedIngredients.insert(id)
        }
    }

    func toggleFavourite() async {
        guard let recipe else { return }
        do {
            try await recipeRepo.toggleFavourite(recipe.id)
            await loadRecipe(recipe.id)
        } catch {
            print("Failed to toggle favourite: \(error)")
        }
    }

    func archiveRecipe() async {
        guard let recipe else { return }
        do {
            try await recipeRepo.archive(recipe.id)
            toastMessage = "Recipe archived"
            toastUndoAction = { [weak self] in
                Task { [weak self] in
                    try? await self?.recipeRepo.restore(recipe.id)
                    await self?.loadRecipe(recipe.id)
                }
            }
            showToast = true
        } catch {
            print("Failed to archive: \(error)")
        }
    }

    func deleteRecipe() async {
        guard let recipe else { return }
        let backup = recipe
        do {
            try await recipeRepo.delete(recipe.id)
            toastMessage = "Recipe deleted"
            toastUndoAction = {
                Task {
                    _ = try? await FirestoreRecipeRepository().create(backup)
                }
            }
            showToast = true
            self.recipe = nil
        } catch {
            print("Failed to delete: \(error)")
        }
    }
}
