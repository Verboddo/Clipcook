import Foundation

@Observable
final class FeatureFlagService {
    var flags: FeatureFlags = .free

    func isEnabled(_ keyPath: KeyPath<FeatureFlags, Bool>) -> Bool {
        flags[keyPath: keyPath]
    }

    func updateFlags(_ newFlags: FeatureFlags) {
        flags = newFlags
    }

    func setAllPremium(_ enabled: Bool) {
        flags = enabled ? .premium : .free
    }
}
