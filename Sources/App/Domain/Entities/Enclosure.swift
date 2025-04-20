import Foundation
import Vapor

enum EnclosureError: Error {
    case enclosureFull
    case animalAlreadyPresent
    case animalNotFound
}

struct Enclosure: Content, Equatable, Identifiable {
    let id: EntityID
    let type: EnclosureType
    let size: Size
    let maxCapacity: Int
    var animalIds: Set<EntityID>

    var currentAnimalCount: Int {
        animalIds.count
    }

    init(
        id: EntityID = EntityID(),
        type: EnclosureType,
        size: Size,
        maxCapacity: Int,
        animalIds: Set<EntityID> = []
    ) {
        self.id = id
        self.type = type
        self.size = size
        self.maxCapacity = maxCapacity
        self.animalIds = Set(animalIds.prefix(maxCapacity))
    }

    mutating func addAnimal(id animalId: EntityID) throws {
        guard currentAnimalCount < maxCapacity else {
            throw EnclosureError.enclosureFull
        }
        guard !animalIds.contains(animalId) else {
            throw EnclosureError.animalAlreadyPresent
        }
        animalIds.insert(animalId)
    }

    mutating func removeAnimal(id animalId: EntityID) throws {
        guard animalIds.contains(animalId) else {
            throw EnclosureError.animalNotFound
        }
        animalIds.remove(animalId)
    }

    mutating func clean() {
    }
}