import Foundation
import FirebaseFirestore

struct AppUser: Codable, Identifiable {
    @DocumentID var firestoreID: String?
    var id: String { firestoreID ?? "" }
    var email: String
    var displayName: String
    var units: MeasurementUnit = .metric
    var darkMode: Bool = false
    var isPremium: Bool = false
    var flags: FeatureFlags = FeatureFlags()
    var nutritionGoals: NutritionGoals = NutritionGoals()
    var schemaVersion: Int = 1
    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    static var empty: AppUser {
        AppUser(email: "", displayName: "")
    }
}
