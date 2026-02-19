import Foundation
import FirebaseFirestore

struct GroceryItem: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var name: String
    var amount: String?
    var unit: String?
    var isChecked: Bool
    var recipeId: String?
    @ServerTimestamp var createdAt: Timestamp?

    init(
        id: String? = nil,
        name: String = "",
        amount: String? = nil,
        unit: String? = nil,
        isChecked: Bool = false,
        recipeId: String? = nil
    ) {
        self.id = id
        self.name = name
        self.amount = amount
        self.unit = unit
        self.isChecked = isChecked
        self.recipeId = recipeId
    }
}
