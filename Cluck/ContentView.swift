//
//  ContentView.swift
//  Cluck
//
//  Main content view for the app
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var appState = AppState()
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        RootView(appState: appState)
            .onAppear {
                // Clean up any duplicate favorites on app launch
                Task { @MainActor in
                    let duplicatesRemoved = FavoritesHelper.removeDuplicates(in: modelContext)
                    if duplicatesRemoved > 0 {
                        print("🧹 Cleaned up \(duplicatesRemoved) duplicate favorite(s)")
                    }
                }
            }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: FavoriteRestaurant.self, configurations: config)
    
    ContentView()
        .modelContainer(container)
}
