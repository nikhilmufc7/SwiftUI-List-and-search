import Foundation
import Combine
@testable import EmployerSearch

final class MockEmployerRepository: EmployerRepository {
    var employers: [Employer] = [
        Employer(id: 1, name: "ABC Company", place: "AMSTERDAM", discountPercentage: 20),
        Employer(id: 2, name: "Middle Corp", place: "UTRECHT", discountPercentage: 15),
        Employer(id: 3, name: "Zebra Corp", place: "ROTTERDAM", discountPercentage: 10),
        Employer(id: 4, name: "Amsterdam Tech", place: "AMSTERDAM", discountPercentage: 25),
        Employer(id: 5, name: "Test Company", place: "EINDHOVEN", discountPercentage: 5)
    ]
    var shouldFail = false
    var error: Error = NSError(domain: "test", code: -1)

    func searchEmployers(query: String) -> AnyPublisher<[Employer], Error> {
        if shouldFail {
            return Fail(error: error).eraseToAnyPublisher()
        }

        let filtered = query.isEmpty ? employers : employers.filter { $0.matches(query: query) }
        return Just(filtered)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func clearExpiredCache() {
        // No-op for tests
    }
}
