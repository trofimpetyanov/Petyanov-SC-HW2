import XCTest
@testable import App

final class GenderTests: XCTestCase {

    func testGenderInitializationAndRawValue() {
        // Test initialization from rawValue
        let male = Gender(rawValue: "male")
        let female = Gender(rawValue: "female")
        let unknown = Gender(rawValue: "unknown")
        let invalid = Gender(rawValue: "invalid")

        // Assert correct initialization
        XCTAssertEqual(male, .male)
        XCTAssertEqual(female, .female)
        XCTAssertEqual(unknown, .unknown)
        XCTAssertNil(invalid, "Initializing with an invalid rawValue should return nil")

        // Test rawValue property
        XCTAssertEqual(Gender.male.rawValue, "male")
        XCTAssertEqual(Gender.female.rawValue, "female")
        XCTAssertEqual(Gender.unknown.rawValue, "unknown")
    }

    func testCaseIterable() {
        // Ensure all cases are present
        XCTAssertEqual(Gender.allCases.count, 3)
        XCTAssertTrue(Gender.allCases.contains(.male))
        XCTAssertTrue(Gender.allCases.contains(.female))
        XCTAssertTrue(Gender.allCases.contains(.unknown))
    }
} 
