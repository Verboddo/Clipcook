import SwiftUI

extension Color {
    /// App accent color — uses system accent by default.
    /// Can be customized later via Assets.xcassets.
    static let appAccent = Color.accentColor

    /// Background colors that adapt to Light/Dark mode.
    static let appBackground = Color(uiColor: .systemBackground)
    static let appSecondaryBackground = Color(uiColor: .secondarySystemBackground)
    static let appGroupedBackground = Color(uiColor: .systemGroupedBackground)
}
