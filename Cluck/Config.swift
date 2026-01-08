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
    static let yelpAPIKey = "xiUiit-fqRAYAntBURBq6sDPIK7a1JoCiy3ye5npbcpI3g7ES5Kul3H3A8r9e0pTztZ37orax1e6k3OXLlPVU9vzEJh1tbX1ASJjHz3XmPGQnRT7EBKZud6uGWddaXYx"
    
    // MARK: - Search Settings
    
    /// Default search radius in meters (5km)
    static let searchRadius = 5000
    
    /// Maximum number of results to fetch
    static let maxResults = 20
}
