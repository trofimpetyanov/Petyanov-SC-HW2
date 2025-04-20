import Foundation
import Vapor

struct ScheduleFeedingInput: Content {
    let animalId: String
    let feedingTime: Date
    let foodType: String
    
    public init(animalId: String, feedingTime: Date, foodType: String) {
        self.animalId = animalId
        self.feedingTime = feedingTime
        self.foodType = foodType
    }
}

protocol FeedingOrganizationService {
    func scheduleFeeding(input: ScheduleFeedingInput) async throws -> FeedingSchedule
    func markFeedingAsCompleted(scheduleId: EntityID) async throws
    func getFeedingScheduleById(id: EntityID) async throws -> FeedingSchedule?
    func getAllFeedingSchedules() async throws -> [FeedingSchedule]
    func getUpcomingFeedings() async throws -> [FeedingSchedule]
    func getFeedingSchedulesForAnimal(animalId: EntityID) async throws -> [FeedingSchedule]
    func deleteFeedingSchedule(id: EntityID) async throws
} 