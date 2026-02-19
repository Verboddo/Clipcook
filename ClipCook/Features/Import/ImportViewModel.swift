import Foundation
import LinkPresentation
import OSLog

private let logger = Logger(subsystem: "com.clipcook.app", category: "ImportViewModel")

@Observable
final class ImportViewModel {
    var urlString = ""
    var isLoading = false
    var errorMessage: String?
    var fetchedTitle: String?
    var fetchedDescription: String?
    var fetchedImageURL: String?
    var detectedSourceType: Recipe.SourceType = .web

    /// Parsed recipe data (ingredients, steps, etc.) from the URL.
    var parsedRecipe: ParsedRecipe?

    private let metadataProvider = LPMetadataProvider()
    private let parsingService = RecipeParsingService()

    // MARK: - URL Detection

    func detectSourceType(from url: String) -> Recipe.SourceType {
        let lowercased = url.lowercased()
        if lowercased.contains("instagram.com") {
            return .instagram
        } else if lowercased.contains("tiktok.com") {
            return .tiktok
        } else if lowercased.contains("youtube.com") || lowercased.contains("youtu.be") {
            return .youtube
        } else {
            return .web
        }
    }

    // MARK: - Metadata Fetching

    func fetchMetadata() async {
        guard let url = URL(string: urlString), urlString.hasPrefix("http") else {
            errorMessage = "Voer een geldige URL in (begin met http:// of https://)."
            return
        }

        isLoading = true
        errorMessage = nil
        parsedRecipe = nil
        detectedSourceType = detectSourceType(from: urlString)

        // Fetch link metadata (title, image) and parse recipe content in parallel
        async let metadataTask: Void = fetchLinkMetadata(url: url)
        async let parsingTask: Void = parseRecipeContent()

        _ = await (metadataTask, parsingTask)

        isLoading = false
    }

    private func fetchLinkMetadata(url: URL) async {
        do {
            let metadata = try await metadataProvider.startFetchingMetadata(for: url)
            fetchedTitle = metadata.title
            fetchedDescription = metadata.value(forKey: "summary") as? String

            if metadata.imageProvider != nil {
                fetchedImageURL = metadata.originalURL?.absoluteString
            }

            logger.info("Metadata fetched for \(url.absoluteString): title=\(self.fetchedTitle ?? "nil")")
        } catch {
            logger.error("Metadata fetch error: \(error.localizedDescription)")
            // Don't set errorMessage here — recipe parsing may still succeed
        }
    }

    private func parseRecipeContent() async {
        let result = await parsingService.parseRecipe(from: urlString)
        parsedRecipe = result

        if result.hasRecipeContent {
            logger.info("Recipe parsed: \(result.ingredients.count) ingredients, \(result.steps.count) steps")
        } else {
            logger.info("No recipe content found in URL — user will fill in manually")
        }
    }

    // MARK: - Create Recipe from Import

    func createRecipe() -> Recipe {
        let parsed = parsedRecipe

        // Use parsed title if available, otherwise fall back to metadata title
        let title = parsed?.title ?? fetchedTitle ?? "Nieuw recept"

        return Recipe(
            title: title,
            sourceURL: urlString,
            sourceType: detectedSourceType,
            imageURL: fetchedImageURL,
            ingredients: parsed?.ingredients ?? [],
            steps: parsed?.steps ?? [],
            servings: parsed?.servings,
            calories: parsed?.calories,
            tags: parsed?.tags ?? [],
            notes: fetchedDescription
        )
    }

    // MARK: - Pending Imports (from Share Extension)

    /// Each pending import is a dictionary with keys: "type", "content", "timestamp"
    /// stored by the Share Extension.
    func loadPendingImports() -> [[String: String]] {
        guard let groupDefaults = UserDefaults(suiteName: "group.com.clipcook.app") else {
            return []
        }
        let pending = groupDefaults.array(forKey: "pendingImports") as? [[String: String]] ?? []
        return pending
    }

    /// Convenience: returns only the URL strings from pending imports.
    func loadPendingImportURLs() -> [String] {
        loadPendingImports()
            .filter { $0["type"] == "url" }
            .compactMap { $0["content"] }
    }

    func clearPendingImports() {
        guard let groupDefaults = UserDefaults(suiteName: "group.com.clipcook.app") else {
            return
        }
        groupDefaults.removeObject(forKey: "pendingImports")
        logger.info("Pending imports cleared")
    }

    func reset() {
        urlString = ""
        fetchedTitle = nil
        fetchedDescription = nil
        fetchedImageURL = nil
        detectedSourceType = .web
        errorMessage = nil
        parsedRecipe = nil
    }
}
