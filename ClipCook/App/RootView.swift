import SwiftUI

struct RootView: View {
    @Environment(AuthViewModel.self) private var authViewModel

    var body: some View {
        Group {
            if authViewModel.isLoading {
                ProgressView("Laden...")
            } else if authViewModel.isAuthenticated {
                MainTabView()
            } else {
                LoginView()
            }
        }
        .animation(.easeInOut, value: authViewModel.isAuthenticated)
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                RecipeListView()
            }
            .tabItem {
                Label("Recepten", systemImage: "book")
            }

            NavigationStack {
                ImportView()
            }
            .tabItem {
                Label("Importeer", systemImage: "link.badge.plus")
            }

            NavigationStack {
                GroceryListView()
            }
            .tabItem {
                Label("Boodschappen", systemImage: "cart")
            }

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Instellingen", systemImage: "gear")
            }
        }
    }
}

#Preview {
    RootView()
        .environment(AuthViewModel())
}
