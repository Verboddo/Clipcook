import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Firebase is configured in ClipCookApp.init() to ensure it runs
        // before any @State properties that depend on Firebase services.
        return true
    }
}
