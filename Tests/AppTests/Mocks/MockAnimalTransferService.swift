import Foundation
@testable import App

class MockAnimalTransferService: AnimalTransferService, @unchecked Sendable {
    var moveAnimalInput: MoveAnimalInput? = nil
    var moveAnimalCalled: Bool = false
    var moveAnimalError: Error? = nil

    func moveAnimal(input: MoveAnimalInput) async throws {
        moveAnimalCalled = true
        moveAnimalInput = input
        if let error = moveAnimalError {
            throw error
        }
    }
    
    func reset() {
        moveAnimalInput = nil
        moveAnimalCalled = false
        moveAnimalError = nil
    }
} 