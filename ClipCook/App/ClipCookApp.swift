import SwiftUI
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import OSLog

private let logger = Logger(subsystem: "com.clipcook.app", category: "App")

@main
struct ClipCookApp: App {
    @State private var authViewModel: AuthViewModel

    init() {
        FirebaseApp.configure()

        #if DEBUG
        // Connect to Firebase Emulator Suite for local development
        // Use 127.0.0.1 instead of localhost to avoid IPv6 resolution issues
        Auth.auth().useEmulator(withHost: "127.0.0.1", port: 9099)

        let settings = Firestore.firestore().settings
        settings.host = "127.0.0.1:8080"
        settings.isSSLEnabled = false
        Firestore.firestore().settings = settings

        logger.info("Firebase Emulators configured: Auth=127.0.0.1:9099, Firestore=127.0.0.1:8080")
        #endif

        _authViewModel = State(initialValue: AuthViewModel())
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(authViewModel)
        }
    }
}
