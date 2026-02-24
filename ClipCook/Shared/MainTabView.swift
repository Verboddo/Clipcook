import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @Binding var deepLinkTarget: DeepLinkTarget?
    @State private var showImportFromDeepLink = false
    @State private var deepLinkRecipeId: String?

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)

            ShoppingListView()
                .tabItem {
                    Image(systemName: "cart.fill")
                    Text("Shopping")
                }
                .tag(1)

            MealPlannerView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Planner")
                }
                .tag(2)

            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
                .tag(3)
        }
        .tint(AppTheme.primary)
        .onChange(of: deepLinkTarget) { _, target in
            guard let target else { return }
            switch target {
            case .imports:
                selectedTab = 0
                showImportFromDeepLink = true
            case .recipe(let id):
                selectedTab = 0
                deepLinkRecipeId = id
            }
            deepLinkTarget = nil
        }
        .fullScreenCover(isPresented: $showImportFromDeepLink) {
            NavigationStack {
                ImportView(onRecipeSaved: { _ in showImportFromDeepLink = false })
            }
        }
    }
}
