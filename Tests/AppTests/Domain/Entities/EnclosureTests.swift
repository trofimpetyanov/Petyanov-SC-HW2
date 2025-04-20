import XCTest
@testable import App
import Foundation

final class EnclosureTests: XCTestCase {

    private func createTestEnclosure(type: EnclosureType = .predator, size: Size = .large, maxCapacity: Int = 3, initialAnimalIds: Set<EntityID> = []) -> Enclosure {
        return Enclosure(
            type: type,
            size: size,
            maxCapacity: maxCapacity,
            animalIds: initialAnimalIds
        )
    }

    func testEnclosureInitialization() {
        let enclosure = Enclosure(id: UUID(), type: .herbivore, size: .medium, maxCapacity: 10, animalIds: [])
        XCTAssertNotNil(enclosure.id)
        XCTAssertEqual(enclosure.type, .herbivore)
        XCTAssertEqual(enclosure.size, .medium)
        XCTAssertEqual(enclosure.maxCapacity, 10)
        XCTAssertEqual(enclosure.animalIds.count, 0)
        XCTAssertEqual(enclosure.currentAnimalCount, 0)
    }
    
    func testAddAnimalSuccess() {
        var enclosure = createTestEnclosure(maxCapacity: 2)
        let animalId1 = UUID()
        let animalId2 = UUID()

        XCTAssertEqual(enclosure.currentAnimalCount, 0)
        
        XCTAssertNoThrow(try enclosure.addAnimal(id: animalId1))
        XCTAssertEqual(enclosure.currentAnimalCount, 1)
        XCTAssertTrue(enclosure.animalIds.contains(animalId1))

        XCTAssertNoThrow(try enclosure.addAnimal(id: animalId2))
        XCTAssertEqual(enclosure.currentAnimalCount, 2)
        XCTAssertTrue(enclosure.animalIds.contains(animalId2))
    }

    func testAddAnimalWhenFull() {
        var enclosure = createTestEnclosure(maxCapacity: 1, initialAnimalIds: [UUID()])
        let extraAnimalId = UUID()
        
        XCTAssertEqual(enclosure.currentAnimalCount, 1)
        XCTAssertThrowsError(try enclosure.addAnimal(id: extraAnimalId)) { error in
            XCTAssertEqual(error as? EnclosureError, .enclosureFull, "Should throw enclosureFull error")
        }
        XCTAssertEqual(enclosure.currentAnimalCount, 1, "Animal count should not change after failed add")
        XCTAssertFalse(enclosure.animalIds.contains(extraAnimalId))
    }

    func testAddAnimalAlreadyPresent() {
        let existingAnimalId = UUID()
        var enclosure = createTestEnclosure(maxCapacity: 2, initialAnimalIds: [existingAnimalId])
        
        XCTAssertEqual(enclosure.currentAnimalCount, 1)
        XCTAssertThrowsError(try enclosure.addAnimal(id: existingAnimalId)) { error in
            XCTAssertEqual(error as? EnclosureError, .animalAlreadyPresent, "Should throw animalAlreadyPresent error")
        }
        XCTAssertEqual(enclosure.currentAnimalCount, 1, "Animal count should not change after failed add")
    }

    func testRemoveAnimalSuccess() {
        let animalId1 = UUID()
        let animalId2 = UUID()
        var enclosure = createTestEnclosure(maxCapacity: 2, initialAnimalIds: [animalId1, animalId2])

        XCTAssertEqual(enclosure.currentAnimalCount, 2)
        XCTAssertTrue(enclosure.animalIds.contains(animalId1))

        XCTAssertNoThrow(try enclosure.removeAnimal(id: animalId1))
        XCTAssertEqual(enclosure.currentAnimalCount, 1)
        XCTAssertFalse(enclosure.animalIds.contains(animalId1))
        XCTAssertTrue(enclosure.animalIds.contains(animalId2))

        XCTAssertNoThrow(try enclosure.removeAnimal(id: animalId2))
        XCTAssertEqual(enclosure.currentAnimalCount, 0)
        XCTAssertFalse(enclosure.animalIds.contains(animalId2))
    }

    func testRemoveAnimalNotFound() {
        let animalIdToRemove = UUID()
        var enclosure = createTestEnclosure(maxCapacity: 2, initialAnimalIds: [UUID()])
        
        XCTAssertEqual(enclosure.currentAnimalCount, 1)
        XCTAssertThrowsError(try enclosure.removeAnimal(id: animalIdToRemove)) { error in
            XCTAssertEqual(error as? EnclosureError, .animalNotFound, "Should throw animalNotFound error")
        }
        XCTAssertEqual(enclosure.currentAnimalCount, 1, "Animal count should not change after failed remove")
    }
    
} 
