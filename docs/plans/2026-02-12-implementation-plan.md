# Visual Polish & Features Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add professional design system, filtering/sorting, favorites, and detail screen to the Employer Search iOS app.

**Architecture:** Clean Architecture + MVVM maintained. Design system in Presentation layer, FavoritesManager in Infrastructure, sorting/filtering logic in Domain layer.

**Tech Stack:** SwiftUI, Combine, iOS 17.0+, UserDefaults for favorites persistence

---

## Task 1: Design System - Colors

**Files:**
- Create: `EmployerSearch/Presentation/DesignSystem/Colors.swift`

**Step 1: Create DesignSystem folder structure**

```bash
mkdir -p EmployerSearch/Presentation/DesignSystem
mkdir -p EmployerSearch/Presentation/DesignSystem/Components
```

**Step 2: Create Colors.swift**

```swift
import SwiftUI

/// Design system color tokens
enum AppColors {
    // MARK: - Brand Colors
    static let primary = Color(hex: "007AFF")
    static let accent = Color(hex: "5AC8FA")

    // MARK: - Semantic Colors (for discount tiers)
    static let success = Color(hex: "34C759")    // 15%+ discounts
    static let warning = Color(hex: "FF9500")    // 10-14% discounts
    static let info = Color(hex: "5856D6")       // 5-9% discounts
    static let gray = Color(hex: "8E8E93")       // <5% discounts

    // MARK: - UI Colors (Dynamic for dark mode)
    static let background = Color(UIColor.systemBackground)
    static let cardBackground = Color(UIColor.secondarySystemBackground)
    static let border = Color(UIColor.tertiarySystemFill)
    static let textPrimary = Color(UIColor.label)
    static let textSecondary = Color(UIColor.secondaryLabel)

    // MARK: - Favorites
    static let favorite = Color(hex: "FFD700")   // Gold
}

// MARK: - Color Extension for Hex
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Discount Color Helper
extension AppColors {
    static func discountColor(for percentage: Int) -> Color {
        switch percentage {
        case 15...:
            return success
        case 10..<15:
            return warning
        case 5..<10:
            return info
        default:
            return gray
        }
    }
}
```

**Step 3: Commit**

```bash
git add EmployerSearch/Presentation/DesignSystem/Colors.swift
git commit -m "feat: add design system color tokens"
```

---

## Task 2: Design System - Typography

**Files:**
- Create: `EmployerSearch/Presentation/DesignSystem/Typography.swift`

**Step 1: Create Typography.swift**

```swift
import SwiftUI

/// Design system typography styles
enum AppTypography {
    // MARK: - Text Styles

    /// Title: SF Pro Display, 28pt, Bold
    static let title: Font = .system(size: 28, weight: .bold, design: .default)

    /// Headline: SF Pro Text, 17pt, Semibold
    static let headline: Font = .system(size: 17, weight: .semibold, design: .default)

    /// Body: SF Pro Text, 15pt, Regular
    static let body: Font = .system(size: 15, weight: .regular, design: .default)

    /// Caption: SF Pro Text, 13pt, Regular
    static let caption: Font = .system(size: 13, weight: .regular, design: .default)

    /// Badge: SF Pro Rounded, 20pt, Bold
    static let badge: Font = .system(size: 20, weight: .bold, design: .rounded)

    /// Large Badge: SF Pro Rounded, 36pt, Bold (for detail view)
    static let largeBadge: Font = .system(size: 36, weight: .bold, design: .rounded)
}
```

**Step 2: Commit**

```bash
git add EmployerSearch/Presentation/DesignSystem/Typography.swift
git commit -m "feat: add design system typography styles"
```

---

## Task 3: Design System - Spacing

**Files:**
- Create: `EmployerSearch/Presentation/DesignSystem/Spacing.swift`

**Step 1: Create Spacing.swift**

```swift
import Foundation

/// Design system spacing constants (8pt grid)
enum AppSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48

    // MARK: - Component Specific
    static let cardCornerRadius: CGFloat = 12
    static let cardPadding: CGFloat = md
    static let badgeSize: CGFloat = 56
    static let largeBadgeSize: CGFloat = 120
}
```

