import Foundation

/// Represents an employer entity with discount information
struct Employer: Identifiable, Hashable, Codable {
    let id: Int
    let name: String
    let place: String
    let discountPercentage: Int

    enum CodingKeys: String, CodingKey {
        case id = "EmployerID"
        case name = "Name"
        case place = "Place"
        case discountPercentage = "DiscountPercentage"
    }

    /// Check if employer matches search query
    func matches(query: String) -> Bool {
        guard !query.isEmpty else { return true }

        let lowercasedQuery = query.lowercased()
        return name.lowercased().contains(lowercasedQuery) ||
               place.lowercased().contains(lowercasedQuery)
    }

    /// Display name with location
    var displayName: String {
        "\(name) - \(place)"
    }
}
