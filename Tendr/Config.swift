//
//  Config.swift
//  Tendr
//
//  Configuration for API keys and app settings
//

import Foundation

enum Config {
    /// Yelp Fusion API key
    /// Get your API key from: https://www.yelp.com/developers/v3/manage_app
    static let yelpAPIKey = "YOUR_YELP_API_KEY_HERE"
    
    // MARK: - Search Settings
    
    /// Default search radius in meters (5km)
    static let searchRadius = 5000
    
    /// Maximum number of results to fetch
    static let maxResults = 20
}
