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
                    \u{2022} Available to all employees
                    \u{2022} No minimum purchase required
                    \u{2022} Valid at all locations
                    \u{2022} Cannot be combined with other offers
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
