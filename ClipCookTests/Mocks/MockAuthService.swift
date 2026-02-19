import Foundation
import FirebaseAuth
@testable import ClipCook

/// Mock implementation of AuthServiceProtocol for unit testing.
final class MockAuthService: AuthServiceProtocol {

    // MARK: - Configurable Behavior

    var shouldFailSignIn = false
    var shouldFailSignUp = false
    var shouldFailSignOut = false
    var shouldFailAppleSignIn = false
    var mockUserId: String?
    var mockError: Error = NSError(domain: "test", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock error"])

    // MARK: - Call Tracking

    var signInCallCount = 0
    var signUpCallCount = 0
    var signOutCallCount = 0
    var appleSignInCallCount = 0
    var lastSignInEmail: String?
    var lastSignUpEmail: String?

    // MARK: - AuthServiceProtocol

    var currentUser: User? { nil }

    var currentUserId: String? { mockUserId }

    func signIn(email: String, password: String) async throws {
        signInCallCount += 1
        lastSignInEmail = email
        if shouldFailSignIn { throw mockError }
        mockUserId = "mock-user-id"
    }

    func signUp(email: String, password: String) async throws {
        signUpCallCount += 1
        lastSignUpEmail = email
        if shouldFailSignUp { throw mockError }
        mockUserId = "mock-user-id"
    }

    func signInWithApple(idToken: String, rawNonce: String, fullName: PersonNameComponents?) async throws {
        appleSignInCallCount += 1
        if shouldFailAppleSignIn { throw mockError }
        mockUserId = "apple-mock-user-id"
    }

    func signOut() throws {
        signOutCallCount += 1
        if shouldFailSignOut { throw mockError }
        mockUserId = nil
    }

    func addStateDidChangeListener(_ listener: @escaping (User?) -> Void) -> AuthStateDidChangeListenerHandle {
        // Immediately call listener with nil (not authenticated)
        listener(nil)
        return NSObject() as! AuthStateDidChangeListenerHandle // swiftlint:disable:this force_cast
    }

    func removeStateDidChangeListener(_ handle: AuthStateDidChangeListenerHandle) {
        // No-op for mock
    }
}
