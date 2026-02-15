import Foundation
import Combine

/// Sort options for employer search results
enum SortOption: String, CaseIterable {
    case nameAsc = "Name (A-Z)"
    case nameDesc = "Name (Z-A)"
    case discountDesc = "Discount (High to Low)"
    case discountAsc = "Discount (Low to High)"
    case locationAsc = "Location (A-Z)"
}

/// Use case for searching and filtering employers
final class SearchEmployersUseCase {
    private let repository: EmployerRepository

    init(repository: EmployerRepository) {
        self.repository = repository
    }

    /// Execute search with optional filtering and sorting
    func execute(
        query: String,
        minDiscount: Int? = nil,
        sortBy: SortOption = .nameAsc
    ) -> AnyPublisher<[Employer], Error> {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)

        return repository.searchEmployers(query: trimmedQuery)
            .map { employers in
                // Filter by minimum discount
                let filtered = employers.filter { employer in
                    guard let minDiscount = minDiscount else { return true }
                    return employer.discountPercentage >= minDiscount
                }

                // Sort
                return self.sort(employers: filtered, by: sortBy)
            }
            .eraseToAnyPublisher()
    }

    /// Sort employers based on selected option
    private func sort(employers: [Employer], by option: SortOption) -> [Employer] {
        switch option {
        case .nameAsc:
            return employers.sorted { $0.name < $1.name }
        case .nameDesc:
            return employers.sorted { $0.name > $1.name }
        case .discountDesc:
            return employers.sorted { $0.discountPercentage > $1.discountPercentage }
        case .discountAsc:
            return employers.sorted { $0.discountPercentage < $1.discountPercentage }
        case .locationAsc:
            return employers.sorted { $0.place < $1.place }
        }
    }
}
