import Foundation

// MARK: - Domain Entities

protocol AnimalRepository: Sendable {
    func save(_ animal: Animal) async throws
    func findById(_ id: EntityID) async throws -> Animal?
    func findAll() async throws -> [Animal]
    func deleteById(_ id: EntityID) async throws
    func findByEnclosureId(_ enclosureId: EntityID) async throws -> [Animal]
} 