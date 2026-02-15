import Foundation
import Combine

/// Protocol for employer data operations
protocol EmployerRepository {
    /// Search for employers matching the query
    /// Results are cached and served from cache if available and not expired
    func searchEmployers(query: String) -> AnyPublisher<[Employer], Error>

    /// Clear expired cache entries
    func clearExpiredCache()
}
