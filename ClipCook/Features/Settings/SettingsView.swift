import SwiftUI

struct SettingsView: View {
    @State private var viewModel = SettingsViewModel()
    @Environment(AuthService.self) private var authService
    @Environment(PremiumService.self) private var premiumService
    @Environment(FeatureFlagService.self) private var featureFlagService
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false
    @State private var showArchived = false
    @State private var showDeleteConfirmation = false
    @State private var showRestoreAlert = false
    @State private var showChangeEmail = false
    @State private var showChangePassword = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                    Text("Settings")
                        .font(AppTheme.titleFont)
                        .padding(.horizontal)
                        .padding(.top, 8)

                    profileCard
                    preferencesSection
                    if premiumService.isPremium { nutritionGoalsSection }
                    premiumSection
                    librarySection
                    subscriptionSection
                    accountSection
                    legalSection
                    aboutSection
                    dangerZone
                }
                .padding(.bottom, AppTheme.spacingXL)
            }
            .background(AppTheme.primaryBackground.ignoresSafeArea())
            .task { await viewModel.loadData(userId: authService.currentUserId) }
            .navigationDestination(isPresented: $showArchived) {
                ArchivedRecipesView()
            }
            .alert("Delete Account", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    Task { await authService.deleteAccount() }
                }
            } message: {
                Text("This will permanently delete your account and all data. This action cannot be undone.")
            }
        }
    }

    private var profileCard: some View {
        HStack(spacing: 14) {
            ChefMascotView(mood: .happy, size: 48)

            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.user.displayName.isEmpty ? "Chef User" : viewModel.user.displayName)
                    .font(.system(size: 16, weight: .semibold))
                Text(viewModel.user.email)
                    .font(AppTheme.captionFont)
                    .foregroundColor(AppTheme.secondaryText)
            }

            Spacer()

            if premiumService.isPremium {
                HStack(spacing: 4) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 11))
                    Text("Premium")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(AppTheme.primary)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(AppTheme.primary.opacity(0.12))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.cornerRadius)
        .padding(.horizontal)
    }

    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader("PREFERENCES")

            VStack(spacing: 0) {
                HStack {
                    Image(systemName: "sun.max.fill")
                        .foregroundColor(.orange)
                    Text("Dark Mode")
                        .font(AppTheme.bodyFont)
                    Spacer()
                    Toggle("", isOn: Binding(
                        get: { viewModel.user.darkMode },
                        set: { newValue in
                            darkModeEnabled = newValue
                            Task { await viewModel.updateDarkMode(newValue, userId: authService.currentUserId) }
                        }
                    ))
                    .tint(AppTheme.primary)
                }
                .padding()

                Divider().padding(.leading, 50)

                HStack {
                    Text("Units")
                        .font(AppTheme.bodyFont)
                        .foregroundColor(AppTheme.primary)
                    Spacer()
                    Picker("", selection: Binding(
                        get: { viewModel.user.units },
                        set: { newValue in Task { await viewModel.updateUnits(newValue, userId: authService.currentUserId) } }
                    )) {
                        Text("Metric").tag(MeasurementUnit.metric)
                        Text("Imperial").tag(MeasurementUnit.imperial)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 180)
                }
                .padding()
            }
            .background(AppTheme.cardBackground)
            .cornerRadius(AppTheme.cornerRadius)
            .padding(.horizontal)
        }
    }

    private var nutritionGoalsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader("DAILY NUTRITION GOALS")
            NutritionGoalsView(goals: $viewModel.nutritionGoals) {
                Task { await viewModel.updateNutritionGoals(userId: authService.currentUserId) }
            }
            .padding(.horizontal)
        }
    }

    private var premiumSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader("PREMIUM")

            VStack(spacing: 0) {
                // Premium toggle (dev preview)
                HStack {
                    Image(systemName: "sparkles")
                        .foregroundColor(AppTheme.primary)
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Premium Mode")
                            .font(AppTheme.bodyFont)
                        Text("Toggle to preview premium features")
                            .font(AppTheme.captionFont)
                            .foregroundColor(AppTheme.secondaryText)
                    }
                    Spacer()
                    Toggle("", isOn: Binding(
                        get: { premiumService.isPremium },
                        set: { _ in
                            Task {
                                await premiumService.togglePremium(userId: authService.currentUserId)
                                featureFlagService.setAllPremium(premiumService.isPremium)
                            }
                        }
                    ))
                    .tint(AppTheme.primary)
                }
                .padding()
                .background(AppTheme.primaryLight.opacity(0.3))

                Divider()

                HStack {
                    Image(systemName: "crown.fill")
                        .foregroundColor(AppTheme.primary)
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Upgrade to Premium")
                            .font(AppTheme.bodyFont)
                        Text("AI extraction, auto nutrition & more")
                            .font(AppTheme.captionFont)
                            .foregroundColor(AppTheme.secondaryText)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(AppTheme.secondaryText)
                }
                .padding()

                Divider()

                featureFlagsList
            }
            .background(AppTheme.cardBackground)
            .cornerRadius(AppTheme.cornerRadius)
            .padding(.horizontal)
        }
    }

    private var featureFlagsList: some View {
        VStack(spacing: 0) {
            flagRow("AI Recipe Extraction", flag: \.aiRecipeParsing)
            flagRow("Auto Nutrition", flag: \.aiNutritionAnalysis)
            flagRow("Daily Macro Tracker", flag: \.aiEnabled)
            flagRow("Video → Recipe", flag: \.aiVideoToRecipe)
            flagRow("Manual Import", isAlwaysFree: true)
            flagRow("Shopping List", isAlwaysFree: true)
        }
    }

    private func flagRow(_ title: String, flag: KeyPath<FeatureFlags, Bool>? = nil, isAlwaysFree: Bool = false) -> some View {
        HStack {
            Text(title)
                .font(AppTheme.bodyFont)
            Spacer()
            if isAlwaysFree {
                Text("Free")
                    .font(AppTheme.badgeFont)
                    .foregroundColor(AppTheme.freeBadge)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(AppTheme.freeBadge.opacity(0.12))
                    .cornerRadius(6)
            } else if let flag, featureFlagService.isEnabled(flag) {
                Text("Active")
                    .font(AppTheme.badgeFont)
                    .foregroundColor(AppTheme.primary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(AppTheme.primary.opacity(0.12))
                    .cornerRadius(6)
            } else {
                Text("Locked")
                    .font(AppTheme.badgeFont)
                    .foregroundColor(AppTheme.lockedBadge)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color(.systemGray5))
                    .cornerRadius(6)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
    }

    private var librarySection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader("LIBRARY")

            Button { showArchived = true } label: {
                HStack {
                    Image(systemName: "archivebox.fill")
                        .foregroundColor(AppTheme.primary)
                    Text("Archived Recipes")
                        .font(AppTheme.bodyFont)
                        .foregroundColor(.primary)
                    Spacer()
                    Text("\(viewModel.archivedCount)")
                        .font(AppTheme.captionFont)
                        .foregroundColor(AppTheme.secondaryText)
                    Image(systemName: "chevron.right")
                        .foregroundColor(AppTheme.secondaryText)
                }
                .padding()
                .background(AppTheme.cardBackground)
                .cornerRadius(AppTheme.cornerRadius)
            }
            .padding(.horizontal)
        }
    }

    private var subscriptionSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader("SUBSCRIPTION")
            VStack(spacing: 0) {
                Button {
                    if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    settingsRow(icon: "creditcard.fill", title: "Manage Subscription")
                }
                Divider().padding(.leading, 50)
                Button { showRestoreAlert = true } label: {
                    settingsRow(icon: "arrow.clockwise", title: "Restore Purchases")
                }
            }
            .background(AppTheme.cardBackground)
            .cornerRadius(AppTheme.cornerRadius)
            .padding(.horizontal)
        }
        .alert("Restore Purchases", isPresented: $showRestoreAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Purchase restoration will be available when the subscription system is fully configured.")
        }
    }

    private var accountSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader("ACCOUNT")
            VStack(spacing: 0) {
                Button { showChangeEmail = true } label: {
                    settingsRow(icon: "envelope.fill", title: "Change Email")
                }
                Divider().padding(.leading, 50)
                Button { showChangePassword = true } label: {
                    settingsRow(icon: "lock.fill", title: "Change Password")
                }
            }
            .background(AppTheme.cardBackground)
            .cornerRadius(AppTheme.cornerRadius)
            .padding(.horizontal)
        }
        .alert("Change Email", isPresented: $showChangeEmail) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Email change is managed through your sign-in provider (Apple, Google, or Email).")
        }
        .alert("Change Password", isPresented: $showChangePassword) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Password change is available for email accounts. A reset link will be sent to your email address.")
        }
    }

    private var legalSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader("LEGAL")
            VStack(spacing: 0) {
                Button {
                    if let url = URL(string: "https://clipcook.app/privacy") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    settingsRow(icon: "doc.text.fill", title: "Privacy Policy")
                }
                Divider().padding(.leading, 50)
                Button {
                    if let url = URL(string: "https://clipcook.app/terms") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    settingsRow(icon: "doc.text.fill", title: "Terms of Service")
                }
            }
            .background(AppTheme.cardBackground)
            .cornerRadius(AppTheme.cornerRadius)
            .padding(.horizontal)
        }
    }

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader("ABOUT")
            HStack {
                Text("ClipCook")
                    .font(AppTheme.bodyFont)
                Spacer()
                Text("v1.0.0")
                    .font(AppTheme.captionFont)
                    .foregroundColor(AppTheme.secondaryText)
            }
            .padding()
            .background(AppTheme.cardBackground)
            .cornerRadius(AppTheme.cornerRadius)
            .padding(.horizontal)
        }
    }

    private var dangerZone: some View {
        VStack(spacing: 12) {
            Button {
                authService.signOut()
            } label: {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                    Text("Log Out")
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.destructive)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(AppTheme.destructive.opacity(0.08))
                .cornerRadius(AppTheme.cornerRadiusSM)
            }

            Button { showDeleteConfirmation = true } label: {
                HStack {
                    Image(systemName: "trash.fill")
                    Text("Delete Account")
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.destructive)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(AppTheme.destructive.opacity(0.08))
                .cornerRadius(AppTheme.cornerRadiusSM)
            }
        }
        .padding(.horizontal)
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 13, weight: .semibold))
            .tracking(1)
            .foregroundColor(AppTheme.primary)
            .padding(.horizontal)
            .padding(.top, AppTheme.spacingMD)
            .padding(.bottom, 6)
    }

    private func settingsRow(icon: String, title: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(AppTheme.secondaryText)
                .frame(width: 24)
            Text(title)
                .font(AppTheme.bodyFont)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(AppTheme.secondaryText)
        }
        .padding()
    }
}
