import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe
    @Environment(RecipeViewModel.self) private var viewModel
    @State private var isEditing = false
    @State private var isShowingDeleteConfirmation = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Source link
                if let sourceURL = recipe.sourceURL, !sourceURL.isEmpty {
                    Link(destination: URL(string: sourceURL)!) {
                        Label("Bekijk origineel (\(recipe.sourceType.rawValue))", systemImage: "link")
                            .font(.subheadline)
                    }
                }

                // Servings & Nutrition
                if recipe.servings != nil || recipe.calories != nil {
                    HStack(spacing: 16) {
                        if let servings = recipe.servings {
                            Label("\(servings) porties", systemImage: "person.2")
                        }
                        if let calories = recipe.calories {
                            Label("\(calories) kcal", systemImage: "flame")
                        }
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }

                // Macros
                if let macros = recipe.macros {
                    HStack(spacing: 16) {
                        MacroLabel(name: "Eiwit", value: macros.protein, unit: "g")
                        MacroLabel(name: "Koolh.", value: macros.carbs, unit: "g")
                        MacroLabel(name: "Vet", value: macros.fat, unit: "g")
                    }
                    .font(.caption)
                }

                // Ingredients
                if !recipe.ingredients.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Ingrediënten")
                            .font(.title2)
                            .fontWeight(.bold)

                        ForEach(recipe.ingredients) { ingredient in
                            HStack {
                                Image(systemName: "circle.fill")
                                    .font(.system(size: 6))
                                    .foregroundStyle(.tint)
                                Text("\(ingredient.amount) \(ingredient.unit) \(ingredient.name)")
                            }
                        }
                    }
                }

                // Steps
                if !recipe.steps.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Bereiding")
                            .font(.title2)
                            .fontWeight(.bold)

                        ForEach(Array(recipe.steps.enumerated()), id: \.offset) { index, step in
                            HStack(alignment: .top, spacing: 12) {
                                Text("\(index + 1)")
                                    .font(.headline)
                                    .foregroundStyle(.tint)
                                    .frame(width: 24)
                                Text(step)
                            }
                        }
                    }
                }

                // Notes
                if let notes = recipe.notes, !notes.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notities")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text(notes)
                            .foregroundStyle(.secondary)
                    }
                }

                // Tags
                if !recipe.tags.isEmpty {
                    FlowLayout(spacing: 8) {
                        ForEach(recipe.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.accentColor.opacity(0.1))
                                .clipShape(Capsule())
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle(recipe.title)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        isEditing = true
                    } label: {
                        Label("Bewerk", systemImage: "pencil")
                    }

                    Button {
                        // Add to grocery list
                    } label: {
                        Label("Naar boodschappenlijst", systemImage: "cart.badge.plus")
                    }

                    Button(role: .destructive) {
                        isShowingDeleteConfirmation = true
                    } label: {
                        Label("Verwijder", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $isEditing) {
            NavigationStack {
                RecipeEditView(recipe: recipe, isNew: false)
            }
        }
        .confirmationDialog(
            "Weet je zeker dat je dit recept wilt verwijderen?",
            isPresented: $isShowingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Verwijder", role: .destructive) {
                guard let recipeId = recipe.id else { return }
                Task {
                    await viewModel.deleteRecipe(recipeId)
                }
            }
        }
    }
}

struct MacroLabel: View {
    let name: String
    let value: Int
    let unit: String

    var body: some View {
        VStack {
            Text("\(value)\(unit)")
                .fontWeight(.semibold)
            Text(name)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.fill)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// Simple flow layout for tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (positions: [CGPoint], size: CGSize) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }

        return (positions, CGSize(width: maxWidth, height: y + rowHeight))
    }
}
