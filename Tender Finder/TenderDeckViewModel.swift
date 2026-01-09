//
//  TenderDeckViewModel.swift
//  Cluck
//
//  Manages the state of the tender deck
//

import SwiftUI
import Observation
import CoreLocation
import SwiftData

@Observable
@MainActor
class TenderDeckViewModel {
    var tenders: [Tender] = []
    var isLoading = false
    var errorMessage: String?
    var lastSwipedRestaurant: Tender?
    
    private let searchService: RestaurantSearchService
    private let locationManager: LocationManager
    private let modelContext: ModelContext
    
    var userLocation: CLLocation? {
        locationManager.location
    }
    
    init(searchService: RestaurantSearchService, locationManager: LocationManager, modelContext: ModelContext) {
        self.searchService = searchService
        self.locationManager = locationManager
        self.modelContext = modelContext
    }
    
    func loadRestaurants() async {
        guard let location = locationManager.location else {
            errorMessage = "Unable to get your location"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let allTenders = try await searchService.searchNearbyRestaurants(near: location)
            print("📥 Fetched \(allTenders.count) restaurants from API")
            
            // Filter out restaurants that are already saved
            tenders = filterUnsavedRestaurants(from: allTenders)
            print("✅ After filtering: \(tenders.count) unsaved restaurants")
            
            if tenders.isEmpty {
                // Check if we filtered everything out
                if !allTenders.isEmpty {
                    errorMessage = "All nearby restaurants are already in your saved list"
                } else {
                    errorMessage = "No restaurants found nearby"
                }
            }
        } catch {
            errorMessage = "Failed to load restaurants: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func removeTopCard() {
        guard !tenders.isEmpty else { return }
        lastSwipedRestaurant = tenders.first
        tenders.removeFirst()
    }
    
    func undoLastSwipe() {
        guard let lastSwiped = lastSwipedRestaurant else { return }
        tenders.insert(lastSwiped, at: 0)
        lastSwipedRestaurant = nil
    }
    
    // MARK: - Private Helpers
    
    /// Filters out restaurants that are already in the saved favorites
    private func filterUnsavedRestaurants(from restaurants: [Tender]) -> [Tender] {
        // Fetch all saved restaurant IDs
        let descriptor = FetchDescriptor<FavoriteRestaurant>()
        guard let savedRestaurants = try? modelContext.fetch(descriptor) else {
            print("⚠️ Could not fetch saved restaurants for filtering")
            return restaurants
        }
        
        let savedIDs = Set(savedRestaurants.map { $0.id })
        print("🔍 Checking against \(savedIDs.count) saved restaurants")
        
        // Filter out any restaurant whose ID is in the saved list
        let filtered = restaurants.filter { tender in
            let isAlreadySaved = savedIDs.contains(tender.id)
            if isAlreadySaved {
                print("⏭️ Skipping '\(tender.name)' - already saved")
            }
            return !isAlreadySaved
        }
        
        let removedCount = restaurants.count - filtered.count
        if removedCount > 0 {
            print("🗑️ Filtered out \(removedCount) already-saved restaurant(s)")
        }
        
        return filtered
    }
}
