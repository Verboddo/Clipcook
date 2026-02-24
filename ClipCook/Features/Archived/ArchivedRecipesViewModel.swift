import Foundation

@Observable
final class ArchivedRecipesViewModel {
    var recipes: [Recipe] = []
    var showToast = false
    var toastMessage = ""
    var toastUndoAction: (() -> Void)?

    private let recipeRepo: RecipeRepositoryProtocol

    init(recipeRepo: RecipeRepositoryProtocol = FirestoreRecipeRepository()) {
        self.recipeRepo = recipeRepo
    }

    func loadArchived() async {
        do {
            recipes = try await recipeRepo.getArchived()
        } catch {
            print("Failed to load archived recipes: \(error)")
        }
    }

    func restoreRecipe(_ recipe: Recipe) async {
        do {
            try await recipeRepo.restore(recipe.id)
            toastMessage = "Recipe restored"
            toastUndoAction = { [weak self] in
                Task {
                    try? await self?.recipeRepo.archive(recipe.id)
                    await self?.loadArchived()
                }
            }
            showToast = true
            await loadArchived()
        } catch {
            print("Failed to restore: \(error)")
        }
    }

    func deleteRecipe(_ recipe: Recipe) async {
        do {
            try await recipeRepo.delete(recipe.id)
            toastMessage = "Recipe permanently deleted"
            showToast = true
            await loadArchived()
        } catch {
            print("Failed to delete: \(error)")
        }
    }
}
