//
//  RestaurantSearchService.swift
//  Tendr
//
//  Uses MapKit to search for nearby restaurants
//

import Foundation
import MapKit
import CoreLocation

@MainActor
class RestaurantSearchService {
    
    func searchNearbyRestaurants(near location: CLLocation) async throws -> [Tender] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "chicken tenders"
        
        // Search within 5km radius
        let region = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: 5000,
            longitudinalMeters: 5000
        )
        request.region = region
        
        // Only return point of interest results (restaurants)
        request.resultTypes = .pointOfInterest
        
        let search = MKLocalSearch(request: request)
        let response = try await search.start()
        
        // Convert MKMapItems to Tender objects
        return response.mapItems.compactMap { mapItem -> Tender? in
            guard let name = mapItem.name else { return nil }
            
            // Determine restaurant type and price range
            let (restaurantType, priceRange) = extractRestaurantInfo(from: mapItem)
            
            // Extract contact information
            let phoneNumber = mapItem.phoneNumber
            let websiteURL = mapItem.url
            
            // Get address
            let address = formatAddress(from: mapItem.placemark)
            
            return Tender(
                name: name,
                restaurantType: restaurantType,
                priceRange: priceRange,
                address: address,
                phoneNumber: phoneNumber,
                websiteURL: websiteURL,
                imageName: nil, // No local image
                imageURL: nil,  // MapKit doesn't provide restaurant photos
                latitude: mapItem.placemark.coordinate.latitude,
                longitude: mapItem.placemark.coordinate.longitude
            )
        }
    }
    
    // MARK: - Helper Methods
    
    private func extractRestaurantInfo(from mapItem: MKMapItem) -> (type: String, price: String) {
        // Check point of interest category
        if let category = mapItem.pointOfInterestCategory {
            switch category {
            case .bakery:
                return ("Bakery", "$ - $$")
            case .cafe:
                return ("Cafe", "$ - $$")
            case .restaurant:
                return ("Restaurant", "$$ - $$$")
            case .foodMarket:
                return ("Food Market", "$")
            default:
                break
            }
        }
        
        // Default based on name analysis
        let name = mapItem.name?.lowercased() ?? ""
        
        if name.contains("fast food") || name.contains("drive") {
            return ("Fast Food", "$")
        } else if name.contains("cafe") || name.contains("coffee") {
            return ("Cafe", "$ - $$")
        } else if name.contains("fine dining") || name.contains("grill") {
            return ("Restaurant", "$$$ - $$$$")
        }
        
        // Default
        return ("Restaurant", "$$ - $$$")
    }
    
    private func formatAddress(from placemark: MKPlacemark) -> String? {
        var components: [String] = []
        
        if let street = placemark.thoroughfare {
            components.append(street)
        }
        
        if let city = placemark.locality {
            components.append(city)
        }
        
        if let state = placemark.administrativeArea {
            components.append(state)
        }
        
        return components.isEmpty ? nil : components.joined(separator: ", ")
    }
}
