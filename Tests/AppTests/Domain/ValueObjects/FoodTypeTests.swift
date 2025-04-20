import XCTest
@testable import App

final class FoodTypeTests: XCTestCase {

    func testValidInitialization() {
        let food = FoodType("Hay")
        XCTAssertNotNil(food)
        XCTAssertEqual(food?.value, "Hay")
    }

    func testInitializationWithWhitespace() {
        let food = FoodType("  Steak  ")
        XCTAssertNotNil(food)
        XCTAssertEqual(food?.value, "Steak", "Whitespace should be trimmed")
    }

    func testInitializationWithEmptyString() {
        let food = FoodType("")
        XCTAssertNil(food, "Initialization with an empty string should fail")
    }

    func testInitializationWithOnlyWhitespace() {
        let food = FoodType("   ")
        XCTAssertNil(food, "Initialization with only whitespace should fail")
    }
} 