**Step 2: Commit**

```bash
git add EmployerSearch/Presentation/DesignSystem/Spacing.swift
git commit -m "feat: add design system spacing constants"
```

---

## Task 4: Design System - Badge Component

**Files:**
- Create: `EmployerSearch/Presentation/DesignSystem/Components/DiscountBadge.swift`

**Step 1: Create DiscountBadge.swift**

```swift
import SwiftUI

/// Reusable discount badge component
struct DiscountBadge: View {
    let percentage: Int
    let size: CGFloat

    init(percentage: Int, size: CGFloat = AppSpacing.badgeSize) {
        self.percentage = percentage
        self.size = size
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(AppColors.discountColor(for: percentage))
                .frame(width: size, height: size)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)

            VStack(spacing: 0) {
                Text("\(percentage)%")
                    .font(size == AppSpacing.badgeSize ? AppTypography.badge : AppTypography.largeBadge)
                    .foregroundColor(.white)
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        DiscountBadge(percentage: 25)
        DiscountBadge(percentage: 12)
        DiscountBadge(percentage: 7)
        DiscountBadge(percentage: 3)
    }
    .padding()
}
```

**Step 2: Test in preview**

Run: Open DiscountBadge.swift in Xcode and view live preview
Expected: See 4 badges with different colors based on discount tiers

**Step 3: Commit**

```bash
git add EmployerSearch/Presentation/DesignSystem/Components/DiscountBadge.swift
git commit -m "feat: add reusable discount badge component"
```

---

## Task 5: Update EmployerRowView with New Design

**Files:**
- Modify: `EmployerSearch/Presentation/Common/Views/EmployerRowView.swift`

**Step 1: Read current EmployerRowView**

Read: `EmployerSearch/Presentation/Common/Views/EmployerRowView.swift`

**Step 2: Replace with enhanced design**

```swift
import SwiftUI

struct EmployerRowView: View {
    let employer: Employer
    @State private var isFavorite: Bool

    init(employer: Employer) {
        self.employer = employer
        self._isFavorite = State(initialValue: FavoritesManager.shared.isFavorite(employerID: employer.id))
    }

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            // Company info
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(employer.name)
                    .font(AppTypography.headline)
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(2)

                HStack(spacing: 4) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)

                    Text(employer.place)
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
            }

            Spacer()

            // Favorite button
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    FavoritesManager.shared.toggleFavorite(employerID: employer.id)
                    isFavorite.toggle()
                }
            } label: {
                Image(systemName: isFavorite ? "star.fill" : "star")
                    .font(.system(size: 20))
                    .foregroundColor(isFavorite ? AppColors.favorite : AppColors.textSecondary)
            }
            .buttonStyle(.plain)

            // Discount badge
            DiscountBadge(percentage: employer.discountPercentage)
        }
        .padding(AppSpacing.cardPadding)
        .background(AppColors.cardBackground)
        .cornerRadius(AppSpacing.cardCornerRadius)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    VStack(spacing: 16) {
        EmployerRowView(employer: Employer(id: 1, name: "Test Company", place: "Amsterdam", discountPercentage: 25))
        EmployerRowView(employer: Employer(id: 2, name: "Another Corp with Long Name", place: "Rotterdam", discountPercentage: 12))
        EmployerRowView(employer: Employer(id: 3, name: "Small Business", place: "Utrecht", discountPercentage: 5))
    }
    .padding()
}
```

**Step 3: Build and preview**

