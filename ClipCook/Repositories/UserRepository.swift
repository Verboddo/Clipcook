import Foundation
import FirebaseFirestore

final class FirestoreUserRepository: UserRepositoryProtocol {
    private let db = Firestore.firestore()

    private var usersRef: CollectionReference {
        db.collection("users")
    }

    func getUser(_ userId: String) async throws -> AppUser? {
        let doc = try await usersRef.document(userId).getDocument()
        return try? doc.data(as: AppUser.self)
    }

    func createUser(_ user: AppUser) async throws {
        try usersRef.document(user.id).setData(from: user)
    }

    func updatePreferences(_ userId: String, units: MeasurementUnit?, darkMode: Bool?) async throws {
        var data: [String: Any] = ["updatedAt": Timestamp(date: Date())]
        if let units { data["units"] = units.rawValue }
        if let darkMode { data["darkMode"] = darkMode }
        try await usersRef.document(userId).updateData(data)
    }

    func updateNutritionGoals(_ userId: String, goals: NutritionGoals) async throws {
        try await usersRef.document(userId).updateData([
            "nutritionGoals": [
                "calories": goals.calories,
                "protein": goals.protein,
                "carbs": goals.carbs,
                "fats": goals.fats
            ],
            "updatedAt": Timestamp(date: Date())
        ])
    }

    func updatePremiumStatus(_ userId: String, isPremium: Bool, flags: FeatureFlags) async throws {
        let flagsData: [String: Any] = [
            "ai_enabled": flags.aiEnabled,
            "ai_recipe_parsing": flags.aiRecipeParsing,
            "ai_nutrition_analysis": flags.aiNutritionAnalysis,
            "ai_video_to_recipe": flags.aiVideoToRecipe,
            "ai_meal_planner": flags.aiMealPlanner,
            "share_extension_enabled": flags.shareExtensionEnabled
        ]
        try await usersRef.document(userId).updateData([
            "isPremium": isPremium,
            "flags": flagsData,
            "updatedAt": Timestamp(date: Date())
        ])
    }

    func deleteAccount(_ userId: String) async throws {
        try await usersRef.document(userId).delete()
    }
}
