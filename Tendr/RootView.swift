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
    
    init(appState: AppState) {
        self.appState = appState
        
        // Customize tab bar appearance
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 1.0, green: 0.95, blue: 0.9, alpha: 1.0)
        
        // Selected tab item color
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(red: 1.0, green: 0.3, blue: 0.2, alpha: 1.0)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(red: 1.0, green: 0.3, blue: 0.2, alpha: 1.0)
        ]
        
        // Normal tab item color
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.systemGray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.systemGray
        ]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
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

