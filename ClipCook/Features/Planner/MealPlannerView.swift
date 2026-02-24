import SwiftUI

struct MealPlannerView: View {
    @State private var viewModel = MealPlannerViewModel()
    @Environment(PremiumService.self) private var premiumService
    @Environment(AuthService.self) private var authService

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            dateNavigation
            ScrollView {
                VStack(spacing: AppTheme.spacingMD) {
                    macroTrackerSection
                    mealsContent
                }
                .padding(.horizontal)
            }
        }
        .background(AppTheme.primaryBackground.ignoresSafeArea())
        .task { await viewModel.loadData() }
        .onChange(of: viewModel.selectedDate) { _, _ in
            Task { await viewModel.loadData() }
        }
        .sheet(isPresented: $viewModel.showAddSheet) {
            AddMealSheet(
                recipes: viewModel.recipes,
                onSelect: { recipeId, quickAdd, mealType in
                    Task {
                        await viewModel.addMeal(recipeId: recipeId, quickAdd: quickAdd, mealType: mealType)
                    }
                }
            )
            .presentationDetents([.large])
        }
    }

    private var header: some View {
        HStack {
            Text("Meal Planner")
                .font(AppTheme.titleFont)
            Spacer()
            Button { viewModel.showAddSheet = true } label: {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(AppTheme.primary)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    private var dateNavigation: some View {
        HStack {
            Button { viewModel.goToPreviousDay() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .semibold))
                    .frame(width: 36, height: 36)
                    .background(Color(.systemGray6))
                    .clipShape(Circle())
            }

            Spacer()

            HStack(spacing: 6) {
                Image(systemName: "calendar")
                    .font(.system(size: 14))
                Text(viewModel.displayDate)
                    .font(.system(size: 16, weight: .semibold))
            }

            Spacer()

            Button { viewModel.goToNextDay() } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .frame(width: 36, height: 36)
                    .background(Color(.systemGray6))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }

    @ViewBuilder
    private var macroTrackerSection: some View {
        if premiumService.isPremium {
            MacroTrackerView(
                nutrition: viewModel.totalNutrition,
                goals: authService.currentUser?.nutritionGoals ?? NutritionGoals()
            )
        } else {
            lockedMacroTracker
        }
    }

    private var lockedMacroTracker: some View {
        HStack(spacing: 12) {
            Image(systemName: "lock.fill")
                .font(.system(size: 20))
                .foregroundColor(AppTheme.primary)
                .frame(width: 40, height: 40)
                .background(AppTheme.primary.opacity(0.15))
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text("Daily Macro Tracker")
                        .font(.system(size: 15, weight: .semibold))
                    Image(systemName: "crown.fill")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.primary)
                }
                Text("Track calories, protein, carbs & fats — upgrade to unlock")
                    .font(AppTheme.captionFont)
                    .foregroundColor(AppTheme.secondaryText)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(AppTheme.secondaryText)
        }
        .padding()
        .background(AppTheme.primaryLight.opacity(0.4))
        .cornerRadius(AppTheme.cornerRadius)
    }

    @ViewBuilder
    private var mealsContent: some View {
        if viewModel.mealSlots.isEmpty {
            VStack(spacing: AppTheme.spacingMD) {
                Spacer().frame(height: 20)
                EmptyStateView(
                    title: "Tap + to plan your today meals",
                    actionTitle: "Add Meal",
                    action: { viewModel.showAddSheet = true }
                )
            }
        } else {
            ForEach(viewModel.groupedSlots, id: \.0) { mealType, slots in
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Text(mealType.emoji)
                        Text(mealType.rawValue.uppercased())
                            .font(.system(size: 13, weight: .bold))
                            .tracking(1)
                            .foregroundColor(AppTheme.secondaryText)
                    }

                    ForEach(slots) { slot in
                        mealSlotCard(slot)
                    }
                }
            }
        }
    }

    private func mealSlotCard(_ slot: MealSlot) -> some View {
        HStack(spacing: 12) {
            if let recipe = viewModel.recipeForSlot(slot) {
                RecipeImageView(urlString: recipe.thumbnail)
                    .frame(width: 48, height: 48)
                    .clipped()
                    .cornerRadius(8)

                VStack(alignment: .leading, spacing: 2) {
                    Text(recipe.title)
                        .font(.system(size: 14, weight: .semibold))
                        .lineLimit(1)
                    if let n = recipe.nutrition {
                        Text("\(n.calories) cal · \(n.protein)g P · \(n.carbs)g C · \(n.fats)g F")
                            .font(AppTheme.captionFont)
                            .foregroundColor(AppTheme.secondaryText)
                    }
                }
            } else if let quickAdd = slot.quickAdd {
                Image(systemName: "leaf.fill")
                    .foregroundColor(AppTheme.success)
                    .frame(width: 48, height: 48)
                    .background(AppTheme.success.opacity(0.1))
                    .cornerRadius(8)

                VStack(alignment: .leading, spacing: 2) {
                    Text(quickAdd.name)
                        .font(.system(size: 14, weight: .semibold))
                    Text("\(quickAdd.calories) cal · \(quickAdd.protein)g P · \(quickAdd.carbs)g C · \(quickAdd.fats)g F")
                        .font(AppTheme.captionFont)
                        .foregroundColor(AppTheme.secondaryText)
                }
            }

            Spacer()

            Button { Task { await viewModel.removeMeal(slot) } } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(AppTheme.secondaryText)
            }
        }
        .padding(12)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.cornerRadiusSM)
    }
}
