import XCTest
@testable import App

final class FavoriteFoodTests: XCTestCase {

    func testValidInitialization() {
        let food = FavoriteFood("Meat")
        XCTAssertNotNil(food)
        XCTAssertEqual(food?.value, "Meat")
    }

    func testInitializationWithWhitespace() {
        let food = FavoriteFood("  Fish  ")
        XCTAssertNotNil(food)
        XCTAssertEqual(food?.value, "Fish", "Whitespace should be trimmed")
    }

    func testInitializationWithEmptyString() {
        let food = FavoriteFood("")
        XCTAssertNil(food, "Initialization with an empty string should fail")
    }

    func testInitializationWithOnlyWhitespace() {
        let food = FavoriteFood("   ")
        XCTAssertNil(food, "Initialization with only whitespace should fail")
    }
} 