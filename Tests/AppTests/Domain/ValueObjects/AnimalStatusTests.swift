import XCTest
@testable import App

final class AnimalStatusTests: XCTestCase {

    func testAnimalStatusInitializationAndRawValue() {
        XCTAssertEqual(AnimalStatus(rawValue: "healthy"), .healthy)
        XCTAssertEqual(AnimalStatus(rawValue: "sick"), .sick)
        XCTAssertNil(AnimalStatus(rawValue: "invalid"))

        XCTAssertEqual(AnimalStatus.healthy.rawValue, "healthy")
        XCTAssertEqual(AnimalStatus.sick.rawValue, "sick")
    }

    func testCaseIterable() {
        XCTAssertEqual(AnimalStatus.allCases.count, 2)
        XCTAssertTrue(AnimalStatus.allCases.contains(.healthy))
        XCTAssertTrue(AnimalStatus.allCases.contains(.sick))
    }
} 