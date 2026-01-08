//
//  RestaurantRepository.swift
//  Tendr
//
//  Repository layer for restaurant data with business logic
//

import Foundation
import CoreLocation

/// Repository that coordinates data fetching and applies business rules.
/// Abstracts the data source so views don't care where data comes from.
@Observable
final class RestaurantRepository: @unchecked Sendable {
    
    // MARK: - Configuration
    
    struct Config {
        var searchQuery: String = "chicken tenders"
        var searchRadiusMeters: Double = 5000 // 5km default
        var minResultsBeforeExpanding: Int = 3
        var expandedRadiusMeters: Double = 10000 // 10km fallback
    }
    
    // MARK: - Properties
    
    private let dataSource: RestaurantDataSource
    private let config: Config
    
    // Cache to avoid redundant searches
    private var cachedResults: [Restaurant] = []
    private var lastSearchLocation: CLLocation?
    private var lastSearchTime: Date?
    private let cacheValiditySeconds: TimeInterval = 300 // 5 minutes
    
    // MARK: - Init
    
    init(dataSource: RestaurantDataSource = MapKitDataSource(), config: Config = Config()) {
        self.dataSource = dataSource
        self.config = config
    }
    
    // MARK: - Public Methods
    
    /// Search for restaurants near the given location.
    /// Returns cached results if valid, otherwise fetches fresh data.
    func searchNearby(location: CLLocation) async throws -> [Restaurant] {
        
        // Check cache validity
        if let cached = cachedResultsIfValid(for: location) {
            return cached
        }
        
        // Fetch from data source
        var results = try await dataSource.searchRestaurants(
            near: location,
            query: config.searchQuery,
            radiusMeters: config.searchRadiusMeters
        )
        
        // If too few results, try expanded radius
        if results.count < config.minResultsBeforeExpanding {
            let expandedResults = try await dataSource.searchRestaurants(
                near: location,
                query: config.searchQuery,
                radiusMeters: config.expandedRadiusMeters
            )
            results = expandedResults
        }
        
        // Apply business rules
        let processed = applyBusinessRules(to: results, userLocation: location)
        
        // Update cache
        cachedResults = processed
        lastSearchLocation = location
        lastSearchTime = Date()
        
        if processed.isEmpty {
            throw SearchError.noResults
        }
        
        return processed
    }
    
    /// Clear the cache to force a fresh search
    func clearCache() {
        cachedResults = []
        lastSearchLocation = nil
        lastSearchTime = nil
    }
    
    // MARK: - Private Methods
    
    private func cachedResultsIfValid(for location: CLLocation) -> [Restaurant]? {
        guard !cachedResults.isEmpty,
              let lastLocation = lastSearchLocation,
              let lastTime = lastSearchTime else {
            return nil
        }
        
        // Cache is valid if:
        // 1. Less than cacheValiditySeconds old
        // 2. User hasn't moved more than 500 meters
        let timeSinceLastSearch = Date().timeIntervalSince(lastTime)
        let distanceMoved = location.distance(from: lastLocation)
        
        if timeSinceLastSearch < cacheValiditySeconds && distanceMoved < 500 {
            return cachedResults
        }
        
        return nil
    }
    
    private func applyBusinessRules(to restaurants: [Restaurant], userLocation: CLLocation) -> [Restaurant] {
        var processed = restaurants
        
        // 1. Remove duplicates (by name + approximate location)
        processed = removeDuplicates(from: processed)
        
        // 2. Sort by distance from user
        processed = sortByDistance(restaurants: processed, from: userLocation)
        
        // 3. Filter out places that are too far (sanity check)
        let maxDistance = config.expandedRadiusMeters * 1.5
        processed = processed.filter { restaurant in
            let restaurantLocation = CLLocation(
                latitude: restaurant.coordinate.latitude,
                longitude: restaurant.coordinate.longitude
            )
            return restaurantLocation.distance(from: userLocation) <= maxDistance
        }
        
        return processed
    }
    
    private func removeDuplicates(from restaurants: [Restaurant]) -> [Restaurant] {
        var seen = Set<String>()
        return restaurants.filter { restaurant in
            // Create a key from name + rounded coordinates (to catch same place, slight coord differences)
            let latRounded = (restaurant.coordinate.latitude * 1000).rounded() / 1000
            let lonRounded = (restaurant.coordinate.longitude * 1000).rounded() / 1000
            let key = "\(restaurant.name.lowercased())-\(latRounded)-\(lonRounded)"
            
            if seen.contains(key) {
                return false
            }
            seen.insert(key)
            return true
        }
    }
    
    private func sortByDistance(restaurants: [Restaurant], from userLocation: CLLocation) -> [Restaurant] {
        return restaurants.sorted { a, b in
            let locationA = CLLocation(latitude: a.coordinate.latitude, longitude: a.coordinate.longitude)
            let locationB = CLLocation(latitude: b.coordinate.latitude, longitude: b.coordinate.longitude)
            return locationA.distance(from: userLocation) < locationB.distance(from: userLocation)
        }
    }
}

// MARK: - Preview/Testing Support

#if DEBUG
extension RestaurantRepository {
    /// Creates a repository with mock data for previews
    static var preview: RestaurantRepository {
        RestaurantRepository(dataSource: MockRestaurantDataSource())
    }
    
    /// Creates a repository that will fail for testing error states
    static var failing: RestaurantRepository {
        var mockSource = MockRestaurantDataSource()
        mockSource.shouldFail = true
        return RestaurantRepository(dataSource: mockSource)
    }
}
#endif
