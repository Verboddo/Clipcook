import Foundation

protocol RecipeRepositoryProtocol {
    func getAll() async throws -> [Recipe]
    func getById(_ id: String) async throws -> Recipe?
    func create(_ recipe: Recipe) async throws -> Recipe
    func update(_ recipe: Recipe) async throws
    func delete(_ id: String) async throws
    func archive(_ id: String) async throws
    func restore(_ id: String) async throws
    func getArchived() async throws -> [Recipe]
    func toggleFavourite(_ id: String) async throws
}
