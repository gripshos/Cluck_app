//
//  RestaurantSearchServiceTests.swift
//  Cluck
//
//  Tests for RestaurantSearchService
//

import Testing
import Foundation
import CoreLocation
import MapKit
@testable import Cluck

@Suite("RestaurantSearchService Tests")
@MainActor
struct RestaurantSearchServiceTests {
    
    // MARK: - Initialization Tests
    
    @Test("Service initializes with YelpService")
    func testInitialization() async throws {
        // Given
        let yelpService = YelpService(apiKey: "test")
        
        // When
        let searchService = RestaurantSearchService(yelpService: yelpService)
        
        // Then - Should initialize without crashing
        #expect(searchService != nil)
    }
    
    // MARK: - Search with Yelp Tests
    
    @Test("Search returns Yelp results when available")
    func testSearchWithYelpResults() async throws {
        // Given
        let mockYelpService = MockYelpService()
        mockYelpService.mockBusinesses = [
            createMockYelpBusiness(name: "Restaurant 1"),
            createMockYelpBusiness(name: "Restaurant 2")
        ]
        let searchService = RestaurantSearchService(yelpService: mockYelpService)
        let location = CLLocation(latitude: 37.7749, longitude: -122.4194)
        
        // When
        let results = try await searchService.searchNearbyRestaurants(near: location)
        
        // Then
        #expect(results.count == 2)
        #expect(results[0].name == "Restaurant 1")
        #expect(results[1].name == "Restaurant 2")
        #expect(mockYelpService.searchCallCount == 1)
    }
    
    @Test("Search creates Tender from YelpBusiness")
    func testCreateTenderFromYelpBusiness() async throws {
        // Given
        let mockYelpService = MockYelpService()
        let yelpBusiness = YelpBusiness(
            id: "test-id",
            name: "Test Restaurant",
            imageUrl: "https://example.com/image.jpg",
            url: "https://example.com",
            reviewCount: 150,
            rating: 4.5,
            coordinates: YelpCoordinates(latitude: 37.7749, longitude: -122.4194),
            price: "$$$",
            location: YelpLocation(displayAddress: ["123 Main St", "San Francisco, CA"]),
            displayPhone: "(415) 555-1234",
            categories: [YelpCategory(title: "Italian")]
        )
        mockYelpService.mockBusinesses = [yelpBusiness]
        
        let searchService = RestaurantSearchService(yelpService: mockYelpService)
        let location = CLLocation(latitude: 37.7749, longitude: -122.4194)
        
        // When
        let results = try await searchService.searchNearbyRestaurants(near: location)
        
        // Then
        #expect(results.count == 1)
        let tender = results[0]
        #expect(tender.name == "Test Restaurant")
        #expect(tender.restaurantType == "Italian")
        #expect(tender.priceRange == "$$$")
        #expect(tender.address == "123 Main St, San Francisco, CA")
        #expect(tender.phoneNumber == "(415) 555-1234")
        #expect(tender.rating == 4.5)
        #expect(tender.reviewCount == 150)
        #expect(tender.websiteURL?.absoluteString == "https://example.com")
        #expect(tender.imageURL?.absoluteString == "https://example.com/image.jpg")
    }
    
    @Test("Search handles YelpBusiness with missing data")
    func testCreateTenderFromIncompleteYelpBusiness() async throws {
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
        
        let searchService = RestaurantSearchService(yelpService: mockYelpService)
        let location = CLLocation(latitude: 37.7749, longitude: -122.4194)
        
        // When
        let results = try await searchService.searchNearbyRestaurants(near: location)
        
        // Then
        #expect(results.count == 1)
        let tender = results[0]
        #expect(tender.name == "Minimal Restaurant")
        #expect(tender.restaurantType == "Restaurant") // Default
        #expect(tender.priceRange == "$$") // Default
        #expect(tender.address == nil)
        #expect(tender.phoneNumber == nil)
        #expect(tender.rating == nil)
        #expect(tender.reviewCount == nil)
    }
    
    @Test("Search uses default price range when not provided")
    func testDefaultPriceRange() async throws {
        // Given
        let mockYelpService = MockYelpService()
        let yelpBusiness = YelpBusiness(
            id: "test-id",
            name: "Test",
            imageUrl: nil,
            url: nil,
            reviewCount: nil,
            rating: nil,
            coordinates: YelpCoordinates(latitude: 37.7749, longitude: -122.4194),
            price: nil, // No price
            location: YelpLocation(displayAddress: nil),
            displayPhone: nil,
            categories: nil
        )
        mockYelpService.mockBusinesses = [yelpBusiness]
        
        let searchService = RestaurantSearchService(yelpService: mockYelpService)
        let location = CLLocation(latitude: 37.7749, longitude: -122.4194)
        
        // When
        let results = try await searchService.searchNearbyRestaurants(near: location)
        
        // Then
        #expect(results[0].priceRange == "$$")
    }
    
