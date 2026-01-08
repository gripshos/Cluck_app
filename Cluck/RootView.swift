//
//  RootView.swift
//  Cluck
//
//  Main navigation and tab view
//

import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    let appState: AppState
    
    @State private var selectedTab = 0
    @State private var viewModel: TenderDeckViewModel?
    @State private var hasCompletedInitialLoad = false
    
    init(appState: AppState) {
        self.appState = appState
        
        // Modern, subtle tab bar appearance with blur material
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        
        // Subtle background with blur
        appearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.8)
        
        // Selected tab item color (vibrant orange)
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(red: 1.0, green: 0.4, blue: 0.2, alpha: 1.0)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(red: 1.0, green: 0.4, blue: 0.2, alpha: 1.0),
            .font: UIFont.systemFont(ofSize: 10, weight: .semibold)
        ]
        
        // Normal tab item color (subtle gray)
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.secondaryLabel
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.secondaryLabel,
            .font: UIFont.systemFont(ofSize: 10, weight: .medium)
        ]
        
        // Apply to all tab bar states
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        Group {
            if hasCompletedInitialLoad {
                // Show tab view after initial load
                tabView
            } else {
                // Show loading state without tab bar
                Group {
                    if let viewModel {
                        SwipeDeckView(viewModel: viewModel, modelContext: modelContext)
                            .onChange(of: viewModel.isLoading) { oldValue, newValue in
                                // When loading completes, mark initial load as done
                                if oldValue && !newValue {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        hasCompletedInitialLoad = true
                                    }
                                }
                            }
                    } else {
                        ProgressView()
                            .onAppear {
                                viewModel = TenderDeckViewModel(
                                    searchService: appState.searchService,
                                    locationManager: appState.locationManager
                                )
                            }
                    }
                }
            }
        }
    }
    
    private var tabView: some View {
        TabView(selection: $selectedTab) {
            // Swipe Deck Tab
            Group {
                if let viewModel {
                    SwipeDeckView(viewModel: viewModel, modelContext: modelContext)
                } else {
                    ProgressView()
                        .onAppear {
                            viewModel = TenderDeckViewModel(
                                searchService: appState.searchService,
                                locationManager: appState.locationManager
                            )
                        }
                }
            }
            .tabItem {
                Label("Discover", systemImage: "flame.fill")
            }
            .tag(0)
            
            // Saved List Tab
            SavedListView()
                .tabItem {
                    Label("Saved", systemImage: "heart.fill")
                }
                .tag(1)
        }
        .tint(Color(red: 1.0, green: 0.3, blue: 0.2))
    }
}
// MARK: - Preview Support

#Preview("Discover Tab") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: FavoriteRestaurant.self, configurations: config)
    
    let mockAppState = AppState()
    
    return RootView(appState: mockAppState)
        .modelContainer(container)
}

#Preview("Saved Tab") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: FavoriteRestaurant.self, configurations: config)
    let context = container.mainContext
    
    // Add some mock saved restaurants
    let mockTender = Tender(
        name: "Raising Cane's",
        restaurantType: "Fast Food",
        priceRange: "$",
        address: "123 Main St, San Francisco, CA",
        latitude: 37.7749,
        longitude: -122.4194
    )
    let mockFavorite = FavoriteRestaurant(from: mockTender)
    context.insert(mockFavorite)
    
    let mockAppState = AppState()
    
    return RootView(appState: mockAppState)
        .modelContainer(container)
        .onAppear {
            // Switch to saved tab
        }
}

