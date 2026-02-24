import SwiftUI

struct RecipeCardView: View {
    let recipe: Recipe
    var onFavouriteTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topTrailing) {
                RecipeImageView(urlString: recipe.thumbnail)
                    .frame(height: 120)
                    .clipped()
                    .cornerRadius(AppTheme.cornerRadiusSM)

                Button {
                    onFavouriteTap()
                } label: {
                    Image(systemName: recipe.isFavourite ? "heart.fill" : "heart")
                        .font(.system(size: 14))
                        .foregroundColor(recipe.isFavourite ? .red : .white)
                        .padding(8)
                        .background(Color.black.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .padding(6)
            }

            Text(recipe.title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)
                .lineLimit(2)

            if !recipe.cookTime.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 11))
                    Text(recipe.cookTime)
                        .font(.system(size: 12))
                }
                .foregroundColor(AppTheme.secondaryText)
            }

            if let nutrition = recipe.nutrition {
                HStack(spacing: 6) {
                    badge(text: "\(nutrition.calories) cal", color: AppTheme.calorieBadge)
                    badge(text: "\(nutrition.protein)g protein", color: AppTheme.proteinBadge)
                }
            }
        }
        .padding(10)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.cornerRadius)
        .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(recipe.title), \(recipe.cookTime.isEmpty ? "" : recipe.cookTime), \(recipe.nutrition.map { "\($0.calories) calories" } ?? "")")
        .accessibilityHint("Double tap to view recipe details")
    }

    private var placeholder: some View {
        Rectangle()
            .fill(Color(.systemGray5))
            .overlay {
                Image(systemName: "photo")
                    .foregroundColor(Color(.systemGray3))
            }
    }

    private func badge(text: String, color: Color) -> some View {
        Text(text)
            .font(AppTheme.badgeFont)
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.12))
            .cornerRadius(6)
    }
}
