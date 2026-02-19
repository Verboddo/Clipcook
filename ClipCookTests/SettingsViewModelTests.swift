//
//  SettingsViewModelTests.swift
//  ClipCookTests
//
//  Tests for SettingsViewModel with mock services.
//

import Testing
import Foundation
@testable import ClipCook

@MainActor
struct SettingsViewModelTests {

    // MARK: - Load Profile

    @Test func loadProfileFetchesFromFirestore() async {
        let mockAuth = MockAuthService()
        mockAuth.mockUserId = "test-user-id"
        let mockFirestore = MockFirestoreService()
        mockFirestore.storedProfile = UserProfile(
            email: "test@example.com",
            displayName: "Test User",
            units: .metric
        )
        let viewModel = SettingsViewModel(firestoreService: mockFirestore, authService: mockAuth)

        await viewModel.loadProfile()

        #expect(viewModel.userProfile?.email == "test@example.com")
        #expect(viewModel.userProfile?.displayName == "Test User")
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
        #expect(mockFirestore.getProfileCallCount == 1)
    }

    @Test func loadProfileWithoutAuthDoesNothing() async {
        let mockAuth = MockAuthService()
        mockAuth.mockUserId = nil // Not authenticated
        let mockFirestore = MockFirestoreService()
        let viewModel = SettingsViewModel(firestoreService: mockFirestore, authService: mockAuth)

        await viewModel.loadProfile()

        #expect(viewModel.userProfile == nil)
        #expect(mockFirestore.getProfileCallCount == 0)
    }

    @Test func loadProfileHandlesError() async {
        let mockAuth = MockAuthService()
        mockAuth.mockUserId = "test-user-id"
        let mockFirestore = MockFirestoreService()
        mockFirestore.shouldFail = true
        let viewModel = SettingsViewModel(firestoreService: mockFirestore, authService: mockAuth)

        await viewModel.loadProfile()

        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.isLoading == false)
    }

    // MARK: - Update Display Name

    @Test func updateDisplayNameCallsFirestore() async {
        let mockAuth = MockAuthService()
        mockAuth.mockUserId = "test-user-id"
        let mockFirestore = MockFirestoreService()
        let viewModel = SettingsViewModel(firestoreService: mockFirestore, authService: mockAuth)
        viewModel.userProfile = UserProfile(email: "test@example.com", displayName: "Old Name")

        await viewModel.updateDisplayName("New Name")

        #expect(mockFirestore.updateProfileCallCount == 1)
        #expect(viewModel.userProfile?.displayName == "New Name")
        #expect(viewModel.errorMessage == nil)
    }

    @Test func updateDisplayNameHandlesError() async {
        let mockAuth = MockAuthService()
        mockAuth.mockUserId = "test-user-id"
        let mockFirestore = MockFirestoreService()
        mockFirestore.shouldFail = true
        let viewModel = SettingsViewModel(firestoreService: mockFirestore, authService: mockAuth)

        await viewModel.updateDisplayName("New Name")

        #expect(viewModel.errorMessage != nil)
    }

    // MARK: - Update Units

    @Test func updateUnitsCallsFirestore() async {
        let mockAuth = MockAuthService()
        mockAuth.mockUserId = "test-user-id"
        let mockFirestore = MockFirestoreService()
        let viewModel = SettingsViewModel(firestoreService: mockFirestore, authService: mockAuth)
        viewModel.userProfile = UserProfile(email: "test@example.com", units: .metric)

        await viewModel.updateUnits(.imperial)

        #expect(mockFirestore.updateProfileCallCount == 1)
        #expect(viewModel.userProfile?.units == .imperial)
        #expect(viewModel.errorMessage == nil)
    }

    @Test func updateUnitsWithoutAuthDoesNothing() async {
        let mockAuth = MockAuthService()
        mockAuth.mockUserId = nil
        let mockFirestore = MockFirestoreService()
        let viewModel = SettingsViewModel(firestoreService: mockFirestore, authService: mockAuth)

        await viewModel.updateUnits(.imperial)

        #expect(mockFirestore.updateProfileCallCount == 0)
    }
}
