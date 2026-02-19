import SwiftUI

struct RecipeEditView: View {
    @Environment(RecipeViewModel.self) private var viewModel
    @Environment(\.dismiss) private var dismiss

    @State var recipe: Recipe
    let isNew: Bool

    var body: some View {
        Form {
            // Basic info
            Section("Basis") {
                TextField("Titel", text: $recipe.title)

                Picker("Bron", selection: $recipe.sourceType) {
                    ForEach(Recipe.SourceType.allCases, id: \.self) { type in
                        Text(type.rawValue.capitalized).tag(type)
                    }
                }

                if recipe.sourceType != .manual {
                    TextField("Link (URL)", text: Binding(
                        get: { recipe.sourceURL ?? "" },
                        set: { recipe.sourceURL = $0.isEmpty ? nil : $0 }
                    ))
                    .keyboardType(.URL)
                    .autocapitalization(.none)
                }
            }

            // Servings & Nutrition
            Section("Porties & Voeding") {
                TextField("Aantal porties", value: $recipe.servings, format: .number)
                    .keyboardType(.numberPad)

                TextField("Calorieën", value: $recipe.calories, format: .number)
                    .keyboardType(.numberPad)
            }

            // Macros
            Section("Macro's (optioneel)") {
                let macros = Binding(
                    get: { recipe.macros ?? Recipe.Macros(protein: 0, carbs: 0, fat: 0) },
                    set: { recipe.macros = $0 }
                )
                TextField("Eiwit (g)", value: macros.protein, format: .number)
                    .keyboardType(.numberPad)
                TextField("Koolhydraten (g)", value: macros.carbs, format: .number)
                    .keyboardType(.numberPad)
                TextField("Vet (g)", value: macros.fat, format: .number)
                    .keyboardType(.numberPad)
            }

            // Ingredients
            Section("Ingrediënten") {
                ForEach($recipe.ingredients) { $ingredient in
                    HStack {
                        TextField("Hoeveelheid", text: $ingredient.amount)
                            .frame(width: 60)
                        TextField("Eenheid", text: $ingredient.unit)
                            .frame(width: 50)
                        TextField("Ingrediënt", text: $ingredient.name)
                    }
                }
                .onDelete { offsets in
                    recipe.ingredients.remove(atOffsets: offsets)
                }

                Button {
                    recipe.ingredients.append(Ingredient())
                } label: {
                    Label("Ingrediënt toevoegen", systemImage: "plus.circle")
                }
            }

            // Steps
            Section("Bereidingsstappen") {
                ForEach(Array(recipe.steps.enumerated()), id: \.offset) { index, _ in
                    HStack(alignment: .top) {
                        Text("\(index + 1).")
                            .foregroundStyle(.secondary)
                            .frame(width: 24)
                        TextField("Stap \(index + 1)", text: $recipe.steps[index], axis: .vertical)
                            .lineLimit(1...5)
                    }
                }
                .onDelete { offsets in
                    recipe.steps.remove(atOffsets: offsets)
                }

                Button {
                    recipe.steps.append("")
                } label: {
                    Label("Stap toevoegen", systemImage: "plus.circle")
                }
            }

            // Tags
            Section("Tags") {
                ForEach(Array(recipe.tags.enumerated()), id: \.offset) { index, _ in
                    TextField("Tag", text: $recipe.tags[index])
                }
                .onDelete { offsets in
                    recipe.tags.remove(atOffsets: offsets)
                }

                Button {
                    recipe.tags.append("")
                } label: {
                    Label("Tag toevoegen", systemImage: "plus.circle")
                }
            }

            // Notes
            Section("Notities") {
                TextField("Persoonlijke notities...", text: Binding(
                    get: { recipe.notes ?? "" },
                    set: { recipe.notes = $0.isEmpty ? nil : $0 }
                ), axis: .vertical)
                .lineLimit(3...8)
            }
        }
        .navigationTitle(isNew ? "Nieuw recept" : "Bewerk recept")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Annuleer") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Bewaar") {
                    Task {
                        if isNew {
                            await viewModel.addRecipe(recipe)
                        } else {
                            await viewModel.updateRecipe(recipe)
                        }
                        dismiss()
                    }
                }
                .disabled(recipe.title.isEmpty)
            }
        }
    }
}

#Preview {
    NavigationStack {
        RecipeEditView(recipe: Recipe(), isNew: true)
            .environment(RecipeViewModel())
    }
}
