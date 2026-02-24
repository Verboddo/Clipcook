import SwiftUI

struct AddMealSheet: View {
    let recipes: [Recipe]
    let onSelect: (String?, QuickAddItem?, MealType) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var selectedTab = 0
    @State private var step: AddMealStep = .chooseFood
    @State private var pendingRecipeId: String?
    @State private var pendingQuickAdd: QuickAddItem?

    enum AddMealStep {
        case chooseFood
        case chooseMeal
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                if step == .chooseFood {
                    chooseFoodView
                } else {
                    chooseMealView
                }
            }
            .navigationTitle(step == .chooseFood ? "Add to Today" : "Choose Meal Slot")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                if step == .chooseMeal {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button { step = .chooseFood } label: {
                            Image(systemName: "chevron.left")
                        }
                    }
                }
            }
        }
    }

    private var chooseFoodView: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
            Text("Pick a recipe or quick snack")
                .font(AppTheme.captionFont)
                .foregroundColor(AppTheme.secondaryText)
                .padding(.horizontal)

            Picker("Type", selection: $selectedTab) {
                Text("Recipes").tag(0)
                Text("Quick Add").tag(1)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            if selectedTab == 0 {
                recipesList
            } else {
                quickAddList
            }
        }
    }

    private var recipesList: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(recipes) { recipe in
                    Button {
                        pendingRecipeId = recipe.id
                        pendingQuickAdd = nil
                        step = .chooseMeal
                    } label: {
                        HStack(spacing: 12) {
                            RecipeImageView(urlString: recipe.thumbnail)
                                .frame(width: 48, height: 48)
                                .clipped()
                                .cornerRadius(8)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(recipe.title)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                                if let n = recipe.nutrition {
                                    Text("\(n.calories) cal · \(n.protein)g protein")
                                        .font(AppTheme.captionFont)
                                        .foregroundColor(AppTheme.secondaryText)
                                }
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .foregroundColor(AppTheme.secondaryText)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                    }

                    Divider().padding(.leading, 76)
                }
            }
        }
    }

    private var quickAddList: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(QuickAddItem.presets) { item in
                    Button {
                        pendingQuickAdd = item
                        pendingRecipeId = nil
                        step = .chooseMeal
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "leaf.fill")
                                .foregroundColor(AppTheme.success)
                                .frame(width: 48, height: 48)
                                .background(AppTheme.success.opacity(0.1))
                                .cornerRadius(8)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.name)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.primary)
                                Text("\(item.calories) cal · \(item.protein)g P · \(item.carbs)g C · \(item.fats)g F")
                                    .font(AppTheme.captionFont)
                                    .foregroundColor(AppTheme.secondaryText)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .foregroundColor(AppTheme.secondaryText)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                    }

                    Divider().padding(.leading, 76)
                }
            }
        }
    }

    private var chooseMealView: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
            Text("Choose a meal slot")
                .font(AppTheme.captionFont)
                .foregroundColor(AppTheme.secondaryText)
                .padding(.horizontal)

            ScrollView {
                VStack(spacing: 8) {
                    ForEach(MealType.allCases) { mealType in
                        Button {
                            onSelect(pendingRecipeId, pendingQuickAdd, mealType)
                            dismiss()
                        } label: {
                            HStack(spacing: 12) {
                                Text(mealType.emoji)
                                    .font(.system(size: 24))
                                    .frame(width: 44, height: 44)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)

                                Text(mealType.rawValue)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.primary)

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .foregroundColor(AppTheme.secondaryText)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                        }
                    }
                }
            }
        }
    }
}
