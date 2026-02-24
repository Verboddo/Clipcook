import Foundation

protocol PendingImportRepositoryProtocol {
    func getPending() async throws -> [PendingImport]
    func add(_ pendingImport: PendingImport) async throws
    func remove(_ id: String) async throws
    func updateStatus(_ id: String, status: ImportStatus) async throws
}
