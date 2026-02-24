import SwiftUI

struct RecipeDetailView: View {
    let recipeId: String
    var onUpdate: (() -> Void)?

    @State private var viewModel = RecipeDetailViewModel()
    @State private var showEdit = false
    @State private var showCookMode = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Group {
            if let recipe = viewModel.recipe {
                recipeContent(recipe)
            } else {
                ProgressView()
            }
        }
        .navigationBarHidden(true)
        .task { await viewModel.loadRecipe(recipeId) }
        .undoToast(isPresented: $viewModel.showToast, message: viewModel.toastMessage) {
            viewModel.toastUndoAction?()
        }
        .fullScreenCover(isPresented: $showEdit) {
            Task { await viewModel.loadRecipe(recipeId); onUpdate?() }
        } content: {
            if let recipe = viewModel.recipe {
                NavigationStack {
                    RecipeEditView(recipe: recipe)
                }
            }
        }
        .fullScreenCover(isPresented: $showCookMode) {
            if let recipe = viewModel.recipe {
                CookModeView(recipe: recipe)
            }
        }
        .onChange(of: viewModel.recipe) {
            if viewModel.recipe == nil && viewModel.showToast {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    onUpdate?()
                    dismiss()
                }
            }
        }
    }

    private func recipeContent(_ recipe: Recipe) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                heroImage(recipe)
                infoCard(recipe)
                ingredientsSection(recipe)
                stepsSection(recipe)
                nutritionSection(recipe)
            }
        }
        .ignoresSafeArea(edges: .top)
        .background(AppTheme.primaryBackground)
    }

    private func heroImage(_ recipe: Recipe) -> some View {
        ZStack(alignment: .top) {
            RecipeImageView(urlString: recipe.thumbnail)
                .frame(height: 280)
                .clipped()

            LinearGradient(colors: [.black.opacity(0.4), .clear], startPoint: .top, endPoint: .center)
                .frame(height: 120)

            HStack {
                Button { onUpdate?(); dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }

                Spacer()

                Button { Task { await viewModel.toggleFavourite() } } label: {
                    Image(systemName: recipe.isFavourite ? "heart.fill" : "heart")
                        .font(.system(size: 16))
                        .foregroundColor(recipe.isFavourite ? .red : .white)
                        .frame(width: 36, height: 36)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }

                Button { showEdit = true } label: {
                    Image(systemName: "pencil")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }

                Menu {
                    Button("Archive", systemImage: "archivebox") {
                        Task { await viewModel.archiveRecipe() }
                    }
                    Button("Delete", systemImage: "trash", role: .destructive) {
                        Task { await viewModel.deleteRecipe() }
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal)
            .padding(.top, 50)
        }
    }

    private func infoCard(_ recipe: Recipe) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(recipe.title)
                .font(.system(size: 22, weight: .bold))

            if let caption = recipe.caption, !caption.isEmpty, caption != recipe.title {
                Text(caption)
                    .font(AppTheme.captionFont)
                    .foregroundStyle(AppTheme.secondaryText)
                    .lineLimit(4)
            }

            if let sourceUrl = recipe.sourceUrl, !sourceUrl.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "link")
                        .font(.system(size: 11))
                    Text(sourceDomain(sourceUrl))
                        .font(AppTheme.captionFont)
                }
                .foregroundStyle(AppTheme.primary)
            }

            HStack(spacing: 16) {
                if !recipe.prepTime.isEmpty {
                    Label("Prep: \(recipe.prepTime)", systemImage: "clock")
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.secondaryText)
                }
                if !recipe.cookTime.isEmpty {
                    Label("Cook: \(recipe.cookTime)", systemImage: "clock")
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.secondaryText)
                }
            }

            HStack {
                Text("Servings")
                    .font(AppTheme.bodyFont)
                Spacer()
                HStack(spacing: 12) {
                    Button { if viewModel.displayServings > 1 { viewModel.displayServings -= 1 } } label: {
                        Image(systemName: "minus")
                            .frame(width: 32, height: 32)
                            .background(Color(.systemGray5))
                            .clipShape(Circle())
                    }
                    Text("\(viewModel.displayServings)")
                        .font(.system(size: 18, weight: .semibold))
                        .frame(width: 30)
                    Button { viewModel.displayServings += 1 } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(AppTheme.primary)
                            .clipShape(Circle())
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(AppTheme.cornerRadiusSM)
        }
        .padding()
    }

    private func ingredientsSection(_ recipe: Recipe) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ingredients")
                .font(AppTheme.headlineFont)
                .padding(.horizontal)

            ForEach(recipe.ingredients) { ingredient in
                Button {
                    viewModel.toggleIngredient(ingredient.id)
                } label: {
                    HStack {
                        Image(systemName: viewModel.checkedIngredients.contains(ingredient.id)
                              ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(viewModel.checkedIngredients.contains(ingredient.id)
                                             ? AppTheme.success : Color(.systemGray3))
                            .font(.system(size: 22))

                        Text(ingredient.name)
                            .font(AppTheme.bodyFont)
                            .strikethrough(viewModel.checkedIngredients.contains(ingredient.id))
                            .foregroundColor(viewModel.checkedIngredients.contains(ingredient.id)
                                             ? AppTheme.secondaryText : .primary)

                        Spacer()

                        Text(ingredient.amount)
                            .font(AppTheme.captionFont)
                            .foregroundColor(AppTheme.secondaryText)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    .background(viewModel.checkedIngredients.contains(ingredient.id)
                                ? AppTheme.success.opacity(0.08)
                                : AppTheme.cardBackground)
                    .cornerRadius(AppTheme.cornerRadiusSM)
                    .padding(.horizontal)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func stepsSection(_ recipe: Recipe) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Steps")
                    .font(AppTheme.headlineFont)
                Spacer()
                if !recipe.steps.isEmpty {
                    Button { showCookMode = true } label: {
                        Label("Cook Mode", systemImage: "flame")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppTheme.primary)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, AppTheme.spacingMD)

            ForEach(Array(recipe.steps.sorted(by: { $0.order < $1.order }).enumerated()), id: \.element.id) { index, step in
                HStack(alignment: .top, spacing: 12) {
                    Text("\(index + 1)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 28, height: 28)
                        .background(AppTheme.primary)
                        .clipShape(Circle())

                    Text(step.text)
                        .font(AppTheme.bodyFont)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal)
                .padding(.vertical, 4)
            }
        }
    }

    @ViewBuilder
    private func nutritionSection(_ recipe: Recipe) -> some View {
        if let nutrition = recipe.nutrition {
            VStack(alignment: .leading, spacing: 12) {
                Button { withAnimation { viewModel.showNutrition.toggle() } } label: {
                    HStack {
                        Text("Nutrition Info")
                            .font(AppTheme.headlineFont)
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .rotationEffect(.degrees(viewModel.showNutrition ? 180 : 0))
                            .foregroundColor(AppTheme.secondaryText)
                    }
                }
                .padding(.horizontal)
                .padding(.top, AppTheme.spacingMD)

                if viewModel.showNutrition {
                    VStack(spacing: 12) {
                        HStack(spacing: 20) {
                            nutritionRing(value: nutrition.calories, label: "kcal", color: AppTheme.primary)
                            VStack(alignment: .leading, spacing: 6) {
                                macroBar(label: "Protein", value: nutrition.protein, unit: "g", color: AppTheme.primary)
                                macroBar(label: "Carbs", value: nutrition.carbs, unit: "g", color: .green)
                                macroBar(label: "Fats", value: nutrition.fats, unit: "g", color: .red)
                            }
                        }
                    }
                    .padding()
                    .background(AppTheme.cardBackground)
                    .cornerRadius(AppTheme.cornerRadius)
                    .padding(.horizontal)
                }
            }
            .padding(.bottom, AppTheme.spacingXL)
        }
    }

    private func nutritionRing(value: Int, label: String, color: Color) -> some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: 8)
            Circle()
                .trim(from: 0, to: min(CGFloat(value) / 600.0, 1.0))
                .stroke(color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(.degrees(-90))
            VStack(spacing: 0) {
                Text("\(value)")
                    .font(.system(size: 18, weight: .bold))
                Text(label)
                    .font(.system(size: 10))
                    .foregroundColor(AppTheme.secondaryText)
            }
        }
        .frame(width: 80, height: 80)
    }

    private func macroBar(label: String, value: Int, unit: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(label)
                    .font(AppTheme.captionFont)
                    .foregroundColor(AppTheme.secondaryText)
                Spacer()
                Text("\(value)\(unit)")
                    .font(.system(size: 13, weight: .semibold))
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(color.opacity(0.15)).frame(height: 6)
                    Capsule().fill(color).frame(width: geo.size.width * min(CGFloat(value) / 100.0, 1.0), height: 6)
                }
            }
            .frame(height: 6)
        }
    }

    private func sourceDomain(_ urlString: String) -> String {
        guard let url = URL(string: urlString), let host = url.host else {
            return urlString
        }
        return host.replacingOccurrences(of: "www.", with: "")
    }
}
