import Foundation
import AuthenticationServices
import FirebaseAuth
import OSLog

private let logger = Logger(subsystem: "com.clipcook.app", category: "AuthViewModel")

@Observable
final class AuthViewModel {
    var isAuthenticated = false
    var isLoading = true
    var errorMessage: String?
    var email = ""
    var password = ""

    private let authService: AuthServiceProtocol
    private let firestoreService: any UserProfileServiceProtocol
    private var authHandle: AuthStateDidChangeListenerHandle?
    private var currentNonce: String?

    init(
        authService: AuthServiceProtocol = AuthService.shared,
        firestoreService: any UserProfileServiceProtocol = FirestoreService.shared
    ) {
        self.authService = authService
        self.firestoreService = firestoreService
        listenToAuthState()
    }

    deinit {
        if let authHandle {
            authService.removeStateDidChangeListener(authHandle)
        }
    }

    // MARK: - Auth State

    private func listenToAuthState() {
        authHandle = authService.addStateDidChangeListener { [weak self] user in
            guard let self else { return }
            self.isAuthenticated = user != nil
            self.isLoading = false
        }
    }

    // MARK: - Email/Password Actions

    func signIn() async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Vul je email en wachtwoord in."
            return
        }
        errorMessage = nil
        isLoading = true

        do {
            try await authService.signIn(email: email, password: password)
            clearForm()
        } catch {
            errorMessage = mapAuthError(error)
            logger.error("Sign in error: \(error.localizedDescription)")
        }

        isLoading = false
    }

    func signUp() async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Vul je email en wachtwoord in."
            return
        }
        guard password.count >= 6 else {
            errorMessage = "Wachtwoord moet minimaal 6 tekens bevatten."
            return
        }
        errorMessage = nil
        isLoading = true

        do {
            try await authService.signUp(email: email, password: password)
            // Create user profile in Firestore
            if let userId = authService.currentUserId {
                let profile = UserProfile(email: email, displayName: "")
                try await firestoreService.createUserProfile(userId: userId, profile: profile)
            }
            clearForm()
        } catch {
            errorMessage = mapAuthError(error)
            logger.error("Sign up error: \(error.localizedDescription)")
        }

        isLoading = false
    }

    // MARK: - Apple Sign In

    /// Configures the Apple Sign In request with a fresh nonce.
    /// Call this from `SignInWithAppleButton`'s `onRequest` closure.
    func handleAppleSignInRequest(_ request: ASAuthorizationAppleIDRequest) {
        let nonce = AppleSignInHelper.randomNonceString()
        currentNonce = nonce
        request.requestedScopes = [.fullName, .email]
        request.nonce = AppleSignInHelper.sha256(nonce)
    }

    /// Handles the result of the Apple Sign In flow.
    /// Call this from `SignInWithAppleButton`'s `onCompletion` closure.
    func handleAppleSignInCompletion(_ result: Result<ASAuthorization, Error>) async {
        isLoading = true
        errorMessage = nil

        switch result {
        case .success(let authorization):
            guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
                  let appleIDToken = appleIDCredential.identityToken,
                  let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                errorMessage = AppleSignInError.missingIdToken.localizedDescription
                isLoading = false
                return
            }

            guard let nonce = currentNonce else {
                errorMessage = AppleSignInError.missingNonce.localizedDescription
                isLoading = false
                return
            }

            do {
                try await authService.signInWithApple(
                    idToken: idTokenString,
                    rawNonce: nonce,
                    fullName: appleIDCredential.fullName
                )

                // Create user profile in Firestore if this is a new user
                if let userId = authService.currentUserId {
                    let existingProfile = try? await firestoreService.getUserProfile(userId: userId)
                    if existingProfile == nil {
                        let displayName = [
                            appleIDCredential.fullName?.givenName,
                            appleIDCredential.fullName?.familyName
                        ]
                            .compactMap { $0 }
                            .joined(separator: " ")
                        let userEmail = appleIDCredential.email ?? authService.currentUser?.email ?? ""
                        let profile = UserProfile(email: userEmail, displayName: displayName)
                        try await firestoreService.createUserProfile(userId: userId, profile: profile)
                    }
                }

                clearForm()
                logger.info("Apple Sign In completed successfully")
            } catch {
                errorMessage = mapAuthError(error)
                logger.error("Apple Sign In error: \(error.localizedDescription)")
            }

        case .failure(let error):
            let nsError = error as NSError
            // Don't show error if user cancelled
            if nsError.code != ASAuthorizationError.canceled.rawValue {
                errorMessage = "Apple Sign In mislukt. Probeer het opnieuw."
                logger.error("Apple Sign In error: \(error.localizedDescription)")
            }
        }

        isLoading = false
    }

    // MARK: - Sign Out

    func signOut() {
        do {
            try authService.signOut()
            clearForm()
        } catch {
            errorMessage = "Uitloggen mislukt. Probeer het opnieuw."
            logger.error("Sign out error: \(error.localizedDescription)")
        }
    }

    // MARK: - Helpers

    private func clearForm() {
        email = ""
        password = ""
        errorMessage = nil
        currentNonce = nil
    }

    private func mapAuthError(_ error: Error) -> String {
        let nsError = error as NSError
        switch nsError.code {
        case AuthErrorCode.wrongPassword.rawValue:
            return "Onjuist wachtwoord."
        case AuthErrorCode.userNotFound.rawValue:
            return "Geen account gevonden met dit emailadres."
        case AuthErrorCode.emailAlreadyInUse.rawValue:
            return "Dit emailadres is al in gebruik."
        case AuthErrorCode.invalidEmail.rawValue:
            return "Ongeldig emailadres."
        case AuthErrorCode.weakPassword.rawValue:
            return "Wachtwoord is te zwak. Gebruik minimaal 6 tekens."
        case AuthErrorCode.networkError.rawValue:
            return "Netwerkfout. Controleer je internetverbinding."
        default:
            return "Er is een fout opgetreden. Probeer het opnieuw."
        }
    }
}
