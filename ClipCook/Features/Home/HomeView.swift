import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    @State private var showImport = false
    @State private var selectedRecipe: Recipe?

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                    header
                    searchBar
                    filterChips
                    recipeGrid
                }
                .padding(.horizontal)
            }
            .background(AppTheme.primaryBackground.ignoresSafeArea())
            .refreshable { await viewModel.loadRecipes() }
            .task { await viewModel.loadRecipes() }
            .navigationDestination(item: $selectedRecipe) { recipe in
                RecipeDetailView(recipeId: recipe.id, onUpdate: {
                    Task { await viewModel.loadRecipes() }
                })
            }
            .fullScreenCover(isPresented: $showImport) {
                Task { await viewModel.loadRecipes() }
            } content: {
                NavigationStack {
                    ImportView(onRecipeSaved: { recipe in
                        showImport = false
                        Task {
                            await viewModel.loadRecipes()
                            selectedRecipe = recipe
                        }
                    })
                }
            }
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("My Recipes")
                    .font(AppTheme.titleFont)
                Text("\(viewModel.recipes.count) recipes saved")
                    .font(AppTheme.captionFont)
                    .foregroundColor(AppTheme.secondaryText)
            }
            Spacer()
            Button { showImport = true } label: {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(AppTheme.primary)
                    .clipShape(Circle())
            }
        }
        .padding(.top, 8)
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppTheme.secondaryText)
            TextField("Search recipes...", text: $viewModel.searchText)
                .font(AppTheme.bodyFont)
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(AppTheme.cornerRadiusSM)
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(FilterCategory.allCases) { category in
                    Button {
                        viewModel.selectedFilter = category
                    } label: {
                        Text(category.rawValue)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(viewModel.selectedFilter == category ? .white : .primary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(viewModel.selectedFilter == category ? AppTheme.primary : Color(.systemGray6))
                            .cornerRadius(20)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var recipeGrid: some View {
        if viewModel.filteredRecipes.isEmpty && !viewModel.isLoading {
            VStack {
                Spacer().frame(height: 40)
                EmptyStateView(
                    title: viewModel.searchText.isEmpty ? "No recipes yet" : "No recipes match your search",
                    subtitle: viewModel.searchText.isEmpty ? "Import your first recipe to get started" : nil,
                    actionTitle: viewModel.searchText.isEmpty ? "Import Recipe" : nil,
                    action: viewModel.searchText.isEmpty ? { showImport = true } : nil
                )
                Spacer()
            }
        } else {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(viewModel.filteredRecipes) { recipe in
                    RecipeCardView(recipe: recipe) {
                        Task { await viewModel.toggleFavourite(recipe) }
                    }
                    .onTapGesture { selectedRecipe = recipe }
                }
            }
        }
    }
}
