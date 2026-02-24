import Foundation
import FirebaseFirestore

struct ShoppingItem: Codable, Identifiable, Equatable {
    @DocumentID var firestoreID: String?
    var id: String { firestoreID ?? localID }
    var localID: String = UUID().uuidString
    var name: String = ""
    var recipeId: String?
    var recipeName: String?
    var checked: Bool = false
    var createdAt: Date = Date()

    enum CodingKeys: String, CodingKey {
        case firestoreID, localID, name, recipeId, recipeName, checked, createdAt
    }
}
