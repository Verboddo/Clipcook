import Foundation
import FirebaseAuth
import FirebaseFirestore
import AuthenticationServices
import CryptoKit

@Observable
final class AuthService: NSObject {
    var isAuthenticated = false
    var currentUserId: String = ""
    var currentUser: AppUser?
    var errorMessage: String?

    private let userRepo = FirestoreUserRepository()
    private var authStateHandle: AuthStateDidChangeListenerHandle?
    private var currentNonce: String?

    override init() {
        super.init()
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.isAuthenticated = user != nil
            self?.currentUserId = user?.uid ?? ""
            if let user {
                Task { await self?.fetchUserProfile(uid: user.uid, firebaseUser: user) }
            } else {
                self?.currentUser = nil
            }
        }
    }

    private func fetchUserProfile(uid: String, firebaseUser: FirebaseAuth.User) async {
        do {
            if let existing = try await userRepo.getUser(uid) {
                currentUser = existing
            } else {
                let newUser = AppUser(
                    firestoreID: uid,
                    email: firebaseUser.email ?? "",
                    displayName: firebaseUser.displayName ?? "Chef User"
                )
                try await userRepo.createUser(newUser)
                currentUser = newUser
                await seedSampleRecipes(userId: uid)
            }
        } catch {
            print("Error fetching user profile: \(error)")
        }
    }

    // MARK: - Apple Sign-In

    func handleAppleSignIn(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let auth):
            guard let credential = auth.credential as? ASAuthorizationAppleIDCredential,
                  let tokenData = credential.identityToken,
                  let idToken = String(data: tokenData, encoding: .utf8),
                  let nonce = currentNonce else {
                errorMessage = "Apple Sign-In failed: invalid credential"
                return
            }
            let firebaseCredential = OAuthProvider.appleCredential(
                withIDToken: idToken,
                rawNonce: nonce,
                fullName: credential.fullName
            )
            Task {
                do {
                    try await Auth.auth().signIn(with: firebaseCredential)
                } catch {
                    errorMessage = error.localizedDescription
                }
            }
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }

    func prepareAppleNonce() -> String {
        let nonce = randomNonceString()
        currentNonce = nonce
        return sha256(nonce)
    }

    // MARK: - Email Sign-In

    func signInWithEmail(email: String, password: String) async {
        do {
            try await Auth.auth().signIn(withEmail: email, password: password)
        } catch {
            do {
                try await Auth.auth().createUser(withEmail: email, password: password)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    // MARK: - Sign Out

    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteAccount() async {
        guard let user = Auth.auth().currentUser else { return }
        do {
            try await userRepo.deleteAccount(user.uid)
            try await user.delete()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Nonce Helpers

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        _ = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        return String(randomBytes.map { charset[Int($0) % charset.count] })
    }

    private func sha256(_ input: String) -> String {
        let data = Data(input.utf8)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }

    // MARK: - Seed Data

    private func seedSampleRecipes(userId: String) async {
        let repo = FirestoreRecipeRepository()
        let recipes = SeedData.sampleRecipes(userId: userId)
        for recipe in recipes {
            _ = try? await repo.create(recipe)
        }
    }
}
