import Foundation
@testable import ClipCook

/// Mock implementation of UserProfileServiceProtocol for unit testing.
final class MockFirestoreService: UserProfileServiceProtocol {

    // MARK: - Configurable Behavior

    var shouldFail = false
    var mockError: Error = NSError(domain: "test", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock Firestore error"])
    var storedProfile: UserProfile?

    // MARK: - Call Tracking

    var createProfileCallCount = 0
    var getProfileCallCount = 0
    var updateProfileCallCount = 0
    var lastUpdatedData: [String: Any]?

    // MARK: - UserProfileServiceProtocol

    func createUserProfile(userId: String, profile: UserProfile) async throws {
        createProfileCallCount += 1
        if shouldFail { throw mockError }
        storedProfile = profile
    }

    func getUserProfile(userId: String) async throws -> UserProfile? {
        getProfileCallCount += 1
        if shouldFail { throw mockError }
        return storedProfile
    }

    func updateUserProfile(userId: String, data: [String: Any]) async throws {
        updateProfileCallCount += 1
        lastUpdatedData = data
        if shouldFail { throw mockError }
    }
}
