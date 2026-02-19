import Foundation
import FirebaseFirestore

struct UserProfile: Codable {
    var email: String
    var displayName: String
    var units: UnitSystem
    var isPremium: Bool
    var isBetaTester: Bool
    @ServerTimestamp var createdAt: Timestamp?
    @ServerTimestamp var updatedAt: Timestamp?

    enum UnitSystem: String, Codable, CaseIterable {
        case metric
        case imperial
    }

    init(
        email: String = "",
        displayName: String = "",
        units: UnitSystem = .metric,
        isPremium: Bool = false,
        isBetaTester: Bool = false
    ) {
        self.email = email
        self.displayName = displayName
        self.units = units
        self.isPremium = isPremium
        self.isBetaTester = isBetaTester
    }
}
