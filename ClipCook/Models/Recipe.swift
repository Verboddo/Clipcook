import Foundation
import FirebaseFirestore

struct Recipe: Codable, Identifiable, Equatable, Hashable {
    @DocumentID var firestoreID: String?
    var id: String { firestoreID ?? localID }
    var localID: String = UUID().uuidString
    var userId: String = ""
    var title: String = ""
    var thumbnail: String?
    var sourceUrl: String?
    var sourcePlatform: SourcePlatform?
    var caption: String?
    var prepTime: String = ""
    var cookTime: String = ""
    var servings: Int = 1
    var category: RecipeCategory = .dinner
    var ingredients: [Ingredient] = []
    var steps: [Step] = []
    var nutrition: Nutrition?
    var aiMeta: AIMeta?
    var isArchived: Bool = false
    var isFavourite: Bool = false
    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    static func == (lhs: Recipe, rhs: Recipe) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    enum CodingKeys: String, CodingKey {
        case firestoreID
        case localID, userId, title, thumbnail, sourceUrl, sourcePlatform
        case caption, prepTime, cookTime, servings, category
        case ingredients, steps, nutrition, aiMeta
        case isArchived, isFavourite, createdAt, updatedAt
    }
}

struct Ingredient: Codable, Identifiable, Equatable {
    var id: String = UUID().uuidString
    var name: String = ""
    var amount: String = ""
    var notes: String?
}

struct Step: Codable, Identifiable, Equatable {
    var id: String = UUID().uuidString
    var order: Int = 1
    var text: String = ""
}

struct Nutrition: Codable, Equatable {
    var calories: Int = 0
    var protein: Int = 0
    var carbs: Int = 0
    var fats: Int = 0
}

struct AIMeta: Codable, Equatable {
    var enabled: Bool = false
    var modelVersion: String?
    var lastRun: Date?
}
