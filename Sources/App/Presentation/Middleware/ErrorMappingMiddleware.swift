import Vapor

final class ErrorMappingMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        do {
            return try await next.respond(to: request)
        } catch let error as AbortError {
            throw error
        } catch let error as FeedingOrganizationError {
            let status: HTTPResponseStatus
            switch error {
            case .scheduleNotFound, .animalNotFound:
                status = .notFound
            case .invalidInput:
                status = .badRequest
            case .alreadyCompleted:
                status = .conflict
            case .repositoryError:
                status = .internalServerError
            }
            throw Abort(status, reason: String(reflecting: error))
        } catch let error as AnimalTransferError {
            let status: HTTPResponseStatus
            switch error {
            case .animalNotFound, .destinationEnclosureNotFound:
                status = .notFound
            case .invalidInput:
                status = .badRequest
            case .sameEnclosure, .transferFailed:
                status = .conflict
            case .repositoryError:
                status = .internalServerError
            }
            throw Abort(status, reason: String(reflecting: error))
        } catch let error as EnclosureManagementError {
             let status: HTTPResponseStatus
             switch error {
             case .enclosureNotFound:
                  status = .notFound
             case .invalidInput:
                  status = .badRequest
             case .repositoryError:
                  status = .internalServerError
             case .enclosureNotEmpty:
                  status = .conflict
             }
             throw Abort(status, reason: String(reflecting: error))
        } catch let error as AnimalManagementError {
             let status: HTTPResponseStatus
             switch error {
             case .animalNotFound:
                  status = .notFound
             case .invalidInput:
                  status = .badRequest
             case .repositoryError:
                  status = .internalServerError
             case .enclosureNotFound:
                  status = .badRequest
             }
             throw Abort(status, reason: String(reflecting: error))
         } catch let error as EnclosureError {
             let status: HTTPResponseStatus
             switch error {
             case .enclosureFull, .animalAlreadyPresent:
                  status = .conflict
             case .animalNotFound:
                  status = .notFound
             }
            throw Abort(status, reason: String(reflecting: error))
        } catch {
            request.logger.error("Unhandled error: \(error)")
            throw Abort(.internalServerError, reason: "An unexpected error occurred.")
        }
    }
}
