import SwiftUI

enum AppTheme {
    // MARK: - Colors

    static let primary = Color(red: 0.91, green: 0.44, blue: 0.23)       // #E8713A warm orange
    static let primaryLight = Color(red: 0.95, green: 0.80, blue: 0.70)   // light orange tint
    static let primaryBackground = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor.systemBackground
            : UIColor(red: 0.98, green: 0.97, blue: 0.96, alpha: 1.0)
    })
    static let cardBackground = Color(.systemBackground)
    static let secondaryText = Color(.secondaryLabel)
    static let destructive = Color.red
    static let success = Color.green
    static let proteinBadge = Color(red: 0.20, green: 0.40, blue: 0.35)
    static let calorieBadge = Color(red: 0.91, green: 0.44, blue: 0.23)
    static let lockedBadge = Color(.secondaryLabel)
    static let freeBadge = Color.green

    // MARK: - Spacing

    static let spacingXS: CGFloat = 4
    static let spacingSM: CGFloat = 8
    static let spacingMD: CGFloat = 16
    static let spacingLG: CGFloat = 24
    static let spacingXL: CGFloat = 32

    // MARK: - Corner Radius

    static let cornerRadius: CGFloat = 16
    static let cornerRadiusSM: CGFloat = 10
    static let cornerRadiusLG: CGFloat = 24

    // MARK: - Fonts

    static let titleFont = Font.system(size: 28, weight: .bold)
    static let headlineFont = Font.system(size: 20, weight: .bold)
    static let subheadlineFont = Font.system(size: 16, weight: .semibold)
    static let bodyFont = Font.system(size: 16, weight: .regular)
    static let captionFont = Font.system(size: 13, weight: .regular)
    static let badgeFont = Font.system(size: 12, weight: .medium)
}

struct AppButtonStyle: ButtonStyle {
    var isPrimary: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(isPrimary ? .white : AppTheme.primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isPrimary ? AppTheme.primary : Color.clear)
            .cornerRadius(AppTheme.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .stroke(isPrimary ? Color.clear : AppTheme.primary, lineWidth: 1.5)
            )
            .opacity(configuration.isPressed ? 0.85 : 1.0)
    }
}
