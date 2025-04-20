import XCTest
@testable import App
import Foundation

final class EnclosureManagementServiceTests: XCTestCase {

    var mockEnclosureRepo: MockEnclosureRepository!
    var mockAnimalRepo: MockAnimalRepository! // Needed for init
    var service: EnclosureManagementService!

    // Helper to create input DTO
    private func createAddEnclosureInput(
        type: String = "herbivore",
        size: String = "medium",
        maxCapacity: Int = 10
    ) -> AddEnclosureInput {
        return AddEnclosureInput(type: type, size: size, maxCapacity: maxCapacity)
    }

    override func setUp() async throws {
        try await super.setUp()
        mockEnclosureRepo = MockEnclosureRepository()
        mockAnimalRepo = MockAnimalRepository() // Initialize mock animal repo
        service = EnclosureManagementServiceImpl(
            enclosureRepository: mockEnclosureRepo,
            animalRepository: mockAnimalRepo // Pass mock animal repo
        )
        await mockEnclosureRepo.reset()
        await mockAnimalRepo.reset()
    }

    override func tearDown() async throws {
        mockEnclosureRepo = nil
        mockAnimalRepo = nil
        service = nil
        try await super.tearDown()
    }

    // MARK: - addEnclosure Tests

    func testAddEnclosureSuccess() async throws {
        // Given
        let input = createAddEnclosureInput(type: "herbivore", size: "large", maxCapacity: 15)

        // When
        let createdEnclosure = try await service.addEnclosure(input: input)

        // Then
        XCTAssertEqual(createdEnclosure.type.rawValue, input.type)
        XCTAssertEqual(createdEnclosure.size.rawValue, input.size)
        XCTAssertEqual(createdEnclosure.maxCapacity, input.maxCapacity)
        XCTAssertTrue(createdEnclosure.animalIds.isEmpty)

        let saveCalled = await mockEnclosureRepo.saveCalled
        XCTAssertTrue(saveCalled, "enclosureRepository.save should be called")
    }

    func testAddEnclosure_InvalidInput_Type() async throws {
        // Given
        let input = createAddEnclosureInput(type: "unknown")

        // When & Then
        await XCTAssertThrowsErrorAsync(try await service.addEnclosure(input: input)) { error in
            guard let managementError = error as? EnclosureManagementError else {
                XCTFail("Unexpected error type: \(error)")
                return
            }
            XCTAssertEqual(managementError, .invalidInput("Invalid enclosure type"))
        }
        
        let saveCalled = await mockEnclosureRepo.saveCalled
        XCTAssertFalse(saveCalled)
    }
    
    func testAddEnclosure_InvalidInput_Size() async throws {
        // Given
        let input = createAddEnclosureInput(size: "huge")

        // When & Then
        await XCTAssertThrowsErrorAsync(try await service.addEnclosure(input: input)) { error in
            guard let managementError = error as? EnclosureManagementError else {
                XCTFail("Unexpected error type: \(error)")
                return
            }
            XCTAssertEqual(managementError, .invalidInput("Invalid enclosure size"))
        }
        
        let saveCalled = await mockEnclosureRepo.saveCalled
        XCTAssertFalse(saveCalled)
    }
    
    func testAddEnclosure_InvalidInput_Capacity() async throws {
        // Given
        let input = createAddEnclosureInput(maxCapacity: 0)

        // When & Then
        await XCTAssertThrowsErrorAsync(try await service.addEnclosure(input: input)) { error in
            guard let managementError = error as? EnclosureManagementError else {
                XCTFail("Unexpected error type: \(error)")
                return
            }
            XCTAssertEqual(managementError, .invalidInput("Max capacity must be positive"))
        }
        
        let saveCalled = await mockEnclosureRepo.saveCalled
        XCTAssertFalse(saveCalled)
    }

    // MARK: - removeEnclosure Tests
    
