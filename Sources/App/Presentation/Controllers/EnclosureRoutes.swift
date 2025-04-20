import Vapor

struct EnclosureRoutes: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let enclosures = routes.grouped("enclosures")

        enclosures.get(use: getAllEnclosures)
        enclosures.get("available", use: getAvailableEnclosures)
        enclosures.post(use: createEnclosure)
        
        enclosures.group(":enclosureID") {
            $0.get(use: getEnclosureById)
            $0.delete(use: deleteEnclosure)
            $0.get("animals", use: getAnimalsInEnclosure)
        }
    }

    // GET /enclosures
    func getAllEnclosures(req: Request) async throws -> [Enclosure] {
        try await req.enclosureManagementService.getAllEnclosures()
    }
    
    // GET /enclosures/available
    func getAvailableEnclosures(req: Request) async throws -> [Enclosure] {
        try await req.enclosureManagementService.getAvailableEnclosures()
    }

    // POST /enclosures
    func createEnclosure(req: Request) async throws -> Enclosure {
        let input = try req.content.decode(AddEnclosureInput.self)
        return try await req.enclosureManagementService.addEnclosure(input: input)
    }

    // GET /enclosures/:enclosureID
    func getEnclosureById(req: Request) async throws -> Enclosure {
        guard let enclosureID = req.parameters.get("enclosureID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid enclosure ID format")
        }
        guard let enclosure = try await req.enclosureManagementService.getEnclosureById(id: enclosureID) else {
            throw Abort(.notFound, reason: "Enclosure with ID \(enclosureID) not found")
        }
        return enclosure
    }
    
    // DELETE /enclosures/:enclosureID
    func deleteEnclosure(req: Request) async throws -> HTTPStatus {
        guard let enclosureID = req.parameters.get("enclosureID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid enclosure ID format")
        }
        try await req.enclosureManagementService.removeEnclosure(id: enclosureID)
        return .noContent
    }
    
    // GET /enclosures/:enclosureID/animals
    func getAnimalsInEnclosure(req: Request) async throws -> [Animal] {
         guard let enclosureID = req.parameters.get("enclosureID", as: UUID.self) else {
             throw Abort(.badRequest, reason: "Invalid enclosure ID format")
         }
         return try await req.animalManagementService.getAnimalsInEnclosure(enclosureId: enclosureID)
     }
} 