import Foundation
import OSLog

private let logger = Logger(subsystem: "com.clipcook.app", category: "RecipeParsing")

/// Result of parsing a URL for recipe content.
struct ParsedRecipe {
    var title: String?
    var ingredients: [Ingredient]
    var steps: [String]
    var servings: Int?
    var calories: Int?
    var tags: [String]
    var notes: String?

    var hasRecipeContent: Bool {
        !ingredients.isEmpty || !steps.isEmpty
    }
}

/// Service that extracts recipe data from URLs.
/// - Instagram/TikTok: Fetches the page HTML, extracts caption from og:description, parses for ingredients & steps.
/// - Recipe websites: Looks for JSON-LD structured data (schema.org/Recipe).
final class RecipeParsingService {

    // MARK: - Public API

    /// Attempts to extract recipe data from a URL.
    func parseRecipe(from urlString: String) async -> ParsedRecipe {
        guard let url = URL(string: urlString) else {
            return ParsedRecipe(ingredients: [], steps: [], tags: [])
        }

        // Fetch the raw HTML of the page
        guard let html = await fetchHTML(from: url) else {
            logger.warning("Could not fetch HTML for \(urlString)")
            return ParsedRecipe(ingredients: [], steps: [], tags: [])
        }

        // Try JSON-LD first (recipe websites like allrecipes, seriouseats, etc.)
        if let jsonLDRecipe = parseJSONLD(from: html) {
            logger.info("Parsed recipe from JSON-LD structured data")
            return jsonLDRecipe
        }

        // Fallback: extract caption/description text and parse it
        let caption = extractCaption(from: html)
        if let caption, !caption.isEmpty {
            let parsed = parseCaptionForRecipe(caption)
            if parsed.hasRecipeContent {
                logger.info("Parsed recipe from caption text: \(parsed.ingredients.count) ingredients, \(parsed.steps.count) steps")
            } else {
                logger.info("Caption found but no recipe pattern detected")
            }
            return parsed
        }

        logger.info("No recipe content found in page")
        return ParsedRecipe(ingredients: [], steps: [], tags: [])
    }

    // MARK: - HTML Fetching

