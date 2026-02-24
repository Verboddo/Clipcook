import Foundation

protocol NutritionServiceProtocol {
    func analyzeIngredients(_ ingredients: [Ingredient]) async -> Nutrition
}

final class NoOpNutritionAnalyzer: NutritionServiceProtocol {
    func analyzeIngredients(_ ingredients: [Ingredient]) async -> Nutrition {
        Nutrition(calories: 0, protein: 0, carbs: 0, fats: 0)
    }
}
