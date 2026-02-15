import Foundation
import Security

/// Manages caching of employer data with expiration
final class CacheManager {
    static let shared = CacheManager()

    private let cacheKey = "com.employersearch.cache.employers"
    private let timestampKey = "com.employersearch.cache.timestamp"
    private let cacheExpiration: TimeInterval = 7 * 24 * 60 * 60 // 1 week

    private init() {}

    /// Save employers to cache with current timestamp
    func save(employers: [Employer]) {
        do {
            let data = try JSONEncoder().encode(employers)
            let timestamp = Date().timeIntervalSince1970

            // Use Keychain for secure storage (bonus requirement)
            try saveToKeychain(data: data, key: cacheKey)
            UserDefaults.standard.set(timestamp, forKey: timestampKey)
        } catch {
            print("Failed to cache employers: \(error)")
        }
    }

    /// Retrieve employers from cache if not expired
    func loadEmployers() -> [Employer]? {
        guard !isExpired() else {
            clearCache()
            return nil
        }

        do {
            guard let data = loadFromKeychain(key: cacheKey) else {
                return nil
            }

            let employers = try JSONDecoder().decode([Employer].self, from: data)
            return employers
        } catch {
            print("Failed to load cached employers: \(error)")
            return nil
        }
    }

    /// Check if cache is expired
    func isExpired() -> Bool {
        guard let timestamp = UserDefaults.standard.object(forKey: timestampKey) as? TimeInterval else {
            return true
        }

        let now = Date().timeIntervalSince1970
        return (now - timestamp) > cacheExpiration
    }

    /// Clear cache
    func clearCache() {
        deleteFromKeychain(key: cacheKey)
        UserDefaults.standard.removeObject(forKey: timestampKey)
    }

    // MARK: - Keychain Operations

    private func saveToKeychain(data: Data, key: String) throws {
        // Delete existing item first
        deleteFromKeychain(key: key)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw CacheError.keychainError(status)
        }
    }

    private func loadFromKeychain(key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess else {
            return nil
        }

        return result as? Data
    }

    private func deleteFromKeychain(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]

        SecItemDelete(query as CFDictionary)
    }
}

enum CacheError: LocalizedError {
    case keychainError(OSStatus)

    var errorDescription: String? {
        switch self {
        case .keychainError(let status):
            return "Keychain error: \(status)"
        }
    }
}
