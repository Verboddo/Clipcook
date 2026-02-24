import Foundation

@Observable
final class HomeViewModel {
    var recipes: [Recipe] = []
    var searchText = ""
    var selectedFilter: FilterCategory = .all
    var isLoading = false

    private let recipeRepo: RecipeRepositoryProtocol

    init(recipeRepo: RecipeRepositoryProtocol = FirestoreRecipeRepository()) {
        self.recipeRepo = recipeRepo
    }

    var filteredRecipes: [Recipe] {
        var result = recipes

        if !searchText.isEmpty {
            result = result.filter { $0.title.localizedStandardContains(searchText) }
        }

        switch selectedFilter {
        case .all:
            break
        case .favorites:
            result = result.filter { $0.isFavourite }
        case .breakfast:
            result = result.filter { $0.category == .breakfast }
        case .lunch:
            result = result.filter { $0.category == .lunch }
        case .dinner:
            result = result.filter { $0.category == .dinner }
        case .snack:
            result = result.filter { $0.category == .snack }
        }

        return result
    }

    func loadRecipes() async {
        isLoading = true
        do {
            recipes = try await recipeRepo.getAll()
        } catch {
            print("Failed to load recipes: \(error)")
        }
        isLoading = false
    }

    func toggleFavourite(_ recipe: Recipe) async {
        do {
            try await recipeRepo.toggleFavourite(recipe.id)
            await loadRecipes()
        } catch {
            print("Failed to toggle favourite: \(error)")
        }
    }
}
