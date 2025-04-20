import Foundation
import Vapor

struct AddEnclosureInput: Content {
    let type: String
    let size: String
    let maxCapacity: Int

    public init(type: String, size: String, maxCapacity: Int) {
        self.type = type
        self.size = size
        self.maxCapacity = maxCapacity
    }
}

protocol EnclosureManagementService {
    func addEnclosure(input: AddEnclosureInput) async throws -> Enclosure
    func removeEnclosure(id: EntityID) async throws
    func getEnclosureById(id: EntityID) async throws -> Enclosure?
    func getAllEnclosures() async throws -> [Enclosure]
    func getAvailableEnclosures() async throws -> [Enclosure]
} 
