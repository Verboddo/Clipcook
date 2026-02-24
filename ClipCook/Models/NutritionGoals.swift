import Foundation

struct NutritionGoals: Codable, Equatable {
    var calories: Int = 2200
    var protein: Int = 120
    var carbs: Int = 250
    var fats: Int = 70

    var proteinCalories: Int { protein * 4 }
    var carbsCalories: Int { carbs * 4 }
    var fatsCalories: Int { fats * 9 }

    mutating func recalculateMacrosFromCalories() {
        protein = Int(Double(calories) * 0.30 / 4.0)
        carbs = Int(Double(calories) * 0.40 / 4.0)
        fats = Int(Double(calories) * 0.30 / 9.0)
    }

    mutating func redistributeAfterProteinChange() {
        let remainingCal = calories - proteinCalories
        let carbsRatio = 0.40 / (0.40 + 0.30)
        carbs = Int(Double(remainingCal) * carbsRatio / 4.0)
        fats = Int(Double(remainingCal) * (1.0 - carbsRatio) / 9.0)
    }

    mutating func redistributeAfterCarbsChange() {
        let remainingCal = calories - carbsCalories
        let proteinRatio = 0.30 / (0.30 + 0.30)
        protein = Int(Double(remainingCal) * proteinRatio / 4.0)
        fats = Int(Double(remainingCal) * (1.0 - proteinRatio) / 9.0)
    }

    mutating func redistributeAfterFatsChange() {
        let remainingCal = calories - fatsCalories
        let proteinRatio = 0.30 / (0.30 + 0.40)
        protein = Int(Double(remainingCal) * proteinRatio / 4.0)
        carbs = Int(Double(remainingCal) * (1.0 - proteinRatio) / 4.0)
    }
}
