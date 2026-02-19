import SwiftUI

struct LinkPreviewCard: View {
    let title: String
    let description: String?
    let sourceType: Recipe.SourceType

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Source badge
            HStack {
                Image(systemName: sourceIcon)
                    .foregroundStyle(.tint)
                Text(sourceType.rawValue.capitalized)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.tint)
                Spacer()
            }

            // Title
            Text(title)
                .font(.headline)
                .lineLimit(2)

            // Description
            if let description, !description.isEmpty {
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var sourceIcon: String {
        switch sourceType {
        case .instagram: return "camera"
        case .tiktok: return "play.rectangle"
        case .youtube: return "play.circle"
        case .web: return "globe"
        case .manual: return "pencil"
        }
    }
}

#Preview {
    LinkPreviewCard(
        title: "Heerlijke Pasta Carbonara",
        description: "Een authentiek Italiaans recept met guanciale, pecorino en ei.",
        sourceType: .instagram
    )
    .padding()
}
