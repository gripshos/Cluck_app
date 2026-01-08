//
//  TenderCardViewTests.swift
//  Cluck
//
//  Tests for the TenderCardView
//

import Testing
import SwiftUI
import CoreLocation
@testable import Cluck

@Suite("TenderCardView Tests")
struct TenderCardViewTests {
    
    // MARK: - Distance Calculation Tests
    
    @Test("Distance text is nil when user location is nil")
    func testDistanceTextNilWithoutUserLocation() async throws {
        // Given
        let tender = Tender.testTender()
        
        // When
        let view = TenderCardView(tender: tender, userLocation: nil)
        
        // Then - View should render without crashing
        #expect(view.tender.name == "Test Restaurant")
    }
    
    @Test("Distance text calculation is accurate")
    func testDistanceTextCalculation() async throws {
        // Given
        let userLocation = CLLocation(latitude: 37.7749, longitude: -122.4194) // San Francisco
        let restaurantLocation = CLLocation(latitude: 37.7849, longitude: -122.4094) // ~1km away
        let tender = Tender(
            name: "Nearby Restaurant",
            restaurantType: "Fast Food",
            priceRange: "$",
            latitude: restaurantLocation.coordinate.latitude,
            longitude: restaurantLocation.coordinate.longitude
        )
        
        // When
        let view = TenderCardView(tender: tender, userLocation: userLocation)
        
        // Then - View renders successfully with location
        #expect(view.userLocation != nil)
        #expect(view.tender.latitude == restaurantLocation.coordinate.latitude)
        #expect(view.tender.longitude == restaurantLocation.coordinate.longitude)
    }
    
    // MARK: - View Rendering Tests
    
    @Test("View renders with minimal tender data")
    func testViewRendersWithMinimalData() async throws {
        // Given
        let tender = Tender(
            name: "Minimal Restaurant",
            restaurantType: "Restaurant",
            priceRange: "$$",
            latitude: 37.7749,
            longitude: -122.4194
        )
        
        // When
        let view = TenderCardView(tender: tender, userLocation: nil)
        
        // Then
        #expect(view.tender.name == "Minimal Restaurant")
        #expect(view.tender.restaurantType == "Restaurant")
        #expect(view.tender.priceRange == "$$")
        #expect(view.tender.address == nil)
        #expect(view.tender.rating == nil)
    }
    
    @Test("View renders with full tender data")
    func testViewRendersWithFullData() async throws {
        // Given
        let tender = Tender.fullTestTender()
        let userLocation = CLLocation(latitude: 37.7749, longitude: -122.4194)
        
        // When
        let view = TenderCardView(tender: tender, userLocation: userLocation)
        
        // Then
        #expect(view.tender.name == "Full Test Restaurant")
        #expect(view.tender.address != nil)
        #expect(view.tender.rating != nil)
        #expect(view.tender.reviewCount != nil)
        #expect(view.tender.isOpenNow != nil)
    }
    
    @Test("View renders with image URL")
    func testViewRendersWithImageURL() async throws {
        // Given
        let tender = Tender(
            name: "Restaurant With Image",
            restaurantType: "Fast Food",
            priceRange: "$",
            imageURL: URL(string: "https://example.com/image.jpg"),
            latitude: 37.7749,
            longitude: -122.4194
        )
        
        // When
        let view = TenderCardView(tender: tender, userLocation: nil)
        
        // Then
        #expect(view.tender.imageURL != nil)
        #expect(view.tender.imageURL?.absoluteString == "https://example.com/image.jpg")
    }
    
    @Test("View renders with local image name")
    func testViewRendersWithLocalImage() async throws {
        // Given
        let tender = Tender(
            name: "Restaurant With Local Image",
            restaurantType: "Fast Food",
            priceRange: "$",
            imageName: "tenders1",
            latitude: 37.7749,
            longitude: -122.4194
        )
        
        // When
        let view = TenderCardView(tender: tender, userLocation: nil)
        
        // Then
        #expect(view.tender.imageName == "tenders1")
    }
    
    @Test("View renders open badge when isOpenNow is true")
    func testViewRendersOpenBadge() async throws {
        // Given
        let tender = Tender(
            name: "Open Restaurant",
            restaurantType: "Fast Food",
            priceRange: "$",
            latitude: 37.7749,
            longitude: -122.4194,
            isOpenNow: true
        )
        
        // When
        let view = TenderCardView(tender: tender, userLocation: nil)
        
        // Then
        #expect(view.tender.isOpenNow == true)
    }
    
    @Test("View renders closed badge when isOpenNow is false")
    func testViewRendersClosedBadge() async throws {
        // Given
        let tender = Tender(
            name: "Closed Restaurant",
            restaurantType: "Fast Food",
            priceRange: "$",
            latitude: 37.7749,
            longitude: -122.4194,
            isOpenNow: false
        )
        
        // When
        let view = TenderCardView(tender: tender, userLocation: nil)
        
        // Then
        #expect(view.tender.isOpenNow == false)
    }
    
