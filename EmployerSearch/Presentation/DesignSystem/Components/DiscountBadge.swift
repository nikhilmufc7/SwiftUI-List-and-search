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
