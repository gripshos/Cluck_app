//
//  ContentView.swift
//  Tendr
//
//  Main content view for the app
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var appState = AppState()
    
    var body: some View {
        RootView(appState: appState)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: FavoriteRestaurant.self, configurations: config)
    
    ContentView()
        .modelContainer(container)
}
