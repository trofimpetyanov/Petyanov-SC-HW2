import Foundation

enum AnimalTransferError: Error, Equatable {
    case invalidInput(String)
    case animalNotFound
    case destinationEnclosureNotFound
    case sameEnclosure
    case transferFailed(Error)
    case repositoryError(Error)
    
    static func == (lhs: AnimalTransferError, rhs: AnimalTransferError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidInput, .invalidInput):
             return true
        case (.animalNotFound, .animalNotFound):
             return true
        case (.destinationEnclosureNotFound, .destinationEnclosureNotFound):
             return true
        case (.sameEnclosure, .sameEnclosure):
             return true
        case (.transferFailed, .transferFailed):
             return true 
        case (.repositoryError, .repositoryError):
             return true
        default:
            return false
        }
    }
}

final class AnimalTransferServiceImpl: @unchecked Sendable, AnimalTransferService {
    private let animalRepository: AnimalRepository
    private let enclosureRepository: EnclosureRepository

    init(animalRepository: AnimalRepository, enclosureRepository: EnclosureRepository) {
        self.animalRepository = animalRepository
        self.enclosureRepository = enclosureRepository
    }

    func moveAnimal(input: MoveAnimalInput) async throws {
        guard let animalId = UUID(uuidString: input.animalId) else {
            throw AnimalTransferError.invalidInput("Invalid animal ID format")
        }
        guard let toEnclosureId = UUID(uuidString: input.toEnclosureId) else {
            throw AnimalTransferError.invalidInput("Invalid destination enclosure ID format")
        }

        guard let animal = try await animalRepository.findById(animalId) else {
            throw AnimalTransferError.animalNotFound
        }
        guard let destinationEnclosure = try await enclosureRepository.findById(toEnclosureId) else {
            throw AnimalTransferError.destinationEnclosureNotFound
        }

        let sourceEnclosureId = animal.enclosureId

        guard sourceEnclosureId != toEnclosureId else {
            throw AnimalTransferError.sameEnclosure
        }

        do {
            var mutableAnimal = animal
            var mutableDestinationEnclosure = destinationEnclosure
            
            var sourceEnclosure: Enclosure? = nil
            if let currentEnclosureId = sourceEnclosureId {
                sourceEnclosure = try await enclosureRepository.findById(currentEnclosureId)
            }

            try mutableDestinationEnclosure.addAnimal(id: animal.id)

            if let src = sourceEnclosure {
                var mutableSourceEnclosure = src
                try? mutableSourceEnclosure.removeAnimal(id: animal.id)
                try await enclosureRepository.save(mutableSourceEnclosure)
            }

            mutableAnimal.assignToEnclosure(id: toEnclosureId)

            try await enclosureRepository.save(mutableDestinationEnclosure)
            try await animalRepository.save(mutableAnimal)

            _ = AnimalMovedEvent(
                animalId: mutableAnimal.id,
                fromEnclosureId: sourceEnclosureId,
                toEnclosureId: toEnclosureId
            )
            
        } catch let error as EnclosureError {
            throw AnimalTransferError.transferFailed(error)
        } catch {
            throw AnimalTransferError.repositoryError(error)
        }
    }
} 