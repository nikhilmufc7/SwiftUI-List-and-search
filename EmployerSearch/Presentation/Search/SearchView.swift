import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel: SearchViewModel

    init() {
        let repository = EmployerRepositoryImpl(
            apiService: MockEmployerAPIService(),
            cacheManager: CacheManager.shared
        )
        let useCase = SearchEmployersUseCase(repository: repository)
        _viewModel = StateObject(wrappedValue: SearchViewModel(searchUseCase: useCase))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Favorites toggle
                Picker("View", selection: $viewModel.showFavoritesOnly) {
                    Text("All Employers").tag(false)
                    Text("Favorites").tag(true)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, AppSpacing.md)
                .padding(.top, AppSpacing.sm)

                // Filter chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        FilterChip(
                            title: "All",
                            isSelected: viewModel.selectedMinDiscount == nil
                        ) {
                            viewModel.selectFilter(nil)
                        }

                        FilterChip(
                            title: "5%+",
                            isSelected: viewModel.selectedMinDiscount == 5
                        ) {
                            viewModel.selectFilter(5)
                        }

                        FilterChip(
                            title: "10%+",
                            isSelected: viewModel.selectedMinDiscount == 10
                        ) {
                            viewModel.selectFilter(10)
                        }

                        FilterChip(
                            title: "15%+",
                            isSelected: viewModel.selectedMinDiscount == 15
                        ) {
                            viewModel.selectFilter(15)
                        }

                        FilterChip(
                            title: "20%+",
                            isSelected: viewModel.selectedMinDiscount == 20
                        ) {
                            viewModel.selectFilter(20)
                        }
                    }
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.vertical, AppSpacing.sm)
                }

                // Content
                Group {
                    if viewModel.isLoading {
                        LoadingView()
                    } else if let errorMessage = viewModel.errorMessage {
                        ErrorView(message: errorMessage, retryAction: viewModel.retry)
                    } else if viewModel.employers.isEmpty {
                        if viewModel.showFavoritesOnly {
                            favoritesEmptyState
                        } else {
                            EmptyStateView()
                        }
                    } else {
                        employersList
                    }
                }
            }
            .navigationTitle("Employers")
            .searchable(text: $viewModel.searchQuery, prompt: "Search by name or location")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.showSortMenu.toggle()
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                            .foregroundColor(AppColors.primary)
                    }
                }
            }
            .sheet(isPresented: $viewModel.showSortMenu) {
                sortMenu
            }
        }
    }

    private var employersList: some View {
        ScrollView {
            LazyVStack(spacing: AppSpacing.md) {
                ForEach(viewModel.employers) { employer in
                    NavigationLink(value: employer) {
                        EmployerRowView(employer: employer)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(AppSpacing.md)
        }
        .navigationDestination(for: Employer.self) { employer in
            EmployerDetailView(employer: employer)
        }
    }

    private var favoritesEmptyState: some View {
        VStack(spacing: AppSpacing.lg) {
            Image(systemName: "star.fill")
                .font(.system(size: 64))
                .foregroundColor(AppColors.favorite)

            Text("No favorites yet")
                .font(AppTypography.headline)
                .foregroundColor(AppColors.textPrimary)

            Text("Tap the star on any employer to add them here")
                .font(AppTypography.body)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.xl)
        }
        .frame(maxHeight: .infinity)
    }

    private var sortMenu: some View {
        NavigationStack {
            List(SortOption.allCases, id: \.self) { option in
                Button {
                    viewModel.selectSort(option)
                } label: {
                    HStack {
                        Text(option.rawValue)
                            .font(AppTypography.body)
                            .foregroundColor(AppColors.textPrimary)

                        Spacer()

                        if viewModel.selectedSort == option {
                            Image(systemName: "checkmark")
                                .foregroundColor(AppColors.primary)
                        }
                    }
                }
            }
            .navigationTitle("Sort By")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        viewModel.showSortMenu = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    SearchView()
}
