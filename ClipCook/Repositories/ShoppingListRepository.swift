import Foundation
import FirebaseFirestore
import FirebaseAuth

final class FirestoreShoppingListRepository: ShoppingListRepositoryProtocol {
    private let db = Firestore.firestore()

    private var userId: String {
        Auth.auth().currentUser?.uid ?? ""
    }

    private var itemsRef: CollectionReference {
        db.collection("users").document(userId).collection("shoppingItems")
    }

    func getItems() async throws -> [ShoppingItem] {
        let snapshot = try await itemsRef
            .order(by: "createdAt", descending: false)
            .getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: ShoppingItem.self) }
    }

    func addItem(_ item: ShoppingItem) async throws {
        var newItem = item
        newItem.createdAt = Date()
        try itemsRef.addDocument(from: newItem)
    }

    func addFromRecipe(_ recipe: Recipe) async throws {
        for ingredient in recipe.ingredients {
            var item = ShoppingItem()
            item.name = "\(ingredient.amount) \(ingredient.name)"
            item.recipeId = recipe.id
            item.recipeName = recipe.title
            try itemsRef.addDocument(from: item)
        }
    }

    func toggleItem(_ id: String) async throws {
        let doc = try await itemsRef.document(id).getDocument()
        guard let item = try? doc.data(as: ShoppingItem.self) else { return }
        try await itemsRef.document(id).updateData(["checked": !item.checked])
    }

    func clearChecked() async throws {
        let snapshot = try await itemsRef
            .whereField("checked", isEqualTo: true)
            .getDocuments()
        let batch = db.batch()
        for doc in snapshot.documents {
            batch.deleteDocument(doc.reference)
        }
        try await batch.commit()
    }

    func deleteItem(_ id: String) async throws {
        try await itemsRef.document(id).delete()
    }
}
