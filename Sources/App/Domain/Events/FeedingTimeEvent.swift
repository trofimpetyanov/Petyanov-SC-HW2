import Foundation

struct FeedingTimeEvent: Codable {
    let eventId: UUID
    let timestamp: Date
    let scheduleId: EntityID
    let animalId: EntityID
    let completionTime: Date

    init(
        eventId: UUID = UUID(),
        timestamp: Date = Date(),
        scheduleId: EntityID,
        animalId: EntityID,
        completionTime: Date
    ) {
        self.eventId = eventId
        self.timestamp = timestamp
        self.scheduleId = scheduleId
        self.animalId = animalId
        self.completionTime = completionTime
    }
} 