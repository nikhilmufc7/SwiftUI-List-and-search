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
