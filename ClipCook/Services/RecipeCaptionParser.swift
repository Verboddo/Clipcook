import Foundation

struct ParsedRecipe {
    var title: String?
    var ingredients: [Ingredient] = []
    var steps: [Step] = []
    var servings: Int?
    var prepTime: String?
    var cookTime: String?

    var hasContent: Bool {
        !ingredients.isEmpty || !steps.isEmpty
    }
}

final class RecipeCaptionParser {

    func parse(_ text: String) -> ParsedRecipe {
        let cleaned = stripHashtags(text)
        let lines = cleaned
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }

        let sections = splitIntoSections(lines)
        var ingredients = extractIngredients(from: sections.ingredientLines)
        let steps = extractSteps(from: sections.stepLines)
        let title = extractTitle(from: sections.headerLines)
        let timing = extractTiming(from: cleaned)

        ingredients = ingredients.filter { isValidIngredient($0) }

        return ParsedRecipe(
            title: title,
            ingredients: ingredients,
            steps: steps,
            servings: timing.servings,
            prepTime: timing.prepTime,
            cookTime: timing.cookTime
        )
    }

    // MARK: - Section Splitting

    private struct Sections {
        var headerLines: [String] = []
        var ingredientLines: [String] = []
        var stepLines: [String] = []
    }

    private let ingredientHeaders: [String] = [
        "ingredients", "ingrediënten", "ingredienten", "what you need",
        "je hebt nodig", "nodig", "benodigdheden", "per meal", "per bowl",
        "per serving", "per portie",
        "🛒", "🥗", "📋", "🧾"
    ]

    private let stepHeaders: [String] = [
        "steps", "method", "instructions", "directions", "bereiding",
        "stappen", "zo maak je het", "werkwijze", "how to",
        "preparation", "how to make", "how to make it",
        "📝", "🔥", "⬇️"
    ]

    private func splitIntoSections(_ lines: [String]) -> Sections {
        var sections = Sections()
        var current: SectionType = .header

        for line in lines {
            guard !line.isEmpty else { continue }

            let lower = line.lowercased()

            if isIngredientHeader(lower) {
                current = .ingredients
                continue
            }
            if isStepHeader(lower) {
                current = .steps
                continue
            }

            switch current {
            case .header:
                if looksLikeIngredient(line) {
                    current = .ingredients
                    sections.ingredientLines.append(line)
                } else if looksLikeStep(line) {
                    current = .steps
                    sections.stepLines.append(line)
                } else {
                    sections.headerLines.append(line)
                }
            case .ingredients:
                if looksLikeStep(line) && !sections.ingredientLines.isEmpty {
                    current = .steps
                    sections.stepLines.append(line)
                } else if isMacroLine(lower) {
                    continue
                } else if looksLikeIngredient(line) || looksLikeBareLine(line) {
                    sections.ingredientLines.append(line)
                } else {
                    current = .header
                    sections.headerLines.append(line)
                }
            case .steps:
                sections.stepLines.append(line)
            }
        }

        return sections
    }

    private enum SectionType {
        case header, ingredients, steps
    }

    private func isIngredientHeader(_ lower: String) -> Bool {
        ingredientHeaders.contains { lower.hasPrefix($0) || lower.contains("ingredient") }
    }

    private func isStepHeader(_ lower: String) -> Bool {
        stepHeaders.contains { lower.hasPrefix($0) }
            || lower.contains("bereiding")
            || lower.contains("method:")
            || lower.contains("instructions:")
            || lower.contains("stappen:")
            || lower.contains("steps:")
            || lower.hasPrefix("how to make")
    }

    // MARK: - Pattern Detection

    private let bulletPrefixes: [String] = [
        "- ", "– ", "— ", "• ", "· ", ". ",
        "✅ ", "✓ ", "▪️ ", "▸ ",
        "🔹 ", "🔸 ", "➡️ ", "⭐ "
    ]

    private let dashNoBulletPrefix = "-"

    private func looksLikeIngredient(_ line: String) -> Bool {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        if bulletPrefixes.contains(where: { trimmed.hasPrefix($0) }) { return true }
        if trimmed.hasPrefix(dashNoBulletPrefix) && trimmed.count > 2 {
            let second = trimmed[trimmed.index(after: trimmed.startIndex)]
            if second.isLetter || second.isNumber { return true }
        }
        let quantityPattern = #"^\d+[\.,]?\d*\s*(g|gram|kg|ml|l|dl|cl|cup|cups|tbsp|tsp|el|tl|eetlepel|theelepel|stuks?|plak|plakken|snuf|snufje|blik|blikje|zakje|potje|hand|handvol|lbs?|oz|bakje)\b"#
        if trimmed.range(of: quantityPattern, options: [.regularExpression, .caseInsensitive]) != nil {
            return true
        }
        return false
    }

    private func looksLikeStep(_ line: String) -> Bool {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        let stepPattern = #"^\d+[\.\)]\s+"#
        return trimmed.range(of: stepPattern, options: .regularExpression) != nil
    }

    private func looksLikeBareLine(_ line: String) -> Bool {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        if trimmed.first?.isNumber == true && trimmed.count < 80 { return true }
        if trimmed.count < 40 && !trimmed.contains("http") { return true }
        return false
    }

    private func isMacroLine(_ lower: String) -> Bool {
        let macroPattern = #"^\d+g?\s*[pcf]$"#
        if lower.range(of: macroPattern, options: .regularExpression) != nil { return true }
        let macroLabels = ["protein:", "carbs:", "fat:", "calories:", "eiwit:", "koolhydraten:", "vetten:", "kcal"]
        return macroLabels.contains(where: { lower.hasPrefix($0) })
    }

    // MARK: - Extraction

    private func extractIngredients(from lines: [String]) -> [Ingredient] {
        lines.compactMap { line in
            var cleaned = line
            for prefix in bulletPrefixes {
                if cleaned.hasPrefix(prefix) {
                    cleaned = String(cleaned.dropFirst(prefix.count))
                    break
                }
            }
            if cleaned.hasPrefix(dashNoBulletPrefix) && cleaned.count > 1 {
                let second = cleaned[cleaned.index(after: cleaned.startIndex)]
                if second.isLetter || second.isNumber {
                    cleaned = String(cleaned.dropFirst(1))
                }
            }
            cleaned = cleaned.trimmingCharacters(in: .whitespaces)
            guard !cleaned.isEmpty, cleaned.count > 1 else { return nil }

            let (amount, name) = splitAmountAndName(cleaned)
            return Ingredient(name: name, amount: amount)
        }
    }

    private let unitWords: Set<String> = [
        "g", "gram", "kg", "ml", "l", "dl", "cl",
        "cup", "cups", "tbsp", "tsp", "el", "tl",
        "eetlepel", "theelepel", "stuks", "stuk",
        "plak", "plakken", "snuf", "snufje",
        "blik", "blikje", "zakje", "potje", "bakje",
        "hand", "handvol", "ounce", "oz", "lb", "lbs",
        "scoop", "scoops"
    ]

    private func splitAmountAndName(_ text: String) -> (amount: String, name: String) {
        let amountPattern = #"^(\d+[\.,/]?\d*)\s*"#
        guard let numRange = text.range(of: amountPattern, options: .regularExpression) else {
            return ("", text)
        }
        let number = String(text[numRange]).trimmingCharacters(in: .whitespaces)
        let afterNumber = String(text[numRange.upperBound...]).trimmingCharacters(in: .whitespaces)

        let unitPattern = #"^(\w+)\b"#
        if let unitRange = afterNumber.range(of: unitPattern, options: [.regularExpression, .caseInsensitive]) {
            let potentialUnit = String(afterNumber[unitRange]).lowercased()
            if unitWords.contains(potentialUnit) {
                let name = String(afterNumber[unitRange.upperBound...]).trimmingCharacters(in: .whitespaces)
                return ("\(number) \(potentialUnit)", name)
            }
        }

        return (number, afterNumber)
    }

    private func isValidIngredient(_ ingredient: Ingredient) -> Bool {
        let name = ingredient.name.lowercased()
        let full = "\(ingredient.amount) \(ingredient.name)".lowercased()
        if name.hasPrefix("http://") || name.hasPrefix("https://") { return false }
        if name.contains("http://") || name.contains("https://") { return false }
        if name.count > 120 { return false }
        let singleLetterMacro = #"^[pcf]$"#
        if name.range(of: singleLetterMacro, options: .regularExpression) != nil { return false }
        if name.hasPrefix("calories") || name.hasPrefix("kcal") { return false }
        if full.hasPrefix("calories") || full.hasPrefix("kcal") { return false }
        if name.hasPrefix("protein") && name.count < 12 && !name.contains("powder") && !name.contains("poeder") { return false }
        if full.contains("carbohydrate") || full.contains("koolhydraten") { return false }

        let socialNoise = ["view all", "comment", "save this", "link in bio",
                           "download", "tag me", "follow", "use code", "free recipe"]
        if socialNoise.contains(where: { full.contains($0) }) { return false }

        if name.hasPrefix("serves") || name.hasPrefix("porties") { return false }
        if full.hasPrefix("📊") || full.hasPrefix("📩") { return false }

        return true
    }

    private func extractSteps(from lines: [String]) -> [Step] {
        var steps: [Step] = []
        var order = 1

        for line in lines {
            var cleaned = line
            let numberPrefix = #"^\d+[\.\)]\s*"#
            if let range = cleaned.range(of: numberPrefix, options: .regularExpression) {
                cleaned = String(cleaned[range.upperBound...])
            }
            cleaned = cleaned.trimmingCharacters(in: .whitespaces)
            guard !cleaned.isEmpty, cleaned.count > 5 else { continue }
            guard !isNonStepLine(cleaned) else { continue }

            steps.append(Step(order: order, text: cleaned))
            order += 1
        }

        return steps
    }

    private func isNonStepLine(_ line: String) -> Bool {
        let lower = line.lowercased()
        let nutritionKeywords = ["kcal", "eiwit", "koolhydraten", "calorieën"]
        if nutritionKeywords.contains(where: { lower.contains($0) }) && lower.contains("|") {
            return true
        }
        let macroSummary = #"^\d+g?\s*(protein|carbs?|fat|calories|eiwit|koolhydraten|vetten)"#
        if lower.range(of: macroSummary, options: .regularExpression) != nil { return true }
        let exclamationWords = ["enjoy", "smakelijk", "eet smakelijk", "bon appetit", "genieten", "succes"]
        if exclamationWords.contains(where: { lower.hasPrefix($0) }) { return true }

        let socialNoise = [
            "save this", "tag me", "link in bio", "link in my bio",
            "follow me", "follow for more", "download", "use code",
            "check out", "recipe inspo", "full recipe inspo",
            "comment", "view all", "free recipe",
        ]
        if socialNoise.contains(where: { lower.contains($0) }) { return true }
        if lower.hasPrefix("📩") || lower.hasPrefix("👉") || lower.hasPrefix("🔗") { return true }

        return false
    }

    private func extractTitle(from lines: [String]) -> String? {
        guard let first = lines.first, !first.isEmpty else { return nil }
        var title = first
        let separators: [Character] = ["|", "·", "•", "—", "–"]
        for sep in separators {
            if let idx = title.firstIndex(of: sep) {
                let before = String(title[title.startIndex..<idx]).trimmingCharacters(in: .whitespaces)
                if before.count >= 5 { title = before; break }
            }
        }
        if title.count > 80 {
            if let space = title.prefix(77).lastIndex(of: " ") {
                title = String(title[title.startIndex..<space]) + "..."
            }
        }
        return title.isEmpty ? nil : title
    }

    // MARK: - Timing Extraction

    private struct TimingInfo {
        var servings: Int?
        var prepTime: String?
        var cookTime: String?
    }

    private func extractTiming(from text: String) -> TimingInfo {
        var info = TimingInfo()
        let lower = text.lowercased()

        let servingsPattern = #"(\d+)\s*(servings?|porties?|personen|persoon)"#
        if let match = lower.range(of: servingsPattern, options: .regularExpression) {
            let matched = String(lower[match])
            let numStr = matched.components(separatedBy: .whitespaces).first ?? ""
            info.servings = Int(numStr)
        }

        let prepPattern = #"prep(?:\s*time)?[:\s]*(\d+)\s*min"#
        if let match = lower.range(of: prepPattern, options: .regularExpression) {
            let matched = String(lower[match])
            if let num = matched.components(separatedBy: .decimalDigits.inverted).compactMap({ Int($0) }).first {
                info.prepTime = "\(num) min"
            }
        }

        let cookPattern = #"(?:cook|bak|oven|kook)(?:\s*time|tijd)?[:\s]*(\d+)\s*min"#
        if let match = lower.range(of: cookPattern, options: .regularExpression) {
            let matched = String(lower[match])
            if let num = matched.components(separatedBy: .decimalDigits.inverted).compactMap({ Int($0) }).first {
                info.cookTime = "\(num) min"
            }
        }

        return info
    }

    // MARK: - Cleanup

    private func stripHashtags(_ text: String) -> String {
        var result = text
        let hashtagSection = #"\n\s*#\w+[\s#\w]*$"#
        if let range = result.range(of: hashtagSection, options: .regularExpression) {
            result = String(result[result.startIndex..<range.lowerBound])
        }
        result = result.replacingOccurrences(
            of: #"#\w+"#,
            with: "",
            options: .regularExpression
        )
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
