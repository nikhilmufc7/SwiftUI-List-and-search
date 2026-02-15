# Visual Polish & Features Enhancement Design

**Date:** 2026-02-12
**Status:** Approved
**Architecture:** Clean Architecture + MVVM (unchanged)

## Overview

Enhancement plan to add visual polish and useful features to the Employer Search iOS app while maintaining the existing Clean Architecture.

## Goals

1. **Visual Polish**: Professional design system with enhanced employer cards
2. **Useful Features**: Filtering, sorting, favorites, and detail view

## Design System

### Structure

```
EmployerSearch/
├── Presentation/
│   └── DesignSystem/
│       ├── Colors.swift          // Semantic color tokens
│       ├── Typography.swift      // Text styles
│       ├── Spacing.swift         // Layout constants
│       └── Components/           // Reusable components
│           ├── Badge.swift
│           ├── FilterChip.swift
│           └── FavoriteButton.swift
```

### Color Palette

**Brand Colors**
- Primary: `#007AFF` (iOS native blue)
- Accent: `#5AC8FA` (Teal)

**Semantic Colors**
- Success: `#34C759` (Green) - for 15%+ discounts
- Warning: `#FF9500` (Orange) - for 10-14% discounts
- Info: `#5856D6` (Purple) - for 5-9% discounts
- Gray: `#8E8E93` - for <5% discounts

**UI Colors**
- Background: Dynamic (white/black for dark mode)
- Card Background: Dynamic secondary background
- Border: Dynamic tertiary
- Text Primary: Dynamic primary label
- Text Secondary: Dynamic secondary label

### Typography System

Using San Francisco (SF Pro):
- **Title**: SF Pro Display, 28pt, Bold
- **Headline**: SF Pro Text, 17pt, Semibold
- **Body**: SF Pro Text, 15pt, Regular
- **Caption**: SF Pro Text, 13pt, Regular
- **Badge**: SF Pro Rounded, 20pt, Bold

### Spacing System

Consistent 8pt grid:
- xs: 4pt
- sm: 8pt
- md: 16pt
- lg: 24pt
- xl: 32pt
- xxl: 48pt

## Enhanced Employer Cards

### Visual Improvements

**Card Design**
- White/dark card background with subtle shadow
- Corner radius: 12pt
- Padding: 16pt
- Elevation: 2pt shadow with 0.1 opacity

**Discount Badge**
- Circular badge (56pt diameter)
- Color-coded by discount tier
- Bold rounded font
- Positioned on the right side
- Subtle scale animation on appear

**Layout**
```
┌─────────────────────────────────────┐
│ Company Name            ⭐  [25%]   │
│ 📍 Location                         │
└─────────────────────────────────────┘
```

**Interactions**
- Tap: Navigate to detail view with scale animation
- Favorite button: Star with spring animation
- Card hover state (subtle scale on press)

## Feature 1: Filtering & Sorting

### Filter Chips

**UI Placement**: Below search bar, horizontal scroll if needed

```
[All] [5%+] [10%+] [15%+] [20%+]
```

**Behavior**
- Single selection (mutually exclusive)
- "All" selected by default
- Selected: filled background with primary color
- Unselected: border only with transparent background
- Smooth fade transition when results update

### Sort Menu

**UI Placement**: Navigation bar trailing button (sort icon ⇅)

**Options**
- Name (A-Z) ✓ [default]
- Name (Z-A)
- Discount (High to Low)
- Discount (Low to High)
- Location (A-Z)

**Presentation**: Bottom sheet with list of options, checkmark on selected

### Domain Layer Changes

```swift
// Domain/UseCases/SearchEmployersUseCase.swift

enum SortOption {
    case nameAsc
    case nameDesc
    case discountDesc
    case discountAsc
    case locationAsc
}

final class SearchEmployersUseCase {
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
                let sorted = self.sort(employers: filtered, by: sortBy)
                return sorted
            }
            .eraseToAnyPublisher()
    }

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

### ViewModel State

```swift
// Presentation/Search/SearchViewModel.swift