    private func fetchHTML(from url: URL) async -> String? {
        var request = URLRequest(url: url)
        request.setValue(
            "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1",
            forHTTPHeaderField: "User-Agent"
        )
        request.setValue("en-US,en;q=0.9,nl;q=0.8", forHTTPHeaderField: "Accept-Language")
        request.timeoutInterval = 15

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                logger.warning("HTTP error fetching \(url.absoluteString)")
                return nil
            }
            return String(data: data, encoding: .utf8)
        } catch {
            logger.error("Failed to fetch HTML: \(error.localizedDescription)")
            return nil
        }
    }

    // MARK: - JSON-LD Parsing (Method 2: Recipe Websites)

    private func parseJSONLD(from html: String) -> ParsedRecipe? {
        // Find all <script type="application/ld+json"> blocks
        let pattern = #"<script[^>]*type\s*=\s*["\']application/ld\+json["\'][^>]*>([\s\S]*?)</script>"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
            return nil
        }

        let range = NSRange(html.startIndex..., in: html)
        let matches = regex.matches(in: html, range: range)

        for match in matches {
            guard let jsonRange = Range(match.range(at: 1), in: html) else { continue }
            let jsonString = String(html[jsonRange]).trimmingCharacters(in: .whitespacesAndNewlines)

            guard let data = jsonString.data(using: .utf8) else { continue }

            // Try parsing as a single object or an array
            if let recipe = extractRecipeFromJSON(data) {
                return recipe
            }
        }

        return nil
    }

    private func extractRecipeFromJSON(_ data: Data) -> ParsedRecipe? {
        guard let json = try? JSONSerialization.jsonObject(with: data) else { return nil }

        // Could be a single object or an array
        if let dict = json as? [String: Any] {
            return parseRecipeDict(dict)
        } else if let array = json as? [[String: Any]] {
            for item in array {
                if let recipe = parseRecipeDict(item) {
                    return recipe
                }
            }
        }
        return nil
    }

    private func parseRecipeDict(_ dict: [String: Any]) -> ParsedRecipe? {
        // Check @type — could be "Recipe" directly or nested in @graph
        let type = dict["@type"] as? String
        if type == "Recipe" {
            return buildRecipeFromDict(dict)
        }

        // Check @graph array (many sites use this structure)
        if let graph = dict["@graph"] as? [[String: Any]] {
            for item in graph {
                if (item["@type"] as? String) == "Recipe" {
                    return buildRecipeFromDict(item)
                }
                // Some sites use arrays for @type
                if let types = item["@type"] as? [String], types.contains("Recipe") {
                    return buildRecipeFromDict(item)
                }
            }
        }

        return nil
    }

    private func buildRecipeFromDict(_ dict: [String: Any]) -> ParsedRecipe {
        let title = dict["name"] as? String

        // Ingredients
        let ingredients: [Ingredient]
        if let rawIngredients = dict["recipeIngredient"] as? [String] {
            ingredients = rawIngredients.map { parseIngredientLine($0) }
        } else {
            ingredients = []
        }

        // Steps
        let steps: [String]
        if let rawInstructions = dict["recipeInstructions"] as? [String] {
            steps = rawInstructions.filter { !$0.isEmpty }
        } else if let rawInstructions = dict["recipeInstructions"] as? [[String: Any]] {
            steps = rawInstructions.compactMap { $0["text"] as? String }
        } else if let rawInstructions = dict["recipeInstructions"] as? String {
            steps = rawInstructions
                .components(separatedBy: .newlines)
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }
        } else {
            steps = []
        }

        // Servings
        var servings: Int?
        if let yieldStr = dict["recipeYield"] as? String {
            servings = Int(yieldStr.filter(\.isNumber))
        } else if let yieldArr = dict["recipeYield"] as? [String], let first = yieldArr.first {
            servings = Int(first.filter(\.isNumber))
        } else if let yieldInt = dict["recipeYield"] as? Int {
            servings = yieldInt
        }

        // Calories
        var calories: Int?
        if let nutrition = dict["nutrition"] as? [String: Any],
           let calStr = nutrition["calories"] as? String {
            calories = Int(calStr.filter(\.isNumber))
        }

        // Tags / keywords
        var tags: [String] = []
        if let keywords = dict["keywords"] as? String {
            tags = keywords.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        } else if let keywords = dict["keywords"] as? [String] {
            tags = keywords
        }
        if let category = dict["recipeCategory"] as? String {
            tags.append(category)
        }

        return ParsedRecipe(
            title: title,
            ingredients: ingredients,
            steps: steps,
            servings: servings,
            calories: calories,
            tags: tags,
            notes: nil
        )
    }

    // MARK: - Caption Parsing (Method 1: Instagram/TikTok/YouTube)

    /// Extracts the og:description or meta description from HTML.
    private func extractCaption(from html: String) -> String? {
        // Try og:description first (Instagram uses this)
        if let desc = extractMetaContent(from: html, property: "og:description") {
            return desc
        }
        // Fallback to meta description
        if let desc = extractMetaContent(from: html, name: "description") {
            return desc
        }
        return nil
    }

    private func extractMetaContent(from html: String, property: String) -> String? {
        // Match <meta property="og:description" content="...">
        let pattern = #"<meta[^>]*property\s*=\s*["\']"# + NSRegularExpression.escapedPattern(for: property) + #"["\'][^>]*content\s*=\s*["\']([^"\']*)["\']"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
            return nil
        }
        let range = NSRange(html.startIndex..., in: html)
        guard let match = regex.firstMatch(in: html, range: range),
              let contentRange = Range(match.range(at: 1), in: html) else {
            // Try reversed attribute order: content before property
            return extractMetaContentReversed(from: html, attr: "property", value: property)
        }
        let content = String(html[contentRange])
        return decodeHTMLEntities(content)
    }

    private func extractMetaContent(from html: String, name: String) -> String? {
        let pattern = #"<meta[^>]*name\s*=\s*["\']"# + NSRegularExpression.escapedPattern(for: name) + #"["\'][^>]*content\s*=\s*["\']([^"\']*)["\']"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
            return nil
        }
        let range = NSRange(html.startIndex..., in: html)
        guard let match = regex.firstMatch(in: html, range: range),
              let contentRange = Range(match.range(at: 1), in: html) else {
            return extractMetaContentReversed(from: html, attr: "name", value: name)
        }
        let content = String(html[contentRange])
        return decodeHTMLEntities(content)
    }

    private func extractMetaContentReversed(from html: String, attr: String, value: String) -> String? {
        let pattern = #"<meta[^>]*content\s*=\s*["\']([^"\']*)["\'][^>]*"# + NSRegularExpression.escapedPattern(for: attr) + #"\s*=\s*["\']"# + NSRegularExpression.escapedPattern(for: value) + #"["\']"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
              let match = regex.firstMatch(in: html, range: NSRange(html.startIndex..., in: html)),
              let contentRange = Range(match.range(at: 1), in: html) else {
            return nil
        }
        let content = String(html[contentRange])
        return decodeHTMLEntities(content)
    }

    /// Parses a caption text for recipe content (ingredients + steps).
    func parseCaptionForRecipe(_ text: String) -> ParsedRecipe {
        let lines = text
            .replacingOccurrences(of: "\r\n", with: "\n")
            .components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespaces) }

        var ingredients: [Ingredient] = []
        var steps: [String] = []
        var tags: [String] = []
        var title: String?

        // Detect sections
        enum Section { case none, ingredients, steps, other }
        var currentSection: Section = .none

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else { continue }

            // Detect section headers
            let lower = trimmed.lowercased()
            if isIngredientsHeader(lower) {
                currentSection = .ingredients
                continue
            }
            if isStepsHeader(lower) {
                currentSection = .steps
                continue
            }

            // Extract hashtags
            let extractedTags = extractHashtags(from: trimmed)
            if !extractedTags.isEmpty {
                tags.append(contentsOf: extractedTags)
                // If the line is ONLY hashtags, skip further processing
                let withoutTags = trimmed.replacingOccurrences(
                    of: #"#\w+"#,
                    with: "",
                    options: .regularExpression
                ).trimmingCharacters(in: .whitespaces)
                if withoutTags.isEmpty { continue }
            }

            // If we haven't found a title yet, use the first meaningful line
            if title == nil && currentSection == .none && !trimmed.hasPrefix("#") {
                // Skip common Instagram engagement text
                if !isEngagementText(lower) {
                    title = trimmed
                    continue
                }
            }

            // Parse based on current section
            switch currentSection {
            case .ingredients:
                let ingredient = parseIngredientLine(trimmed)
                if !ingredient.name.isEmpty {
                    ingredients.append(ingredient)
                }
            case .steps:
                let step = cleanStepText(trimmed)
                if !step.isEmpty {
                    steps.append(step)
                }
            case .none, .other:
                // Auto-detect: if the line looks like an ingredient or step
                if looksLikeStep(trimmed) {
                    if currentSection != .steps { currentSection = .steps }
                    let step = cleanStepText(trimmed)
                    if !step.isEmpty { steps.append(step) }
                } else if looksLikeIngredient(trimmed) {
                    if currentSection != .ingredients { currentSection = .ingredients }
                    let ingredient = parseIngredientLine(trimmed)
                    if !ingredient.name.isEmpty { ingredients.append(ingredient) }
                }
            }
        }

        return ParsedRecipe(
            title: title,
            ingredients: ingredients,
            steps: steps,
            servings: nil,
            calories: nil,
            tags: tags,
            notes: nil
        )
    }

    // MARK: - Section Header Detection

    private func isIngredientsHeader(_ lower: String) -> Bool {
        let headers = [
            "ingredients:", "ingredients", "ingrediënten:", "ingrediënten",
            "ingredienten:", "ingredienten", "what you need:", "what you'll need:",
            "you'll need:", "you will need:", "shopping list:",
            "ingredient list:", "benodigdheden:", "benodigdheden"
        ]
        return headers.contains(where: { lower.hasPrefix($0) })
    }

    private func isStepsHeader(_ lower: String) -> Bool {
        let headers = [
            "directions:", "directions", "instructions:", "instructions",
            "method:", "method", "steps:", "steps",
            "bereiding:", "bereiding", "bereidingswijze:", "bereidingswijze",
            "how to make it:", "how to make:", "here is how to make it:",
            "here's how to make it:", "preparation:", "preparation"
        ]
        return headers.contains(where: { lower.hasPrefix($0) })
    }

    // MARK: - Line Classification

    private func looksLikeIngredient(_ line: String) -> Bool {
        let trimmed = line.trimmingCharacters(in: .whitespaces)

        // Starts with bullet: · • - ▪ ▸ ►
        if trimmed.hasPrefix("·") || trimmed.hasPrefix("•") || trimmed.hasPrefix("▪") ||
            trimmed.hasPrefix("▸") || trimmed.hasPrefix("►") {
            return true
        }

        // Starts with a dash followed by a space
        if trimmed.hasPrefix("- ") {
            return true
        }

        // Starts with a quantity pattern: number + unit
        let quantityPattern = #"^[\d½¼¾⅓⅔⅛⅜⅝⅞]+[\s/\d]*\s*(tsp|tbsp|teaspoon|tablespoon|cup|cups|oz|ounce|lb|lbs|pound|g|gram|kg|ml|liter|litre|pinch|bunch|clove|cloves|can|cans|package|bag|piece|pieces|stuk|stuks|eetlepel|theelepel|el|tl|kopje|gram|kilo)\b"#
        if let regex = try? NSRegularExpression(pattern: quantityPattern, options: .caseInsensitive),
           regex.firstMatch(in: trimmed, range: NSRange(trimmed.startIndex..., in: trimmed)) != nil {
            return true
        }

        // Starts with a number and has food-related content
        let startsWithNumber = #"^[\d½¼¾⅓⅔/]+"#
        if let regex = try? NSRegularExpression(pattern: startsWithNumber),
           regex.firstMatch(in: trimmed, range: NSRange(trimmed.startIndex..., in: trimmed)) != nil,
           trimmed.count < 100 { // Ingredients are usually short
            return true
        }

        return false
    }

    private func looksLikeStep(_ line: String) -> Bool {
        let trimmed = line.trimmingCharacters(in: .whitespaces)

        // Emoji numbers: 1️⃣ 2️⃣ etc.
        let emojiNumberPattern = #"^[\d]️⃣"#
        if let regex = try? NSRegularExpression(pattern: emojiNumberPattern),
           regex.firstMatch(in: trimmed, range: NSRange(trimmed.startIndex..., in: trimmed)) != nil {
            return true
        }

        // "1." "2." etc. at start of line (with at least some text after)
        let numberedPattern = #"^\d+[\.\)]\s+\S"#
        if let regex = try? NSRegularExpression(pattern: numberedPattern),
           regex.firstMatch(in: trimmed, range: NSRange(trimmed.startIndex..., in: trimmed)) != nil {
            return true
        }

        // "Step 1:", "Stap 1:" etc.
        let stepPattern = #"^(step|stap)\s+\d"#
        if let regex = try? NSRegularExpression(pattern: stepPattern, options: .caseInsensitive),
           regex.firstMatch(in: trimmed, range: NSRange(trimmed.startIndex..., in: trimmed)) != nil {
            return true
        }

        return false
    }

    private func isEngagementText(_ lower: String) -> Bool {
        let patterns = [
            "comment", "dm ", "dm!", "save this", "share this", "follow",
            "like this", "tag a friend", "link in bio", "check out",
            "tap the link", "double tap"
        ]
        return patterns.contains(where: { lower.contains($0) })
    }

    // MARK: - Ingredient Parsing

    /// Parses a single ingredient line into an Ingredient struct.
    func parseIngredientLine(_ line: String) -> Ingredient {
        var text = line.trimmingCharacters(in: .whitespaces)

        // Remove leading bullet characters
        let bullets: [Character] = ["·", "•", "▪", "▸", "►", "-", "*"]
        while let first = text.first, bullets.contains(first) {
            text = String(text.dropFirst()).trimmingCharacters(in: .whitespaces)
        }

        // Try to extract: amount + unit + name
        let pattern = #"^([\d½¼¾⅓⅔⅛⅜⅝⅞]+[\s/\d½¼¾⅓⅔⅛⅜⅝⅞]*)\s*(tsp|tbsp|teaspoons?|tablespoons?|cups?|oz|ounces?|lbs?|pounds?|g|grams?|kg|ml|liters?|litres?|pinch|bunch|cloves?|cans?|packages?|bags?|pieces?|stuks?|eetlepels?|theelepels?|el|tl|kopjes?|kilo)?\s*[,.]?\s*(.+)"#

        if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
           let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) {

            let amount = match.range(at: 1).location != NSNotFound
                ? String(text[Range(match.range(at: 1), in: text)!]).trimmingCharacters(in: .whitespaces)
                : ""
            let unit = match.range(at: 2).location != NSNotFound
                ? String(text[Range(match.range(at: 2), in: text)!]).trimmingCharacters(in: .whitespaces)
                : ""
            let name = match.range(at: 3).location != NSNotFound
                ? String(text[Range(match.range(at: 3), in: text)!]).trimmingCharacters(in: .whitespaces)
                : text

            return Ingredient(name: name, amount: amount, unit: unit)
        }

        // Fallback: the whole line is the ingredient name
        return Ingredient(name: text, amount: "", unit: "")
    }

    // MARK: - Step Cleaning

    private func cleanStepText(_ text: String) -> String {
        var cleaned = text

        // Remove emoji number prefixes: 1️⃣, 2️⃣, etc.
        let emojiPattern = #"^[\d]️⃣\s*"#
        if let regex = try? NSRegularExpression(pattern: emojiPattern) {
            cleaned = regex.stringByReplacingMatches(
                in: cleaned,
                range: NSRange(cleaned.startIndex..., in: cleaned),
                withTemplate: ""
            )
        }

        // Remove numbered prefixes: "1. ", "2) ", etc.
        let numberPattern = #"^\d+[\.\)]\s*"#
        if let regex = try? NSRegularExpression(pattern: numberPattern) {
            cleaned = regex.stringByReplacingMatches(
                in: cleaned,
                range: NSRange(cleaned.startIndex..., in: cleaned),
                withTemplate: ""
            )
        }

        // Remove "Step X:" prefixes
        let stepPattern = #"^(step|stap)\s+\d+[:\.]?\s*"#
        if let regex = try? NSRegularExpression(pattern: stepPattern, options: .caseInsensitive) {
            cleaned = regex.stringByReplacingMatches(
                in: cleaned,
                range: NSRange(cleaned.startIndex..., in: cleaned),
                withTemplate: ""
            )
        }

        return cleaned.trimmingCharacters(in: .whitespaces)
    }

    // MARK: - Hashtag Extraction

    private func extractHashtags(from text: String) -> [String] {
        let pattern = #"#(\w+)"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        let range = NSRange(text.startIndex..., in: text)
        return regex.matches(in: text, range: range).compactMap { match in
            guard let tagRange = Range(match.range(at: 1), in: text) else { return nil }
            return String(text[tagRange])
        }
    }

    // MARK: - HTML Entity Decoding

    private func decodeHTMLEntities(_ text: String) -> String {
        var result = text
        let entities: [(String, String)] = [
            ("&amp;", "&"), ("&lt;", "<"), ("&gt;", ">"),
            ("&quot;", "\""), ("&#39;", "'"), ("&apos;", "'"),
            ("&#x27;", "'"), ("&#x2F;", "/"), ("&nbsp;", " "),
            ("&#10;", "\n"), ("&#13;", "\r"), ("&ndash;", "–"),
            ("&mdash;", "—"), ("&frac12;", "½"), ("&frac14;", "¼"),
            ("&frac34;", "¾")
        ]
        for (entity, char) in entities {
            result = result.replacingOccurrences(of: entity, with: char)
        }
        return result
    }
}
