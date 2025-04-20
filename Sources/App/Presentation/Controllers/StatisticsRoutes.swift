import Vapor

struct StatisticsRoutes: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let statistics = routes.grouped("statistics")
        statistics.get(use: getStatistics)
    }

    // GET /statistics
    func getStatistics(req: Request) async throws -> ZooStatistics {
        try await req.zooStatisticsService.getStatistics()
    }
} 