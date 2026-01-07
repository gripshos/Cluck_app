//
//  Restaurant.swift
//  Tendr
//
//  Core domain model for restaurant data
//

import Foundation
import CoreLocation

/// Core restaurant model used throughout the app.
/// Designed to be API-agnostic so we can swap MapKit for Yelp later.
struct Restaurant: Identifiable, Hashable, Codable, Sendable {
    let id: UUID
    let name: String
    let address: String
    let coordinate: Coordinate
    let priceLevel: PriceLevel
    let phoneNumber: String?
    let websiteURL: URL?
    let imageURL: URL?
    
    /// Nested coordinate type for Codable support (CLLocationCoordinate2D isn't Codable)
    struct Coordinate: Hashable, Codable, Sendable {
        let latitude: Double
        let longitude: Double
        
        var clCoordinate: CLLocationCoordinate2D {
            CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        
        init(latitude: Double, longitude: Double) {
            self.latitude = latitude
            self.longitude = longitude
        }
        
        init(from clCoordinate: CLLocationCoordinate2D) {
            self.latitude = clCoordinate.latitude
            self.longitude = clCoordinate.longitude
        }
    }
    
    /// Price level enum with display formatting
    enum PriceLevel: Int, Codable, Sendable, CaseIterable {
        case unknown = 0
        case cheap = 1      // $
        case moderate = 2   // $$
        case expensive = 3  // $$$
        case veryExpensive = 4 // $$$$
        
        var displayString: String {
            switch self {
            case .unknown: return "Price N/A"
            case .cheap: return "$"
            case .moderate: return "$$"
            case .expensive: return "$$$"
            case .veryExpensive: return "$$$$"
            }
        }
    }
    
    // MARK: - Hashable (by ID only for performance)
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Restaurant, rhs: Restaurant) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Convenience Initializers

extension Restaurant {
    /// Creates a Restaurant with a new UUID
    init(
        name: String,
        address: String,
        coordinate: Coordinate,
        priceLevel: PriceLevel = .moderate,
        phoneNumber: String? = nil,
        websiteURL: URL? = nil,
        imageURL: URL? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.address = address
        self.coordinate = coordinate
        self.priceLevel = priceLevel
        self.phoneNumber = phoneNumber
        self.websiteURL = websiteURL
        self.imageURL = imageURL
    }
}

// MARK: - Preview Helpers

#if DEBUG
extension Restaurant {
    static let preview = Restaurant(
        name: "Crispy Chicken Co.",
        address: "123 Main St, Columbus, OH",
        coordinate: Coordinate(latitude: 39.9612, longitude: -82.9988),
        priceLevel: .moderate,
        phoneNumber: "614-555-0100",
        websiteURL: URL(string: "https://example.com"),
        imageURL: nil
    )
    
    static let previewList: [Restaurant] = [
        Restaurant(
            name: "Crispy Chicken Co.",
            address: "123 Main St, Columbus, OH",
            coordinate: Coordinate(latitude: 39.9612, longitude: -82.9988),
            priceLevel: .cheap
        ),
        Restaurant(
            name: "Tender Love & Chicken",
            address: "456 Oak Ave, Columbus, OH",
            coordinate: Coordinate(latitude: 39.9650, longitude: -82.9950),
            priceLevel: .moderate
        ),
        Restaurant(
            name: "The Golden Tender",
            address: "789 Pine St, Columbus, OH",
            coordinate: Coordinate(latitude: 39.9580, longitude: -83.0020),
            priceLevel: .expensive
        )
    ]
}
#endif
