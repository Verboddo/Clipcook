import Foundation

struct FeatureFlags: Codable, Equatable {
    var aiEnabled: Bool = false
    var aiRecipeParsing: Bool = false
    var aiNutritionAnalysis: Bool = false
    var aiVideoToRecipe: Bool = false
    var aiMealPlanner: Bool = false
    var shareExtensionEnabled: Bool = true

    enum CodingKeys: String, CodingKey {
        case aiEnabled = "ai_enabled"
        case aiRecipeParsing = "ai_recipe_parsing"
        case aiNutritionAnalysis = "ai_nutrition_analysis"
        case aiVideoToRecipe = "ai_video_to_recipe"
        case aiMealPlanner = "ai_meal_planner"
        case shareExtensionEnabled = "share_extension_enabled"
    }

    static var free: FeatureFlags { FeatureFlags() }

    static var premium: FeatureFlags {
        FeatureFlags(
            aiEnabled: true,
            aiRecipeParsing: true,
            aiNutritionAnalysis: true,
            aiVideoToRecipe: true,
            aiMealPlanner: true,
            shareExtensionEnabled: true
        )
    }
}
