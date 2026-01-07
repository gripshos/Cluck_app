//
//  MapKitDataSource.swift
//  Tendr
//
//  MapKit-based restaurant search implementation
//

import Foundation
import MapKit
import CoreLocation

// MARK: - Protocol

/// Protocol for restaurant data sources, allowing swappable implementations (MapKit, Yelp, etc.)
protocol RestaurantDataSource: Sendable {
    func searchRestaurants(near location: CLLocation, query: String, radiusMeters: Double) async throws -> [Restaurant]
}

// MARK: - MapKit Implementation

/// Searches for restaurants using Apple's MapKit Local Search API.
/// Free, no API key required, good coverage.
struct MapKitDataSource: RestaurantDataSource {
    
    func searchRestaurants(
        near location: CLLocation,
        query: String = "chicken tenders",
        radiusMeters: Double = 5000
    ) async throws -> [Restaurant] {
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: radiusMeters,
            longitudinalMeters: radiusMeters
        )
        request.resultTypes = [.pointOfInterest]
        
        let search = MKLocalSearch(request: request)
        
        do {
            let response = try await search.start()
            return response.mapItems.compactMap { mapItem in
                mapItemToRestaurant(mapItem)
            }
        } catch let error as MKError {
            throw mapMKError(error)
        } catch {
            throw SearchError.unknown(underlying: error.localizedDescription)
        }
    }
    
    // MARK: - Private Helpers
    
    private func mapItemToRestaurant(_ mapItem: MKMapItem) -> Restaurant? {
        guard let name = mapItem.name,
              let coordinate = mapItem.placemark.location?.coordinate else {
            return nil
        }
        
        let address = formatAddress(from: mapItem.placemark)
        let priceLevel = determinePriceLevel(from: mapItem.pointOfInterestCategory)
        
        return Restaurant(
            name: name,
            address: address,
            coordinate: Restaurant.Coordinate(from: coordinate),
            priceLevel: priceLevel,
            phoneNumber: mapItem.phoneNumber,
            websiteURL: mapItem.url,
            imageURL: nil // MapKit doesn't provide images
        )
    }
    
    private func formatAddress(from placemark: MKPlacemark) -> String {
        let components = [
            placemark.thoroughfare,
            placemark.locality,
            placemark.administrativeArea
        ].compactMap { $0 }
        
        return components.isEmpty ? "Address unavailable" : components.joined(separator: ", ")
    }
    
    private func determinePriceLevel(from category: MKPointOfInterestCategory?) -> Restaurant.PriceLevel {
        guard let category = category else { return .moderate }
        
        switch category {
        case .restaurant:
            return .moderate
        case .foodMarket:
            return .cheap
        case .cafe, .bakery:
            return .cheap
        default:
            return .moderate
        }
    }
    
    private func mapMKError(_ error: MKError) -> SearchError {
        switch error.code {
        case .placemarkNotFound, .directionsNotFound:
            return .noResults
        case .networkFailure, .serverFailure, .loadingThrottled:
            return .networkError(underlying: error.localizedDescription)
        default:
            return .unknown(underlying: error.localizedDescription)
        }
    }
}

// MARK: - Mock Data Source for Testing

#if DEBUG
struct MockRestaurantDataSource: RestaurantDataSource {
    var mockResults: [Restaurant] = Restaurant.previewList
    var shouldFail: Bool = false
    var failureError: SearchError = .networkError(underlying: "Mock network error")
    
    func searchRestaurants(
        near location: CLLocation,
        query: String,
        radiusMeters: Double
    ) async throws -> [Restaurant] {
        // Simulate network delay
        try await Task.sleep(for: .milliseconds(500))
        
        if shouldFail {
            throw failureError
        }
        
        return mockResults
    }
}
#endif
