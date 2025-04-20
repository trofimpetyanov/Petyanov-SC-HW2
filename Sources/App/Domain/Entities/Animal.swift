import Foundation
import Vapor

struct Animal: Content, Equatable, Identifiable {
    let id: EntityID
    var species: AnimalSpecies
    var nickname: AnimalNickname
    var birthDate: Date
    var gender: Gender
    var favoriteFood: FavoriteFood
    var status: AnimalStatus
    var enclosureId: EntityID?

    init(
        id: EntityID = EntityID(),
        species: AnimalSpecies,
        nickname: AnimalNickname,
        birthDate: Date,
        gender: Gender,
        favoriteFood: FavoriteFood,
        status: AnimalStatus = .healthy,
        enclosureId: EntityID? = nil
    ) {
        self.id = id
        self.species = species
        self.nickname = nickname
        self.birthDate = birthDate
        self.gender = gender
        self.favoriteFood = favoriteFood
        self.status = status
        self.enclosureId = enclosureId
    }

    mutating func feed() {
    }

    mutating func heal() {
        self.status = .healthy
    }

    mutating func assignToEnclosure(id: EntityID?) {
        self.enclosureId = id
    }
}