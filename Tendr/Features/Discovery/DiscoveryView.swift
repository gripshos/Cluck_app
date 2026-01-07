//
//  DiscoveryView.swift
//  Tendr
//
//  Main discovery tab with swipe deck
//

import SwiftUI

/// The main discovery view with swipeable restaurant cards.
struct DiscoveryView: View {
    @Bindable var viewModel: DiscoveryViewModel
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Main content based on state
            contentView
                .ignoresSafeArea(edges: .top)
            
            // Floating action buttons (only when cards are showing)
            if viewModel.hasMoreCards && !viewModel.searchState.isLoading {
                ActionButtonsView(
                    onNope: { withAnimation { viewModel.swipeLeft() } },
                    onLike: { withAnimation { viewModel.swipeRight() } },
                    disabled: !viewModel.hasMoreCards
                )
                .padding(.bottom, 44)
            }
        }
        .navigationTitle("Tendr")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .task {
            await loadIfNeeded()
        }
        .onChange(of: viewModel.hasLocationPermission) { _, hasPermission in
            if hasPermission {
                Task { await viewModel.loadRestaurants() }
            }
        }
    }
    
    // MARK: - Content View
    
    @ViewBuilder
    private var contentView: some View {
        switch viewModel.searchState {
        case .idle:
            // Check location permission first
            if viewModel.locationPermissionDenied {
                ErrorStateView(
                    error: .locationPermissionDenied,
                    onRetry: { Task { await viewModel.loadRestaurants() } },
                    onOpenSettings: openAppSettings
                )
            } else if !viewModel.hasLocationPermission {
                LocationPermissionView(
                    onRequestPermission: viewModel.requestLocationPermission
                )
            } else {
                LoadingStateView()
            }
            
        case .loading:
            LoadingStateView()
            
        case .success:
            CardDeckView(viewModel: viewModel)
            
        case .empty:
            EmptyStateView(
                title: "All done!",
                message: "You've seen all the chicken tender spots nearby",
                actionTitle: "Search Again",
                onAction: { Task { await viewModel.refresh() } }
            )
            
        case .failure(let error):
            ErrorStateView(
                error: error,
                onRetry: { Task { await viewModel.loadRestaurants() } },
                onOpenSettings: error == .locationPermissionDenied ? openAppSettings : nil
            )
        }
    }
    
    // MARK: - Helpers
    
    private func loadIfNeeded() async {
        // Only load if we haven't already
        if case .idle = viewModel.searchState {
            if viewModel.hasLocationPermission {
                await viewModel.loadRestaurants()
            } else {
                viewModel.requestLocationPermission()
            }
        }
    }
    
    private func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Preview

#Preview("With Cards") {
    NavigationStack {
        DiscoveryView(viewModel: .preview)
    }
}

#Preview("Loading") {
    NavigationStack {
        DiscoveryView(viewModel: .loading)
    }
}

#Preview("Empty") {
    NavigationStack {
        DiscoveryView(viewModel: .empty)
    }
}

#Preview("Error") {
    NavigationStack {
        DiscoveryView(viewModel: .error)
    }
}
