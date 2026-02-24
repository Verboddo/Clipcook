import SwiftUI
import PhotosUI

struct RecipeEditView: View {
    @State private var viewModel: RecipeEditViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImageData: Data?

    init(recipe: Recipe) {
        _viewModel = State(initialValue: RecipeEditViewModel(recipe: recipe))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                photoSection
                titleSection
                timingSection
                ingredientsSection
                stepsSection
                nutritionSection
            }
            .padding()
        }
        .background(AppTheme.primaryBackground.ignoresSafeArea())
        .navigationTitle("Edit Recipe")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    Task {
                        if await viewModel.save() {
                            try? await Task.sleep(for: .seconds(1.2))
                            dismiss()
                        }
                    }
                } label: {
                    Text("Save")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(AppTheme.primary)
                        .cornerRadius(AppTheme.cornerRadiusSM)
                }
            }
        }
        .overlay {
            if viewModel.showCelebration {
                celebrationOverlay
            }
        }
    }

    private var photoSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Photo")
                .font(AppTheme.captionFont)
                .foregroundColor(AppTheme.secondaryText)

            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                Group {
                    if let data = selectedImageData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else if let urlString = viewModel.recipe.thumbnail,
                              let url = URL(string: urlString),
                              url.isFileURL,
                              let data = try? Data(contentsOf: url),
                              let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        AsyncImage(url: URL(string: viewModel.recipe.thumbnail ?? "")) { phase in
                            if let image = phase.image {
                                image.resizable().aspectRatio(contentMode: .fill)
                            } else {
                                Rectangle()
                                    .fill(Color(.systemGray5))
                                    .overlay {
                                        VStack(spacing: 6) {
                                            Image(systemName: "camera.fill")
                                                .font(.system(size: 24))
                                            Text("Tap to add photo")
                                                .font(AppTheme.captionFont)
                                        }
                                        .foregroundStyle(AppTheme.secondaryText)
                                    }
                            }
                        }
                    }
                }
                .frame(height: 180)
                .clipped()
                .cornerRadius(AppTheme.cornerRadius)
            }
            .onChange(of: selectedPhotoItem) { _, newItem in
                guard let newItem else { return }
                Task {
                    if let data = try? await newItem.loadTransferable(type: Data.self) {
                        selectedImageData = data
                    }
                }
            }
        }
    }

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Title")
                .font(AppTheme.captionFont)
                .foregroundColor(AppTheme.secondaryText)
            TextField("Recipe title", text: $viewModel.recipe.title)
                .font(AppTheme.bodyFont)
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(AppTheme.cornerRadiusSM)
        }
    }

    private var timingSection: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Prep Time")
                    .font(AppTheme.captionFont)
                    .foregroundColor(AppTheme.secondaryText)
                TextField("10 min", text: $viewModel.recipe.prepTime)
                    .font(AppTheme.bodyFont)
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(AppTheme.cornerRadiusSM)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("Cook Time")
                    .font(AppTheme.captionFont)
                    .foregroundColor(AppTheme.secondaryText)
                TextField("25 min", text: $viewModel.recipe.cookTime)
                    .font(AppTheme.bodyFont)
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(AppTheme.cornerRadiusSM)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("Servings")
                    .font(AppTheme.captionFont)
                    .foregroundColor(AppTheme.secondaryText)
                TextField("4", value: $viewModel.recipe.servings, format: .number)
                    .font(AppTheme.bodyFont)
                    .keyboardType(.numberPad)
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(AppTheme.cornerRadiusSM)
            }
        }
    }

    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Ingredients")
                    .font(AppTheme.headlineFont)
                Spacer()
                Button { viewModel.addIngredient() } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(AppTheme.primary)
                        .clipShape(Circle())
                }
            }

            ForEach($viewModel.recipe.ingredients) { $ingredient in
                ingredientRow(ingredient: $ingredient)
            }
            .onMove { source, destination in
                viewModel.moveIngredient(from: source, to: destination)
            }
        }
    }

    private func ingredientRow(ingredient: Binding<Ingredient>) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "line.3.horizontal")
                .foregroundColor(Color(.systemGray3))
                .font(.system(size: 14))

            TextField("Ingredient", text: ingredient.name)
                .font(AppTheme.bodyFont)
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(8)

            TextField("Qty", text: ingredient.amount)
                .font(AppTheme.bodyFont)
                .frame(width: 70)
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(8)

            Button {
                viewModel.recipe.ingredients.removeAll { $0.id == ingredient.wrappedValue.id }
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 14))
                    .foregroundColor(.red.opacity(0.7))
            }
        }
    }

    private var stepsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Steps")
                    .font(AppTheme.headlineFont)
                Spacer()
                Button { viewModel.addStep() } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(AppTheme.primary)
                        .clipShape(Circle())
                }
            }

            ForEach($viewModel.recipe.steps) { $step in
                stepRow(step: $step)
            }
            .onMove { source, destination in
                viewModel.moveStep(from: source, to: destination)
            }
        }
    }

    private func stepRow(step: Binding<Step>) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "line.3.horizontal")
                .foregroundColor(Color(.systemGray3))
                .font(.system(size: 14))
                .padding(.top, 14)

            Text("\(step.wrappedValue.order)")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(AppTheme.primary)
                .clipShape(Circle())
                .padding(.top, 10)

            TextField("Step instruction...", text: step.text, axis: .vertical)
                .font(AppTheme.bodyFont)
                .lineLimit(2...5)
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(8)

            Button {
                viewModel.recipe.steps.removeAll { $0.id == step.wrappedValue.id }
                for i in viewModel.recipe.steps.indices {
                    viewModel.recipe.steps[i].order = i + 1
                }
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 14))
                    .foregroundColor(.red.opacity(0.7))
            }
            .padding(.top, 14)
        }
    }

    private var nutritionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Nutrition")
                .font(AppTheme.headlineFont)

            let nutrition = Binding(
                get: { viewModel.recipe.nutrition ?? Nutrition() },
                set: { viewModel.recipe.nutrition = $0 }
            )

            HStack(spacing: 12) {
                nutritionField(label: "Calories", value: nutrition.calories)
                nutritionField(label: "Protein", value: nutrition.protein)
                nutritionField(label: "Carbs", value: nutrition.carbs)
                nutritionField(label: "Fats", value: nutrition.fats)
            }
        }
        .padding(.bottom, AppTheme.spacingXL)
    }

    private func nutritionField(label: String, value: Binding<Int>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(AppTheme.captionFont)
                .foregroundColor(AppTheme.secondaryText)
            TextField("0", value: value, format: .number)
                .font(AppTheme.bodyFont)
                .keyboardType(.numberPad)
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(8)
        }
    }

    private var celebrationOverlay: some View {
        ZStack {
            Color.black.opacity(0.3).ignoresSafeArea()
            VStack(spacing: 16) {
                ChefMascotView(mood: .excited, size: 90)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(AppTheme.success)
                Text("Recipe Saved!")
                    .font(.system(size: 22, weight: .bold))
            }
            .padding(40)
            .background(.ultraThickMaterial)
            .cornerRadius(AppTheme.cornerRadiusLG)
        }
        .transition(.opacity)
    }
}
