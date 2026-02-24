import Foundation
import FirebaseFirestore

struct MealSlot: Codable, Identifiable, Equatable {
    @DocumentID var firestoreID: String?
    var id: String { firestoreID ?? localID }
    var localID: String = UUID().uuidString
    var day: String = ""
    var meal: MealType = .dinner
    var recipeId: String?
    var quickAdd: QuickAddItem?
    var createdAt: Date = Date()

    enum CodingKeys: String, CodingKey {
        case firestoreID, localID, day, meal, recipeId, quickAdd, createdAt
    }
}

struct QuickAddItem: Codable, Equatable, Identifiable {
    var id: String { name }
    var name: String
    var calories: Int
    var protein: Int
    var carbs: Int
    var fats: Int

    static let presets: [QuickAddItem] = [
        QuickAddItem(name: "Banana", calories: 105, protein: 1, carbs: 27, fats: 0),
        QuickAddItem(name: "Apple", calories: 95, protein: 0, carbs: 25, fats: 0),
        QuickAddItem(name: "Greek Yogurt", calories: 130, protein: 12, carbs: 9, fats: 5),
        QuickAddItem(name: "Protein Bar", calories: 200, protein: 20, carbs: 22, fats: 7),
        QuickAddItem(name: "Handful of Nuts", calories: 170, protein: 5, carbs: 6, fats: 15),
        QuickAddItem(name: "Hard Boiled Egg", calories: 78, protein: 6, carbs: 1, fats: 5),
        QuickAddItem(name: "Rice Cake", calories: 35, protein: 1, carbs: 7, fats: 0),
        QuickAddItem(name: "Orange", calories: 62, protein: 1, carbs: 15, fats: 0),
    ]
}
