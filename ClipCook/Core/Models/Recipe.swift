import Foundation
import FirebaseFirestore

struct Recipe: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var title: String
    var sourceURL: String?
    var sourceType: SourceType
    var imageURL: String?
    var ingredients: [Ingredient]
    var steps: [String]
    var servings: Int?
    var calories: Int?
    var macros: Macros?
    var tags: [String]
    var notes: String?
    @ServerTimestamp var createdAt: Timestamp?
    @ServerTimestamp var updatedAt: Timestamp?

    enum SourceType: String, Codable, CaseIterable {
        case manual
        case instagram
        case tiktok
        case youtube
        case web
    }

    struct Macros: Codable, Hashable {
        var protein: Int
        var carbs: Int
        var fat: Int
    }

    init(
        id: String? = nil,
        title: String = "",
        sourceURL: String? = nil,
        sourceType: SourceType = .manual,
        imageURL: String? = nil,
        ingredients: [Ingredient] = [],
        steps: [String] = [],
        servings: Int? = nil,
        calories: Int? = nil,
        macros: Macros? = nil,
        tags: [String] = [],
        notes: String? = nil
    ) {
        self.id = id
        self.title = title
        self.sourceURL = sourceURL
        self.sourceType = sourceType
        self.imageURL = imageURL
        self.ingredients = ingredients
        self.steps = steps
        self.servings = servings
        self.calories = calories
        self.macros = macros
        self.tags = tags
        self.notes = notes
    }
}
