import Foundation
import FirebaseFirestore

struct PendingImport: Codable, Identifiable, Equatable {
    @DocumentID var firestoreID: String?
    var id: String { firestoreID ?? localID }
    var localID: String = UUID().uuidString
    var url: String = ""
    var status: ImportStatus = .importing
    var title: String?
    var thumbnail: String?
    var caption: String?
    var createdAt: Date = Date()

    enum CodingKeys: String, CodingKey {
        case firestoreID, localID, url, status, title, thumbnail, caption, createdAt
    }
}
