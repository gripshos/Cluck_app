//
//  DiscoveryViewModel.swift
//  Tendr
//
//  ViewModel for the restaurant discovery/swipe feature
//

import Foundation
import CoreLocation
import Observation

/// Manages state and actions for the discovery swipe deck.
@Observable
@MainActor
final class DiscoveryViewModel {
    
    // MARK: - State
    
    /// Current search state
    private(set) var searchState: SearchState<[Restaurant]> = .idle
    
    /// The deck of restaurants to swipe through
    private(set) var deck: [Restaurant] = []
    
    /// Index of the current top card
    private(set) var currentIndex: Int = 0
    
    /// The currently visible restaurant (top of deck)
    var currentRestaurant: Restaurant? {
        guard currentIndex < deck.count else { return nil }
        return deck[currentIndex]
    }
    
    /// Whether there are more cards to show
    var hasMoreCards: Bool {
        currentIndex < deck.count
    }
    
    /// Number of remaining cards
    var remainingCount: Int {
        max(0, deck.count - currentIndex)
    }
    
    // MARK: - Dependencies
    
    private let restaurantRepository: RestaurantRepository
    private let favoritesRepository: FavoritesRepository
    private let locationService: LocationService
    
    // MARK: - Init
    
    init(
        restaurantRepository: RestaurantRepository,
        favoritesRepository: FavoritesRepository,
        locationService: LocationService
    ) {
        self.restaurantRepository = restaurantRepository
        self.favoritesRepository = favoritesRepository
        self.locationService = locationService
    }
    
    // MARK: - Actions
    
    /// Load restaurants near the user's current location
    func loadRestaurants() async {
        // Don't reload if already loading
        guard !searchState.isLoading else { return }
        
        searchState = .loading
        
        do {
            // Get location
            let location = try await locationService.getCurrentLocation()
            
            // Search for restaurants
            let restaurants = try await restaurantRepository.searchNearby(location: location)
            
            // Update state
            deck = restaurants
            currentIndex = 0
            searchState = restaurants.isEmpty ? .empty : .success(restaurants)
            
        } catch let error as SearchError {
            searchState = .failure(error)
        } catch {
            searchState = .failure(.unknown(underlying: error.localizedDescription))
        }
    }
    
    /// Handle swipe left (dismiss/skip)
    func swipeLeft() {
        guard hasMoreCards else { return }
        currentIndex += 1
        
        // Check if we've run out of cards
        if !hasMoreCards {
            searchState = .empty
        }
    }
    
    /// Handle swipe right (like/save)
    func swipeRight() {
        guard let restaurant = currentRestaurant else { return }
        
        // Save to favorites
        favoritesRepository.add(restaurant)
        
        // Advance to next card
        currentIndex += 1
        
        // Check if we've run out of cards
        if !hasMoreCards {
            searchState = .empty
        }
    }
    
    /// Reset and reload the deck
    func refresh() async {
        restaurantRepository.clearCache()
        currentIndex = 0
        deck = []
        await loadRestaurants()
    }
    
    /// Request location permission
    func requestLocationPermission() {
        locationService.requestAuthorization()
    }
    
    /// Check if location permission is granted
    var hasLocationPermission: Bool {
        let status = locationService.authorizationStatus
        return status == .authorizedWhenInUse || status == .authorizedAlways
    }
    
    /// Check if location permission was denied
    var locationPermissionDenied: Bool {
        locationService.authorizationStatus == .denied
    }
}

// MARK: - Preview Support

#if DEBUG
extension DiscoveryViewModel {
    /// Creates a view model with mock data for previews
    static var preview: DiscoveryViewModel {
        let vm = DiscoveryViewModel(
            restaurantRepository: .preview,
            favoritesRepository: .empty,
            locationService: LocationService()
        )
        // Pre-populate with mock data
        vm.deck = Restaurant.previewList
        vm.searchState = .success(Restaurant.previewList)
        return vm
    }
    
    /// Creates a view model in loading state
    static var loading: DiscoveryViewModel {
        let vm = DiscoveryViewModel(
            restaurantRepository: .preview,
            favoritesRepository: .empty,
            locationService: LocationService()
        )
        vm.searchState = .loading
        return vm
    }
    
    /// Creates a view model in error state
    static var error: DiscoveryViewModel {
        let vm = DiscoveryViewModel(
            restaurantRepository: .failing,
            favoritesRepository: .empty,
            locationService: LocationService()
        )
        vm.searchState = .failure(.networkError(underlying: "Mock error"))
        return vm
    }
    
    /// Creates a view model in empty state
    static var empty: DiscoveryViewModel {
        let vm = DiscoveryViewModel(
            restaurantRepository: .preview,
            favoritesRepository: .empty,
            locationService: LocationService()
        )
        vm.searchState = .empty
        return vm
    }
}
#endif
