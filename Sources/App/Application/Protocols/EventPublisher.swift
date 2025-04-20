import Foundation

protocol DomainEvent {
    var eventId: UUID { get }
    var timestamp: Date { get }
}

extension AnimalMovedEvent: DomainEvent {}
extension FeedingTimeEvent: DomainEvent {}

protocol EventPublisher: Sendable {
    func publish<T: DomainEvent>(_ event: T) async
} 