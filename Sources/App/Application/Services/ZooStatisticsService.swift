import Foundation
import Vapor

struct ZooStatistics: Content {
    let totalAnimalCount: Int
    let availableEnclosureCount: Int
    let sickAnimalCount: Int
}

protocol ZooStatisticsService {
    func getStatistics() async throws -> ZooStatistics
}