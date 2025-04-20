import Foundation

actor InMemoryAnimalRepository: AnimalRepository {
    private var animals: [EntityID: Animal] = [:]

    func save(_ animal: Animal) async throws {
        animals[animal.id] = animal
    }

    func findById(_ id: EntityID) async throws -> Animal? {
        return animals[id]
    }

    func findAll() async throws -> [Animal] {
        return Array(animals.values)
    }

    func deleteById(_ id: EntityID) async throws {
        animals.removeValue(forKey: id)
    }

    func findByEnclosureId(_ enclosureId: EntityID) async throws -> [Animal] {
        return animals.values.filter { $0.enclosureId == enclosureId }
    }
} 