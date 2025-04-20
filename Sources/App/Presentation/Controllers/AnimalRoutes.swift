import Vapor

struct AnimalRoutes: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let animals = routes.grouped("animals")

        // GET /animals
        animals.get(use: getAllAnimals)
        
        // POST /animals
        animals.post(use: createAnimal)
        
        // GET /animals/:animalID
        animals.group(":animalID") {
            $0.get(use: getAnimalById)
            $0.delete(use: deleteAnimal)
        }
    }

    // GET /animals
    func getAllAnimals(req: Request) async throws -> [Animal] {
        try await req.animalManagementService.getAllAnimals()
    }

    // POST /animals
    func createAnimal(req: Request) async throws -> Animal {
        let input = try req.content.decode(AddAnimalInput.self)
        return try await req.animalManagementService.addAnimal(input: input)
    }

    // GET /animals/:animalID
    func getAnimalById(req: Request) async throws -> Animal {
        guard let animalID = req.parameters.get("animalID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid animal ID format")
        }
        guard let animal = try await req.animalManagementService.getAnimalById(id: animalID) else {
            throw Abort(.notFound, reason: "Animal with ID \(animalID) not found")
        }
        return animal
    }
    
    // DELETE /animals/:animalID
    func deleteAnimal(req: Request) async throws -> HTTPStatus {
        guard let animalID = req.parameters.get("animalID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid animal ID format")
        }
        try await req.animalManagementService.removeAnimal(id: animalID)
        return .noContent // 204 No Content
    }
} 