import Vapor

final class CustomErrorMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        return next.respond(to: request).flatMapErrorThrowing { error in
            let status: HTTPResponseStatus
            let reason: String
            var headers: HTTPHeaders = [:]

            switch error {
            case let appError as AnimalManagementError:
                (status, reason) = self.mapAnimalManagementError(appError)
            case let appError as EnclosureManagementError:
                (status, reason) = self.mapEnclosureManagementError(appError)
            case let appError as AnimalTransferError:
                (status, reason) = self.mapAnimalTransferError(appError)
            case let appError as FeedingOrganizationError:
                (status, reason) = self.mapFeedingOrganizationError(appError)
            case let appError as StatisticsError:
                (status, reason) = self.mapStatisticsError(appError)
            
            case let domainError as EnclosureError:
                (status, reason) = self.mapEnclosureError(domainError)

            case let abort as AbortError:
                status = abort.status
                reason = abort.reason
                headers = abort.headers
                request.logger.report(error: error)
                
            default:
                status = .internalServerError
                reason = request.application.environment == .development ? String(reflecting: error) : "Something went wrong."
                request.logger.report(error: error)
            }

            request.logger.error("\(error) -> \(status.code) \(reason)")

            let response = Response(status: status, headers: headers)
            do {
                struct ErrorResponse: Codable {
                    var error: Bool = true
                    var reason: String
                }
                let errorResponse = ErrorResponse(reason: reason)
                response.body = try .init(data: JSONEncoder().encode(errorResponse), byteBufferAllocator: request.byteBufferAllocator)
                response.headers.replaceOrAdd(name: .contentType, value: "application/json; charset=utf-8")
            } catch {
                 response.body = .init(string: "{\"error\":true,\"reason\":\"Failed to encode error response.\"}")
                 response.headers.replaceOrAdd(name: .contentType, value: "application/json; charset=utf-8")
            }
            return response
        }
    }

    private func mapAnimalManagementError(_ error: AnimalManagementError) -> (HTTPResponseStatus, String) {
        switch error {
        case .invalidInput(let msg): return (.badRequest, msg)
        case .animalNotFound: return (.notFound, "Animal not found")
        case .enclosureNotFound: return (.notFound, "Enclosure not found")
        case .repositoryError: return (.internalServerError, "Database error occurred")
        }
    }

    private func mapEnclosureManagementError(_ error: EnclosureManagementError) -> (HTTPResponseStatus, String) {
        switch error {
        case .invalidInput(let msg): return (.badRequest, msg)
        case .enclosureNotFound: return (.notFound, "Enclosure not found")
        case .enclosureNotEmpty: return (.conflict, "Cannot remove non-empty enclosure")
        case .repositoryError: return (.internalServerError, "Database error occurred")
        }
    }

    private func mapAnimalTransferError(_ error: AnimalTransferError) -> (HTTPResponseStatus, String) {
        switch error {
        case .invalidInput(let msg): return (.badRequest, msg)
        case .animalNotFound: return (.notFound, "Animal not found")
        case .destinationEnclosureNotFound: return (.notFound, "Destination enclosure not found")
        case .sameEnclosure: return (.badRequest, "Animal is already in the target enclosure")
        case .transferFailed(let underlyingError):
            if let enclosureError = underlyingError as? EnclosureError {
                return mapEnclosureError(enclosureError)
            } else {
                 return (.conflict, "Transfer failed due to an enclosure issue")
            }
        case .repositoryError: return (.internalServerError, "Database error occurred")
        }
    }

    private func mapFeedingOrganizationError(_ error: FeedingOrganizationError) -> (HTTPResponseStatus, String) {
        switch error {
        case .invalidInput(let msg): return (.badRequest, msg)
        case .animalNotFound: return (.notFound, "Animal not found")
        case .scheduleNotFound: return (.notFound, "Feeding schedule not found")
        case .alreadyCompleted: return (.conflict, "Feeding schedule already completed")
        case .repositoryError: return (.internalServerError, "Database error occurred")
        }
    }
    
    private func mapStatisticsError(_ error: StatisticsError) -> (HTTPResponseStatus, String) {
        switch error {
        case .repositoryError: return (.internalServerError, "Database error occurred while fetching statistics")
        }
    }

    private func mapEnclosureError(_ error: EnclosureError) -> (HTTPResponseStatus, String) {
        switch error {
        case .enclosureFull: return (.conflict, "Enclosure is full")
        case .animalAlreadyPresent: return (.conflict, "Animal is already in this enclosure")
        case .animalNotFound: return (.notFound, "Animal not found in this enclosure for removal")
        }
    }
} 