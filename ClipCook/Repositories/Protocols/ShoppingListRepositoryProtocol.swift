import Foundation

protocol ShoppingListRepositoryProtocol {
    func getItems() async throws -> [ShoppingItem]
    func addItem(_ item: ShoppingItem) async throws
    func addFromRecipe(_ recipe: Recipe) async throws
    func toggleItem(_ id: String) async throws
    func clearChecked() async throws
    func deleteItem(_ id: String) async throws
}
