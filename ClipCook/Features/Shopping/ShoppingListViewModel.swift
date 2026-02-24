import Foundation

@Observable
final class ShoppingListViewModel {
    var items: [ShoppingItem] = []
    var recipes: [Recipe] = []
    var newItemText = ""
    var isLoading = false

    private let shoppingRepo: ShoppingListRepositoryProtocol
    private let recipeRepo: RecipeRepositoryProtocol

    init(
        shoppingRepo: ShoppingListRepositoryProtocol = FirestoreShoppingListRepository(),
        recipeRepo: RecipeRepositoryProtocol = FirestoreRecipeRepository()
    ) {
        self.shoppingRepo = shoppingRepo
        self.recipeRepo = recipeRepo
    }

    var checkedCount: Int {
        items.filter(\.checked).count
    }

    var hasCheckedItems: Bool {
        checkedCount > 0
    }

    func loadData() async {
        isLoading = true
        do {
            items = try await shoppingRepo.getItems()
            recipes = try await recipeRepo.getAll()
        } catch {
            print("Failed to load shopping data: \(error)")
        }
        isLoading = false
    }

    func addItem() async {
        guard !newItemText.isEmpty else { return }
        var item = ShoppingItem()
        item.name = newItemText
        do {
            try await shoppingRepo.addItem(item)
            newItemText = ""
            await loadData()
        } catch {
            print("Failed to add item: \(error)")
        }
    }

    func addFromRecipe(_ recipe: Recipe) async {
        do {
            try await shoppingRepo.addFromRecipe(recipe)
            await loadData()
        } catch {
            print("Failed to add from recipe: \(error)")
        }
    }

    func toggleItem(_ item: ShoppingItem) async {
        do {
            try await shoppingRepo.toggleItem(item.id)
            await loadData()
        } catch {
            print("Failed to toggle item: \(error)")
        }
    }

    func clearChecked() async {
        do {
            try await shoppingRepo.clearChecked()
            await loadData()
        } catch {
            print("Failed to clear checked: \(error)")
        }
    }
}
