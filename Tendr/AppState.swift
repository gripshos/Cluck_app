//
//  AppState.swift
//  Tendr
//
//  Central app state managing all dependencies
//

import SwiftUI
import Observation

@Observable
class AppState {
    // Location manager handles user location
    let locationManager = LocationManager()
    
    // Restaurant search service
    let searchService = RestaurantSearchService()
    
    init() {
        // Request location permission on app launch
        locationManager.requestLocation()
    }
}
