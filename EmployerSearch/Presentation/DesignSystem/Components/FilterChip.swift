import SwiftUI

/// Filter chip component for discount filtering
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppTypography.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : AppColors.primary)
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isSelected ? AppColors.primary : Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(AppColors.primary, lineWidth: isSelected ? 0 : 1.5)
                        )
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HStack(spacing: 12) {
        FilterChip(title: "All", isSelected: true) {}
        FilterChip(title: "5%+", isSelected: false) {}
        FilterChip(title: "10%+", isSelected: false) {}
        FilterChip(title: "15%+", isSelected: false) {}
        FilterChip(title: "20%+", isSelected: false) {}
    }
    .padding()
}
