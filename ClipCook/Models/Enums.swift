import Foundation

enum RecipeCategory: String, Codable, CaseIterable, Identifiable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case snack = "Snack"

    var id: String { rawValue }
}

enum MealType: String, Codable, CaseIterable, Identifiable {
    case breakfast = "Breakfast"
    case morningSnack = "Morning Snack"
    case lunch = "Lunch"
    case afternoonSnack = "Afternoon Snack"
    case dinner = "Dinner"
    case eveningSnack = "Evening Snack"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .breakfast: return "🌅"
        case .morningSnack: return "🍎"
        case .lunch: return "☀️"
        case .afternoonSnack: return "🍪"
        case .dinner: return "🌙"
        case .eveningSnack: return "🌜"
        }
    }
}

enum ImportStatus: String, Codable {
    case importing
    case ready
    case failed
}

enum SourcePlatform: String, Codable {
    case instagram
    case tiktok
    case youtube
}

enum MeasurementUnit: String, Codable {
    case metric
    case imperial
}

enum SyncStatus {
    case synced
    case pending
    case conflict
    case offline
}

enum FilterCategory: String, CaseIterable, Identifiable {
    case all = "All"
    case favorites = "Favorites"
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case snack = "Snack"

    var id: String { rawValue }
}
