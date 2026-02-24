import Foundation
import FirebaseFirestore
import FirebaseAuth

final class FirestoreRecipeRepository: RecipeRepositoryProtocol {
    private let db = Firestore.firestore()

    private var userId: String {
        Auth.auth().currentUser?.uid ?? ""
    }

    private var recipesRef: CollectionReference {
        db.collection("users").document(userId).collection("recipes")
    }

    func getAll() async throws -> [Recipe] {
        let snapshot = try await recipesRef
            .whereField("isArchived", isEqualTo: false)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: Recipe.self) }
    }

    func getById(_ id: String) async throws -> Recipe? {
        let doc = try await recipesRef.document(id).getDocument()
        return try? doc.data(as: Recipe.self)
    }

    func create(_ recipe: Recipe) async throws -> Recipe {
        var newRecipe = recipe
        newRecipe.userId = userId
        newRecipe.createdAt = Date()
        newRecipe.updatedAt = Date()
        let ref = try recipesRef.addDocument(from: newRecipe)
        var saved = newRecipe
        saved.firestoreID = ref.documentID
        return saved
    }

    func update(_ recipe: Recipe) async throws {
        var updated = recipe
        updated.updatedAt = Date()
        try recipesRef.document(recipe.id).setData(from: updated, merge: true)
    }

    func delete(_ id: String) async throws {
        try await recipesRef.document(id).delete()
    }

    func archive(_ id: String) async throws {
        try await recipesRef.document(id).updateData([
            "isArchived": true,
            "updatedAt": Timestamp(date: Date())
        ])
    }

    func restore(_ id: String) async throws {
        try await recipesRef.document(id).updateData([
            "isArchived": false,
            "updatedAt": Timestamp(date: Date())
        ])
    }

    func getArchived() async throws -> [Recipe] {
        let snapshot = try await recipesRef
            .whereField("isArchived", isEqualTo: true)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: Recipe.self) }
    }

    func toggleFavourite(_ id: String) async throws {
        let doc = try await recipesRef.document(id).getDocument()
        guard let recipe = try? doc.data(as: Recipe.self) else { return }
        try await recipesRef.document(id).updateData([
            "isFavourite": !recipe.isFavourite,
            "updatedAt": Timestamp(date: Date())
        ])
    }
}
