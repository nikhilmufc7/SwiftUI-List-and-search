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