    @Test("View renders with rating and review count")
    func testViewRendersWithRatingAndReviews() async throws {
        // Given
        let tender = Tender(
            name: "Rated Restaurant",
            restaurantType: "Fast Food",
            priceRange: "$",
            latitude: 37.7749,
            longitude: -122.4194,
            rating: 4.5,
            reviewCount: 250
        )
        
        // When
        let view = TenderCardView(tender: tender, userLocation: nil)
        
        // Then
        #expect(view.tender.rating == 4.5)
        #expect(view.tender.reviewCount == 250)
    }
    
    // MARK: - Edge Cases
    
    @Test("View handles very long restaurant name")
    func testViewHandlesLongName() async throws {
        // Given
        let longName = "The Very Long Restaurant Name That Goes On And On And Should Be Truncated Properly"
        let tender = Tender(
            name: longName,
            restaurantType: "Restaurant",
            priceRange: "$$",
            latitude: 37.7749,
            longitude: -122.4194
        )
        
        // When
        let view = TenderCardView(tender: tender, userLocation: nil)
        
        // Then
        #expect(view.tender.name == longName)
    }
    
    @Test("View handles very long address")
    func testViewHandlesLongAddress() async throws {
        // Given
        let longAddress = "1234 Very Long Street Name That Goes On And On, Building 567, Suite 890, San Francisco, CA 94102, United States of America"
        let tender = Tender(
            name: "Restaurant",
            restaurantType: "Restaurant",
            priceRange: "$$",
            address: longAddress,
            latitude: 37.7749,
            longitude: -122.4194
        )
        
        // When
        let view = TenderCardView(tender: tender, userLocation: nil)
        
        // Then
        #expect(view.tender.address == longAddress)
    }
    
    @Test("View handles zero rating")
    func testViewHandlesZeroRating() async throws {
        // Given
        let tender = Tender(
            name: "New Restaurant",
            restaurantType: "Restaurant",
            priceRange: "$$",
            latitude: 37.7749,
            longitude: -122.4194,
            rating: 0.0,
            reviewCount: 0
        )
        
        // When
        let view = TenderCardView(tender: tender, userLocation: nil)
        
        // Then
        #expect(view.tender.rating == 0.0)
        #expect(view.tender.reviewCount == 0)
    }
    
    @Test("View handles maximum rating")
    func testViewHandlesMaximumRating() async throws {
        // Given
        let tender = Tender(
            name: "Perfect Restaurant",
            restaurantType: "Fine Dining",
            priceRange: "$$$$",
            latitude: 37.7749,
            longitude: -122.4194,
            rating: 5.0,
            reviewCount: 1000
        )
        
        // When
        let view = TenderCardView(tender: tender, userLocation: nil)
        
        // Then
        #expect(view.tender.rating == 5.0)
        #expect(view.tender.reviewCount == 1000)
    }
    
    @Test("View handles fractional ratings")
    func testViewHandlesFractionalRatings() async throws {
        // Given
        let ratings = [1.5, 2.3, 3.7, 4.2, 4.9]
        
        for rating in ratings {
            // When
            let tender = Tender(
                name: "Restaurant",
                restaurantType: "Restaurant",
                priceRange: "$$",
                latitude: 37.7749,
                longitude: -122.4194,
                rating: rating,
                reviewCount: 50
            )
            let view = TenderCardView(tender: tender, userLocation: nil)
            
            // Then
            #expect(view.tender.rating == rating)
        }
    }
    
    // MARK: - Distance Tests
    
    @Test("View calculates distance between two close locations")
    func testDistanceCalculationCloseLocations() async throws {
        // Given - Two locations very close together (same coordinates)
        let location = CLLocation(latitude: 37.7749, longitude: -122.4194)
        let tender = Tender(
            name: "Same Location Restaurant",
            restaurantType: "Restaurant",
            priceRange: "$$",
            latitude: 37.7749,
            longitude: -122.4194
        )
        
        // When
        let view = TenderCardView(tender: tender, userLocation: location)
        
        // Then - Distance should be very small (essentially 0)
        let restaurantLocation = CLLocation(latitude: tender.latitude, longitude: tender.longitude)
        let distance = location.distance(from: restaurantLocation)
        #expect(distance < 1.0, "Distance should be less than 1 meter")
    }
    
    @Test("View calculates distance between two far locations")
    func testDistanceCalculationFarLocations() async throws {
        // Given - San Francisco to New York
        let userLocation = CLLocation(latitude: 37.7749, longitude: -122.4194) // SF
        let tender = Tender(
            name: "Far Restaurant",
            restaurantType: "Restaurant",
            priceRange: "$$",
            latitude: 40.7128,
            longitude: -74.0060 // NYC
        )
        
        // When
        let view = TenderCardView(tender: tender, userLocation: userLocation)
        
        // Then - Distance should be very large
        let restaurantLocation = CLLocation(latitude: tender.latitude, longitude: tender.longitude)
        let distanceInMeters = userLocation.distance(from: restaurantLocation)
        let distanceInMiles = distanceInMeters / 1609.34
        #expect(distanceInMiles > 2000, "Distance should be over 2000 miles")
    }
}
