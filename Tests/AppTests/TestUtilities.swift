import Foundation
import XCTest

enum TestError: Error, Equatable {
    case someError
    case anotherError
}

// Helper function to assert async throws (if not already present)
// Copied from AnimalManagementServiceTests.swift just in case
func XCTAssertThrowsErrorAsync<T>(
    _ expression: @autoclosure () async throws -> T,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath,
    line: UInt = #line,
    _ errorHandler: (_ error: Error) -> Void = { _ in }
) async {
    do {
        _ = try await expression()
        XCTFail(message(), file: file, line: line)
    } catch {
        errorHandler(error)
    }
} 