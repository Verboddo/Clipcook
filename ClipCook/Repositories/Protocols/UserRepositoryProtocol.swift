import Foundation

protocol UserRepositoryProtocol {
    func getUser(_ userId: String) async throws -> AppUser?
    func createUser(_ user: AppUser) async throws
    func updatePreferences(_ userId: String, units: MeasurementUnit?, darkMode: Bool?) async throws
    func updateNutritionGoals(_ userId: String, goals: NutritionGoals) async throws
    func updatePremiumStatus(_ userId: String, isPremium: Bool, flags: FeatureFlags) async throws
    func deleteAccount(_ userId: String) async throws
}
