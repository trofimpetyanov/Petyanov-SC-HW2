import XCTest
@testable import App
import Foundation

final class ZooStatisticsServiceTests: XCTestCase {

    var mockAnimalRepo: MockAnimalRepository!
    var mockEnclosureRepo: MockEnclosureRepository!
    var statisticsService: ZooStatisticsService!

    private func createTestAnimal(id: EntityID = UUID(), status: AnimalStatus = .healthy) -> Animal {
        return Animal(
            id: id,
            species: AnimalSpecies("Test")!, nickname: AnimalNickname("Test")!,
            birthDate: Date(), gender: .unknown, favoriteFood: FavoriteFood("Test")!,
            status: status
        )
    }
    
    private func createTestEnclosure(id: EntityID = UUID(), currentAnimals: Int, maxCapacity: Int) -> Enclosure {
        let animalIds = (0..<currentAnimals).map { _ in UUID() }
        return Enclosure(id: id, type: .herbivore, size: .medium, maxCapacity: maxCapacity, animalIds: Set(animalIds))
    }

    override func setUp() async throws {
        try await super.setUp()
        mockAnimalRepo = MockAnimalRepository()
        mockEnclosureRepo = MockEnclosureRepository()
        statisticsService = ZooStatisticsServiceImpl(
            animalRepository: mockAnimalRepo,
            enclosureRepository: mockEnclosureRepo
        )
        await mockAnimalRepo.reset()
        await mockEnclosureRepo.reset()
    }

    override func tearDown() async throws {
        mockAnimalRepo = nil
        mockEnclosureRepo = nil
        statisticsService = nil
        try await super.tearDown()
    }

    func testGetStatisticsSuccess() async throws {
        let animals = [
            createTestAnimal(status: .healthy),
            createTestAnimal(status: .healthy),
            createTestAnimal(status: .sick),
            createTestAnimal(status: .sick)
        ]
        let enclosures = [
            createTestEnclosure(currentAnimals: 1, maxCapacity: 5),
            createTestEnclosure(currentAnimals: 3, maxCapacity: 3),
            createTestEnclosure(currentAnimals: 0, maxCapacity: 2)
        ]
        await mockAnimalRepo.reset()
        await mockEnclosureRepo.reset()
        await mockAnimalRepo.setAnimalsToReturn(animals)
        await mockEnclosureRepo.setEnclosuresToReturn(enclosures)

        let statistics = try await statisticsService.getStatistics()

        XCTAssertEqual(statistics.totalAnimalCount, 4)
        XCTAssertEqual(statistics.sickAnimalCount, 2)
        XCTAssertEqual(statistics.availableEnclosureCount, 2, "Available count should match mock logic") 
        
        let animalRepoFindAllCalled = await mockAnimalRepo.findAllCalled
        let enclosureRepoFindAvailableCalled = await mockEnclosureRepo.findAvailableCalled
        XCTAssertTrue(animalRepoFindAllCalled, "animalRepository.findAll should be called")
        XCTAssertTrue(enclosureRepoFindAvailableCalled, "enclosureRepository.findAvailable should be called")
    }
    
    func testGetStatisticsWhenAnimalRepoFails() async throws {
        let testError = TestError.someError
        await mockAnimalRepo.reset()
        await mockEnclosureRepo.reset()
        await mockAnimalRepo.setErrorToThrow(testError)
        
        do {
            _ = try await statisticsService.getStatistics()
            XCTFail("Should have thrown an error")
        } catch let error as StatisticsError {
            if case .repositoryError(let underlyingError) = error {
                 XCTAssertEqual(underlyingError as? TestError, testError, "Underlying error should be the one thrown by the mock")
            } else {
                XCTFail("Caught StatisticsError, but it wasn't a repositoryError")
            }
        } catch {
            XCTFail("Caught unexpected error type: \(error)")
        }
        
        let didAttempt = await mockAnimalRepo.didAttemptFindAll
        XCTAssertTrue(didAttempt, "animalRepository.findAll should have been attempted before throwing")
    }
    
    func testGetStatisticsWhenEnclosureRepoFails() async throws {
        let testError = TestError.someError
        await mockAnimalRepo.reset()
        await mockEnclosureRepo.reset()
        await mockEnclosureRepo.setErrorToThrow(testError)
        
        do {
             _ = try await statisticsService.getStatistics()
            XCTFail("Should have thrown an error")
        } catch let error as StatisticsError {
            if case .repositoryError(let underlyingError) = error {
                 XCTAssertEqual(underlyingError as? TestError, testError, "Underlying error should be the one thrown by the mock")
            } else {
                XCTFail("Caught StatisticsError, but it wasn't a repositoryError")
            }
        } catch {
            XCTFail("Caught unexpected error type: \(error)")
        }
        
        let animalRepoCalled = await mockAnimalRepo.findAllCalled
        let didAttemptEnclosure = await mockEnclosureRepo.didAttemptFindAvailable
        XCTAssertTrue(animalRepoCalled, "animalRepository.findAll should have been called")
        XCTAssertTrue(didAttemptEnclosure, "enclosureRepository.findAvailable should have been attempted before throwing")
    }
}