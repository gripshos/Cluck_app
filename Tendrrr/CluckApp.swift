//
//  CluckApp.swift
//  Cluck
//
//  App entry point with SwiftData configuration
//

import SwiftUI
import SwiftData

@main
struct CluckApp: App {
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        // Configure SwiftData model container
        .modelContainer(for: FavoriteRestaurant.self)
    }
}
