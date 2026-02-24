import Foundation
import FirebaseFirestore
import FirebaseAuth

final class FirestoreMealPlanRepository: MealPlanRepositoryProtocol {
    private let db = Firestore.firestore()

    private var userId: String {
        Auth.auth().currentUser?.uid ?? ""
    }

    private var slotsRef: CollectionReference {
        db.collection("users").document(userId).collection("mealSlots")
    }

    func getSlots(for day: String) async throws -> [MealSlot] {
        let snapshot = try await slotsRef
            .whereField("day", isEqualTo: day)
            .getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: MealSlot.self) }
    }

    func addSlot(_ slot: MealSlot) async throws {
        var newSlot = slot
        newSlot.createdAt = Date()
        try slotsRef.addDocument(from: newSlot)
    }

    func removeSlot(_ id: String) async throws {
        try await slotsRef.document(id).delete()
    }
}
