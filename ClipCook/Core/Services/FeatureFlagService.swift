import Foundation
import OSLog

private let logger = Logger(subsystem: "com.clipcook.app", category: "FeatureFlagService")

/// Service for managing feature flags.
/// In MVP, all AI flags return false.
/// Later, this will integrate with Firebase Remote Config.
final class FeatureFlagService {
    static let shared = FeatureFlagService()

    private init() {}

    // MARK: - AI Flags (all false in MVP)

    var isAIEnabled: Bool { false }
    var isAIRecipeParsingEnabled: Bool { false }
    var isAINutritionAnalysisEnabled: Bool { false }
    var isAIVideoToRecipeEnabled: Bool { false }
    var isAIMealPlannerEnabled: Bool { false }

    // MARK: - App Flags

    var isShareExtensionEnabled: Bool { true }

    // MARK: - Remote Config (placeholder for future)

    func fetchRemoteConfig() async {
        // TODO: Implement Firebase Remote Config fetch when AI features are added
        logger.info("Remote config fetch skipped (MVP mode)")
    }
}
