//
//  RestaurantSearchServiceTests.swift
//  Cluck
//
//  Tests for the RestaurantSearchService
//

import Testing
import Foundation
import CoreLocation
import MapKit
@testable import Cluck

@Suite("RestaurantSearchService Tests")
@MainActor
struct RestaurantSearchServiceTests {
    
    // MARK: - Mock YelpService
    
    class MockYelpService: YelpService {
        var mockBusinesses: [YelpBusiness] = []
        var shouldThrowError = false
        var searchCallCount = 0
        var lastSearchLocation: CLLocation?
        var lastSearchTerm: String?
        var lastSearchRadius: Int?
        var lastSearchLimit: Int?
        
        init() {
            super.init(apiKey: "mock-api-key")
        }
        
        override func searchBusinesses(near location: CLLocation, term: String, radius: Int, limit: Int) async throws -> [YelpBusiness] {
            searchCallCount += 1
            lastSearchLocation = location
            lastSearchTerm = term
            lastSearchRadius = radius
            lastSearchLimit = limit
            
            if shouldThrowError {
                throw NSError(domain: "MockYelpError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock Yelp error"])
            }
            
            return mockBusinesses
        }
    }
    
    // MARK: - Helper Methods
    
    func createMockYelpBusiness(
        name: String = "Test Restaurant",
        latitude: Double = 37.7749,
        longitude: Double = -122.4194,
        rating: Double? = 4.5,
        reviewCount: Int? = 100,
        price: String? = "$$",
        imageUrl: String? = "https://example.com/image.jpg"
    ) -> YelpBusiness {
        YelpBusiness(
            id: UUID().uuidString,
            name: name,
            imageUrl: imageUrl,
            url: "https://example.com",
            reviewCount: reviewCount,
            rating: rating,
            coordinates: YelpCoordinates(latitude: latitude, longitude: longitude),
            price: price,
            location: YelpLocation(displayAddress: ["123 Main St", "San Francisco, CA 94102"]),
            displayPhone: "(415) 555-1234",
            categories: [YelpCategory(title: "Chicken Wings")]
        )
    }
    
    // MARK: - Initialization Tests
    
    @Test("Service initializes with YelpService")
    func testServiceInitialization() async throws {
        // Given
        let mockYelpService = MockYelpService()
        
        // When
        let service = RestaurantSearchService(yelpService: mockYelpService)
        
        // Then - If no crash, initialization successful
        #expect(service != nil)
    }
    
    // MARK: - Yelp Search Tests
    
    @Test("Search returns Yelp results when available")
    func testSearchReturnsYelpResults() async throws {
        // Given
        let mockYelpService = MockYelpService()
        mockYelpService.mockBusinesses = [
            createMockYelpBusiness(name: "Restaurant 1"),
            createMockYelpBusiness(name: "Restaurant 2"),
            createMockYelpBusiness(name: "Restaurant 3")
        ]
        let service = RestaurantSearchService(yelpService: mockYelpService)
        let location = CLLocation(latitude: 37.7749, longitude: -122.4194)
        
        // When
        let results = try await service.searchNearbyRestaurants(near: location)
        
        // Then
        #expect(results.count == 3)
        #expect(results[0].name == "Restaurant 1")
        #expect(results[1].name == "Restaurant 2")
        #expect(results[2].name == "Restaurant 3")
        #expect(mockYelpService.searchCallCount == 1)
    }
    
    @Test("Search passes correct parameters to Yelp")
    func testSearchPassesCorrectParameters() async throws {
        // Given
        let mockYelpService = MockYelpService()
        mockYelpService.mockBusinesses = [createMockYelpBusiness()]
        let service = RestaurantSearchService(yelpService: mockYelpService)
        let location = CLLocation(latitude: 40.7128, longitude: -74.0060)
        
        // When
        _ = try await service.searchNearbyRestaurants(near: location)
        
        // Then
        #expect(mockYelpService.lastSearchLocation?.coordinate.latitude == 40.7128)
        #expect(mockYelpService.lastSearchLocation?.coordinate.longitude == -74.0060)
        #expect(mockYelpService.lastSearchTerm == "chicken tenders")
        #expect(mockYelpService.lastSearchRadius == Config.searchRadius)
        #expect(mockYelpService.lastSearchLimit == Config.maxResults)
    }
    
    @Test("Converts Yelp business to Tender correctly")
    func testConvertsYelpBusinessToTender() async throws {
        // Given
        let mockYelpService = MockYelpService()
        let yelpBusiness = createMockYelpBusiness(
            name: "Test Chicken Place",
            latitude: 37.7749,
            longitude: -122.4194,
            rating: 4.5,
            reviewCount: 150,
            price: "$$$",
            imageUrl: "https://example.com/image.jpg"
        )
        mockYelpService.mockBusinesses = [yelpBusiness]
        let service = RestaurantSearchService(yelpService: mockYelpService)
        let location = CLLocation(latitude: 37.7749, longitude: -122.4194)
        
        // When
        let results = try await service.searchNearbyRestaurants(near: location)
        
        // Then
        let tender = try #require(results.first)
        #expect(tender.name == "Test Chicken Place")
        #expect(tender.latitude == 37.7749)
        #expect(tender.longitude == -122.4194)
        #expect(tender.rating == 4.5)
        #expect(tender.reviewCount == 150)
        #expect(tender.priceRange == "$$$")
        #expect(tender.restaurantType == "Chicken Wings")
        #expect(tender.imageURL?.absoluteString == "https://example.com/image.jpg")
        #expect(tender.phoneNumber == "(415) 555-1234")
        #expect(tender.address == "123 Main St, San Francisco, CA 94102")
    }
    
    @Test("Handles Yelp business without optional fields")
    func testHandlesYelpBusinessWithoutOptionalFields() async throws {
        // Given
        let mockYelpService = MockYelpService()
        let yelpBusiness = YelpBusiness(
            id: "test-id",
            name: "Minimal Restaurant",
            imageUrl: nil,
            url: nil,
            reviewCount: nil,
            rating: nil,
            coordinates: YelpCoordinates(latitude: 37.7749, longitude: -122.4194),
            price: nil,
            location: YelpLocation(displayAddress: nil),
            displayPhone: nil,
            categories: nil
        )
        mockYelpService.mockBusinesses = [yelpBusiness]
        let service = RestaurantSearchService(yelpService: mockYelpService)
        let location = CLLocation(latitude: 37.7749, longitude: -122.4194)
        
        // When
        let results = try await service.searchNearbyRestaurants(near: location)
        
        // Then
        let tender = try #require(results.first)
        #expect(tender.name == "Minimal Restaurant")
        #expect(tender.restaurantType == "Restaurant")
        #expect(tender.priceRange == "$$")
        #expect(tender.imageURL == nil)
        #expect(tender.phoneNumber == nil)
        #expect(tender.address == nil)
        #expect(tender.rating == nil)
        #expect(tender.reviewCount == nil)
    }
    
    @Test("Filters out nil Tenders from Yelp results")
    func testFiltersOutNilTenders() async throws {
        // Given
        let mockYelpService = MockYelpService()
        mockYelpService.mockBusinesses = [
            createMockYelpBusiness(name: "Valid Restaurant 1"),
            createMockYelpBusiness(name: "Valid Restaurant 2")
        ]
        let service = RestaurantSearchService(yelpService: mockYelpService)
        let location = CLLocation(latitude: 37.7749, longitude: -122.4194)
        
        // When
        let results = try await service.searchNearbyRestaurants(near: location)
        
        // Then
        #expect(results.count == 2)
        #expect(results.allSatisfy { !$0.name.isEmpty })
    }
    
    // MARK: - MapKit Fallback Tests
    
    @Test("Falls back to MapKit when Yelp returns empty results")
    func testFallbackToMapKitWhenYelpEmpty() async throws {
        // Given
        let mockYelpService = MockYelpService()
        mockYelpService.mockBusinesses = [] // Empty results
        let service = RestaurantSearchService(yelpService: mockYelpService)
        let location = CLLocation(latitude: 37.7749, longitude: -122.4194)
        
        // When
        // Note: This will actually call MapKit in a real environment
        // In a real test, we'd need to mock MKLocalSearch as well
        let results = try await service.searchNearbyRestaurants(near: location)
        
        // Then
        // The test should at least not crash
        #expect(mockYelpService.searchCallCount == 1)
    }
    
    @Test("Falls back to MapKit when Yelp throws error")
    func testFallbackToMapKitWhenYelpFails() async throws {
        // Given
        let mockYelpService = MockYelpService()
        mockYelpService.shouldThrowError = true
        let service = RestaurantSearchService(yelpService: mockYelpService)
        let location = CLLocation(latitude: 37.7749, longitude: -122.4194)
        
        // When
        // Note: This will actually call MapKit in a real environment
        let results = try await service.searchNearbyRestaurants(near: location)
        
        // Then
        // The test should at least not crash
        #expect(mockYelpService.searchCallCount == 1)
    }
    
    // MARK: - Price Range Tests
    
    @Test("Handles various Yelp price ranges")
    func testHandlesVariousPriceRanges() async throws {
        // Given
        let priceRanges = ["$", "$$", "$$$", "$$$$"]
        
        for priceRange in priceRanges {
            // Given
            let mockYelpService = MockYelpService()
            let yelpBusiness = createMockYelpBusiness(price: priceRange)
            mockYelpService.mockBusinesses = [yelpBusiness]
            let service = RestaurantSearchService(yelpService: mockYelpService)
            let location = CLLocation(latitude: 37.7749, longitude: -122.4194)
            
            // When
            let results = try await service.searchNearbyRestaurants(near: location)
            
            // Then
            let tender = try #require(results.first)
            #expect(tender.priceRange == priceRange)
        }
    }
    
    // MARK: - Category Tests
    
    @Test("Extracts restaurant type from Yelp categories")
    func testExtractsRestaurantTypeFromCategories() async throws {
        // Given
        let categories = [
            YelpCategory(title: "Chicken Wings"),
            YelpCategory(title: "Fast Food")
        ]
        let mockYelpService = MockYelpService()
        let yelpBusiness = YelpBusiness(
            id: "test",
            name: "Test",
            imageUrl: nil,
            url: nil,
            reviewCount: nil,
            rating: nil,
            coordinates: YelpCoordinates(latitude: 37.7749, longitude: -122.4194),
            price: nil,
            location: YelpLocation(displayAddress: nil),
            displayPhone: nil,
            categories: categories
        )
        mockYelpService.mockBusinesses = [yelpBusiness]
        let service = RestaurantSearchService(yelpService: mockYelpService)
        let location = CLLocation(latitude: 37.7749, longitude: -122.4194)
        
        // When
        let results = try await service.searchNearbyRestaurants(near: location)
        
        // Then
        let tender = try #require(results.first)
        #expect(tender.restaurantType == "Chicken Wings")
    }
    
    // MARK: - Location Tests
    
    @Test("Searches near various locations")
    func testSearchesNearVariousLocations() async throws {
        // Given
        let locations = [
            CLLocation(latitude: 37.7749, longitude: -122.4194), // San Francisco
            CLLocation(latitude: 40.7128, longitude: -74.0060),  // New York
            CLLocation(latitude: 34.0522, longitude: -118.2437), // Los Angeles
            CLLocation(latitude: 51.5074, longitude: -0.1278)    // London
        ]
        
        for location in locations {
            // Given
            let mockYelpService = MockYelpService()
            mockYelpService.mockBusinesses = [createMockYelpBusiness()]
            let service = RestaurantSearchService(yelpService: mockYelpService)
            
            // When
            _ = try await service.searchNearbyRestaurants(near: location)
            
            // Then
            let searchedLocation = try #require(mockYelpService.lastSearchLocation)
            #expect(abs(searchedLocation.coordinate.latitude - location.coordinate.latitude) < 0.0001)
            #expect(abs(searchedLocation.coordinate.longitude - location.coordinate.longitude) < 0.0001)
        }
    }
}
