import Vapor

var env = try Environment.detect()
try LoggingSystem.bootstrap(from: &env)

let app = try await Application.make(env) 
do {
    try await configure(app)
} catch {
    app.logger.report(error: error)
    throw error
}
try await app.execute() 

func configure(_ app: Application) async throws {
    app.middleware.use(ErrorMappingMiddleware())
    
    app.http.server.configuration.port = 8080

    // Register Concrete Repositories
    let animalRepo = InMemoryAnimalRepository()
    let enclosureRepo = InMemoryEnclosureRepository()
    let scheduleRepo = InMemoryFeedingScheduleRepository()
    
    app.storage[RepositoryKeys.AnimalRepoKey.self] = animalRepo
    app.storage[RepositoryKeys.EnclosureRepoKey.self] = enclosureRepo
    app.storage[RepositoryKeys.ScheduleRepoKey.self] = scheduleRepo

    // Register Concrete Services
    app.storage[ServiceKeys.AnimalManagementSvcKey.self] = AnimalManagementServiceImpl(
        animalRepository: app.storage[RepositoryKeys.AnimalRepoKey.self]!,
        enclosureRepository: app.storage[RepositoryKeys.EnclosureRepoKey.self]!
    )
    app.storage[ServiceKeys.EnclosureManagementSvcKey.self] = EnclosureManagementServiceImpl(
        enclosureRepository: app.storage[RepositoryKeys.EnclosureRepoKey.self]!,
        animalRepository: app.storage[RepositoryKeys.AnimalRepoKey.self]!
    )
    app.storage[ServiceKeys.AnimalTransferSvcKey.self] = AnimalTransferServiceImpl(
        animalRepository: app.storage[RepositoryKeys.AnimalRepoKey.self]!,
        enclosureRepository: app.storage[RepositoryKeys.EnclosureRepoKey.self]!
    )
    app.storage[ServiceKeys.FeedingOrganizationSvcKey.self] = FeedingOrganizationServiceImpl(
        scheduleRepository: app.storage[RepositoryKeys.ScheduleRepoKey.self]!,
        animalRepository: app.storage[RepositoryKeys.AnimalRepoKey.self]!
    )
    app.storage[ServiceKeys.ZooStatisticsSvcKey.self] = ZooStatisticsServiceImpl(
        animalRepository: app.storage[RepositoryKeys.AnimalRepoKey.self]!,
        enclosureRepository: app.storage[RepositoryKeys.EnclosureRepoKey.self]!
    )

    try routes(app)
}

// Define keys for accessing CONCRETE implementations
struct RepositoryKeys {
    struct AnimalRepoKey: StorageKey { typealias Value = InMemoryAnimalRepository }
    struct EnclosureRepoKey: StorageKey { typealias Value = InMemoryEnclosureRepository }
    struct ScheduleRepoKey: StorageKey { typealias Value = InMemoryFeedingScheduleRepository }
}

struct ServiceKeys {
    struct AnimalManagementSvcKey: StorageKey { typealias Value = AnimalManagementServiceImpl }
    struct EnclosureManagementSvcKey: StorageKey { typealias Value = EnclosureManagementServiceImpl }
    struct AnimalTransferSvcKey: StorageKey { typealias Value = AnimalTransferServiceImpl }
    struct FeedingOrganizationSvcKey: StorageKey { typealias Value = FeedingOrganizationServiceImpl }
    struct ZooStatisticsSvcKey: StorageKey { typealias Value = ZooStatisticsServiceImpl }
}

// Helper extension fetches concrete type and returns as protocol type
extension Request {
    var animalManagementService: AnimalManagementService { application.storage[ServiceKeys.AnimalManagementSvcKey.self]! }
    var enclosureManagementService: EnclosureManagementService { application.storage[ServiceKeys.EnclosureManagementSvcKey.self]! }
    var animalTransferService: AnimalTransferService { application.storage[ServiceKeys.AnimalTransferSvcKey.self]! }
    var feedingOrganizationService: FeedingOrganizationService { application.storage[ServiceKeys.FeedingOrganizationSvcKey.self]! }
    var zooStatisticsService: ZooStatisticsService { application.storage[ServiceKeys.ZooStatisticsSvcKey.self]! }
}

func routes(_ app: Application) throws {
    try app.register(collection: AnimalRoutes())
    try app.register(collection: EnclosureRoutes())
    try app.register(collection: AnimalTransferRoutes())
    try app.register(collection: FeedingScheduleRoutes())
    try app.register(collection: StatisticsRoutes())
    
    app.get { req async -> String in 
        "It works!"
    }

    app.get("hello") { req async -> String in 
        "Hello, world!"
    }
}