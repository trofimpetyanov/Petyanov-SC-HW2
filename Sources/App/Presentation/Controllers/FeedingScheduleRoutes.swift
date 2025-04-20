import Vapor

struct FeedingScheduleRoutes: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let schedules = routes.grouped("feeding-schedules")

        schedules.get(use: getAllSchedules)
        schedules.get("upcoming", use: getUpcomingSchedules)
        schedules.post(use: createSchedule)
        
        schedules.group(":scheduleID") {
            $0.get(use: getScheduleById)
            $0.post("complete", use: markAsCompleted)
            $0.delete(use: deleteSchedule)
        }
        
        routes.get("animals", ":animalID", "feeding-schedules", use: getSchedulesForAnimal)
    }

    // GET /feeding-schedules
    func getAllSchedules(req: Request) async throws -> [FeedingSchedule] {
        try await req.feedingOrganizationService.getAllFeedingSchedules()
    }
    
    // GET /feeding-schedules/upcoming
    func getUpcomingSchedules(req: Request) async throws -> [FeedingSchedule] {
        try await req.feedingOrganizationService.getUpcomingFeedings()
    }

    // POST /feeding-schedules
    func createSchedule(req: Request) async throws -> FeedingSchedule {
        let input = try req.content.decode(ScheduleFeedingInput.self)
        return try await req.feedingOrganizationService.scheduleFeeding(input: input)
    }

    // GET /feeding-schedules/:scheduleID
    func getScheduleById(req: Request) async throws -> FeedingSchedule {
        guard let scheduleID = req.parameters.get("scheduleID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid schedule ID format")
        }
        guard let schedule = try await req.feedingOrganizationService.getFeedingScheduleById(id: scheduleID) else {
            throw Abort(.notFound, reason: "Schedule with ID \(scheduleID) not found")
        }
        return schedule
    }
    
    // POST /feeding-schedules/:scheduleID/complete
    func markAsCompleted(req: Request) async throws -> HTTPStatus {
        guard let scheduleID = req.parameters.get("scheduleID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid schedule ID format")
        }
        try await req.feedingOrganizationService.markFeedingAsCompleted(scheduleId: scheduleID)
        return .ok
    }
    
    // GET /animals/:animalID/feeding-schedules
    func getSchedulesForAnimal(req: Request) async throws -> [FeedingSchedule] {
         guard let animalID = req.parameters.get("animalID", as: UUID.self) else {
             throw Abort(.badRequest, reason: "Invalid animal ID format")
         }
         return try await req.feedingOrganizationService.getFeedingSchedulesForAnimal(animalId: animalID)
     }
     
    // DELETE /feeding-schedules/:scheduleID
    func deleteSchedule(req: Request) async throws -> HTTPStatus {
        guard let scheduleID = req.parameters.get("scheduleID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid schedule ID format")
        }
        try await req.feedingOrganizationService.deleteFeedingSchedule(id: scheduleID)
        return .noContent
    }
} 