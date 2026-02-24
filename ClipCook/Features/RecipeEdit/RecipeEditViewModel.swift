import Foundation
import SwiftUI

@Observable
final class RecipeEditViewModel {
    var recipe: Recipe
    var isSaving = false
    var showCelebration = false

    private let recipeRepo: RecipeRepositoryProtocol

    init(recipe: Recipe, recipeRepo: RecipeRepositoryProtocol = FirestoreRecipeRepository()) {
        self.recipe = recipe
        self.recipeRepo = recipeRepo
    }

    func addIngredient() {
        recipe.ingredients.append(Ingredient())
    }

    func removeIngredient(at offsets: IndexSet) {
        recipe.ingredients.remove(atOffsets: offsets)
    }

    func moveIngredient(from source: IndexSet, to destination: Int) {
        recipe.ingredients.move(fromOffsets: source, toOffset: destination)
    }

    func addStep() {
        let nextOrder = (recipe.steps.map(\.order).max() ?? 0) + 1
        recipe.steps.append(Step(order: nextOrder, text: ""))
    }

    func removeStep(at offsets: IndexSet) {
        recipe.steps.remove(atOffsets: offsets)
        for i in recipe.steps.indices {
            recipe.steps[i].order = i + 1
        }
    }

    func moveStep(from source: IndexSet, to destination: Int) {
        recipe.steps.move(fromOffsets: source, toOffset: destination)
        for i in recipe.steps.indices {
            recipe.steps[i].order = i + 1
        }
    }

    func save() async -> Bool {
        isSaving = true
        do {
            if recipe.firestoreID != nil {
                try await recipeRepo.update(recipe)
            } else {
                recipe = try await recipeRepo.create(recipe)
            }
            showCelebration = true
            isSaving = false
            return true
        } catch {
            print("Failed to save recipe: \(error)")
            isSaving = false
            return false
        }
    }
}
