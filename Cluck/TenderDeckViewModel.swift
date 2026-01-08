//
//  TenderDeckViewModel.swift
//  Cluck
//
//  Manages the state of the tender deck
//

import SwiftUI
import Observation
import CoreLocation

@Observable
@MainActor
class TenderDeckViewModel {
    var tenders: [Tender] = []
    var isLoading = false
    var errorMessage: String?
    var lastSwipedRestaurant: Tender?
    
    private let searchService: RestaurantSearchService
    private let locationManager: LocationManager
    
    var userLocation: CLLocation? {
        locationManager.location
    }
    
    init(searchService: RestaurantSearchService, locationManager: LocationManager) {
        self.searchService = searchService
        self.locationManager = locationManager
    }
    
    func loadRestaurants() async {
        guard let location = locationManager.location else {
            errorMessage = "Unable to get your location"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            tenders = try await searchService.searchNearbyRestaurants(near: location)
            
            if tenders.isEmpty {
                errorMessage = "No restaurants found nearby"
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
}
