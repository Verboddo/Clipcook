import Foundation

struct Ingredient: Identifiable, Codable, Hashable {
    var id: String = UUID().uuidString
    var name: String
    var amount: String
    var unit: String

    init(name: String = "", amount: String = "", unit: String = "") {
        self.name = name
        self.amount = amount
        self.unit = unit
    }
}
