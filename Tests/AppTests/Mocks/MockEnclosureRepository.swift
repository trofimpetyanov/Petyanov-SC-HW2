import XCTest
@testable import App
import Foundation

actor MockEnclosureRepository: EnclosureRepository {
    
    private(set) var saveCalled = false
    private(set) var findByIdCalledWith: EntityID? = nil
    private(set) var findAllCalled = false
    private(set) var deleteByIdCalledWith: EntityID? = nil
    private(set) var findAvailableCalled = false
    private(set) var didAttemptFindAvailable = false
    
    private var _enclosuresToReturn: [Enclosure] = []
    private var _enclosureToReturn: Enclosure? = nil
    
    private var _errorToThrow: Error? = nil
    
    private var storedEnclosures: [EntityID: Enclosure] = [:]

    func reset() {
        saveCalled = false
        findByIdCalledWith = nil
        findAllCalled = false
        deleteByIdCalledWith = nil
        findAvailableCalled = false
        didAttemptFindAvailable = false
        _enclosuresToReturn = []
        _enclosureToReturn = nil
        _errorToThrow = nil
        storedEnclosures = [:]
    }
    
    func setEnclosuresToReturn(_ enclosures: [Enclosure]) {
        self._enclosuresToReturn = enclosures
    }
    
    func setEnclosureToReturn(_ enclosure: Enclosure?) {
        self._enclosureToReturn = enclosure
    }
    
    func setErrorToThrow(_ error: Error?) {
        self._errorToThrow = error
    }
    
    func save(_ enclosure: Enclosure) async throws {
        if let error = _errorToThrow {
            throw error
        }
        saveCalled = true
        storedEnclosures[enclosure.id] = enclosure
    }

    func findById(_ id: EntityID) async throws -> Enclosure? {
        if let error = _errorToThrow {
            throw error
        }
        findByIdCalledWith = id
        return _enclosureToReturn ?? storedEnclosures[id]
    }

    func findAll() async throws -> [Enclosure] {
        findAllCalled = true
        if let error = _errorToThrow {
            throw error
        }
        return _enclosuresToReturn.isEmpty ? Array(storedEnclosures.values) : _enclosuresToReturn
    }

    func deleteById(_ id: EntityID) async throws {
        if let error = _errorToThrow {
            throw error
        }
        deleteByIdCalledWith = id
        storedEnclosures.removeValue(forKey: id)
    }

    func findAvailable() async throws -> [Enclosure] {
        findAvailableCalled = true
        didAttemptFindAvailable = true
        if let error = _errorToThrow {
            throw error
        }
        if !_enclosuresToReturn.isEmpty {
             return _enclosuresToReturn.filter { $0.currentAnimalCount < $0.maxCapacity }
        } else {
            return storedEnclosures.values.filter { $0.currentAnimalCount < $0.maxCapacity }
        }
    }
}
