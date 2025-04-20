import Vapor

struct AnimalTransferRoutes: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let transfers = routes.grouped("animals", ":animalID", "move")
        
        transfers.post(use: moveAnimal)
    }

    func moveAnimal(req: Request) async throws -> HTTPStatus {
        guard let animalIDString = req.parameters.get("animalID") else {
            throw Abort(.badRequest, reason: "Missing animal ID parameter")
        }

        struct MoveAnimalBody: Content {
             let toEnclosureId: String
        }
        let body = try req.content.decode(MoveAnimalBody.self)
        
        let input = MoveAnimalInput(animalId: animalIDString, toEnclosureId: body.toEnclosureId)
        
        try await req.animalTransferService.moveAnimal(input: input)
        
        return .ok
    }
}
