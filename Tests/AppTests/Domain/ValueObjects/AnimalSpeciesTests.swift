import XCTest
@testable import App

final class AnimalSpeciesTests: XCTestCase {

    func testValidInitialization() {
        let species = AnimalSpecies("Lion")
        XCTAssertNotNil(species)
        XCTAssertEqual(species?.value, "Lion")
    }

    func testInitializationWithWhitespace() {
        let species = AnimalSpecies("  Tiger  ")
        XCTAssertNotNil(species)
        XCTAssertEqual(species?.value, "Tiger", "Whitespace should be trimmed")
    }

    func testInitializationWithEmptyString() {
        let species = AnimalSpecies("")
        XCTAssertNil(species, "Initialization with an empty string should fail")
    }

    func testInitializationWithOnlyWhitespace() {
        let species = AnimalSpecies("   ")
        XCTAssertNil(species, "Initialization with only whitespace should fail")
    }
} 