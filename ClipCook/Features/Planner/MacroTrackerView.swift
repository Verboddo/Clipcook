import SwiftUI

struct MacroTrackerView: View {
    let nutrition: Nutrition
    var goals: NutritionGoals = NutritionGoals()

    var body: some View {
        VStack(spacing: AppTheme.spacingMD) {
            HStack {
                Text("Today's Nutrition")
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
                Text("\(nutrition.calories) / \(goals.calories) kcal")
                    .font(AppTheme.captionFont)
                    .foregroundColor(AppTheme.secondaryText)
            }

            calorieBar

            HStack(spacing: 20) {
                macroGauge(
                    label: "Protein",
                    value: nutrition.protein,
                    goal: goals.protein,
                    color: AppTheme.primary
                )
                macroGauge(
                    label: "Carbs",
                    value: nutrition.carbs,
                    goal: goals.carbs,
                    color: .green
                )
                macroGauge(
                    label: "Fats",
                    value: nutrition.fats,
                    goal: goals.fats,
                    color: .red
                )
            }
        }
        .padding()
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.cornerRadius)
        .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
    }

    private var calorieBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color(.systemGray5))
                Capsule()
                    .fill(calorieBarColor)
                    .frame(width: geo.size.width * calorieProgress)
                    .animation(.easeInOut, value: nutrition.calories)
            }
        }
        .frame(height: 10)
        .cornerRadius(5)
    }

    private var calorieProgress: CGFloat {
        guard goals.calories > 0 else { return 0 }
        return min(CGFloat(nutrition.calories) / CGFloat(goals.calories), 1.2)
    }

    private var calorieBarColor: Color {
        if nutrition.calories > goals.calories {
            return .red
        }
        return AppTheme.primary
    }

    private func macroGauge(label: String, value: Int, goal: Int, color: Color) -> some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 6)
                Circle()
                    .trim(from: 0, to: goal > 0 ? min(CGFloat(value) / CGFloat(goal), 1.0) : 0)
                    .stroke(color, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut, value: value)

                Text("\(value)g")
                    .font(.system(size: 14, weight: .bold))
            }
            .frame(width: 60, height: 60)

            Text(label)
                .font(.system(size: 12))
                .foregroundColor(AppTheme.secondaryText)
            Text("/ \(goal)g")
                .font(.system(size: 11))
                .foregroundColor(Color(.systemGray3))
        }
    }
}
