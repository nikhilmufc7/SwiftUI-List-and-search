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
        .onAppear {
            isFavorite = FavoritesManager.shared.isFavorite(employerID: employer.id)
        }
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
