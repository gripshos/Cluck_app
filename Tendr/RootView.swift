//
//  RootView.swift
//  Tendr
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
                Label("Discover", systemImage: "fork.knife")
            }
            .tag(0)
            
            // Saved List Tab
            SavedListView()
                .tabItem {
                    Label("Saved", systemImage: "heart.fill")
                }
                .tag(1)
        }
    }
}