    func testRemoveEnclosure_Success_Empty() async throws {
        // Given
        let enclosureId = UUID()
        let enclosure = Enclosure(id: enclosureId, type: .predator, size: .large, maxCapacity: 5, animalIds: [])
        await mockEnclosureRepo.setEnclosureToReturn(enclosure)
        
        // When
        try await service.removeEnclosure(id: enclosureId)
        
        // Then
        let findByIdCalled = await mockEnclosureRepo.findByIdCalledWith
        XCTAssertEqual(findByIdCalled, enclosureId)
        let deleteCalled = await mockEnclosureRepo.deleteByIdCalledWith
        XCTAssertEqual(deleteCalled, enclosureId)
    }
    
    func testRemoveEnclosure_Fails_NotEmpty() async throws {
        // Given
        let enclosureId = UUID()
        let animalId = UUID()
        let enclosure = Enclosure(id: enclosureId, type: .predator, size: .large, maxCapacity: 5, animalIds: [animalId])
        await mockEnclosureRepo.setEnclosureToReturn(enclosure)
        
        // When & Then
        await XCTAssertThrowsErrorAsync(try await service.removeEnclosure(id: enclosureId)) { error in
            guard let managementError = error as? EnclosureManagementError else {
                return XCTFail("Expected EnclosureManagementError")
            }
            XCTAssertEqual(managementError, .enclosureNotEmpty)
        }
        
        let findByIdCalled = await mockEnclosureRepo.findByIdCalledWith
        XCTAssertEqual(findByIdCalled, enclosureId)
        let deleteCalled = await mockEnclosureRepo.deleteByIdCalledWith
        XCTAssertNil(deleteCalled, "Delete should not be called if enclosure is not empty")
    }
    
    func testRemoveEnclosure_NotFound() async throws {
        // Given
        let enclosureId = UUID()
        await mockEnclosureRepo.setEnclosureToReturn(nil) 
        
        // When & Then
        await XCTAssertThrowsErrorAsync(try await service.removeEnclosure(id: enclosureId)) { error in
            guard let managementError = error as? EnclosureManagementError else {
                return XCTFail("Expected EnclosureManagementError")
            }
            XCTAssertEqual(managementError, .enclosureNotFound)
        }
        
        let findByIdCalled = await mockEnclosureRepo.findByIdCalledWith
        XCTAssertEqual(findByIdCalled, enclosureId)
        let findAnimalsCalled = await mockAnimalRepo.findByEnclosureIdCalledWith
        XCTAssertNil(findAnimalsCalled, "Animal find should not be called if enclosure not found")
        let deleteCalled = await mockEnclosureRepo.deleteByIdCalledWith
        XCTAssertNil(deleteCalled)
    }
    
    // MARK: - getEnclosureById Tests
    
    func testGetEnclosureById_Found() async throws {
        // Given
        let enclosureId = UUID()
        let testEnclosure = Enclosure(
            id: enclosureId, 
            type: .predator, 
            size: .large, 
            maxCapacity: 5, 
            animalIds: []
        )
        await mockEnclosureRepo.setEnclosureToReturn(testEnclosure)
        
        // When
        let foundEnclosure = try await service.getEnclosureById(id: enclosureId)
        
        // Then
        let findCalled = await mockEnclosureRepo.findByIdCalledWith
        XCTAssertEqual(findCalled, enclosureId)
        XCTAssertNotNil(foundEnclosure)
        XCTAssertEqual(foundEnclosure?.id, enclosureId)
        XCTAssertEqual(foundEnclosure?.type, .predator)
    }
    
    func testGetEnclosureById_NotFound() async throws {
        // Given
        let enclosureId = UUID()
        await mockEnclosureRepo.setEnclosureToReturn(nil)
        
        // When
        let foundEnclosure = try await service.getEnclosureById(id: enclosureId)
        
        // Then
        let findCalled = await mockEnclosureRepo.findByIdCalledWith
        XCTAssertEqual(findCalled, enclosureId)
        XCTAssertNil(foundEnclosure)
    }
    
    // MARK: - getAllEnclosures Tests
    
