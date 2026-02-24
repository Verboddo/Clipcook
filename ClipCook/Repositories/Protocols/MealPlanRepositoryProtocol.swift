import Foundation

protocol MealPlanRepositoryProtocol {
    func getSlots(for day: String) async throws -> [MealSlot]
    func addSlot(_ slot: MealSlot) async throws
    func removeSlot(_ id: String) async throws
}
