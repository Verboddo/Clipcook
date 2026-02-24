import Foundation
import FirebaseFirestore
import FirebaseAuth

final class FirestorePendingImportRepository: PendingImportRepositoryProtocol {
    private let db = Firestore.firestore()

    private var userId: String {
        Auth.auth().currentUser?.uid ?? ""
    }

    private var importsRef: CollectionReference {
        db.collection("users").document(userId).collection("pendingImports")
    }

    func getPending() async throws -> [PendingImport] {
        let snapshot = try await importsRef
            .order(by: "createdAt", descending: true)
            .getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: PendingImport.self) }
    }

    func add(_ pendingImport: PendingImport) async throws {
        try importsRef.addDocument(from: pendingImport)
    }

    func remove(_ id: String) async throws {
        try await importsRef.document(id).delete()
    }

    func updateStatus(_ id: String, status: ImportStatus) async throws {
        try await importsRef.document(id).updateData(["status": status.rawValue])
    }
}
