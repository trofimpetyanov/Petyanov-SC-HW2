import XCTest
@testable import App
import Foundation

final class AnimalManagementServiceTests: XCTestCase {

    var mockAnimalRepo: MockAnimalRepository!
    var mockEnclosureRepo: MockEnclosureRepository!
    var service: AnimalManagementService!

    private func createAddAnimalInput(
        species: String = "Lion",
        nickname: String = "Simba",
        birthDate: Date = Date(),
        gender: String = "male",
        favoriteFood: String = "Meat",
        enclosureId: String? = nil
    ) -> AddAnimalInput {
        return AddAnimalInput(
            species: species,
            nickname: nickname,
            birthDate: birthDate,
            gender: gender,
            favoriteFood: favoriteFood,
            enclosureId: enclosureId
        )
    }

     private func createTestEnclosure(id: EntityID = UUID(), type: EnclosureType = .herbivore, size: Size = .large, maxCapacity: Int = 5, currentAnimals: Int = 0) -> Enclosure {
         let animalIds = (0..<currentAnimals).map { _ in UUID() }
         return Enclosure(id: id, type: type, size: size, maxCapacity: maxCapacity, animalIds: Set(animalIds))
     }

    override func setUp() async throws {
        try await super.setUp()
        mockAnimalRepo = MockAnimalRepository()
        mockEnclosureRepo = MockEnclosureRepository()
        service = AnimalManagementServiceImpl(
            animalRepository: mockAnimalRepo,
            enclosureRepository: mockEnclosureRepo
        )
        await mockAnimalRepo.reset()
        await mockEnclosureRepo.reset()
    }

    override func tearDown() async throws {
        mockAnimalRepo = nil
        mockEnclosureRepo = nil
        service = nil
        try await super.tearDown()
    }

    // MARK: - addAnimal Tests

    func testAddAnimalSuccess_NoEnclosure() async throws {
        // Given
        let input = createAddAnimalInput(enclosureId: nil)

        // When
        let createdAnimal = try await service.addAnimal(input: input)

        // Then
        XCTAssertEqual(createdAnimal.species.value, input.species)
        XCTAssertEqual(createdAnimal.nickname.value, input.nickname)
        XCTAssertEqual(createdAnimal.gender.rawValue, input.gender)
        XCTAssertNil(createdAnimal.enclosureId)

        let saveCalled = await mockAnimalRepo.saveCalled
        XCTAssertTrue(saveCalled, "animalRepository.save should be called")

        let enclosureFindCalled = await mockEnclosureRepo.findByIdCalledWith
        let enclosureSaveCalled = await mockEnclosureRepo.saveCalled
        XCTAssertNil(enclosureFindCalled)
        XCTAssertFalse(enclosureSaveCalled)
    }
    
    func testAddAnimalSuccess_WithExistingEnclosure() async throws {
        // Given
        let enclosure = createTestEnclosure(maxCapacity: 5, currentAnimals: 1)
        await mockEnclosureRepo.setEnclosureToReturn(enclosure)
        
        let input = createAddAnimalInput(enclosureId: enclosure.id.uuidString)

        // When
        let createdAnimal = try await service.addAnimal(input: input)

        // Then
        XCTAssertEqual(createdAnimal.species.value, input.species)
        XCTAssertEqual(createdAnimal.nickname.value, input.nickname)
        XCTAssertEqual(createdAnimal.enclosureId, enclosure.id)

        let animalSaveCalled = await mockAnimalRepo.saveCalled
        XCTAssertTrue(animalSaveCalled, "animalRepository.save should be called at least once") 
        
        let enclosureFindCalled = await mockEnclosureRepo.findByIdCalledWith
        XCTAssertEqual(enclosureFindCalled, enclosure.id, "enclosureRepository.findById should be called")
        
        let enclosureSaveCalled = await mockEnclosureRepo.saveCalled
        XCTAssertTrue(enclosureSaveCalled, "enclosureRepository.save should be called to update animal count")
    }
    
     func testAddAnimal_InvalidInput_Species() async throws {
         // Given
         let input = createAddAnimalInput(species: "")

         // When & Then
         await XCTAssertThrowsErrorAsync(try await service.addAnimal(input: input)) { error in
             guard let managementError = error as? AnimalManagementError else {
                 XCTFail("Unexpected error type: \(error)")
                 return
             }
             XCTAssertEqual(managementError, .invalidInput("Invalid species"))
         }
         
         let saveCalled = await mockAnimalRepo.saveCalled
         XCTAssertFalse(saveCalled)
     }
     
