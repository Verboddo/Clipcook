import SwiftUI

struct NutritionGoalsView: View {
    @Binding var goals: NutritionGoals
    var onSave: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
            calorieSlider
            macroInfo
            macroSlider(label: "Protein", value: $goals.protein, color: AppTheme.primary, calories: goals.proteinCalories) {
                goals.redistributeAfterProteinChange()
                onSave()
            }
            macroSlider(label: "Carbs", value: $goals.carbs, color: .green, calories: goals.carbsCalories) {
                goals.redistributeAfterCarbsChange()
                onSave()
            }
            macroSlider(label: "Fats", value: $goals.fats, color: .red, calories: goals.fatsCalories) {
                goals.redistributeAfterFatsChange()
                onSave()
            }
        }
        .padding()
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.cornerRadius)
    }

    private var calorieSlider: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Daily Calories")
                    .font(AppTheme.bodyFont)
                Spacer()
                HStack(spacing: 4) {
                    Text("\(goals.calories)")
                        .font(.system(size: 16, weight: .bold))
                        .frame(width: 50)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 6)
                        .background(Color(.systemGray6))
                        .cornerRadius(6)
                    Text("kcal")
                        .font(AppTheme.captionFont)
                        .foregroundColor(AppTheme.secondaryText)
                }
            }

            Slider(value: Binding(
                get: { Double(goals.calories) },
                set: {
                    goals.calories = Int($0)
                    goals.recalculateMacrosFromCalories()
                    onSave()
                }
            ), in: 1200...4000, step: 50)
            .tint(AppTheme.primary)

            HStack {
                Text("1200")
                    .font(AppTheme.captionFont)
                    .foregroundColor(AppTheme.secondaryText)
                Spacer()
                Text("4000")
                    .font(AppTheme.captionFont)
                    .foregroundColor(AppTheme.secondaryText)
            }
        }
    }

    private var macroInfo: some View {
        Text("Auto-calculated from calories (30% P / 40% C / 30% F). Fine-tune below.")
            .font(AppTheme.captionFont)
            .foregroundColor(AppTheme.secondaryText)
    }

    private func macroSlider(label: String, value: Binding<Int>, color: Color, calories: Int, onChange: @escaping () -> Void) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label)
                    .font(AppTheme.bodyFont)
                    .foregroundColor(color)
                Spacer()
                HStack(spacing: 4) {
                    Text("\(value.wrappedValue)")
                        .font(.system(size: 16, weight: .bold))
                        .frame(width: 44)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 4)
                        .background(Color(.systemGray6))
                        .cornerRadius(6)
                    Text("g")
                        .font(AppTheme.captionFont)
                        .foregroundColor(AppTheme.secondaryText)
                    Text("(\(calories) cal)")
                        .font(AppTheme.captionFont)
                        .foregroundColor(AppTheme.secondaryText)
                }
            }

            Slider(value: Binding(
                get: { Double(value.wrappedValue) },
                set: {
                    value.wrappedValue = Int($0)
                    onChange()
                }
            ), in: 0...400, step: 5)
            .tint(color)
        }
    }
}
