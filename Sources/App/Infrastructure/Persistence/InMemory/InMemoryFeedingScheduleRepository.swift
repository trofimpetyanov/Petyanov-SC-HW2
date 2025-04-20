import Foundation

actor InMemoryFeedingScheduleRepository: FeedingScheduleRepository {
    private var schedules: [EntityID: FeedingSchedule] = [:]

    func save(_ schedule: FeedingSchedule) async throws {
        schedules[schedule.id] = schedule
    }

    func findById(_ id: EntityID) async throws -> FeedingSchedule? {
        return schedules[id]
    }

    func findAll() async throws -> [FeedingSchedule] {
        return Array(schedules.values).sorted { $0.feedingTime < $1.feedingTime }
    }

    func findByAnimalId(_ animalId: EntityID) async throws -> [FeedingSchedule] {
        return schedules.values.filter { $0.animalId == animalId }.sorted { $0.feedingTime < $1.feedingTime }
    }

    func findUpcoming() async throws -> [FeedingSchedule] {
        return schedules.values.filter { !$0.isCompleted }.sorted { $0.feedingTime < $1.feedingTime }
    }

    func deleteById(_ id: EntityID) async throws {
        schedules.removeValue(forKey: id)
    }
} 