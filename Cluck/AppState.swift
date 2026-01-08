//
//  AppState.swift
//  Cluck
//
//  Central app state managing all dependencies
//
import SwiftUI
import Observation

@MainActor
@Observable
class AppState {
    // Location manager handles user location
    let locationManager = LocationManager()
    
    // Yelp service for restaurant data and images
    let yelpService = YelpService(apiKey: Config.yelpAPIKey)
    
    // Restaurant search service
    let searchService: RestaurantSearchService
    
    init() {
        // Initialize search service with Yelp integration
        self.searchService = RestaurantSearchService(yelpService: yelpService)
        
        // Request location permission on app launch
        locationManager.requestLocation()
    }
}
