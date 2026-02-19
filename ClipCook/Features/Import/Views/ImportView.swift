import SwiftUI

struct ImportView: View {
    @State private var viewModel = ImportViewModel()
    @State private var recipeViewModel = RecipeViewModel()
    @State private var importedRecipe: Recipe?

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "link.badge.plus")
                        .font(.system(size: 48))
                        .foregroundStyle(.tint)

                    Text("Recept importeren")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Plak een link van Instagram, TikTok, YouTube of een andere website.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top)

                // URL Input
                VStack(spacing: 12) {
                    HStack {
                        TextField("https://...", text: $viewModel.urlString)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.URL)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)

                        Button {
                            if let clipboard = UIPasteboard.general.string {
                                viewModel.urlString = clipboard
                            }
                        } label: {
                            Image(systemName: "doc.on.clipboard")
                        }
                        .buttonStyle(.bordered)
                    }

                    Button {
                        Task { await viewModel.fetchMetadata() }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Preview ophalen")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.urlString.isEmpty || viewModel.isLoading)
                }
                .padding(.horizontal)

                // Error
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(.horizontal)
                }

                // Preview Card
                if viewModel.fetchedTitle != nil || viewModel.parsedRecipe?.hasRecipeContent == true {
                    LinkPreviewCard(
                        title: viewModel.fetchedTitle ?? viewModel.parsedRecipe?.title ?? "",
                        description: viewModel.fetchedDescription,
                        sourceType: viewModel.detectedSourceType
                    )
                    .padding(.horizontal)

                    // Show parsing results
                    if let parsed = viewModel.parsedRecipe, parsed.hasRecipeContent {
                        HStack(spacing: 16) {
                            Label("\(parsed.ingredients.count) ingrediënten", systemImage: "list.bullet")
                            Label("\(parsed.steps.count) stappen", systemImage: "text.justify.left")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                    } else if viewModel.parsedRecipe != nil {
                        Text("Geen recept gevonden in de tekst. Je kunt de details handmatig invullen.")
                            .font(.caption)
                            .foregroundStyle(.orange)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    Button {
                        importedRecipe = viewModel.createRecipe()
                    } label: {
                        Label("Opslaan als recept", systemImage: "square.and.arrow.down")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.horizontal)
                }

                Spacer()
            }
        }
        .navigationTitle("Importeer")
        .sheet(item: $importedRecipe) { recipe in
            NavigationStack {
                RecipeEditView(recipe: recipe, isNew: true)
            }
            .environment(recipeViewModel)
        }
    }
}

#Preview {
    NavigationStack {
        ImportView()
    }
}
