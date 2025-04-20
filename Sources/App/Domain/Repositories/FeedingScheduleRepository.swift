import Foundation

// MARK: - Domain Entities

protocol FeedingScheduleRepository: Sendable {
    func save(_ schedule: FeedingSchedule) async throws
    func findById(_ id: EntityID) async throws -> FeedingSchedule?
    func findAll() async throws -> [FeedingSchedule]
    func findByAnimalId(_ animalId: EntityID) async throws -> [FeedingSchedule]
    func findUpcoming() async throws -> [FeedingSchedule]
    func deleteById(_ id: EntityID) async throws
} 