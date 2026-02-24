import Foundation

@Observable
final class MealPlannerViewModel {
    var selectedDate = Date()
    var mealSlots: [MealSlot] = []
    var recipes: [Recipe] = []
    var showAddSheet = false
    var isLoading = false

    private let mealPlanRepo: MealPlanRepositoryProtocol
    private let recipeRepo: RecipeRepositoryProtocol

    init(
        mealPlanRepo: MealPlanRepositoryProtocol = FirestoreMealPlanRepository(),
        recipeRepo: RecipeRepositoryProtocol = FirestoreRecipeRepository()
    ) {
        self.mealPlanRepo = mealPlanRepo
        self.recipeRepo = recipeRepo
    }

    var dayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: selectedDate)
    }

    var displayDate: String {
        if Calendar.current.isDateInToday(selectedDate) {
            return "Today"
        }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: selectedDate)
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(selectedDate)
    }

    var groupedSlots: [(MealType, [MealSlot])] {
        let grouped = Dictionary(grouping: mealSlots, by: \.meal)
        return MealType.allCases.compactMap { type in
            guard let slots = grouped[type], !slots.isEmpty else { return nil }
            return (type, slots)
        }
    }

    var totalNutrition: Nutrition {
        var total = Nutrition()
        for slot in mealSlots {
            if let quickAdd = slot.quickAdd {
                total.calories += quickAdd.calories
                total.protein += quickAdd.protein
                total.carbs += quickAdd.carbs
                total.fats += quickAdd.fats
            } else if let recipeId = slot.recipeId,
                      let recipe = recipes.first(where: { $0.id == recipeId }),
                      let nutrition = recipe.nutrition {
                total.calories += nutrition.calories
                total.protein += nutrition.protein
                total.carbs += nutrition.carbs
                total.fats += nutrition.fats
            }
        }
        return total
    }

    func loadData() async {
        isLoading = true
        do {
            mealSlots = try await mealPlanRepo.getSlots(for: dayString)
            recipes = try await recipeRepo.getAll()
        } catch {
            print("Failed to load meal plan: \(error)")
        }
        isLoading = false
    }

    func goToPreviousDay() {
        selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
        Task { await loadData() }
    }

    func goToNextDay() {
        selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
        Task { await loadData() }
    }

    func goToToday() {
        selectedDate = Date()
        Task { await loadData() }
    }

    func addMeal(recipeId: String?, quickAdd: QuickAddItem?, mealType: MealType) async {
        var slot = MealSlot()
        slot.day = dayString
        slot.meal = mealType
        slot.recipeId = recipeId
        slot.quickAdd = quickAdd
        do {
            try await mealPlanRepo.addSlot(slot)
            await loadData()
        } catch {
            print("Failed to add meal: \(error)")
        }
    }

    func removeMeal(_ slot: MealSlot) async {
        do {
            try await mealPlanRepo.removeSlot(slot.id)
            await loadData()
        } catch {
            print("Failed to remove meal: \(error)")
        }
    }

    func recipeForSlot(_ slot: MealSlot) -> Recipe? {
        guard let recipeId = slot.recipeId else { return nil }
        return recipes.first { $0.id == recipeId }
    }
}
