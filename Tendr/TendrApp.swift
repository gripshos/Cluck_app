//
//  TendrApp.swift
//  Tendr
//
//  App entry point with SwiftData configuration
//

import SwiftUI
import SwiftData

@main
struct TendrApp: App {
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        // Configure SwiftData model container
        .modelContainer(for: FavoriteRestaurant.self)
    }
}
