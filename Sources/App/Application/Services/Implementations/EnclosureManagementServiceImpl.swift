import Foundation

enum EnclosureManagementError: Error, Equatable {
    case invalidInput(String)
    case enclosureNotFound
    case repositoryError(Error)
    case enclosureNotEmpty

    static func == (lhs: EnclosureManagementError, rhs: EnclosureManagementError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidInput, .invalidInput):
            return true
        case (.enclosureNotFound, .enclosureNotFound):
            return true
        case (.repositoryError, .repositoryError):
            return true
        case (.enclosureNotEmpty, .enclosureNotEmpty):
            return true
        default:
            return false
        }
    }
}

final class EnclosureManagementServiceImpl: @unchecked Sendable, EnclosureManagementService {
    private let enclosureRepository: EnclosureRepository
    private let animalRepository: AnimalRepository

    init(enclosureRepository: EnclosureRepository, animalRepository: AnimalRepository) {
        self.enclosureRepository = enclosureRepository
        self.animalRepository = animalRepository
    }

    func addEnclosure(input: AddEnclosureInput) async throws -> Enclosure {
        guard let type = EnclosureType(rawValue: input.type.lowercased()) else {
            throw EnclosureManagementError.invalidInput("Invalid enclosure type")
        }
        guard let size = Size(rawValue: input.size.lowercased()) else {
            throw EnclosureManagementError.invalidInput("Invalid enclosure size")
        }
        guard input.maxCapacity > 0 else {
            throw EnclosureManagementError.invalidInput("Max capacity must be positive")
        }

        let newEnclosure = Enclosure(
            type: type,
            size: size,
            maxCapacity: input.maxCapacity
        )

        do {
            try await enclosureRepository.save(newEnclosure)
            return newEnclosure
        } catch {
            throw EnclosureManagementError.repositoryError(error)
        }
    }

    func removeEnclosure(id: EntityID) async throws {
        guard let enclosure = try await enclosureRepository.findById(id) else {
            throw EnclosureManagementError.enclosureNotFound
        }

        guard enclosure.currentAnimalCount == 0 else {
             throw EnclosureManagementError.enclosureNotEmpty
        }
        
        do {
            try await enclosureRepository.deleteById(id)
        } catch {
            throw EnclosureManagementError.repositoryError(error)
        }
    }

    func getEnclosureById(id: EntityID) async throws -> Enclosure? {
        do {
            return try await enclosureRepository.findById(id)
        } catch {
            throw EnclosureManagementError.repositoryError(error)
        }
    }

    func getAllEnclosures() async throws -> [Enclosure] {
        do {
            return try await enclosureRepository.findAll()
        } catch {
            throw EnclosureManagementError.repositoryError(error)
        }
    }

    func getAvailableEnclosures() async throws -> [Enclosure] {
        do {
            return try await enclosureRepository.findAvailable()
        } catch {
            throw EnclosureManagementError.repositoryError(error)
        }
    }
} 
