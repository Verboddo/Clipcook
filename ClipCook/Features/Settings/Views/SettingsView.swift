import SwiftUI

struct SettingsView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @State private var viewModel = SettingsViewModel()
    @State private var displayName = ""

    var body: some View {
        Form {
            // Profile
            Section("Profiel") {
                HStack {
                    Text("Email")
                    Spacer()
                    Text(viewModel.userProfile?.email ?? "–")
                        .foregroundStyle(.secondary)
                }

                TextField("Naam", text: $displayName)
                    .onSubmit {
                        Task { await viewModel.updateDisplayName(displayName) }
                    }
            }

            // Units
            Section("Eenheden") {
                Picker("Eenheidssysteem", selection: Binding(
                    get: { viewModel.userProfile?.units ?? .metric },
                    set: { newValue in
                        Task { await viewModel.updateUnits(newValue) }
                    }
                )) {
                    Text("Metrisch (g, ml)").tag(UserProfile.UnitSystem.metric)
                    Text("Imperiaal (oz, cups)").tag(UserProfile.UnitSystem.imperial)
                }
            }

            // App info
            Section("Over ClipCook") {
                HStack {
                    Text("Versie")
                    Spacer()
                    Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                        .foregroundStyle(.secondary)
                }
            }

            // Sign out
            Section {
                Button("Uitloggen", role: .destructive) {
                    authViewModel.signOut()
                }
            }
        }
        .navigationTitle("Instellingen")
        .task {
            await viewModel.loadProfile()
            displayName = viewModel.userProfile?.displayName ?? ""
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environment(AuthViewModel())
    }
}
