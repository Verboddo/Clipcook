import Foundation

@Observable
final class PremiumService {
    var isPremium: Bool = false

    private let userRepo = FirestoreUserRepository()

    func togglePremium(userId: String) async {
        isPremium.toggle()
        let flags: FeatureFlags = isPremium ? .premium : .free
        try? await userRepo.updatePremiumStatus(userId, isPremium: isPremium, flags: flags)
    }

    func loadStatus(from user: AppUser) {
        isPremium = user.isPremium
    }
}
