import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: icon)
        } description: {
            Text(message)
        }
    }
}

#Preview {
    EmptyStateView(
        icon: "book",
        title: "Geen recepten",
        message: "Voeg je eerste recept toe via de + knop."
    )
}
