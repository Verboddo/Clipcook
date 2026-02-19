import Foundation
import AuthenticationServices
import CryptoKit
import OSLog

private let logger = Logger(subsystem: "com.clipcook.app", category: "AppleSignIn")

// MARK: - Apple Sign In Helpers

/// Utility functions for the Sign in with Apple authentication flow.
/// Used by AuthViewModel to generate nonces and hash them for secure auth.
enum AppleSignInHelper {

    /// Generates a cryptographically secure random nonce string.
    /// - Parameter length: The length of the nonce (default: 32).
    /// - Returns: A random string of the specified length.
    static func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        return String(randomBytes.map { byte in charset[Int(byte) % charset.count] })
    }

    /// SHA256 hash of the input string, returned as a hex-encoded string.
    /// - Parameter input: The string to hash.
    /// - Returns: A lowercase hex-encoded SHA256 hash.
    static func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - Apple Sign In Error

/// Errors specific to the Apple Sign In flow.
enum AppleSignInError: LocalizedError {
    case invalidCredential
    case missingIdToken
    case missingNonce

    var errorDescription: String? {
        switch self {
        case .invalidCredential:
            return "Ongeldige Apple Sign In gegevens ontvangen."
        case .missingIdToken:
            return "Geen identity token ontvangen van Apple."
        case .missingNonce:
            return "Beveiligingsfout: nonce ontbreekt. Probeer opnieuw."
        }
    }
}
