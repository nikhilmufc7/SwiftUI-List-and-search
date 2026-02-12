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
