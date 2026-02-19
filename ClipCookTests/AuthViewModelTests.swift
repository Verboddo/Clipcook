//
//  AuthViewModelTests.swift
//  ClipCookTests
//
//  Tests for AuthViewModel validation logic and error handling.
//

import Testing
import Foundation
@testable import ClipCook

@MainActor
struct AuthViewModelTests {

    // MARK: - Sign In Validation

    @Test func signInWithEmptyFieldsShowsError() async {
        let mockAuth = MockAuthService()
        let mockFirestore = MockFirestoreService()
        let viewModel = AuthViewModel(authService: mockAuth, firestoreService: mockFirestore)

        viewModel.email = ""
        viewModel.password = ""

        await viewModel.signIn()

        #expect(viewModel.errorMessage == "Vul je email en wachtwoord in.")
        #expect(mockAuth.signInCallCount == 0, "signIn should not be called with empty fields")
    }

    @Test func signInWithEmptyEmailShowsError() async {
        let mockAuth = MockAuthService()
        let mockFirestore = MockFirestoreService()
        let viewModel = AuthViewModel(authService: mockAuth, firestoreService: mockFirestore)

        viewModel.email = ""
        viewModel.password = "password123"

        await viewModel.signIn()

        #expect(viewModel.errorMessage == "Vul je email en wachtwoord in.")
    }

    @Test func signInWithEmptyPasswordShowsError() async {
        let mockAuth = MockAuthService()
        let mockFirestore = MockFirestoreService()
        let viewModel = AuthViewModel(authService: mockAuth, firestoreService: mockFirestore)

        viewModel.email = "test@example.com"
        viewModel.password = ""

        await viewModel.signIn()

        #expect(viewModel.errorMessage == "Vul je email en wachtwoord in.")
    }

    @Test func signInCallsAuthService() async {
        let mockAuth = MockAuthService()
        let mockFirestore = MockFirestoreService()
        let viewModel = AuthViewModel(authService: mockAuth, firestoreService: mockFirestore)

        viewModel.email = "test@example.com"
        viewModel.password = "password123"

        await viewModel.signIn()

        #expect(mockAuth.signInCallCount == 1)
        #expect(mockAuth.lastSignInEmail == "test@example.com")
        #expect(viewModel.errorMessage == nil)
    }

    @Test func signInFailureShowsError() async {
        let mockAuth = MockAuthService()
        mockAuth.shouldFailSignIn = true
        let mockFirestore = MockFirestoreService()
        let viewModel = AuthViewModel(authService: mockAuth, firestoreService: mockFirestore)

        viewModel.email = "test@example.com"
        viewModel.password = "password123"

        await viewModel.signIn()

        #expect(viewModel.errorMessage != nil)
        #expect(mockAuth.signInCallCount == 1)
    }

    @Test func signInSuccessClearsForm() async {
        let mockAuth = MockAuthService()
        let mockFirestore = MockFirestoreService()
        let viewModel = AuthViewModel(authService: mockAuth, firestoreService: mockFirestore)

        viewModel.email = "test@example.com"
        viewModel.password = "password123"

        await viewModel.signIn()

        #expect(viewModel.email == "")
        #expect(viewModel.password == "")
    }

    // MARK: - Sign Up Validation

    @Test func signUpWithEmptyFieldsShowsError() async {
        let mockAuth = MockAuthService()
        let mockFirestore = MockFirestoreService()
        let viewModel = AuthViewModel(authService: mockAuth, firestoreService: mockFirestore)

        viewModel.email = ""
        viewModel.password = ""

        await viewModel.signUp()

        #expect(viewModel.errorMessage == "Vul je email en wachtwoord in.")
        #expect(mockAuth.signUpCallCount == 0)
    }

    @Test func signUpWithShortPasswordShowsError() async {
        let mockAuth = MockAuthService()
        let mockFirestore = MockFirestoreService()
        let viewModel = AuthViewModel(authService: mockAuth, firestoreService: mockFirestore)

        viewModel.email = "test@example.com"
        viewModel.password = "12345"

        await viewModel.signUp()

        #expect(viewModel.errorMessage == "Wachtwoord moet minimaal 6 tekens bevatten.")
        #expect(mockAuth.signUpCallCount == 0)
    }

    @Test func signUpCallsAuthAndFirestore() async {
        let mockAuth = MockAuthService()
        let mockFirestore = MockFirestoreService()
        let viewModel = AuthViewModel(authService: mockAuth, firestoreService: mockFirestore)

        viewModel.email = "test@example.com"
        viewModel.password = "password123"

        await viewModel.signUp()

        #expect(mockAuth.signUpCallCount == 1)
        #expect(mockAuth.lastSignUpEmail == "test@example.com")
        #expect(mockFirestore.createProfileCallCount == 1)
        #expect(viewModel.errorMessage == nil)
    }

    @Test func signUpSuccessClearsForm() async {
        let mockAuth = MockAuthService()
        let mockFirestore = MockFirestoreService()
        let viewModel = AuthViewModel(authService: mockAuth, firestoreService: mockFirestore)

        viewModel.email = "test@example.com"
        viewModel.password = "password123"

        await viewModel.signUp()

        #expect(viewModel.email == "")
        #expect(viewModel.password == "")
    }

    // MARK: - Sign Out

    @Test func signOutCallsAuthService() {
        let mockAuth = MockAuthService()
        let mockFirestore = MockFirestoreService()
        let viewModel = AuthViewModel(authService: mockAuth, firestoreService: mockFirestore)

        viewModel.signOut()

        #expect(mockAuth.signOutCallCount == 1)
    }

    @Test func signOutFailureShowsError() {
        let mockAuth = MockAuthService()
        mockAuth.shouldFailSignOut = true
        let mockFirestore = MockFirestoreService()
        let viewModel = AuthViewModel(authService: mockAuth, firestoreService: mockFirestore)

        viewModel.signOut()

        #expect(viewModel.errorMessage == "Uitloggen mislukt. Probeer het opnieuw.")
    }
}
