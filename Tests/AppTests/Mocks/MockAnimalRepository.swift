import XCTest
@testable import App
import Foundation

actor MockAnimalRepository: AnimalRepository {
    
    private(set) var saveCalled = false
    private(set) var findByIdCalledWith: EntityID? = nil
    private(set) var findAllCalled = false
    private(set) var deleteByIdCalledWith: EntityID? = nil
    private(set) var findByEnclosureIdCalledWith: EntityID? = nil
    private(set) var didAttemptFindAll = false 
    
    private var _animalsToReturn: [Animal] = []
    private var _animalToReturn: Animal? = nil
    
    private var _errorToThrow: Error? = nil
    
    private var storedAnimals: [EntityID: Animal] = [:]

    func reset() {
        saveCalled = false
        findByIdCalledWith = nil
        findAllCalled = false
        deleteByIdCalledWith = nil
        findByEnclosureIdCalledWith = nil
        didAttemptFindAll = false
        _animalsToReturn = []
        _animalToReturn = nil
        _errorToThrow = nil
        storedAnimals = [:]
    }
    
    func setAnimalsToReturn(_ animals: [Animal]) {
        self._animalsToReturn = animals
    }
    
    func setAnimalToReturn(_ animal: Animal?) {
        self._animalToReturn = animal
    }
    
    func setErrorToThrow(_ error: Error?) {
        self._errorToThrow = error
    }
    
    func save(_ animal: Animal) async throws {
        if let error = _errorToThrow {
            throw error
        }
        saveCalled = true
        storedAnimals[animal.id] = animal
    }

    func findById(_ id: EntityID) async throws -> Animal? {
        if let error = _errorToThrow {
            throw error
        }
        findByIdCalledWith = id
        return _animalToReturn ?? storedAnimals[id]
    }

    func findAll() async throws -> [Animal] {
        findAllCalled = true
        didAttemptFindAll = true
        if let error = _errorToThrow {
            throw error
        }
        return _animalsToReturn.isEmpty ? Array(storedAnimals.values) : _animalsToReturn
    }

    func deleteById(_ id: EntityID) async throws {
        if let error = _errorToThrow {
            throw error
        }
        deleteByIdCalledWith = id
        storedAnimals.removeValue(forKey: id)
    }

    func findByEnclosureId(_ enclosureId: EntityID) async throws -> [Animal] {
        findByEnclosureIdCalledWith = enclosureId
        if let error = _errorToThrow {
            throw error
        }
        let storedFiltered = storedAnimals.values.filter { $0.enclosureId == enclosureId }
        let setFiltered = _animalsToReturn.filter { $0.enclosureId == enclosureId }
        return setFiltered.isEmpty ? storedFiltered : setFiltered
    }
}
