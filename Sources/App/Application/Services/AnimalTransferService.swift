import Foundation
import Vapor

// Moved outside protocol
struct MoveAnimalInput: Content {
    let animalId: String
    let toEnclosureId: String
    
    public init(animalId: String, toEnclosureId: String) {
        self.animalId = animalId
        self.toEnclosureId = toEnclosureId
    }
}

protocol AnimalTransferService {
    func moveAnimal(input: MoveAnimalInput) async throws
} 