     func testAddAnimal_InvalidInput_Nickname() async throws {
          // Given
          let input = createAddAnimalInput(nickname: " ")

          // When & Then
          await XCTAssertThrowsErrorAsync(try await service.addAnimal(input: input)) { error in
              guard let managementError = error as? AnimalManagementError else {
                  XCTFail("Unexpected error type: \(error)")
                  return
              }
              XCTAssertEqual(managementError, .invalidInput("Invalid nickname"))
          }
          
          let saveCalled = await mockAnimalRepo.saveCalled
          XCTAssertFalse(saveCalled)
      }
      
       func testAddAnimal_InvalidInput_Gender() async throws {
           // Given
           let input = createAddAnimalInput(gender: "other")

           // When & Then
           await XCTAssertThrowsErrorAsync(try await service.addAnimal(input: input)) { error in
               guard let managementError = error as? AnimalManagementError else {
                   XCTFail("Unexpected error type: \(error)")
                   return
               }
               XCTAssertEqual(managementError, .invalidInput("Invalid gender"))
           }
           
           let saveCalled = await mockAnimalRepo.saveCalled
           XCTAssertFalse(saveCalled)
       }
       
       func testAddAnimal_InvalidInput_FavoriteFood() async throws {
            // Given
            let input = createAddAnimalInput(favoriteFood: "")

            // When & Then
            await XCTAssertThrowsErrorAsync(try await service.addAnimal(input: input)) { error in
                guard let managementError = error as? AnimalManagementError else {
                    XCTFail("Unexpected error type: \(error)")
                    return
                }
                XCTAssertEqual(managementError, .invalidInput("Invalid favorite food"))
            }
            
            let saveCalled = await mockAnimalRepo.saveCalled
            XCTAssertFalse(saveCalled)
        }
        
        func testAddAnimal_InvalidInput_EnclosureIdFormat() async throws {
             // Given
             let input = createAddAnimalInput(enclosureId: "not-a-uuid")

             // When & Then
             await XCTAssertThrowsErrorAsync(try await service.addAnimal(input: input)) { error in
                 guard let managementError = error as? AnimalManagementError else {
                     XCTFail("Unexpected error type: \(error)")
                     return
                 }
                 XCTAssertEqual(managementError, .invalidInput("Invalid enclosure ID format"))
             }
             
             let saveCalled = await mockAnimalRepo.saveCalled
             XCTAssertFalse(saveCalled)
             
             let enclosureFindCalled = await mockEnclosureRepo.findByIdCalledWith
             XCTAssertNil(enclosureFindCalled, "Enclosure find should not be called with invalid ID format")
         }

    func testAddAnimal_EnclosureNotFound() async throws {
        // Given
        let nonExistentEnclosureId = UUID()
        await mockEnclosureRepo.setEnclosureToReturn(nil)
        
        let input = createAddAnimalInput(enclosureId: nonExistentEnclosureId.uuidString)

        // When & Then
        await XCTAssertThrowsErrorAsync(try await service.addAnimal(input: input)) { error in
            guard let managementError = error as? AnimalManagementError else {
                XCTFail("Unexpected error type: \(error)")
                return
            }
            XCTAssertEqual(managementError, .enclosureNotFound)
        }

        let enclosureFindCalled = await mockEnclosureRepo.findByIdCalledWith
        XCTAssertEqual(enclosureFindCalled, nonExistentEnclosureId)
        
        let animalSaveCalled = await mockAnimalRepo.saveCalled
        XCTAssertFalse(animalSaveCalled, "Animal save should not be called if enclosure not found")
    }

    // MARK: - removeAnimal Tests
    
    func testRemoveAnimal_Success_NoEnclosure() async throws {
        // Given
        let animalId = UUID()
        let animal = Animal(id: animalId, species: AnimalSpecies("A")!, nickname: AnimalNickname("N")!, birthDate: Date(), gender: .male, favoriteFood: FavoriteFood("F")!, enclosureId: nil)
        await mockAnimalRepo.setAnimalToReturn(animal)
        
        // When
        try await service.removeAnimal(id: animalId)
        
        // Then
        let findByIdCalled = await mockAnimalRepo.findByIdCalledWith
        XCTAssertEqual(findByIdCalled, animalId)
        let deleteCalled = await mockAnimalRepo.deleteByIdCalledWith
        XCTAssertEqual(deleteCalled, animalId)
        let enclosureFindCalled = await mockEnclosureRepo.findByIdCalledWith
        XCTAssertNil(enclosureFindCalled, "Enclosure find should not be called")
    }
    
