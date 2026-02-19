import Foundation
import FirebaseFirestore
import OSLog

private let logger = Logger(subsystem: "com.clipcook.app", category: "RecipeRepository")

protocol RecipeRepositoryProtocol {
    func addRecipe(_ recipe: Recipe) async throws -> String
    func updateRecipe(_ recipe: Recipe) async throws
    func deleteRecipe(_ recipeId: String) async throws
    func startListening(onChange: @escaping (Result<[Recipe], Error>) -> Void)
    func stopListening()
}

final class RecipeRepository: RecipeRepositoryProtocol {
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

    func addRecipe(_ recipe: Recipe) async throws -> String {
        guard let userId else {
            throw RecipeRepositoryError.notAuthenticated
        }
        return try await firestoreService.addRecipe(userId: userId, recipe: recipe)
    }

    func updateRecipe(_ recipe: Recipe) async throws {
        guard let userId else {
            throw RecipeRepositoryError.notAuthenticated
        }
        guard let recipeId = recipe.id else {
            throw RecipeRepositoryError.missingId
        }
        try await firestoreService.updateRecipe(userId: userId, recipeId: recipeId, recipe: recipe)
    }

    func deleteRecipe(_ recipeId: String) async throws {
        guard let userId else {
            throw RecipeRepositoryError.notAuthenticated
        }
        try await firestoreService.deleteRecipe(userId: userId, recipeId: recipeId)
    }

    func startListening(onChange: @escaping (Result<[Recipe], Error>) -> Void) {
        guard let userId else {
            onChange(.failure(RecipeRepositoryError.notAuthenticated))
            return
        }
        listener = firestoreService.recipesListener(userId: userId, onChange: onChange)
    }

    func stopListening() {
        listener?.remove()
        listener = nil
    }
}

enum RecipeRepositoryError: LocalizedError {
    case notAuthenticated
    case missingId

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "Je moet ingelogd zijn om recepten te beheren."
        case .missingId:
            return "Recept ID ontbreekt."
        }
    }
}
