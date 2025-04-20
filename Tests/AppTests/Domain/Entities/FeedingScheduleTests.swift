import XCTest
@testable import App
import Foundation

final class FeedingScheduleTests: XCTestCase {

    private func createTestSchedule(animalId: EntityID = UUID(), feedingTime: Date = Date(), foodType: FoodType = FoodType("Hay")!, isCompleted: Bool = false) -> FeedingSchedule {
        return FeedingSchedule(
            animalId: animalId,
            feedingTime: feedingTime,
            foodType: foodType,
            isCompleted: isCompleted
        )
    }

    func testFeedingScheduleInitialization() {
        let animalId = UUID()
        let time = Date()
        let food = FoodType("Meat")!
        let schedule = FeedingSchedule(id: UUID(), animalId: animalId, feedingTime: time, foodType: food, isCompleted: false)
        
        XCTAssertNotNil(schedule.id)
        XCTAssertEqual(schedule.animalId, animalId)
        XCTAssertEqual(schedule.feedingTime, time)
        XCTAssertEqual(schedule.foodType, food)
        XCTAssertFalse(schedule.isCompleted)
    }

    func testMarkAsCompleted() {
        var schedule = createTestSchedule(isCompleted: false)
        XCTAssertFalse(schedule.isCompleted, "Schedule should initially be incomplete")
        
        schedule.markAsCompleted()
        XCTAssertTrue(schedule.isCompleted, "Schedule should be completed after calling markAsCompleted()")

        let currentState = schedule.isCompleted
        schedule.markAsCompleted()
        XCTAssertEqual(schedule.isCompleted, currentState, "Calling markAsCompleted() again should not change state")
    }

    func testUpdateSchedule() {
        var schedule = createTestSchedule()
        let originalTime = schedule.feedingTime
        let originalFood = schedule.foodType

        let newTime = originalTime.addingTimeInterval(3600) 
        let newFood = FoodType("Fish")!

        schedule.update(newTime: newTime)
        XCTAssertEqual(schedule.feedingTime, newTime, "Feeding time should be updated")
        XCTAssertEqual(schedule.foodType, originalFood, "Food type should remain unchanged")

        schedule.update(newFoodType: newFood)
        XCTAssertEqual(schedule.feedingTime, newTime, "Feeding time should remain unchanged")
        XCTAssertEqual(schedule.foodType, newFood, "Food type should be updated")

        let evenNewerTime = newTime.addingTimeInterval(3600)
        let evenNewerFood = FoodType("Berries")!
        schedule.update(newTime: evenNewerTime, newFoodType: evenNewerFood)
        XCTAssertEqual(schedule.feedingTime, evenNewerTime, "Feeding time should be updated again")
        XCTAssertEqual(schedule.foodType, evenNewerFood, "Food type should be updated again")

        let lastTime = schedule.feedingTime
        let lastFood = schedule.foodType
        schedule.update(newTime: nil, newFoodType: nil)
        XCTAssertEqual(schedule.feedingTime, lastTime, "Feeding time should not change when nil is passed")
        XCTAssertEqual(schedule.foodType, lastFood, "Food type should not change when nil is passed")
    }
} 
