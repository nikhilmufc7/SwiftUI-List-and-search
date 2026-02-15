import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(.gray)

            Text("No Results")
                .font(.title3)
                .fontWeight(.semibold)

            Text("Try adjusting your search")
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    EmptyStateView()
}