    func testRemoveAnimal_Success_WithEnclosure() async throws {
        // Given
        let animalId = UUID()
        let enclosureId = UUID()
        let animal = Animal(id: animalId, species: AnimalSpecies("A")!, nickname: AnimalNickname("N")!, birthDate: Date(), gender: .male, favoriteFood: FavoriteFood("F")!, enclosureId: enclosureId)
        let enclosure = Enclosure(id: enclosureId, type: .herbivore, size: .medium, maxCapacity: 5, animalIds: [animalId, UUID()]) // Has 2 animals
        
        await mockAnimalRepo.setAnimalToReturn(animal)
        await mockEnclosureRepo.setEnclosureToReturn(enclosure)
        
        // When
        try await service.removeAnimal(id: animalId)
        
        // Then
        let findByIdCalled = await mockAnimalRepo.findByIdCalledWith
        XCTAssertEqual(findByIdCalled, animalId)
        let deleteCalled = await mockAnimalRepo.deleteByIdCalledWith
        XCTAssertEqual(deleteCalled, animalId)
        
        let enclosureFindCalled = await mockEnclosureRepo.findByIdCalledWith
        XCTAssertEqual(enclosureFindCalled, enclosureId, "Enclosure find should be called")
        
        let enclosureSaveCalled = await mockEnclosureRepo.saveCalled
        XCTAssertTrue(enclosureSaveCalled, "Enclosure save should be called")
        // Optional: Add assertion to check if the saved enclosure has the animal removed
    }
    
    func testRemoveAnimal_AnimalNotFound() async throws {
        // Given
        let animalId = UUID()
        await mockAnimalRepo.setAnimalToReturn(nil)
        
        // When & Then
        await XCTAssertThrowsErrorAsync(try await service.removeAnimal(id: animalId)) { error in
            guard let managementError = error as? AnimalManagementError else {
                return XCTFail("Expected AnimalManagementError")
            }
            XCTAssertEqual(managementError, .animalNotFound)
        }
        
        let findByIdCalled = await mockAnimalRepo.findByIdCalledWith
        XCTAssertEqual(findByIdCalled, animalId)
        let deleteCalled = await mockAnimalRepo.deleteByIdCalledWith
        XCTAssertNil(deleteCalled)
    }
    
    func testRemoveAnimal_EnclosureNotFound_WhenRemovingFromEnclosure() async throws {
        // Given
        let animalId = UUID()
        let enclosureId = UUID()
        let animal = Animal(id: animalId, species: AnimalSpecies("A")!, nickname: AnimalNickname("N")!, birthDate: Date(), gender: .male, favoriteFood: FavoriteFood("F")!, enclosureId: enclosureId)
        await mockAnimalRepo.setAnimalToReturn(animal)
        await mockEnclosureRepo.setEnclosureToReturn(nil) // Enclosure not found
        
        // When & Then
        await XCTAssertThrowsErrorAsync(try await service.removeAnimal(id: animalId)) { error in
              guard let managementError = error as? AnimalManagementError else {
                  return XCTFail("Expected AnimalManagementError")
              }
              XCTAssertEqual(managementError, .enclosureNotFound)
        }
        
        let findByIdCalled = await mockAnimalRepo.findByIdCalledWith
        XCTAssertEqual(findByIdCalled, animalId)
        let deleteCalled = await mockAnimalRepo.deleteByIdCalledWith
        XCTAssertNil(deleteCalled)
        let enclosureFindCalled = await mockEnclosureRepo.findByIdCalledWith
        XCTAssertEqual(enclosureFindCalled, enclosureId)
    }

    // MARK: - getAnimalById Tests

    func testGetAnimalById_Found() async throws {
        // Given
        let animalId = UUID()
        let testAnimal = Animal(
            id: animalId,
            species: AnimalSpecies("Tiger")!,
            nickname: AnimalNickname("Rajah")!,
            birthDate: Date(),
            gender: .male,
            favoriteFood: FavoriteFood("Steak")!
        )
        await mockAnimalRepo.setAnimalToReturn(testAnimal)

        // When
        let foundAnimal = try await service.getAnimalById(id: animalId)

        // Then
        let findByIdArgument = await mockAnimalRepo.findByIdCalledWith
        XCTAssertEqual(findByIdArgument, animalId, "findById should be called with the correct ID")
        XCTAssertNotNil(foundAnimal)
        XCTAssertEqual(foundAnimal?.id, animalId)
        XCTAssertEqual(foundAnimal?.nickname.value, "Rajah")
    }

