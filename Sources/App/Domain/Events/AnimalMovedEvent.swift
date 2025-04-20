import Foundation

struct AnimalMovedEvent: Codable {
    let eventId: UUID
    let timestamp: Date
    let animalId: EntityID
    let fromEnclosureId: EntityID?
    let toEnclosureId: EntityID

    init(
        eventId: UUID = UUID(),
        timestamp: Date = Date(),
        animalId: EntityID,
        fromEnclosureId: EntityID?,
        toEnclosureId: EntityID
    ) {
        self.eventId = eventId
        self.timestamp = timestamp
        self.animalId = animalId
        self.fromEnclosureId = fromEnclosureId
        self.toEnclosureId = toEnclosureId
    }
} 