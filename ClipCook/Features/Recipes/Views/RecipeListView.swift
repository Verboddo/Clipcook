import SwiftUI

struct RecipeListView: View {
    @State private var viewModel = RecipeViewModel()
    @State private var isShowingAddRecipe = false

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Recepten laden...")
            } else if viewModel.recipes.isEmpty {
                EmptyStateView(
                    icon: "book",
                    title: "Geen recepten",
                    message: "Voeg je eerste recept toe via de + knop of importeer een link."
                )
            } else {
                List {
                    ForEach(viewModel.recipes) { recipe in
                        NavigationLink(value: recipe) {
                            RecipeRowView(recipe: recipe)
                        }
                    }
                    .onDelete(perform: deleteRecipes)
                }
            }
        }
        .navigationTitle("Recepten")
        .navigationDestination(for: Recipe.self) { recipe in
            RecipeDetailView(recipe: recipe)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isShowingAddRecipe = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $isShowingAddRecipe) {
            NavigationStack {
                RecipeEditView(recipe: Recipe(), isNew: true)
            }
            .environment(viewModel)
        }
        .onAppear {
            viewModel.startListening()
        }
        .onDisappear {
            viewModel.stopListening()
        }
        .environment(viewModel)
    }

    private func deleteRecipes(at offsets: IndexSet) {
        for index in offsets {
            let recipe = viewModel.recipes[index]
            guard let recipeId = recipe.id else { continue }
            Task {
                await viewModel.deleteRecipe(recipeId)
            }
        }
    }
}

struct RecipeRowView: View {
    let recipe: Recipe

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(recipe.title)
                .font(.headline)

            HStack(spacing: 8) {
                if recipe.sourceType != .manual {
                    Label(recipe.sourceType.rawValue.capitalized, systemImage: "link")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if let servings = recipe.servings {
                    Label("\(servings) porties", systemImage: "person.2")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if !recipe.tags.isEmpty {
                    Text(recipe.tags.joined(separator: ", "))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        RecipeListView()
    }
}