    func testGetAllEnclosures_Success() async throws {
        // Given
        let enclosures = [
            Enclosure(id: UUID(), type: .predator, size: .large, maxCapacity: 5),
            Enclosure(id: UUID(), type: .herbivore, size: .medium, maxCapacity: 10)
        ]
        await mockEnclosureRepo.setEnclosuresToReturn(enclosures)
        
        // When
        let result = try await service.getAllEnclosures()
        
        // Then
        let findAllCalled = await mockEnclosureRepo.findAllCalled
        XCTAssertTrue(findAllCalled)
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result.map { $0.id }.sorted(by: { $0.uuidString < $1.uuidString }), 
                       enclosures.map { $0.id }.sorted(by: { $0.uuidString < $1.uuidString }))
    }
    
    func testGetAllEnclosures_Empty() async throws {
        // Given
        await mockEnclosureRepo.setEnclosuresToReturn([])
        
        // When
        let result = try await service.getAllEnclosures()
        
        // Then
        let findAllCalled = await mockEnclosureRepo.findAllCalled
        XCTAssertTrue(findAllCalled)
        XCTAssertTrue(result.isEmpty)
    }
    
    func testGetAllEnclosures_ThrowsError() async throws {
        // Given
        let testError = TestError.someError
        await mockEnclosureRepo.setErrorToThrow(testError)
        
        // When & Then
        await XCTAssertThrowsErrorAsync(try await service.getAllEnclosures()) { error in
            guard let repoError = error as? EnclosureManagementError else {
                return XCTFail("Expected EnclosureManagementError")
            }
            XCTAssertEqual(repoError, .repositoryError(testError))
        }
        let findAllCalled = await mockEnclosureRepo.findAllCalled
        XCTAssertTrue(findAllCalled)
    }

    // MARK: - getAvailableEnclosures Tests
    
    func testGetAvailableEnclosures_Success() async throws {
        // Given
        let fullEnclosure = Enclosure(id: UUID(), type: .predator, size: .small, maxCapacity: 1, animalIds: [UUID()])
        let availableEnclosure1 = Enclosure(id: UUID(), type: .herbivore, size: .medium, maxCapacity: 5, animalIds: [UUID(), UUID()])
        let availableEnclosure2 = Enclosure(id: UUID(), type: .bird, size: .large, maxCapacity: 10, animalIds: [])
        let enclosures = [fullEnclosure, availableEnclosure1, availableEnclosure2]
        await mockEnclosureRepo.setEnclosuresToReturn(enclosures)
        
        // When
        let result = try await service.getAvailableEnclosures()
        
        // Then
        let findAvailableCalled = await mockEnclosureRepo.findAvailableCalled
        XCTAssertTrue(findAvailableCalled)
        XCTAssertEqual(result.count, 2)
        XCTAssertTrue(result.contains { $0.id == availableEnclosure1.id })
        XCTAssertTrue(result.contains { $0.id == availableEnclosure2.id })
        XCTAssertFalse(result.contains { $0.id == fullEnclosure.id })
    }
    
    func testGetAvailableEnclosures_NoneAvailable() async throws {
        // Given
        let fullEnclosure = Enclosure(id: UUID(), type: .predator, size: .small, maxCapacity: 1, animalIds: [UUID()])
        await mockEnclosureRepo.setEnclosuresToReturn([fullEnclosure])
        
        // When
        let result = try await service.getAvailableEnclosures()
        
        // Then
        let findAvailableCalled = await mockEnclosureRepo.findAvailableCalled
        XCTAssertTrue(findAvailableCalled)
        XCTAssertTrue(result.isEmpty)
    }
    
    func testGetAvailableEnclosures_ThrowsError() async throws {
        // Given
        let testError = TestError.someError
        await mockEnclosureRepo.setErrorToThrow(testError)
        
        // When & Then
        await XCTAssertThrowsErrorAsync(try await service.getAvailableEnclosures()) { error in
            guard let repoError = error as? EnclosureManagementError else {
                return XCTFail("Expected EnclosureManagementError")
            }
            XCTAssertEqual(repoError, .repositoryError(testError))
        }
        let findAvailableCalled = await mockEnclosureRepo.findAvailableCalled
        XCTAssertTrue(findAvailableCalled)
    }

} 
