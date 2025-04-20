import Foundation

actor InMemoryEnclosureRepository: EnclosureRepository {
    private var enclosures: [EntityID: Enclosure] = [:]

    func save(_ enclosure: Enclosure) async throws {
        enclosures[enclosure.id] = enclosure
    }

    func findById(_ id: EntityID) async throws -> Enclosure? {
        return enclosures[id]
    }

    func findAll() async throws -> [Enclosure] {
        return Array(enclosures.values)
    }

    func deleteById(_ id: EntityID) async throws {
        enclosures.removeValue(forKey: id)
    }

    func findAvailable() async throws -> [Enclosure] {
        return enclosures.values.filter { $0.currentAnimalCount < $0.maxCapacity }
    }
} 