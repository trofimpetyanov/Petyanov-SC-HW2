import Foundation

// MARK: - Domain Entities

protocol EnclosureRepository: Sendable {
    func save(_ enclosure: Enclosure) async throws
    func findById(_ id: EntityID) async throws -> Enclosure?
    func findAll() async throws -> [Enclosure]
    func deleteById(_ id: EntityID) async throws
    func findAvailable() async throws -> [Enclosure]
} 