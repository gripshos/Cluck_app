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
    
    private let searchService: RestaurantSearchService
    private let locationManager: LocationManager
    
    init(searchService: RestaurantSearchService, locationManager: LocationManager) {
        self.searchService = searchService
        self.locationManager = locationManager
    }
    
    func loadRestaurants(excluding savedNames: Set<String> = []) async {
        guard let location = locationManager.location else {
            errorMessage = "Unable to get your location"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let allTenders = try await searchService.searchNearbyRestaurants(near: location)
            
            // Filter out restaurants that are already saved
            // Use lowercased comparison for case-insensitive matching
            let lowercasedSavedNames = Set(savedNames.map { $0.lowercased() })
            tenders = allTenders.filter { tender in
                !lowercasedSavedNames.contains(tender.name.lowercased())
            }
            
            if tenders.isEmpty && !allTenders.isEmpty {
                errorMessage = "You've saved all nearby restaurants! 🎉"
            } else if tenders.isEmpty {
                errorMessage = "No restaurants found nearby"
            }
        } catch {
            errorMessage = "Failed to load restaurants: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func removeTopCard() {
        guard !tenders.isEmpty else { return }
        tenders.removeFirst()
    }
    
    /// Remove a specific restaurant from the deck (used when saving)
    func removeFromDeck(named restaurantName: String) {
        tenders.removeAll { $0.name.lowercased() == restaurantName.lowercased() }
    }
}
