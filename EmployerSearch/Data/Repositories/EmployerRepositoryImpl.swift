import Foundation
import Combine

/// Implementation of EmployerRepository with caching
final class EmployerRepositoryImpl: EmployerRepository {
    private let apiService: EmployerAPIService
    private let cacheManager: CacheManager

    init(
        apiService: EmployerAPIService = MockEmployerAPIService(),
        cacheManager: CacheManager = .shared
    ) {
        self.apiService = apiService
        self.cacheManager = cacheManager
    }

    func searchEmployers(query: String) -> AnyPublisher<[Employer], Error> {
        // Try cache first
        if let cachedEmployers = cacheManager.loadEmployers() {
            return Just(filterEmployers(cachedEmployers, query: query))
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        // Fetch from API and cache
        return apiService.fetchEmployers()
            .handleEvents(receiveOutput: { [weak self] employers in
                self?.cacheManager.save(employers: employers)
            })
            .map { employers in
                self.filterEmployers(employers, query: query)
            }
            .eraseToAnyPublisher()
    }

    func clearExpiredCache() {
        if cacheManager.isExpired() {
            cacheManager.clearCache()
        }
    }

    private func filterEmployers(_ employers: [Employer], query: String) -> [Employer] {
        guard !query.isEmpty else { return employers }
        return employers.filter { $0.matches(query: query) }
    }
}