@Published var selectedMinDiscount: Int? = nil
@Published var selectedSort: SortOption = .nameAsc
@Published var showSortMenu: Bool = false
```

## Feature 2: Favorites System

### UI Components

**Segmented Control** (top of list)
```
[All Employers] [Favorites ⭐]
```

**Favorite Button**
- Star icon (SF Symbol: star.fill / star)
- Positioned top-right of each card
- Gold color (#FFD700) when favorited
- Spring animation on toggle
- Haptic feedback on tap

**Empty State** (when no favorites)
```
⭐
No favorites yet
Tap the star on any employer to add them here
```

### Data Persistence

**New Component**: `Infrastructure/Storage/FavoritesManager.swift`

```swift
final class FavoritesManager {
    static let shared = FavoritesManager()

    private let key = "com.employersearch.favorites"
    private let defaults = UserDefaults.standard

    private init() {}

    func toggleFavorite(employerID: Int) {
        var favorites = getFavoriteIDs()
        if favorites.contains(employerID) {
            favorites.remove(employerID)
        } else {
            favorites.insert(employerID)
        }
        saveFavorites(favorites)
    }

    func isFavorite(employerID: Int) -> Bool {
        return getFavoriteIDs().contains(employerID)
    }

    func getFavoriteIDs() -> Set<Int> {
        guard let data = defaults.data(forKey: key),
              let ids = try? JSONDecoder().decode(Set<Int>.self, from: data) else {
            return []
        }
        return ids
    }

    private func saveFavorites(_ favorites: Set<Int>) {
        if let data = try? JSONEncoder().encode(favorites) {
            defaults.set(data, forKey: key)
        }
    }
}
```

**Why UserDefaults?**
- Only storing employer IDs (not sensitive data)
- Simple, lightweight solution
- Synchronous access for UI
- Appropriate for small datasets (<100 items)

### Domain Extension

```swift
// Domain/Entities/Employer.swift

extension Employer {
    var isFavorite: Bool {
        FavoritesManager.shared.isFavorite(employerID: id)
    }
}
```

### ViewModel State

```swift
// Presentation/Search/SearchViewModel.swift

@Published var showFavoritesOnly: Bool = false