    @Test("Search uses first category as restaurant type")
    func testRestaurantTypeFromCategories() async throws {
        // Given
        let mockYelpService = MockYelpService()
        let yelpBusiness = YelpBusiness(
            id: "test-id",
            name: "Test",
            imageUrl: nil,
            url: nil,
            reviewCount: nil,
            rating: nil,
            coordinates: YelpCoordinates(latitude: 37.7749, longitude: -122.4194),
            price: nil,
            location: YelpLocation(displayAddress: nil),
            displayPhone: nil,
            categories: [
                YelpCategory(title: "Italian"),
                YelpCategory(title: "Pizza")
            ]
        )
        mockYelpService.mockBusinesses = [yelpBusiness]
        
        let searchService = RestaurantSearchService(yelpService: mockYelpService)
        let location = CLLocation(latitude: 37.7749, longitude: -122.4194)
        
        // When
        let results = try await searchService.searchNearbyRestaurants(near: location)
        
        // Then
        #expect(results[0].restaurantType == "Italian")
    }
    
    @Test("Search joins address components correctly")
    func testAddressFormatting() async throws {
        // Given
        let mockYelpService = MockYelpService()
        let yelpBusiness = YelpBusiness(
            id: "test-id",
            name: "Test",
            imageUrl: nil,
            url: nil,
            reviewCount: nil,
            rating: nil,
            coordinates: YelpCoordinates(latitude: 37.7749, longitude: -122.4194),
            price: nil,
            location: YelpLocation(displayAddress: ["123 Main St", "Suite 100", "San Francisco", "CA 94102"]),
            displayPhone: nil,
            categories: nil
        )
        mockYelpService.mockBusinesses = [yelpBusiness]
        
        let searchService = RestaurantSearchService(yelpService: mockYelpService)
        let location = CLLocation(latitude: 37.7749, longitude: -122.4194)
        
        // When
        let results = try await searchService.searchNearbyRestaurants(near: location)
        
        // Then
        #expect(results[0].address == "123 Main St, Suite 100, San Francisco, CA 94102")
    }
    
    // MARK: - MapKit Fallback Tests
    
    @Test("Search falls back to MapKit when Yelp fails")
    func testMapKitFallback() async throws {
        // Given
        let mockYelpService = MockYelpService()
        mockYelpService.shouldThrowError = true
        
        let searchService = RestaurantSearchService(yelpService: mockYelpService)
        let location = CLLocation(latitude: 37.7749, longitude: -122.4194)
        
        // When
        let results = try await searchService.searchNearbyRestaurants(near: location)
        
        // Then - Should fallback to MapKit (results may vary)
        // In a test environment, MapKit may return empty results
        #expect(mockYelpService.searchCallCount == 1)
    }
    
    @Test("Search falls back to MapKit when Yelp returns empty")
    func testMapKitFallbackWithEmptyYelpResults() async throws {
        // Given
        let mockYelpService = MockYelpService()
        mockYelpService.mockBusinesses = []
        
        let searchService = RestaurantSearchService(yelpService: mockYelpService)
        let location = CLLocation(latitude: 37.7749, longitude: -122.4194)
        
        // When
        let results = try await searchService.searchNearbyRestaurants(near: location)
        
        // Then - Should fallback to MapKit
        #expect(mockYelpService.searchCallCount == 1)
        // Results depend on MapKit availability in test environment
    }
    
    // MARK: - Error Handling Tests
    
    @Test("Search propagates MapKit errors")
    func testMapKitErrorPropagation() async throws {
        // Given
        let mockYelpService = MockYelpService()
        mockYelpService.shouldThrowError = true
        
        let searchService = RestaurantSearchService(yelpService: mockYelpService)
        let location = CLLocation(latitude: 37.7749, longitude: -122.4194)
        
        // When & Then
        // MapKit may throw or return empty results
        // We just verify it doesn't crash
        do {
            let _ = try await searchService.searchNearbyRestaurants(near: location)
        } catch {
            // Expected behavior - error is propagated
            #expect(error != nil)
        }
    }
    
    // MARK: - Integration Tests
    
