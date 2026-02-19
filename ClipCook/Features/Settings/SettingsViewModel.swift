import Foundation
import OSLog

private let logger = Logger(subsystem: "com.clipcook.app", category: "SettingsViewModel")

@Observable
final class SettingsViewModel {
    var userProfile: UserProfile?
    var isLoading = false
    var errorMessage: String?

    private let firestoreService: any UserProfileServiceProtocol
    private let authService: AuthServiceProtocol

    init(
        firestoreService: any UserProfileServiceProtocol = FirestoreService.shared,
        authService: AuthServiceProtocol = AuthService.shared
    ) {
        self.firestoreService = firestoreService
        self.authService = authService
    }

    func loadProfile() async {
        guard let userId = authService.currentUserId else { return }
        isLoading = true
        do {
            userProfile = try await firestoreService.getUserProfile(userId: userId)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
            logger.error("Load profile error: \(error.localizedDescription)")
        }
        isLoading = false
    }

    func updateDisplayName(_ name: String) async {
        guard let userId = authService.currentUserId else { return }
        do {
            try await firestoreService.updateUserProfile(userId: userId, data: ["displayName": name])
            userProfile?.displayName = name
        } catch {
            errorMessage = error.localizedDescription
            logger.error("Update display name error: \(error.localizedDescription)")
        }
    }

    func updateUnits(_ units: UserProfile.UnitSystem) async {
        guard let userId = authService.currentUserId else { return }
        do {
            try await firestoreService.updateUserProfile(userId: userId, data: ["units": units.rawValue])
            userProfile?.units = units
        } catch {
            errorMessage = error.localizedDescription
            logger.error("Update units error: \(error.localizedDescription)")
        }
    }
}
