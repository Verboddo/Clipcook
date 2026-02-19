import Foundation
import AuthenticationServices
import FirebaseAuth
import OSLog

private let logger = Logger(subsystem: "com.clipcook.app", category: "AuthService")

protocol AuthServiceProtocol {
    var currentUser: User? { get }
    var currentUserId: String? { get }
    func signIn(email: String, password: String) async throws
    func signUp(email: String, password: String) async throws
    func signInWithApple(idToken: String, rawNonce: String, fullName: PersonNameComponents?) async throws
    func signOut() throws
    func addStateDidChangeListener(_ listener: @escaping (User?) -> Void) -> AuthStateDidChangeListenerHandle
    func removeStateDidChangeListener(_ handle: AuthStateDidChangeListenerHandle)
}

final class AuthService: AuthServiceProtocol {
    static let shared = AuthService()

    private let auth = Auth.auth()

    private init() {}

    var currentUser: User? {
        auth.currentUser
    }

    var currentUserId: String? {
        auth.currentUser?.uid
    }

    func signIn(email: String, password: String) async throws {
        do {
            try await auth.signIn(withEmail: email, password: password)
            logger.info("User signed in successfully")
        } catch {
            logger.error("Sign in failed: \(error.localizedDescription)")
            throw error
        }
    }

    func signUp(email: String, password: String) async throws {
        do {
            let result = try await auth.createUser(withEmail: email, password: password)
            logger.info("User created successfully: \(result.user.uid)")
        } catch {
            logger.error("Sign up failed: \(error.localizedDescription)")
            throw error
        }
    }

    func signInWithApple(idToken: String, rawNonce: String, fullName: PersonNameComponents?) async throws {
        let credential = OAuthProvider.appleCredential(
            withIDToken: idToken,
            rawNonce: rawNonce,
            fullName: fullName
        )
        do {
            try await auth.signIn(with: credential)
            logger.info("User signed in with Apple successfully")
        } catch {
            logger.error("Apple Sign In failed: \(error.localizedDescription)")
            throw error
        }
    }

    func signOut() throws {
        do {
            try auth.signOut()
            logger.info("User signed out successfully")
        } catch {
            logger.error("Sign out failed: \(error.localizedDescription)")
            throw error
        }
    }

    func addStateDidChangeListener(_ listener: @escaping (User?) -> Void) -> AuthStateDidChangeListenerHandle {
        auth.addStateDidChangeListener { _, user in
            listener(user)
        }
    }

    func removeStateDidChangeListener(_ handle: AuthStateDidChangeListenerHandle) {
        auth.removeStateDidChangeListener(handle)
    }
}
