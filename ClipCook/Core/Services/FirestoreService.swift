import Foundation
import FirebaseFirestore
import OSLog

private let logger = Logger(subsystem: "com.clipcook.app", category: "FirestoreService")

/// Protocol for user profile operations — used by ViewModels for dependency injection and testability.
protocol UserProfileServiceProtocol {
    func createUserProfile(userId: String, profile: UserProfile) async throws
    func getUserProfile(userId: String) async throws -> UserProfile?
    func updateUserProfile(userId: String, data: [String: Any]) async throws
}

final class FirestoreService: UserProfileServiceProtocol {
    static let shared = FirestoreService()

    private let db = Firestore.firestore()

    private init() {}

    // MARK: - User Profile

    func createUserProfile(userId: String, profile: UserProfile) async throws {
        try db.collection("users").document(userId).setData(from: profile)
        logger.info("User profile created for \(userId)")
    }

    func getUserProfile(userId: String) async throws -> UserProfile? {
        let document = try await db.collection("users").document(userId).getDocument()
        return try document.data(as: UserProfile.self)
    }

    func updateUserProfile(userId: String, data: [String: Any]) async throws {
        var updateData = data
        updateData["updatedAt"] = FieldValue.serverTimestamp()
        try await db.collection("users").document(userId).updateData(updateData)
        logger.info("User profile updated for \(userId)")
    }

    // MARK: - Recipes

    private func recipesCollection(userId: String) -> CollectionReference {
        db.collection("users").document(userId).collection("recipes")
    }

    func addRecipe(userId: String, recipe: Recipe) async throws -> String {
        var recipeData = recipe
        recipeData.updatedAt = nil // Let server set timestamp
        let ref = try recipesCollection(userId: userId).addDocument(from: recipeData)
        logger.info("Recipe added: \(ref.documentID)")
        return ref.documentID
    }

    func updateRecipe(userId: String, recipeId: String, recipe: Recipe) async throws {
        try recipesCollection(userId: userId).document(recipeId).setData(from: recipe, merge: true)
        logger.info("Recipe updated: \(recipeId)")
    }

    func deleteRecipe(userId: String, recipeId: String) async throws {
        try await recipesCollection(userId: userId).document(recipeId).delete()
        logger.info("Recipe deleted: \(recipeId)")
    }

    func recipesListener(
        userId: String,
        onChange: @escaping (Result<[Recipe], Error>) -> Void
    ) -> ListenerRegistration {
        recipesCollection(userId: userId)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error {
                    logger.error("Recipes listener error: \(error.localizedDescription)")
                    onChange(.failure(error))
                    return
                }
                guard let snapshot else { return }
                let recipes = snapshot.documents.compactMap { doc in
                    try? doc.data(as: Recipe.self)
                }
                onChange(.success(recipes))
            }
    }

    // MARK: - Grocery Items

    private func groceryCollection(userId: String) -> CollectionReference {
        db.collection("users").document(userId).collection("groceryItems")
    }

    func addGroceryItem(userId: String, item: GroceryItem) async throws -> String {
        let ref = try groceryCollection(userId: userId).addDocument(from: item)
        logger.info("Grocery item added: \(ref.documentID)")
        return ref.documentID
    }

    func updateGroceryItem(userId: String, itemId: String, data: [String: Any]) async throws {
        try await groceryCollection(userId: userId).document(itemId).updateData(data)
    }

    func deleteGroceryItem(userId: String, itemId: String) async throws {
        try await groceryCollection(userId: userId).document(itemId).delete()
    }

    func groceryItemsListener(
        userId: String,
        onChange: @escaping (Result<[GroceryItem], Error>) -> Void
    ) -> ListenerRegistration {
        groceryCollection(userId: userId)
            .order(by: "createdAt", descending: false)
            .addSnapshotListener { snapshot, error in
                if let error {
                    logger.error("Grocery listener error: \(error.localizedDescription)")
                    onChange(.failure(error))
                    return
                }
                guard let snapshot else { return }
                let items = snapshot.documents.compactMap { doc in
                    try? doc.data(as: GroceryItem.self)
                }
                onChange(.success(items))
            }
    }
}
