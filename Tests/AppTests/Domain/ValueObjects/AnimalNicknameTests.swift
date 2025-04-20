import XCTest
@testable import App

final class AnimalNicknameTests: XCTestCase {

    func testValidInitialization() {
        let nickname = AnimalNickname("Simba")
        XCTAssertNotNil(nickname)
        XCTAssertEqual(nickname?.value, "Simba")
    }

    func testInitializationWithWhitespace() {
        let nickname = AnimalNickname("  Nala  ")
        XCTAssertNotNil(nickname)
        XCTAssertEqual(nickname?.value, "Nala", "Whitespace should be trimmed")
    }

    func testInitializationWithEmptyString() {
        let nickname = AnimalNickname("")
        XCTAssertNil(nickname, "Initialization with an empty string should fail")
    }

    func testInitializationWithOnlyWhitespace() {
        let nickname = AnimalNickname("   ")
        XCTAssertNil(nickname, "Initialization with only whitespace should fail")
    }
} 