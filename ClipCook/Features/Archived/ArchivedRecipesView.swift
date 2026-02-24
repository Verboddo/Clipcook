import SwiftUI

struct ArchivedRecipesView: View {
    @State private var viewModel = ArchivedRecipesViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                }

                Text("Archived Recipes")
                    .font(AppTheme.titleFont)

                Spacer()

                Text("\(viewModel.recipes.count) recipes")
                    .font(AppTheme.captionFont)
                    .foregroundColor(AppTheme.secondaryText)
            }
            .padding()

            if viewModel.recipes.isEmpty {
                Spacer()
                EmptyStateView(title: "No archived recipes")
                    .frame(maxWidth: .infinity)
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(viewModel.recipes) { recipe in
                            archivedRecipeRow(recipe)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .background(AppTheme.primaryBackground.ignoresSafeArea())
        .navigationBarHidden(true)
        .task { await viewModel.loadArchived() }
        .undoToast(isPresented: $viewModel.showToast, message: viewModel.toastMessage) {
            viewModel.toastUndoAction?()
        }
    }

    private func archivedRecipeRow(_ recipe: Recipe) -> some View {
        HStack(spacing: 12) {
            RecipeImageView(urlString: recipe.thumbnail)
                .frame(width: 56, height: 56)
                .clipped()
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.title)
                    .font(.system(size: 15, weight: .semibold))
                    .lineLimit(1)
                HStack(spacing: 8) {
                    if !recipe.cookTime.isEmpty {
                        Label(recipe.cookTime, systemImage: "clock")
                            .font(AppTheme.captionFont)
                    }
                    if let cal = recipe.nutrition?.calories {
                        Text("\(cal) cal")
                            .font(AppTheme.captionFont)
                    }
                }
                .foregroundColor(AppTheme.secondaryText)
            }

            Spacer()

            Button { Task { await viewModel.restoreRecipe(recipe) } } label: {
                Image(systemName: "arrow.uturn.backward")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(AppTheme.primary)
                    .clipShape(Circle())
            }

            Button { Task { await viewModel.deleteRecipe(recipe) } } label: {
                Image(systemName: "trash")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(AppTheme.destructive)
                    .clipShape(Circle())
            }
        }
        .padding(12)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.cornerRadius)
    }
}
