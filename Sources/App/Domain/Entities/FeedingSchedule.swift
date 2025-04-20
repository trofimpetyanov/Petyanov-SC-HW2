import Foundation
import Vapor

struct FeedingSchedule: Content, Equatable, Identifiable {
    let id: EntityID
    let animalId: EntityID
    var feedingTime: Date
    var foodType: FoodType
    var isCompleted: Bool

    init(
        id: EntityID = EntityID(),
        animalId: EntityID,
        feedingTime: Date,
        foodType: FoodType,
        isCompleted: Bool = false
    ) {
        self.id = id
        self.animalId = animalId
        self.feedingTime = feedingTime
        self.foodType = foodType
        self.isCompleted = isCompleted
    }

    mutating func update(newTime: Date? = nil, newFoodType: FoodType? = nil) {
        if let newTime = newTime {
            self.feedingTime = newTime
        }
        if let newFoodType = newFoodType {
            self.foodType = newFoodType
        }
    }

    mutating func markAsCompleted() {
        guard !isCompleted else { return }
        self.isCompleted = true
    }
} 