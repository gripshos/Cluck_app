//
//  RestaurantSearchService.swift
//  Cluck
//
//  Uses MapKit and Yelp to search for nearby restaurants
//

import Foundation
import MapKit
import CoreLocation

@MainActor
class RestaurantSearchService {
    
    private let yelpService: YelpService
    
    init(yelpService: YelpService) {
        self.yelpService = yelpService
    }
    
    func searchNearbyRestaurants(near location: CLLocation) async throws -> [Tender] {
        // First, try to get data directly from Yelp
        do {
            let yelpBusinesses = try await yelpService.searchBusinesses(
                near: location,
                term: "chicken tenders",
                radius: Config.searchRadius,
                limit: Config.maxResults
            )
            
            // Convert Yelp businesses to Tender objects
            let tenders = yelpBusinesses.compactMap { business -> Tender? in
                createTender(from: business)
            }
            
            if !tenders.isEmpty {
                return tenders
            }
        } catch {
            print("⚠️ Yelp search failed: \(error.localizedDescription)")
            // Fall through to MapKit backup
        }
        
        // Fallback to MapKit if Yelp fails or returns no results
        return try await searchWithMapKit(near: location)
    }
    
    // MARK: - Yelp Integration
    
    private func createTender(from yelpBusiness: YelpBusiness) -> Tender? {
        // Determine restaurant type from categories
        let restaurantType = yelpBusiness.categories?.first?.title ?? "Restaurant"
        
        // Use Yelp's price range or default
        let priceRange = yelpBusiness.price ?? "$$"
        
        // Format address from Yelp location
        let address = yelpBusiness.location.displayAddress?.joined(separator: ", ")
        
        // Parse image URL
        let imageURL: URL? = {
            guard let imageUrlString = yelpBusiness.imageUrl else { return nil }
            return URL(string: imageUrlString)
        }()
        
        // Parse website URL
        let websiteURL: URL? = {
            guard let urlString = yelpBusiness.url else { return nil }
            return URL(string: urlString)
        }()
        
        return Tender(
            name: yelpBusiness.name,
            restaurantType: restaurantType,
            priceRange: priceRange,
            address: address,
            phoneNumber: yelpBusiness.displayPhone,
            websiteURL: websiteURL,
            imageName: nil,
            imageURL: imageURL,
            latitude: yelpBusiness.coordinates.latitude,
            longitude: yelpBusiness.coordinates.longitude,
            rating: yelpBusiness.rating,
            reviewCount: yelpBusiness.reviewCount,
            isOpenNow: nil,
            additionalPhotos: nil
        )
    }
    
    // MARK: - MapKit Fallback
    
    private func searchWithMapKit(near location: CLLocation) async throws -> [Tender] {
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
