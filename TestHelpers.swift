//
//  TestHelpers.swift
//  Cluck
//
//  Helper types and utilities for testing
//

import Foundation
import CoreLocation
import SwiftData
@testable import Cluck

// MARK: - Mock YelpService Types

/// Mock Yelp coordinates structure
struct YelpCoordinates: Codable {
    let latitude: Double
    let longitude: Double
}

/// Mock Yelp location structure
struct YelpLocation: Codable {
    let displayAddress: [String]?
}

/// Mock Yelp category structure
struct YelpCategory: Codable {
    let title: String
}

/// Mock Yelp business structure
struct YelpBusiness: Codable {
    let id: String
    let name: String
    let imageUrl: String?
    let url: String?
    let reviewCount: Int?
    let rating: Double?
    let coordinates: YelpCoordinates
    let price: String?
    let location: YelpLocation
    let displayPhone: String?
    let categories: [YelpCategory]?
}

/// Mock YelpService for testing
@MainActor
class YelpService {
    let apiKey: String
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func searchBusinesses(near location: CLLocation, term: String, radius: Int, limit: Int) async throws -> [YelpBusiness] {
        // Default implementation returns empty array
        return []
    }
}

// MARK: - Mock AppState

/// Mock AppState for testing
@Observable
@MainActor
class AppState {
    let searchService: RestaurantSearchService
    let locationManager: LocationManager
    
    init() {
        self.locationManager = LocationManager()
        self.searchService = RestaurantSearchService(yelpService: YelpService(apiKey: "test"))
    }
}

// MARK: - Mock LocationManager

/// Mock LocationManager for testing
class LocationManager: NSObject {
    var location: CLLocation?
    
    override init() {
        super.init()
    }
}

// MARK: - Mock FavoriteRestaurant (SwiftData Model)

/// Mock FavoriteRestaurant model for testing
@Model
class FavoriteRestaurant {
    var id: UUID
    var name: String
    var restaurantType: String
    var priceRange: String
    var address: String?
    var phoneNumber: String?
    var websiteURLString: String?
    var imageURLString: String?
    var latitude: Double
    var longitude: Double
    var rating: Double?
    var reviewCount: Int?
    var savedDate: Date
    
    init(from tender: Tender) {
        self.id = tender.id
        self.name = tender.name
        self.restaurantType = tender.restaurantType
        self.priceRange = tender.priceRange
        self.address = tender.address
        self.phoneNumber = tender.phoneNumber
        self.websiteURLString = tender.websiteURL?.absoluteString
        self.imageURLString = tender.imageURL?.absoluteString
        self.latitude = tender.latitude
        self.longitude = tender.longitude
        self.rating = tender.rating
        self.reviewCount = tender.reviewCount
        self.savedDate = Date()
    }
}

// MARK: - Test Helpers

extension Tender {
    /// Create a test Tender with default values
    static func testTender(
        name: String = "Test Restaurant",
        restaurantType: String = "Fast Food",
        priceRange: String = "$$",
        latitude: Double = 37.7749,
        longitude: Double = -122.4194
    ) -> Tender {
        Tender(
            name: name,
            restaurantType: restaurantType,
            priceRange: priceRange,
            latitude: latitude,
            longitude: longitude
        )
    }
    
    /// Create a fully populated test Tender
    static func fullTestTender(
        name: String = "Full Test Restaurant"
    ) -> Tender {
        Tender(
            name: name,
            restaurantType: "Fast Food",
            priceRange: "$$$",
            address: "123 Test St, San Francisco, CA",
            phoneNumber: "(415) 555-1234",
            websiteURL: URL(string: "https://example.com"),
            imageURL: URL(string: "https://example.com/image.jpg"),
            latitude: 37.7749,
            longitude: -122.4194,
            rating: 4.5,
            reviewCount: 100,
            isOpenNow: true,
            additionalPhotos: [
                URL(string: "https://example.com/photo1.jpg")!,
                URL(string: "https://example.com/photo2.jpg")!
            ]
        )
    }
}
