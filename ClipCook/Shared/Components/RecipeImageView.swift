import SwiftUI

struct RecipeImageView: View {
    let urlString: String?

    var body: some View {
        if let urlString, let url = URL(string: urlString) {
            if url.isFileURL {
                localImage(url: url)
            } else {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    default:
                        placeholder
                    }
                }
            }
        } else {
            placeholder
        }
    }

    @ViewBuilder
    private func localImage(url: URL) -> some View {
        if let data = try? Data(contentsOf: url),
           let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else {
            placeholder
        }
    }

    private var placeholder: some View {
        Rectangle()
            .fill(Color(.systemGray5))
            .overlay {
                Image(systemName: "photo")
                    .foregroundStyle(Color(.systemGray3))
            }
    }
}
