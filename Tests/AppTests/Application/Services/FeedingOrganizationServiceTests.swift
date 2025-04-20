import XCTest
@testable import App
import Foundation

final class FeedingOrganizationServiceTests: XCTestCase {

    var mockScheduleRepo: MockFeedingScheduleRepository!
    var mockAnimalRepo: MockAnimalRepository!
    var service: FeedingOrganizationService!
    
    private func createTestAnimal(id: EntityID = UUID()) -> Animal {
        return Animal(
            id: id,
            species: AnimalSpecies("Test")!, nickname: AnimalNickname("Test")!,
            birthDate: Date(), gender: .unknown, favoriteFood: FavoriteFood("Test")!
        )
    }
    
    private func createTestSchedule(id: EntityID = UUID(), animalId: EntityID, feedingTime: Date = Date(), isCompleted: Bool = false) -> FeedingSchedule {
        return FeedingSchedule(
            id: id, 
            animalId: animalId, 
            feedingTime: feedingTime, 
            foodType: FoodType("TestFood")!, 
            isCompleted: isCompleted
        )
    }

    override func setUp() async throws {
        try await super.setUp()
        mockScheduleRepo = MockFeedingScheduleRepository()
        mockAnimalRepo = MockAnimalRepository()
        service = FeedingOrganizationServiceImpl(
            scheduleRepository: mockScheduleRepo,
            animalRepository: mockAnimalRepo
        )
        await mockScheduleRepo.reset()
        await mockAnimalRepo.reset()
    }

    override func tearDown() async throws {
        mockScheduleRepo = nil
        mockAnimalRepo = nil
        service = nil
        try await super.tearDown()
    }

    func testScheduleFeedingSuccess() async throws {
        let animal = createTestAnimal()
        await mockAnimalRepo.setAnimalToReturn(animal)
        
        let input = ScheduleFeedingInput(animalId: animal.id.uuidString, feedingTime: Date(), foodType: "Pellets")
        
        let createdSchedule = try await service.scheduleFeeding(input: input)
        
        XCTAssertEqual(createdSchedule.animalId, animal.id)
        XCTAssertEqual(createdSchedule.foodType.value, "Pellets")
        XCTAssertFalse(createdSchedule.isCompleted)
        
        let animalFindByIdCalled = await mockAnimalRepo.findByIdCalledWith
        let scheduleSaveCalled = await mockScheduleRepo.saveCalled
        XCTAssertEqual(animalFindByIdCalled, animal.id)
        XCTAssertTrue(scheduleSaveCalled)
    }

    func testScheduleFeedingAnimalNotFound() async throws {
        let nonExistentAnimalId = UUID()
        await mockAnimalRepo.setAnimalToReturn(nil)
        
        let input = ScheduleFeedingInput(animalId: nonExistentAnimalId.uuidString, feedingTime: Date(), foodType: "Pellets")

        do {
            _ = try await service.scheduleFeeding(input: input)
            XCTFail("Should have thrown animalNotFound error")
        } catch let error as FeedingOrganizationError {
            XCTAssertEqual(error, .animalNotFound)
        } catch {
            XCTFail("Caught unexpected error type: \(error)")
        }
        
        let animalFindByIdCalled = await mockAnimalRepo.findByIdCalledWith
        let scheduleSaveCalled = await mockScheduleRepo.saveCalled
        XCTAssertEqual(animalFindByIdCalled, nonExistentAnimalId)
        XCTAssertFalse(scheduleSaveCalled, "Save should not be called if animal not found")
    }
    
    func testScheduleFeedingInvalidInput() async throws {
        let animal = createTestAnimal()
        await mockAnimalRepo.setAnimalToReturn(animal)

        let inputInvalidAnimalId = ScheduleFeedingInput(animalId: "not-a-uuid", feedingTime: Date(), foodType: "Pellets")
        do {
            _ = try await service.scheduleFeeding(input: inputInvalidAnimalId)
            XCTFail("Should have thrown invalidInput error for animalId")
        } catch FeedingOrganizationError.invalidInput(let msg) {
             XCTAssertTrue(msg.contains("Invalid animal ID"))
        } catch { XCTFail("Wrong error: \(error)") }
        
        let inputInvalidFood = ScheduleFeedingInput(animalId: animal.id.uuidString, feedingTime: Date(), foodType: " ")
         do {
             _ = try await service.scheduleFeeding(input: inputInvalidFood)
             XCTFail("Should have thrown invalidInput error for foodType")
         } catch FeedingOrganizationError.invalidInput(let msg) {
              XCTAssertTrue(msg.contains("Invalid food type"))
         } catch { XCTFail("Wrong error: \(error)") }
    }
    