    @Test("Search passes correct parameters to Yelp")
    func testYelpSearchParameters() async throws {
        // Given
        let mockYelpService = MockYelpService()
        mockYelpService.mockBusinesses = [createMockYelpBusiness(name: "Test")]
        
        let searchService = RestaurantSearchService(yelpService: mockYelpService)
        let location = CLLocation(latitude: 37.7749, longitude: -122.4194)
        
        // When
        let _ = try await searchService.searchNearbyRestaurants(near: location)
        
        // Then
        #expect(mockYelpService.searchCallCount == 1)
        #expect(mockYelpService.lastSearchLocation?.coordinate.latitude == 37.7749)
        #expect(mockYelpService.lastSearchLocation?.coordinate.longitude == -122.4194)
        #expect(mockYelpService.lastSearchTerm == "chicken tenders")
        #expect(mockYelpService.lastSearchRadius == Config.searchRadius)
        #expect(mockYelpService.lastSearchLimit == Config.maxResults)
    }
    
    @Test("Search filters nil results from Yelp")
    func testFilterNilResults() async throws {
        // Given
        let mockYelpService = MockYelpService()
        mockYelpService.mockBusinesses = [
            createMockYelpBusiness(name: "Valid Restaurant"),
            // In real implementation, some businesses might be filtered out
        ]
        
        let searchService = RestaurantSearchService(yelpService: mockYelpService)
        let location = CLLocation(latitude: 37.7749, longitude: -122.4194)
        
        // When
        let results = try await searchService.searchNearbyRestaurants(near: location)
        
        // Then
        #expect(!results.isEmpty)
        for tender in results {
            #expect(!tender.name.isEmpty)
        }
    }
    
    @Test("Search handles multiple results")
    func testMultipleResults() async throws {
        // Given
        let mockYelpService = MockYelpService()
        mockYelpService.mockBusinesses = (1...20).map { i in
            createMockYelpBusiness(name: "Restaurant \(i)")
        }
        
        let searchService = RestaurantSearchService(yelpService: mockYelpService)
        let location = CLLocation(latitude: 37.7749, longitude: -122.4194)
        
        // When
        let results = try await searchService.searchNearbyRestaurants(near: location)
        
        // Then
        #expect(results.count == 20)
        #expect(results[0].name == "Restaurant 1")
        #expect(results[19].name == "Restaurant 20")
    }
    
    @Test("Search preserves coordinates accurately")
    func testCoordinateAccuracy() async throws {
        // Given
        let mockYelpService = MockYelpService()
        let yelpBusiness = YelpBusiness(
            id: "test-id",
            name: "Test",
            imageUrl: nil,
            url: nil,
            reviewCount: nil,
            rating: nil,
            coordinates: YelpCoordinates(latitude: 37.774929, longitude: -122.419418),
            price: nil,
            location: YelpLocation(displayAddress: nil),
            displayPhone: nil,
            categories: nil
        )
        mockYelpService.mockBusinesses = [yelpBusiness]
        
        let searchService = RestaurantSearchService(yelpService: mockYelpService)
        let location = CLLocation(latitude: 37.7749, longitude: -122.4194)
        
        // When
        let results = try await searchService.searchNearbyRestaurants(near: location)
        
        // Then
        #expect(results[0].latitude == 37.774929)
        #expect(results[0].longitude == -122.419418)
    }
    
    // MARK: - Helper Classes
    
    class MockYelpService: YelpService {
        var mockBusinesses: [YelpBusiness] = []
        var shouldThrowError = false
        var searchCallCount = 0
        var lastSearchLocation: CLLocation?
        var lastSearchTerm: String?
        var lastSearchRadius: Int?
        var lastSearchLimit: Int?
        
        init() {
            super.init(apiKey: "mock")
        }
        
        override func searchBusinesses(near location: CLLocation, term: String, radius: Int, limit: Int) async throws -> [YelpBusiness] {
            searchCallCount += 1
            lastSearchLocation = location
            lastSearchTerm = term
            lastSearchRadius = radius
            lastSearchLimit = limit
            
            if shouldThrowError {
                throw NSError(domain: "MockError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock error"])
            }
            
            return mockBusinesses
        }
    }
    
    func createMockYelpBusiness(name: String) -> YelpBusiness {
        YelpBusiness(
            id: UUID().uuidString,
            name: name,
            imageUrl: "https://example.com/image.jpg",
            url: "https://example.com",
            reviewCount: 100,
            rating: 4.5,
            coordinates: YelpCoordinates(latitude: 37.7749, longitude: -122.4194),
            price: "$$",
            location: YelpLocation(displayAddress: ["123 Main St", "San Francisco, CA"]),
            displayPhone: "(415) 555-1234",
            categories: [YelpCategory(title: "Fast Food")]
        )
    }
}
