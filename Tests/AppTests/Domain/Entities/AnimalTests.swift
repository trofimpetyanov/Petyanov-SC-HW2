import XCTest
@testable import App
import Foundation

final class AnimalTests: XCTestCase {

    private func createTestAnimal(status: AnimalStatus = .healthy, enclosureId: EntityID? = nil) -> Animal {
        return Animal(
            species: AnimalSpecies("Lion")!,
            nickname: AnimalNickname("TestLion")!,
            birthDate: Date(),
            gender: .male,
            favoriteFood: FavoriteFood("Meat")!,
            status: status,
            enclosureId: enclosureId
        )
    }

    func testAnimalInitialization() {
        let date = Date()
        let animal = Animal(
            id: UUID(), 
            species: AnimalSpecies("Tiger")!, 
            nickname: AnimalNickname("Rajah")!, 
            birthDate: date, 
            gender: .female, 
            favoriteFood: FavoriteFood("Chicken")!, 
            status: .sick,
            enclosureId: UUID()
        )
        
        XCTAssertNotNil(animal.id)
        XCTAssertEqual(animal.species.value, "Tiger")
        XCTAssertEqual(animal.nickname.value, "Rajah")
        XCTAssertEqual(animal.birthDate, date)
        XCTAssertEqual(animal.gender, .female)
        XCTAssertEqual(animal.favoriteFood.value, "Chicken")
        XCTAssertEqual(animal.status, .sick)
        XCTAssertNotNil(animal.enclosureId)
    }

    func testHealMethod() {
        var animal = createTestAnimal(status: .sick)
        XCTAssertEqual(animal.status, .sick, "Animal should initially be sick")
        
        animal.heal()
        XCTAssertEqual(animal.status, .healthy, "Animal status should be healthy after calling heal()")
    }

    func testAssignToEnclosure() {
        var animal = createTestAnimal(enclosureId: nil)
        XCTAssertNil(animal.enclosureId, "Animal should initially have no enclosure")
        
        let newEnclosureId = UUID()
        animal.assignToEnclosure(id: newEnclosureId)
        XCTAssertEqual(animal.enclosureId, newEnclosureId, "Animal should be assigned to the new enclosure")

        animal.assignToEnclosure(id: nil)
        XCTAssertNil(animal.enclosureId, "Animal should have no enclosure after assigning nil")
    }

} 