    func testScheduleFeedingRepoSaveError() async throws {
         let animal = createTestAnimal()
         await mockAnimalRepo.setAnimalToReturn(animal)
         let testError = TestError.someError
         await mockScheduleRepo.setErrorToThrow(testError)
         
         let input = ScheduleFeedingInput(animalId: animal.id.uuidString, feedingTime: Date(), foodType: "Pellets")
 
         await XCTAssertThrowsErrorAsync(try await service.scheduleFeeding(input: input), "Expected repositoryError") { error in
             guard let orgError = error as? FeedingOrganizationError else {
                XCTFail("Caught error is not a FeedingOrganizationError: \(error)")
                return
            }
            guard case .repositoryError(let underlyingError) = orgError else {
                XCTFail("Caught FeedingOrganizationError is not .repositoryError: \(orgError)")
                return
            }
            XCTAssertNotNil(underlyingError, "Underlying error should not be nil")
        }
          
        let scheduleSaveCalled = await mockScheduleRepo.saveCalled
        XCTAssertTrue(scheduleSaveCalled, "Save should have been attempted")
    }
    
    func testMarkFeedingAsCompletedSuccess() async throws {
        let animalId = UUID()
        let scheduleId = UUID()
        let schedule = createTestSchedule(id: scheduleId, animalId: animalId, isCompleted: false)
        await mockScheduleRepo.setScheduleToReturn(schedule)
        
        try await service.markFeedingAsCompleted(scheduleId: scheduleId)
        
        let scheduleFindByIdCalled = await mockScheduleRepo.findByIdCalledWith
        let scheduleSaveCalled = await mockScheduleRepo.saveCalled
        XCTAssertEqual(scheduleFindByIdCalled, scheduleId)
        XCTAssertTrue(scheduleSaveCalled, "Save should be called after marking complete")
    }
    
    func testMarkFeedingAsCompletedNotFound() async throws {
        let nonExistentScheduleId = UUID()
        await mockScheduleRepo.setScheduleToReturn(nil)
        
        do {
            try await service.markFeedingAsCompleted(scheduleId: nonExistentScheduleId)
            XCTFail("Should have thrown scheduleNotFound error")
        } catch FeedingOrganizationError.scheduleNotFound {
        } catch { XCTFail("Wrong error: \(error)") }
        
        let scheduleFindByIdCalled = await mockScheduleRepo.findByIdCalledWith
        let scheduleSaveCalled = await mockScheduleRepo.saveCalled
        XCTAssertEqual(scheduleFindByIdCalled, nonExistentScheduleId)
        XCTAssertFalse(scheduleSaveCalled, "Save should not be called if schedule not found")
    }
    
    func testMarkFeedingAsCompletedAlreadyCompleted() async throws {
         let animalId = UUID()
         let scheduleId = UUID()
         let schedule = createTestSchedule(id: scheduleId, animalId: animalId, isCompleted: true)
         await mockScheduleRepo.setScheduleToReturn(schedule)
         
         do {
             try await service.markFeedingAsCompleted(scheduleId: scheduleId)
             XCTFail("Should have thrown alreadyCompleted error")
         } catch FeedingOrganizationError.alreadyCompleted {
         } catch { XCTFail("Wrong error: \(error)") }
         
         let scheduleFindByIdCalled = await mockScheduleRepo.findByIdCalledWith
         let scheduleSaveCalled = await mockScheduleRepo.saveCalled
         XCTAssertEqual(scheduleFindByIdCalled, scheduleId)
         XCTAssertFalse(scheduleSaveCalled, "Save should not be called if already completed")
     }

    func testGetFeedingScheduleByIdSuccess() async throws {
        let scheduleId = UUID()
        let schedule = createTestSchedule(id: scheduleId, animalId: UUID())
        await mockScheduleRepo.setScheduleToReturn(schedule)

        let foundSchedule = try await service.getFeedingScheduleById(id: scheduleId)

        XCTAssertEqual(foundSchedule?.id, scheduleId)
        let findByIdCalled = await mockScheduleRepo.findByIdCalledWith
        XCTAssertEqual(findByIdCalled, scheduleId)
    }
    
     func testGetFeedingScheduleByIdError() async throws {
         let scheduleId = UUID()
         let testError = TestError.someError
         await mockScheduleRepo.setErrorToThrow(testError)
         
         do {
             _ = try await service.getFeedingScheduleById(id: scheduleId)
             XCTFail("Should throw")
         } catch FeedingOrganizationError.repositoryError { 
         } catch { XCTFail("Wrong error") }
         
         let findByIdCalled = await mockScheduleRepo.findByIdCalledWith
         XCTAssertEqual(findByIdCalled, scheduleId)
     }
     
}