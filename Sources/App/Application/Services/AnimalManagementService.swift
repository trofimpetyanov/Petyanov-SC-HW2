import Foundation
import Vapor

struct AddAnimalInput: Content {
    let species: String
    let nickname: String
    let birthDate: Date
    let gender: String
    let favoriteFood: String
    let enclosureId: String?
    
    public init(species: String, nickname: String, birthDate: Date, gender: String, favoriteFood: String, enclosureId: String?) {
        self.species = species
        self.nickname = nickname
        self.birthDate = birthDate
        self.gender = gender
        self.favoriteFood = favoriteFood
        self.enclosureId = enclosureId
    }
}

protocol AnimalManagementService {
    func addAnimal(input: AddAnimalInput) async throws -> Animal
    func removeAnimal(id: EntityID) async throws
    func getAnimalById(id: EntityID) async throws -> Animal?
    func getAllAnimals() async throws -> [Animal]
    func getAnimalsInEnclosure(enclosureId: EntityID) async throws -> [Animal]
}
