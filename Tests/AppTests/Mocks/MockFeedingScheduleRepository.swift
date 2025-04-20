import XCTest
@testable import App
import Foundation

enum MockError: Error { 
    case operationFailed 
}

actor MockFeedingScheduleRepository: FeedingScheduleRepository {
    
    private(set) var saveCalled = false
    private(set) var findByIdCalledWith: EntityID? = nil
    private(set) var findAllCalled = false
    private(set) var findByAnimalIdCalledWith: EntityID? = nil
    private(set) var findUpcomingCalled = false
    private(set) var deleteByIdCalledWith: EntityID? = nil
    
    private(set) var lastErrorEncountered: Error? 
    
    private var _schedulesToReturn: [FeedingSchedule] = []
    private var _scheduleToReturn: FeedingSchedule? = nil
    
    private var _errorToThrow: Error? = nil
    
    private var storedSchedules: [EntityID: FeedingSchedule] = [:]

    func reset() {
        saveCalled = false
        findByIdCalledWith = nil
        findAllCalled = false
        findByAnimalIdCalledWith = nil
        findUpcomingCalled = false
        deleteByIdCalledWith = nil
        lastErrorEncountered = nil
        _schedulesToReturn = []
        _scheduleToReturn = nil
        _errorToThrow = nil
        storedSchedules = [:]
    }
    
    func setSchedulesToReturn(_ schedules: [FeedingSchedule]) {
        self._schedulesToReturn = schedules
    }
    
    func setScheduleToReturn(_ schedule: FeedingSchedule?) {
        self._scheduleToReturn = schedule
    }
    
    func setErrorToThrow(_ error: Error?) {
        self._errorToThrow = error
    }
    
    func save(_ schedule: FeedingSchedule) async throws {
        saveCalled = true
        if let error = _errorToThrow {
            lastErrorEncountered = error
            throw MockError.operationFailed
        }
        storedSchedules[schedule.id] = schedule
    }

    func findById(_ id: EntityID) async throws -> FeedingSchedule? {
        findByIdCalledWith = id
        if let error = _errorToThrow {
            throw error
        }
        return _scheduleToReturn ?? storedSchedules[id]
    }

    func findAll() async throws -> [FeedingSchedule] {
        findAllCalled = true
        if let error = _errorToThrow {
            throw error
        }
        return _schedulesToReturn.isEmpty ? Array(storedSchedules.values) : _schedulesToReturn
    }

    func findByAnimalId(_ animalId: EntityID) async throws -> [FeedingSchedule] {
        findByAnimalIdCalledWith = animalId
        if let error = _errorToThrow {
            throw error
        }
        return storedSchedules.values.filter { $0.animalId == animalId }
    }

    func findUpcoming() async throws -> [FeedingSchedule] {
        findUpcomingCalled = true
        if let error = _errorToThrow {
            throw error
        }
        return storedSchedules.values.filter { !$0.isCompleted }
    }

    func deleteById(_ id: EntityID) async throws {
        if let error = _errorToThrow {
            throw error
        }
        deleteByIdCalledWith = id
        storedSchedules.removeValue(forKey: id)
    }
}