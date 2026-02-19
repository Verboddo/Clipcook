import Foundation
import FirebaseFirestore
import OSLog

private let logger = Logger(subsystem: "com.clipcook.app", category: "GroceryRepository")

protocol GroceryRepositoryProtocol {
    func addItem(_ item: GroceryItem) async throws -> String
    func toggleItem(_ itemId: String, isChecked: Bool) async throws
    func deleteItem(_ itemId: String) async throws
    func addIngredientsFromRecipe(_ ingredients: [Ingredient], recipeId: String) async throws
    func startListening(onChange: @escaping (Result<[GroceryItem], Error>) -> Void)
    func stopListening()
}

final class GroceryRepository: GroceryRepositoryProtocol {
    private let firestoreService: FirestoreService
    private let authService: AuthServiceProtocol
    private var listener: ListenerRegistration?

    init(
        firestoreService: FirestoreService = .shared,
        authService: AuthServiceProtocol = AuthService.shared
    ) {
        self.firestoreService = firestoreService
        self.authService = authService
    }

    private var userId: String? {
        authService.currentUserId
    }

    func addItem(_ item: GroceryItem) async throws -> String {
        guard let userId else {
            throw GroceryRepositoryError.notAuthenticated
        }
        return try await firestoreService.addGroceryItem(userId: userId, item: item)
    }

    func toggleItem(_ itemId: String, isChecked: Bool) async throws {
        guard let userId else {
            throw GroceryRepositoryError.notAuthenticated
        }
        try await firestoreService.updateGroceryItem(
            userId: userId,
            itemId: itemId,
            data: ["isChecked": isChecked]
        )
    }

    func deleteItem(_ itemId: String) async throws {
        guard let userId else {
            throw GroceryRepositoryError.notAuthenticated
        }
        try await firestoreService.deleteGroceryItem(userId: userId, itemId: itemId)
    }

    func addIngredientsFromRecipe(_ ingredients: [Ingredient], recipeId: String) async throws {
        guard let userId else {
            throw GroceryRepositoryError.notAuthenticated
        }
        for ingredient in ingredients where !ingredient.name.isEmpty {
            let item = GroceryItem(
                name: ingredient.name,
                amount: ingredient.amount.isEmpty ? nil : ingredient.amount,
                unit: ingredient.unit.isEmpty ? nil : ingredient.unit,
                recipeId: recipeId
            )
            _ = try await firestoreService.addGroceryItem(userId: userId, item: item)
        }
        logger.info("Added \(ingredients.count) ingredients to grocery list from recipe \(recipeId)")
    }

    func startListening(onChange: @escaping (Result<[GroceryItem], Error>) -> Void) {
        guard let userId else {
            onChange(.failure(GroceryRepositoryError.notAuthenticated))
            return
        }
        listener = firestoreService.groceryItemsListener(userId: userId, onChange: onChange)
    }

    func stopListening() {
        listener?.remove()
        listener = nil
    }
}

enum GroceryRepositoryError: LocalizedError {
    case notAuthenticated

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "Je moet ingelogd zijn om je boodschappenlijst te beheren."
        }
    }
}
