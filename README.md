# Employer Search

An iOS app for searching Dutch employers with discount information. Features intelligent caching, secure local storage, and a clean architecture.

## How to run

```bash
open EmployerSearch.xcodeproj
```

Select a simulator and press ⌘+R.

## Features

- **Real-time search** - Search employers by name or location with 300ms debounce
- **Advanced filtering** - Filter by minimum discount percentage (5%+, 10%+, 15%+, 20%+)
- **Flexible sorting** - Sort by name, discount amount, or location
- **Favorites system** - Save favorite employers with persistent storage
- **Detailed view** - Rich employer detail page with hero badge and info cards
- **Professional design** - Consistent design system with color-coded discount tiers
- **Smart caching** - Results cached locally for 1 week to reduce network calls
- **Secure storage** - Cache stored in iOS Keychain, favorites in UserDefaults
- **Loading states** - Graceful handling of async operations
- **Error handling** - Clear error messages with retry functionality
- **Dark mode** - Full support for light and dark appearance
- **Offline support** - Works from cache when available

## Architecture

Clean Architecture with three main layers:

**Domain** - Business logic, no framework dependencies
- `Employer` - Core entity with search matching logic
- `SearchEmployersUseCase` - Search orchestration
- `EmployerRepository` - Protocol for data access

**Data** - Infrastructure and persistence
- `EmployerRepositoryImpl` - Repository with cache-first strategy
- `EmployerAPIService` - API abstraction (currently mock)
- `CacheManager` - Secure caching with Keychain

**Presentation** - SwiftUI views and view models
- `SearchView` - Main search interface with filters, sort, and favorites toggle
- `SearchViewModel` - State management with Combine
- `EmployerDetailView` - Rich employer detail screen
- Design system: `AppColors`, `AppTypography`, `AppSpacing`
- Reusable components: `DiscountBadge`, `FilterChip`, loading/error/empty states

## Technical Decisions

**Cache-first strategy** - Check cache before hitting the API. This reduces network traffic as required.

**Keychain for storage** - Using iOS Keychain instead of UserDefaults for the bonus security requirement. Cache expires after 1 week.

**Debounced search** - 300ms debounce on search input to avoid excessive queries while typing.

**Mock API** - Currently using hardcoded data. In production, would swap `MockEmployerAPIService` with real HTTP implementation using URLSession.

**Protocol-based design** - Makes testing straightforward. Repository and API service are protocols, easy to mock.

## Project Structure

```
EmployerSearch/
├── Domain/
│   ├── Entities/Employer.swift
│   ├── UseCases/SearchEmployersUseCase.swift    # Includes SortOption enum
│   └── RepositoryInterfaces/EmployerRepository.swift
├── Data/
│   ├── Repositories/EmployerRepositoryImpl.swift
│   ├── Network/EmployerAPIService.swift
│   └── Cache/CacheManager.swift
├── Infrastructure/
│   ├── Cache/CacheManager.swift
│   └── Storage/FavoritesManager.swift            # Favorites persistence
├── Presentation/
│   ├── DesignSystem/
│   │   ├── Colors.swift                          # Semantic color tokens
│   │   ├── Typography.swift                      # Text styles
│   │   ├── Spacing.swift                         # 8pt grid spacing
│   │   └── Components/
│   │       ├── DiscountBadge.swift               # Color-coded badge
│   │       └── FilterChip.swift                  # Filter toggle chip
│   ├── Search/
│   │   ├── SearchView.swift                      # Main search + filters + sort
│   │   └── SearchViewModel.swift                 # State with filter/sort/favorites
│   ├── EmployerDetail/
│   │   └── EmployerDetailView.swift              # Detail screen with hero badge
│   └── Common/Views/
│       ├── EmployerRowView.swift                 # Enhanced card with favorites
│       ├── LoadingView.swift
│       ├── ErrorView.swift
│       └── EmptyStateView.swift
└── App/
    └── EmployerSearchApp.swift
```

## Cache Implementation

Cache has 1 week expiration as specified. On app launch, expired cache is automatically cleared. Cache key and timestamp stored separately for efficient expiration checks.

The cache uses iOS Keychain for secure storage:
- Data encrypted at rest
- Accessible only to this app
- Protected by device unlock

## Testing

Tests included for:
- `EmployerTests` - Entity business logic
- `SearchEmployersUseCaseTests` - Search and sorting
- `MockEmployerRepository` - For testing without real data

Run tests: `⌘+U` or:
```bash
xcodebuild test -project EmployerSearch.xcodeproj -scheme EmployerSearch \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

## Network Optimization

As per requirements, responses are cached to minimize network traffic. The cache-first strategy means:
1. Check local cache
2. If valid (< 1 week old), return cached data
3. Otherwise, fetch from API and cache

This reduces API calls significantly for repeated searches.

## Future Improvements

If more time available:
- Add actual HTTP networking with URLSession
- Implement response pagination for large datasets
- Add Xcode test target to run unit tests from CLI
- UI tests for critical flows
- Analytics for cache hit rate

## Requirements

- iOS 17.0+
- Xcode 15.0+

## Development Time Log

Total time: ~6 hours (within 8 hour limit)
- Architecture planning: 30 min
- Domain layer: 45 min
- Data layer (API, cache, repository): 1.5 hours
- Presentation layer (views, view models): 2 hours
- Testing: 1 hour
- Documentation: 15 min
