import Foundation

enum AnimalManagementError: Error, Equatable {
    case invalidInput(String)
    case animalNotFound
    case enclosureNotFound
    case repositoryError(Error)

    static func == (lhs: AnimalManagementError, rhs: AnimalManagementError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidInput, .invalidInput):
            return true
        case (.animalNotFound, .animalNotFound):
            return true
        case (.enclosureNotFound, .enclosureNotFound):
            return true
        case (.repositoryError, .repositoryError):
            return true
        default:
            return false
        }
    }
}

final class AnimalManagementServiceImpl: @unchecked Sendable, AnimalManagementService {
    private let animalRepository: AnimalRepository
    private let enclosureRepository: EnclosureRepository

    init(animalRepository: AnimalRepository, enclosureRepository: EnclosureRepository) {
        self.animalRepository = animalRepository
        self.enclosureRepository = enclosureRepository
    }

    func addAnimal(input: AddAnimalInput) async throws -> Animal {
        guard let species = AnimalSpecies(input.species) else {
            throw AnimalManagementError.invalidInput("Invalid species")
        }
        guard let nickname = AnimalNickname(input.nickname) else {
            throw AnimalManagementError.invalidInput("Invalid nickname")
        }
        guard let gender = Gender(rawValue: input.gender.lowercased()) else {
            throw AnimalManagementError.invalidInput("Invalid gender")
        }
        guard let favoriteFood = FavoriteFood(input.favoriteFood) else {
            throw AnimalManagementError.invalidInput("Invalid favorite food")
        }

        var targetEnclosureId: EntityID? = nil
        if let enclosureIdString = input.enclosureId {
            guard let parsedId = UUID(uuidString: enclosureIdString) else {
                throw AnimalManagementError.invalidInput("Invalid enclosure ID format")
            }
            guard let _ = try await enclosureRepository.findById(parsedId) else {
                throw AnimalManagementError.enclosureNotFound
            }
            targetEnclosureId = parsedId
        }

        let newAnimal = Animal(
            species: species,
            nickname: nickname,
            birthDate: input.birthDate,
            gender: gender,
            favoriteFood: favoriteFood,
            status: .healthy,
            enclosureId: targetEnclosureId
        )

        do {
            try await animalRepository.save(newAnimal)
            if let enclosureId = targetEnclosureId,
               let enclosure = try await enclosureRepository.findById(enclosureId) {
                var mutableEnclosure = enclosure
                try mutableEnclosure.addAnimal(id: newAnimal.id)
                try await enclosureRepository.save(mutableEnclosure)
                
                var mutableAnimal = newAnimal
                mutableAnimal.assignToEnclosure(id: enclosureId)
                try await animalRepository.save(mutableAnimal)
                return mutableAnimal
            }
            return newAnimal
        } catch let error as EnclosureError {
             throw AnimalManagementError.repositoryError(error)
        } catch {
            throw AnimalManagementError.repositoryError(error)
        }
    }

    func removeAnimal(id: EntityID) async throws {
        guard let animal = try await animalRepository.findById(id) else {
            throw AnimalManagementError.animalNotFound
        }
        
        do {
             if let enclosureId = animal.enclosureId {
                 guard let enclosure = try await enclosureRepository.findById(enclosureId) else {
                      throw AnimalManagementError.enclosureNotFound
                 }
                 var mutableEnclosure = enclosure
                 try? mutableEnclosure.removeAnimal(id: animal.id)
                 try await enclosureRepository.save(mutableEnclosure)
             }
            try await animalRepository.deleteById(id)
        } catch let knownError as AnimalManagementError {
            throw knownError
        } catch {
            throw AnimalManagementError.repositoryError(error)
        }
    }

    func getAnimalById(id: EntityID) async throws -> Animal? {
        do {
            return try await animalRepository.findById(id)
        } catch {
            throw AnimalManagementError.repositoryError(error)
        }
    }

    func getAllAnimals() async throws -> [Animal] {
        do {
            return try await animalRepository.findAll()
        } catch {
            throw AnimalManagementError.repositoryError(error)
        }
    }
    
    func getAnimalsInEnclosure(enclosureId: EntityID) async throws -> [Animal] {
        do {
             return try await animalRepository.findByEnclosureId(enclosureId)
        } catch {
            throw AnimalManagementError.repositoryError(error)
        }
    }
} 
