import XCTest
@testable import App

final class SizeTests: XCTestCase {

    func testSizeInitializationAndRawValue() {
        XCTAssertEqual(Size(rawValue: "small"), .small)
        XCTAssertEqual(Size(rawValue: "medium"), .medium)
        XCTAssertEqual(Size(rawValue: "large"), .large)
        XCTAssertNil(Size(rawValue: "invalid"))

        XCTAssertEqual(Size.small.rawValue, "small")
        XCTAssertEqual(Size.medium.rawValue, "medium")
        XCTAssertEqual(Size.large.rawValue, "large")
    }

    func testCaseIterable() {
        XCTAssertEqual(Size.allCases.count, 3)
        XCTAssertTrue(Size.allCases.contains(.small))
        XCTAssertTrue(Size.allCases.contains(.medium))
        XCTAssertTrue(Size.allCases.contains(.large))
    }
} 