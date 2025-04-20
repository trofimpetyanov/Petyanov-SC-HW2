import Foundation

enum StatisticsError: Error, Equatable {
    case repositoryError(Error)
    
    static func == (lhs: StatisticsError, rhs: StatisticsError) -> Bool {
        switch (lhs, rhs) {
        case (.repositoryError, .repositoryError):
            return true 
        }
    }
}

final class ZooStatisticsServiceImpl: @unchecked Sendable, ZooStatisticsService {
    private let animalRepository: AnimalRepository
    private let enclosureRepository: EnclosureRepository

    init(animalRepository: AnimalRepository, enclosureRepository: EnclosureRepository) {
        self.animalRepository = animalRepository
        self.enclosureRepository = enclosureRepository
    }

    func getStatistics() async throws -> ZooStatistics {
        do {
            let allAnimals = try await animalRepository.findAll()
            let availableEnclosures = try await enclosureRepository.findAvailable()

            let totalAnimalCount = allAnimals.count
            let availableEnclosureCount = availableEnclosures.count
            let sickAnimalCount = allAnimals.filter { $0.status == .sick }.count

            return ZooStatistics(
                totalAnimalCount: totalAnimalCount,
                availableEnclosureCount: availableEnclosureCount,
                sickAnimalCount: sickAnimalCount
            )
        } catch {
            throw StatisticsError.repositoryError(error)
        }
    }
} 