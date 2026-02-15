import Foundation
import Combine

/// View model for employer search
final class SearchViewModel: ObservableObject {
    @Published var searchQuery = ""
    @Published var employers: [Employer] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedMinDiscount: Int? = nil
    @Published var selectedSort: SortOption = .nameAsc
    @Published var showSortMenu: Bool = false
    @Published var showFavoritesOnly: Bool = false

    private let searchUseCase: SearchEmployersUseCase
    private var cancellables = Set<AnyCancellable>()

    init(searchUseCase: SearchEmployersUseCase) {
        self.searchUseCase = searchUseCase
        setupSearchObserver()
        setupFilterObserver()
        setupSortObserver()
        setupFavoritesObserver()
    }

    private func setupSearchObserver() {
        $searchQuery
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] query in
                self?.performSearch(query: query)
            }
            .store(in: &cancellables)
    }

    private func setupFilterObserver() {
        $selectedMinDiscount
            .dropFirst()
            .sink { [weak self] _ in
                self?.performSearch(query: self?.searchQuery ?? "")
            }
            .store(in: &cancellables)
    }

    private func setupSortObserver() {
        $selectedSort
            .dropFirst()
            .sink { [weak self] _ in
                self?.performSearch(query: self?.searchQuery ?? "")
            }
            .store(in: &cancellables)
    }

    private func setupFavoritesObserver() {
        $showFavoritesOnly
            .dropFirst()
            .sink { [weak self] _ in
                self?.performSearch(query: self?.searchQuery ?? "")
            }
            .store(in: &cancellables)
    }

    private func performSearch(query: String) {
        isLoading = true
        errorMessage = nil

        searchUseCase.execute(
            query: query,
            minDiscount: selectedMinDiscount,
            sortBy: selectedSort
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            },
            receiveValue: { [weak self] employers in
                guard let self = self else { return }

                if self.showFavoritesOnly {
                    self.employers = employers.filter {
                        FavoritesManager.shared.isFavorite(employerID: $0.id)
                    }
                } else {
                    self.employers = employers
                }
            }
        )
        .store(in: &cancellables)
    }

    func retry() {
        performSearch(query: searchQuery)
    }

    func selectFilter(_ minDiscount: Int?) {
        selectedMinDiscount = minDiscount
    }

    func selectSort(_ sort: SortOption) {
        selectedSort = sort
        showSortMenu = false
    }
}
