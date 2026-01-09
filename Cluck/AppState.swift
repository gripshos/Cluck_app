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
    
    // StoreKit service for tip jar
    let storeKitService: StoreKitService
    
    init() {
        // Initialize search service with Yelp integration
        self.searchService = RestaurantSearchService(yelpService: yelpService)
        
        // Initialize StoreKit service
        self.storeKitService = StoreKitService()
        
        // Request location permission on app launch
        locationManager.requestLocation()
    }
}