private func performSearch(query: String) {
    // ... existing search logic

    // Filter by favorites if enabled
    if showFavoritesOnly {
        employers = employers.filter { $0.isFavorite }
    }
}
```

## Feature 3: Employer Detail Screen

### Navigation

Use SwiftUI NavigationStack (already in SearchView):

```swift
// Update SearchView.swift
NavigationLink(value: employer) {
    EmployerRowView(employer: employer, isFavorite: employer.isFavorite)
}
.navigationDestination(for: Employer.self) { employer in
    EmployerDetailView(employer: employer)
}
```

### Layout Structure

```
┌─────────────────────────────────────┐
│ [← Back]              [⭐ Favorite]  │  Navigation bar
├─────────────────────────────────────┤
│                                      │
│        Gradient Background           │
│                                      │
│      ┌───────────────┐              │
│      │               │              │
│      │     25%       │              │  Large discount badge
│      │      OFF      │              │  (120pt diameter)
│      │               │              │
│      └───────────────┘              │
│                                      │
├─────────────────────────────────────┤
│                                      │
│     Company Name (Bold, 28pt)       │
│     📍 Amsterdam                     │
│                                      │
├─────────────────────────────────────┤
│  Card Section                        │
│  ℹ️ About                            │
│  This employer offers special        │
│  discounts to all verified           │
│  employees.                          │
└─────────────────────────────────────┘
│  Card Section                        │
│  📊 Discount Details                 │
│  • Available to all employees        │
│  • No minimum purchase               │
│  • Valid at all locations            │
└─────────────────────────────────────┘
```

### Visual Design

**Hero Section**
- Gradient background (primary color, fading to transparent)
- Large circular discount badge (120pt diameter)
- Badge has subtle shadow for depth
- Color matches employer's discount tier

**Content Sections**
- White cards on light gray background
- 12pt corner radius
- 16pt padding
- 16pt spacing between cards

**Typography**
- Company name: 28pt, Bold
- Location: 17pt, Regular, secondary color
- Section headers: 17pt, Semibold
- Body text: 15pt, Regular

### Component Structure

```
Presentation/
├── EmployerDetail/
│   ├── EmployerDetailView.swift
│   └── Components/
│       ├── DetailHeroSection.swift
│       ├── DetailInfoCard.swift
│       └── DetailBadge.swift
```

### Future Enhancements

Placeholder sections for:
- Contact information
- Directions/map
- Terms & conditions
- Share functionality

## Implementation Order

Recommended sequence to maintain working state:

### Phase 1: Design System Foundation (30-45 min)
1. Create DesignSystem folder structure
2. Implement Colors.swift
3. Implement Typography.swift
4. Implement Spacing.swift
5. Create reusable Badge component

### Phase 2: Enhanced Cards (20-30 min)
1. Update EmployerRowView with new design
2. Add shadow and elevation
3. Improve badge styling
4. Add tap animations

### Phase 3: Favorites System (45-60 min)
1. Implement FavoritesManager
2. Add FavoriteButton component
3. Add segmented control to SearchView
4. Update ViewModel for favorites filtering
5. Add empty state for favorites

### Phase 4: Filtering & Sorting (45-60 min)
1. Create FilterChip component
2. Add filter chips to SearchView
3. Update SearchEmployersUseCase with sorting logic
4. Create sort menu component
5. Wire up filter/sort to ViewModel

### Phase 5: Detail Screen (45-60 min)
1. Create EmployerDetailView
2. Implement hero section with large badge
3. Add info card sections
4. Wire up navigation
5. Add favorite button to detail view

### Phase 6: Polish & Testing (30-45 min)
1. Add animations and transitions
2. Test all interactions
3. Verify dark mode support
4. Test on different screen sizes
5. Update documentation

**Total estimated time: 3.5 - 4.5 hours**

## Testing Strategy

### Unit Tests to Add

1. **SortOption Tests**
   - Test each sort option returns correct order
   - Test with empty array
   - Test with single item

2. **Filter Tests**
   - Test minDiscount filtering
   - Test edge cases (0%, 100%)

3. **Favorites Tests**
   - Test toggle functionality
   - Test persistence across launches
   - Test isFavorite queries

### Manual Testing

- Test all filter combinations
- Test all sort options
- Test favorites across app restarts
- Test detail screen navigation
- Test animations on real device
- Test accessibility (VoiceOver, Dynamic Type)
- Test dark mode appearance

## Architecture Impact

**No changes to core architecture:**
- Domain layer: Minor additions (SortOption enum, sorting logic)
- Data layer: Unchanged (cache, repository, API)
- Presentation layer: New views and components
- Infrastructure layer: New FavoritesManager

**Maintains Clean Architecture principles:**
- Domain logic remains pure and testable
- UI components depend on domain, not vice versa
- Easy to test each layer independently

## Success Criteria

**Visual Polish**
- ✅ Consistent design system applied throughout
- ✅ Professional-looking cards with proper elevation
- ✅ Smooth animations and transitions
- ✅ Dark mode support

**Features**
- ✅ Filtering by discount percentage works correctly
- ✅ Sorting options apply to results
- ✅ Favorites persist across app launches
- ✅ Detail screen shows comprehensive employer info

**Technical**
- ✅ No regression in existing functionality
- ✅ Tests pass for new features
- ✅ Code follows existing patterns
- ✅ Performance remains smooth (60fps)

## Documentation Updates

After implementation:
1. Update README.md with new features
2. Update PROJECT_SUMMARY.md with enhancements
3. Add screenshots to docs/ folder
4. Update DEVELOPMENT_LOG.txt with time spent

---

**Ready for implementation approval and execution.**