    func testGetAnimalById_NotFound() async throws {
        // Given
        let animalId = UUID()
        await mockAnimalRepo.setAnimalToReturn(nil)

        // When
        let foundAnimal = try await service.getAnimalById(id: animalId)

        // Then
        let findByIdArgument = await mockAnimalRepo.findByIdCalledWith
        XCTAssertEqual(findByIdArgument, animalId, "findById should be called with the correct ID")
        XCTAssertNil(foundAnimal)
    }
    
    // MARK: - getAllAnimals Tests
    
    func testGetAllAnimals_Success() async throws {
        // Given
        let animals = [
            Animal(id: UUID(), species: AnimalSpecies("Lion")!, nickname: AnimalNickname("S")!, birthDate: Date(), gender: .male, favoriteFood: FavoriteFood("M")!),
            Animal(id: UUID(), species: AnimalSpecies("Zebra")!, nickname: AnimalNickname("Z")!, birthDate: Date(), gender: .female, favoriteFood: FavoriteFood("H")!)
        ]
        await mockAnimalRepo.setAnimalsToReturn(animals)
        
        // When
        let result = try await service.getAllAnimals()
        
        // Then
        let findAllCalled = await mockAnimalRepo.findAllCalled
        XCTAssertTrue(findAllCalled)
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result.map { $0.id }.sorted(by: { $0.uuidString < $1.uuidString }), 
                       animals.map { $0.id }.sorted(by: { $0.uuidString < $1.uuidString }))
    }
    
    func testGetAllAnimals_Empty() async throws {
        // Given
        await mockAnimalRepo.setAnimalsToReturn([])
        
        // When
        let result = try await service.getAllAnimals()
        
        // Then
        let findAllCalled = await mockAnimalRepo.findAllCalled
        XCTAssertTrue(findAllCalled)
        XCTAssertTrue(result.isEmpty)
    }
    
    func testGetAllAnimals_ThrowsError() async throws {
        // Given
        let testError = TestError.someError
        await mockAnimalRepo.setErrorToThrow(testError)
        
        // When & Then
        await XCTAssertThrowsErrorAsync(try await service.getAllAnimals()) { error in
            guard let repoError = error as? AnimalManagementError else {
                return XCTFail("Expected AnimalManagementError")
            }
            XCTAssertEqual(repoError, .repositoryError(testError))
        }
        let findAllCalled = await mockAnimalRepo.findAllCalled
        XCTAssertTrue(findAllCalled)
    }
    
    // MARK: - getAnimalsInEnclosure Tests
    
    func testGetAnimalsInEnclosure_Success() async throws {
        // Given
        let enclosureId = UUID()
        let animals = [
            Animal(id: UUID(), species: AnimalSpecies("Lion")!, nickname: AnimalNickname("L1")!, birthDate: Date(), gender: .male, favoriteFood: FavoriteFood("M")!, enclosureId: enclosureId),
            Animal(id: UUID(), species: AnimalSpecies("Tiger")!, nickname: AnimalNickname("T1")!, birthDate: Date(), gender: .female, favoriteFood: FavoriteFood("M")!, enclosureId: enclosureId)
        ]
        await mockAnimalRepo.setAnimalsToReturn(animals)
        
        // When
        let result = try await service.getAnimalsInEnclosure(enclosureId: enclosureId)
        
        // Then
        let findByEnclosureCalled = await mockAnimalRepo.findByEnclosureIdCalledWith
        XCTAssertEqual(findByEnclosureCalled, enclosureId)
        XCTAssertEqual(result.count, 2) 
    }
    
    func testGetAnimalsInEnclosure_NoneFound() async throws {
        // Given
        let enclosureId = UUID()
        await mockAnimalRepo.setAnimalsToReturn([])
        
        // When
        let result = try await service.getAnimalsInEnclosure(enclosureId: enclosureId)
        
        // Then
        let findByEnclosureCalled = await mockAnimalRepo.findByEnclosureIdCalledWith
        XCTAssertEqual(findByEnclosureCalled, enclosureId)
        XCTAssertTrue(result.isEmpty)
    }
    
    func testGetAnimalsInEnclosure_ThrowsError() async throws {
        // Given
        let enclosureId = UUID()
        let testError = TestError.someError
        await mockAnimalRepo.setErrorToThrow(testError)
        
        // When & Then
        await XCTAssertThrowsErrorAsync(try await service.getAnimalsInEnclosure(enclosureId: enclosureId)) { error in
            guard let repoError = error as? AnimalManagementError else {
                return XCTFail("Expected AnimalManagementError")
            }
            XCTAssertEqual(repoError, .repositoryError(testError))
        }
        let findByEnclosureCalled = await mockAnimalRepo.findByEnclosureIdCalledWith
        XCTAssertEqual(findByEnclosureCalled, enclosureId)
    }

}