Run: `⌘+B` to build
Expected: Build succeeds (will show FavoritesManager error - we'll fix in next task)

**Step 4: Commit**

```bash
git add EmployerSearch/Presentation/Common/Views/EmployerRowView.swift
git commit -m "feat: enhance employer card design with new styling"
```

---

## Task 6: Implement FavoritesManager

**Files:**
- Create: `EmployerSearch/Infrastructure/Storage/FavoritesManager.swift`

**Step 1: Create Storage folder**

```bash
mkdir -p EmployerSearch/Infrastructure/Storage
```

**Step 2: Create FavoritesManager.swift**

```swift
import Foundation

/// Manages favorite employers persistence
final class FavoritesManager {
    static let shared = FavoritesManager()

    private let key = "com.employersearch.favorites"
    private let defaults = UserDefaults.standard

    private init() {}

    /// Toggle favorite status for an employer
    func toggleFavorite(employerID: Int) {
        var favorites = getFavoriteIDs()
        if favorites.contains(employerID) {
            favorites.remove(employerID)
        } else {
            favorites.insert(employerID)
        }
        saveFavorites(favorites)
    }

    /// Check if employer is favorited
    func isFavorite(employerID: Int) -> Bool {
        return getFavoriteIDs().contains(employerID)
    }

    /// Get all favorite employer IDs
    func getFavoriteIDs() -> Set<Int> {
        guard let data = defaults.data(forKey: key),
              let ids = try? JSONDecoder().decode(Set<Int>.self, from: data) else {
            return []
        }
        return ids
    }

    /// Save favorites to UserDefaults
    private func saveFavorites(_ favorites: Set<Int>) {
        if let data = try? JSONEncoder().encode(favorites) {
            defaults.set(data, forKey: key)
        }
    }

    /// Clear all favorites (for testing)
    func clearAllFavorites() {
        defaults.removeObject(forKey: key)
    }
}
```

**Step 3: Build to verify**

Run: `⌘+B`
Expected: Build succeeds, no errors

**Step 4: Commit**

```bash
git add EmployerSearch/Infrastructure/Storage/FavoritesManager.swift
git commit -m "feat: add favorites persistence manager"
```

---

## Task 7: Add SortOption to Domain

**Files:**
- Modify: `EmployerSearch/Domain/UseCases/SearchEmployersUseCase.swift`

**Step 1: Read current SearchEmployersUseCase**

Read: `EmployerSearch/Domain/UseCases/SearchEmployersUseCase.swift`

**Step 2: Add SortOption enum and update use case**

```swift
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
            .map { [weak self] employers in
                guard let self = self else { return [] }

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
```

**Step 3: Build to verify**

Run: `⌘+B`
Expected: Build succeeds

**Step 4: Commit**

```bash
git add EmployerSearch/Domain/UseCases/SearchEmployersUseCase.swift
git commit -m "feat: add sorting and filtering to search use case"
```

---

## Task 8: Write Tests for Sorting and Filtering

**Files:**
- Modify: `EmployerSearchTests/Domain/SearchEmployersUseCaseTests.swift`

**Step 1: Read current test file**

Read: `EmployerSearchTests/Domain/SearchEmployersUseCaseTests.swift`

**Step 2: Add comprehensive tests**

```swift
import XCTest
import Combine
@testable import EmployerSearch

final class SearchEmployersUseCaseTests: XCTestCase {
    var sut: SearchEmployersUseCase!
    var mockRepository: MockEmployerRepository!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockRepository = MockEmployerRepository()
        sut = SearchEmployersUseCase(repository: mockRepository)
        cancellables = []
    }

    override func tearDown() {
        cancellables = nil
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    // MARK: - Sorting Tests

    func testSortByNameAscending() {
        let expectation = expectation(description: "Sort by name ascending")

        sut.execute(query: "", sortBy: .nameAsc)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { employers in
                XCTAssertEqual(employers.first?.name, "ABC Company")
                XCTAssertEqual(employers.last?.name, "Zebra Corp")
                expectation.fulfill()
            })
            .store(in: &cancellables)

        waitForExpectations(timeout: 1.0)
    }

    func testSortByNameDescending() {
        let expectation = expectation(description: "Sort by name descending")

        sut.execute(query: "", sortBy: .nameDesc)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { employers in
                XCTAssertEqual(employers.first?.name, "Zebra Corp")
                XCTAssertEqual(employers.last?.name, "ABC Company")
                expectation.fulfill()
            })
            .store(in: &cancellables)

        waitForExpectations(timeout: 1.0)
    }

    func testSortByDiscountDescending() {
        let expectation = expectation(description: "Sort by discount descending")

        sut.execute(query: "", sortBy: .discountDesc)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { employers in
                XCTAssertGreaterThanOrEqual(employers.first!.discountPercentage,
                                           employers.last!.discountPercentage)
                expectation.fulfill()
            })
            .store(in: &cancellables)

        waitForExpectations(timeout: 1.0)
    }

    func testSortByLocationAscending() {
        let expectation = expectation(description: "Sort by location ascending")

        sut.execute(query: "", sortBy: .locationAsc)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { employers in
                for i in 0..<employers.count-1 {
                    XCTAssertLessThanOrEqual(employers[i].place, employers[i+1].place)
                }
                expectation.fulfill()
            })
            .store(in: &cancellables)

        waitForExpectations(timeout: 1.0)
    }

    // MARK: - Filtering Tests

    func testFilterByMinDiscount() {
        let expectation = expectation(description: "Filter by minimum discount")

        sut.execute(query: "", minDiscount: 15)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { employers in
                for employer in employers {
                    XCTAssertGreaterThanOrEqual(employer.discountPercentage, 15)
                }
                expectation.fulfill()
            })
            .store(in: &cancellables)

        waitForExpectations(timeout: 1.0)
    }

    func testFilterByMinDiscountReturnsEmpty() {
        let expectation = expectation(description: "Filter returns empty for high threshold")

        sut.execute(query: "", minDiscount: 100)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { employers in
                XCTAssertTrue(employers.isEmpty)
                expectation.fulfill()
            })
            .store(in: &cancellables)

        waitForExpectations(timeout: 1.0)
    }

    func testFilterWithZeroDiscount() {
        let expectation = expectation(description: "Filter with zero discount")

        sut.execute(query: "", minDiscount: 0)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { employers in
                XCTAssertFalse(employers.isEmpty)
                expectation.fulfill()
            })
            .store(in: &cancellables)

        waitForExpectations(timeout: 1.0)
    }

    // MARK: - Combined Tests

    func testFilterAndSort() {
        let expectation = expectation(description: "Filter and sort combined")

        sut.execute(query: "", minDiscount: 10, sortBy: .discountDesc)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { employers in
                // All should have 10%+
                for employer in employers {
                    XCTAssertGreaterThanOrEqual(employer.discountPercentage, 10)
                }
                // Should be sorted descending
                for i in 0..<employers.count-1 {
                    XCTAssertGreaterThanOrEqual(employers[i].discountPercentage,
                                               employers[i+1].discountPercentage)
                }
                expectation.fulfill()
            })
            .store(in: &cancellables)

        waitForExpectations(timeout: 1.0)
    }

    func testSearchWithFilterAndSort() {
        let expectation = expectation(description: "Search with filter and sort")

        sut.execute(query: "Amsterdam", minDiscount: 5, sortBy: .nameAsc)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { employers in
                // All should match query
                for employer in employers {
                    XCTAssertTrue(employer.matches(query: "Amsterdam"))
                }
                // All should have 5%+
                for employer in employers {
                    XCTAssertGreaterThanOrEqual(employer.discountPercentage, 5)
                }
                // Should be sorted by name
                for i in 0..<employers.count-1 {
                    XCTAssertLessThanOrEqual(employers[i].name, employers[i+1].name)
                }
                expectation.fulfill()
            })
            .store(in: &cancellables)

        waitForExpectations(timeout: 1.0)
    }
}
```

**Step 3: Run tests**

Run: `⌘+U`
Expected: All tests pass

**Step 4: Commit**

```bash
git add EmployerSearchTests/Domain/SearchEmployersUseCaseTests.swift
git commit -m "test: add comprehensive tests for sorting and filtering"
```

---

## Task 9: Create FilterChip Component

**Files:**
- Create: `EmployerSearch/Presentation/DesignSystem/Components/FilterChip.swift`

**Step 1: Create FilterChip.swift**

```swift
import SwiftUI

/// Filter chip component for discount filtering
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppTypography.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : AppColors.primary)
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isSelected ? AppColors.primary : Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(AppColors.primary, lineWidth: isSelected ? 0 : 1.5)
                        )
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HStack(spacing: 12) {
        FilterChip(title: "All", isSelected: true) {}
        FilterChip(title: "5%+", isSelected: false) {}
        FilterChip(title: "10%+", isSelected: false) {}
        FilterChip(title: "15%+", isSelected: false) {}
        FilterChip(title: "20%+", isSelected: false) {}
    }
    .padding()
}
```

**Step 2: Preview in Xcode**

Expected: See filter chips with selected/unselected states

**Step 3: Commit**

```bash
git add EmployerSearch/Presentation/DesignSystem/Components/FilterChip.swift
git commit -m "feat: add filter chip component"
```

---

## Task 10: Update SearchViewModel for Filtering and Sorting

**Files:**
- Modify: `EmployerSearch/Presentation/Search/SearchViewModel.swift`

**Step 1: Read current SearchViewModel**

Read: `EmployerSearch/Presentation/Search/SearchViewModel.swift`

**Step 2: Add filter and sort state**

```swift
import Foundation
import Combine

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

                // Filter by favorites if enabled
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
```

**Step 3: Build to verify**

Run: `⌘+B`
Expected: Build succeeds

**Step 4: Commit**

```bash
git add EmployerSearch/Presentation/Search/SearchViewModel.swift
git commit -m "feat: add filtering, sorting, and favorites to view model"
```

---

## Task 11: Update SearchView with Filters and Sort

**Files:**
- Modify: `EmployerSearch/Presentation/Search/SearchView.swift`

**Step 1: Read current SearchView**

Read: `EmployerSearch/Presentation/Search/SearchView.swift`

**Step 2: Add filter chips, sort button, and favorites toggle**

```swift
import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel: SearchViewModel

    init() {
        let repository = EmployerRepositoryImpl(
            apiService: MockEmployerAPIService(),
            cacheManager: CacheManager.shared
        )
        let useCase = SearchEmployersUseCase(repository: repository)
        _viewModel = StateObject(wrappedValue: SearchViewModel(searchUseCase: useCase))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Favorites toggle
                Picker("View", selection: $viewModel.showFavoritesOnly) {
                    Text("All Employers").tag(false)
                    Text("Favorites ⭐").tag(true)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, AppSpacing.md)
                .padding(.top, AppSpacing.sm)

                // Filter chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        FilterChip(
                            title: "All",
                            isSelected: viewModel.selectedMinDiscount == nil
                        ) {
                            viewModel.selectFilter(nil)
                        }

                        FilterChip(
                            title: "5%+",
                            isSelected: viewModel.selectedMinDiscount == 5
                        ) {
                            viewModel.selectFilter(5)
                        }

                        FilterChip(
                            title: "10%+",
                            isSelected: viewModel.selectedMinDiscount == 10
                        ) {
                            viewModel.selectFilter(10)
                        }

                        FilterChip(
                            title: "15%+",
                            isSelected: viewModel.selectedMinDiscount == 15
                        ) {
                            viewModel.selectFilter(15)
                        }

                        FilterChip(
                            title: "20%+",
                            isSelected: viewModel.selectedMinDiscount == 20
                        ) {
                            viewModel.selectFilter(20)
                        }
                    }
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.vertical, AppSpacing.sm)
                }

                // Content
                Group {
                    if viewModel.isLoading {
                        LoadingView()
                    } else if let errorMessage = viewModel.errorMessage {
                        ErrorView(message: errorMessage, retryAction: viewModel.retry)
                    } else if viewModel.employers.isEmpty {
                        if viewModel.showFavoritesOnly {
                            favoritesEmptyState
                        } else {
                            EmptyStateView()
                        }
                    } else {
                        employersList
                    }
                }
            }
            .navigationTitle("Employers")
            .searchable(text: $viewModel.searchQuery, prompt: "Search by name or location")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.showSortMenu.toggle()
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                            .foregroundColor(AppColors.primary)
                    }
                }
            }
            .sheet(isPresented: $viewModel.showSortMenu) {
                sortMenu
            }
        }
    }

    private var employersList: some View {
        ScrollView {
            LazyVStack(spacing: AppSpacing.md) {
                ForEach(viewModel.employers) { employer in
                    NavigationLink(value: employer) {
                        EmployerRowView(employer: employer)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(AppSpacing.md)
        }
        .navigationDestination(for: Employer.self) { employer in
            EmployerDetailView(employer: employer)
        }
    }

    private var favoritesEmptyState: some View {
        VStack(spacing: AppSpacing.lg) {
            Image(systemName: "star.fill")
                .font(.system(size: 64))
                .foregroundColor(AppColors.favorite)

            Text("No favorites yet")
                .font(AppTypography.headline)
                .foregroundColor(AppColors.textPrimary)

            Text("Tap the star on any employer to add them here")
                .font(AppTypography.body)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.xl)
        }
        .frame(maxHeight: .infinity)
    }

    private var sortMenu: some View {
        NavigationStack {
            List(SortOption.allCases, id: \.self) { option in
                Button {
                    viewModel.selectSort(option)
                } label: {
                    HStack {
                        Text(option.rawValue)
                            .font(AppTypography.body)
                            .foregroundColor(AppColors.textPrimary)

                        Spacer()

                        if viewModel.selectedSort == option {
                            Image(systemName: "checkmark")
                                .foregroundColor(AppColors.primary)
                        }
                    }
                }
            }
            .navigationTitle("Sort By")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        viewModel.showSortMenu = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    SearchView()
}
```

**Step 3: Build and run**

Run: `⌘+R`
Expected: App runs, shows filter chips, sort button, favorites toggle

**Step 4: Commit**

```bash
git add EmployerSearch/Presentation/Search/SearchView.swift
git commit -m "feat: add filtering, sorting, and favorites UI to search view"
```

---

## Task 12: Create Employer Detail View

**Files:**
- Create: `EmployerSearch/Presentation/EmployerDetail/EmployerDetailView.swift`

**Step 1: Create EmployerDetail folder**

```bash
mkdir -p EmployerSearch/Presentation/EmployerDetail
```

**Step 2: Create EmployerDetailView.swift**

```swift
import SwiftUI

struct EmployerDetailView: View {
    let employer: Employer
    @State private var isFavorite: Bool
    @Environment(\.dismiss) private var dismiss

    init(employer: Employer) {
        self.employer = employer
        self._isFavorite = State(initialValue: FavoritesManager.shared.isFavorite(employerID: employer.id))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Hero section with large badge
                heroSection

                // Company info
                companyInfoSection

                // About section
                infoCard(
                    icon: "info.circle.fill",
                    title: "About",
                    content: "This employer offers special discounts to all verified employees. Discounts may vary by location and are subject to availability."
                )

                // Discount details
                infoCard(
                    icon: "chart.bar.fill",
                    title: "Discount Details",
                    content: """
                    • Available to all employees
                    • No minimum purchase required
                    • Valid at all locations
                    • Cannot be combined with other offers
                    """
                )
            }
        }
        .background(AppColors.background)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        FavoritesManager.shared.toggleFavorite(employerID: employer.id)
                        isFavorite.toggle()
                    }
                } label: {
                    Image(systemName: isFavorite ? "star.fill" : "star")
                        .foregroundColor(isFavorite ? AppColors.favorite : AppColors.textSecondary)
                }
            }
        }
    }

    private var heroSection: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [
                    AppColors.discountColor(for: employer.discountPercentage).opacity(0.3),
                    AppColors.background.opacity(0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 250)

            // Large discount badge
            DiscountBadge(
                percentage: employer.discountPercentage,
                size: AppSpacing.largeBadgeSize
            )
        }
    }

    private var companyInfoSection: some View {
        VStack(spacing: AppSpacing.sm) {
            Text(employer.name)
                .font(AppTypography.title)
                .foregroundColor(AppColors.textPrimary)
                .multilineTextAlignment(.center)

            HStack(spacing: 6) {
                Image(systemName: "mappin.circle.fill")
                    .foregroundColor(AppColors.textSecondary)

                Text(employer.place)
                    .font(AppTypography.headline)
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.vertical, AppSpacing.lg)
    }

    private func infoCard(icon: String, title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: icon)
                    .foregroundColor(AppColors.primary)

                Text(title)
                    .font(AppTypography.headline)
                    .foregroundColor(AppColors.textPrimary)
            }

            Text(content)
                .font(AppTypography.body)
                .foregroundColor(AppColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppSpacing.md)
        .background(AppColors.cardBackground)
        .cornerRadius(AppSpacing.cardCornerRadius)
        .padding(.horizontal, AppSpacing.md)
        .padding(.bottom, AppSpacing.md)
    }
}

#Preview {
    NavigationStack {
        EmployerDetailView(
            employer: Employer(
                id: 1,
                name: "Test Company B.V.",
                place: "Amsterdam",
                discountPercentage: 25
            )
        )
    }
}
```

**Step 3: Build and preview**

Run: `⌘+B` then view preview
Expected: Detail view shows with hero badge, company info, and info cards

**Step 4: Commit**

```bash
git add EmployerSearch/Presentation/EmployerDetail/EmployerDetailView.swift
git commit -m "feat: add employer detail screen"
```

---

## Task 13: Test Full App Flow

**Step 1: Build and run on simulator**

Run: `⌘+R`

**Step 2: Manual testing checklist**

Test the following:
- [ ] Search for employers by name
- [ ] Search for employers by location
- [ ] Tap "All" filter - shows all results
- [ ] Tap "5%+" filter - shows only 5%+ discounts
- [ ] Tap "10%+" filter - shows only 10%+ discounts
- [ ] Tap "15%+" filter - shows only 15%+ discounts
- [ ] Tap "20%+" filter - shows only 20%+ discounts
- [ ] Tap sort button - menu appears
- [ ] Select different sort options - results reorder
- [ ] Tap star on employer card - becomes favorited (gold)
- [ ] Tap star again - unfavorites
- [ ] Switch to "Favorites" tab - shows favorited employers
- [ ] Favorites tab with no favorites - shows empty state
- [ ] Tap employer card - navigates to detail view
- [ ] Detail view shows large badge with correct color
- [ ] Detail view shows company info correctly
- [ ] Tap favorite star in detail view - toggles correctly
- [ ] Close app and reopen - favorites persist
- [ ] Test in dark mode - colors adapt correctly

**Step 3: Run unit tests**

Run: `⌘+U`
Expected: All tests pass

**Step 4: Document any issues found**

If issues found, create tasks to fix them before final commit.

---

## Task 14: Update Documentation

**Files:**
- Modify: `README.md`
- Modify: `PROJECT_SUMMARY.md`
- Modify: `DEVELOPMENT_LOG.txt`

**Step 1: Update README.md**

Add to Features section:
```markdown
## Features

- **Real-time search** - Search employers by name or location with 300ms debounce
- **Advanced filtering** - Filter by minimum discount percentage (5%+, 10%+, 15%+, 20%+)
- **Flexible sorting** - Sort by name, discount amount, or location
- **Favorites system** - Save favorite employers with persistent storage
- **Detailed view** - Rich employer detail page with comprehensive information
- **Professional design** - Consistent design system with color-coded discount tiers
- **Smart caching** - Results cached locally for 1 week to reduce network calls
- **Secure storage** - Cache stored in iOS Keychain, favorites in UserDefaults
- **Loading states** - Graceful handling of async operations
- **Error handling** - Clear error messages with retry functionality
- **Dark mode** - Full support for light and dark appearance
- **Offline support** - Works from cache when available
```

**Step 2: Update PROJECT_SUMMARY.md**

Add enhancements section:
```markdown
## Recent Enhancements

### Design System (Professional Polish)
- ✅ **Color tokens** - Semantic colors with dark mode support
- ✅ **Typography system** - Consistent text styles throughout
- ✅ **Spacing system** - 8pt grid for layout consistency
- ✅ **Reusable components** - Badge, FilterChip, FavoriteButton

### New Features
- ✅ **Filtering** - Filter by discount tiers (5%+, 10%+, 15%+, 20%+)
- ✅ **Sorting** - 5 sort options (name asc/desc, discount asc/desc, location)
- ✅ **Favorites** - Persist favorites with UserDefaults, dedicated favorites view
- ✅ **Detail screen** - Full employer details with hero badge and info cards
- ✅ **Enhanced cards** - Color-coded badges, favorites button, improved layout

### Testing
- ✅ **Sort tests** - All 5 sort options tested
- ✅ **Filter tests** - Boundary conditions and edge cases
- ✅ **Combined tests** - Filter + sort + search integration
```

**Step 3: Update DEVELOPMENT_LOG.txt**

Add enhancement session:
```
Session 6: Visual Polish & Features (3.5 hours)
-----------------------------------------------
- 45 min: Design system (colors, typography, spacing, badge component)
- 30 min: Enhanced employer cards with new design
- 60 min: Favorites system (manager, UI, persistence)
- 45 min: Filtering and sorting (use case, tests, UI)
- 60 min: Employer detail screen
- 30 min: Testing and polish

Total Project Time: ~9.5 hours
```

**Step 4: Commit documentation**

```bash
git add README.md PROJECT_SUMMARY.md DEVELOPMENT_LOG.txt
git commit -m "docs: update documentation for new features"
```

---

## Task 15: Final Build and Verification

**Step 1: Clean build**

```bash
rm -rf ~/Library/Developer/Xcode/DerivedData/EmployerSearch-*
```

Run: `⌘+Shift+K` (Clean Build Folder)
Run: `⌘+B` (Build)
Expected: Clean build succeeds with no warnings

**Step 2: Run all tests**

Run: `⌘+U`
Expected: All tests pass

**Step 3: Test on multiple simulators**

Test on:
- iPhone SE (small screen)
- iPhone 15 Pro (standard)
- iPad Air (tablet)

Expected: UI adapts correctly to all screen sizes

**Step 4: Verify dark mode**

Enable dark mode in simulator
Expected: All colors adapt, badges remain readable

**Step 5: Final commit**

```bash
git add .
git commit -m "feat: complete visual polish and features enhancement

- Design system with colors, typography, spacing
- Enhanced employer cards with shadows and animations
- Filtering by discount percentage (5%+, 10%+, 15%+, 20%+)
- Sorting by name, discount, location
- Favorites system with persistence
- Employer detail screen with hero badge
- Comprehensive tests for new features
- Updated documentation

Total implementation time: ~3.5 hours"
```

---

## Success Criteria

✅ All requirements from design document implemented
✅ Design system applied consistently
✅ All filters and sorts work correctly
✅ Favorites persist across app restarts
✅ Detail screen displays correctly
✅ All tests pass
✅ No compilation warnings
✅ Dark mode fully supported
✅ Documentation updated
✅ Clean git history with atomic commits

---

## Estimated Total Time

- Task 1-3: Design System Foundation (30 min)
- Task 4-5: Badge Component & Enhanced Cards (30 min)
- Task 6-8: Favorites System & Tests (45 min)
- Task 7-10: Sorting, Filtering, Tests (60 min)
- Task 9-11: Filter UI & ViewModel Updates (45 min)
- Task 12: Detail Screen (45 min)
- Task 13: Testing (30 min)
- Task 14-15: Documentation & Verification (20 min)

**Total: ~3.5-4 hours**
