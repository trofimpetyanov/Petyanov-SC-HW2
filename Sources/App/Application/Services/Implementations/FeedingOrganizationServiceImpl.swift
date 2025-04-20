import Foundation

enum FeedingOrganizationError: Error, Equatable {
    case invalidInput(String)
    case animalNotFound
    case scheduleNotFound
    case alreadyCompleted
    case repositoryError(Error)
    
    // Manual Equatable conformance (comparing cases only)
    static func == (lhs: FeedingOrganizationError, rhs: FeedingOrganizationError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidInput, .invalidInput):
            return true // Ignore associated String value for test comparison
        case (.animalNotFound, .animalNotFound):
            return true
        case (.scheduleNotFound, .scheduleNotFound):
            return true
        case (.alreadyCompleted, .alreadyCompleted):
            return true
        case (.repositoryError, .repositoryError):
            return true // Ignore associated Error value for test comparison
        default:
            return false
        }
    }
}

enum FeedingScheduleError: Error, Equatable {
    case invalidInput(String)
    case animalNotFound
    case enclosureNotFound
    case scheduleConflict
    case repositoryError(Error)

    // Manual Equatable conformance (comparing cases only)
    static func == (lhs: FeedingScheduleError, rhs: FeedingScheduleError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidInput, .invalidInput):
            return true
        case (.animalNotFound, .animalNotFound):
            return true
        case (.enclosureNotFound, .enclosureNotFound):
            return true
        case (.scheduleConflict, .scheduleConflict):
            return true
        case (.repositoryError, .repositoryError):
            return true
        default:
            return false
        }
    }
}

actor FeedingOrganizationServiceImpl: FeedingOrganizationService {
    private let scheduleRepository: FeedingScheduleRepository
    private let animalRepository: AnimalRepository

    init(scheduleRepository: FeedingScheduleRepository, animalRepository: AnimalRepository) {
        self.scheduleRepository = scheduleRepository
        self.animalRepository = animalRepository
    }

    func scheduleFeeding(input: ScheduleFeedingInput) async throws -> FeedingSchedule {
        guard let animalId = UUID(uuidString: input.animalId) else {
            throw FeedingOrganizationError.invalidInput("Invalid animal ID format")
        }
        guard let foodType = FoodType(input.foodType) else {
            throw FeedingOrganizationError.invalidInput("Invalid food type")
        }

        let animalRepo = self.animalRepository
        guard let _ = try await animalRepo.findById(animalId) else {
            throw FeedingOrganizationError.animalNotFound
        }

        let newSchedule = FeedingSchedule(
            animalId: animalId,
            feedingTime: input.feedingTime,
            foodType: foodType
        )

        do {
            let scheduleRepo = self.scheduleRepository
            try await scheduleRepo.save(newSchedule)
            return newSchedule
        } catch { 
            if error is FeedingOrganizationError {
                throw error
            } else {
                throw FeedingOrganizationError.repositoryError(error)
            }
        }
    }

    func markFeedingAsCompleted(scheduleId: EntityID) async throws {
        let scheduleRepo = self.scheduleRepository
        guard var schedule = try await scheduleRepo.findById(scheduleId) else {
            throw FeedingOrganizationError.scheduleNotFound
        }

        guard !schedule.isCompleted else {
            throw FeedingOrganizationError.alreadyCompleted
        }

        schedule.markAsCompleted()

        do {
            try await scheduleRepo.save(schedule)
            
            _ = FeedingTimeEvent(
                scheduleId: schedule.id,
                animalId: schedule.animalId,
                completionTime: Date()
            )
        } catch { 
            if error is FeedingOrganizationError {
                throw error
            } else {
                throw FeedingOrganizationError.repositoryError(error)
            }
        }
    }

    func getFeedingScheduleById(id: EntityID) async throws -> FeedingSchedule? {
        do {
            let scheduleRepo = self.scheduleRepository
            return try await scheduleRepo.findById(id)
        } catch {
            throw FeedingOrganizationError.repositoryError(error)
        }
    }

    func getAllFeedingSchedules() async throws -> [FeedingSchedule] {
        do {
            let scheduleRepo = self.scheduleRepository
            return try await scheduleRepo.findAll()
        } catch {
            throw FeedingOrganizationError.repositoryError(error)
        }
    }

    func getUpcomingFeedings() async throws -> [FeedingSchedule] {
        do {
            let scheduleRepo = self.scheduleRepository
            return try await scheduleRepo.findUpcoming()
        } catch {
            throw FeedingOrganizationError.repositoryError(error)
        }
    }

    func getFeedingSchedulesForAnimal(animalId: EntityID) async throws -> [FeedingSchedule] {
        do {
            let scheduleRepo = self.scheduleRepository
            return try await scheduleRepo.findByAnimalId(animalId)
        } catch {
            throw FeedingOrganizationError.repositoryError(error)
        }
    }

    func deleteFeedingSchedule(id: EntityID) async throws {
        do {
            let scheduleRepo = self.scheduleRepository
            try await scheduleRepo.deleteById(id)
        } catch let knownError as FeedingOrganizationError {
             throw knownError
        } catch {
            throw FeedingOrganizationError.repositoryError(error)
        }
    }
} 