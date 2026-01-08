//
//  IntegrationTests.swift
//  Cluck
//
//  Integration tests for the entire app flow
//

import Testing
import Foundation
import CoreLocation
import SwiftData
@testable import Cluck

@Suite("Integration Tests")
@MainActor
struct IntegrationTests {
    
    // MARK: - Full App Flow Tests
    
    @Test("Complete user flow: load, swipe, save, undo")
    func testCompleteUserFlow() async throws {
        // Given - Set up complete app environment
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: FavoriteRestaurant.self, configurations: config)
        let modelContext = container.mainContext
        
        let mockLocationManager = MockLocationManager()
        mockLocationManager.mockLocation = CLLocation(latitude: 37.7749, longitude: -122.4194)
        
        let mockYelpService = MockYelpService()
        mockYelpService.mockBusinesses = [
            createMockYelpBusiness(name: "Restaurant 1"),
            createMockYelpBusiness(name: "Restaurant 2"),
            createMockYelpBusiness(name: "Restaurant 3")
        ]
        
        let searchService = RestaurantSearchService(yelpService: mockYelpService)
        let viewModel = TenderDeckViewModel(
            searchService: searchService,
            locationManager: mockLocationManager
        )
        
        // When - Load restaurants
        await viewModel.loadRestaurants()
        
        // Then - Should have 3 restaurants
        #expect(viewModel.tenders.count == 3)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
        
        // When - Swipe right (save first restaurant)
        let firstRestaurant = viewModel.tenders[0]
        let favorite = FavoriteRestaurant(from: firstRestaurant)
        modelContext.insert(favorite)
        try modelContext.save()
        viewModel.removeTopCard()
        
        // Then - Should have 2 restaurants left and 1 saved
        #expect(viewModel.tenders.count == 2)
        #expect(viewModel.lastSwipedRestaurant != nil)
        
        let descriptor = FetchDescriptor<FavoriteRestaurant>()
        let savedRestaurants = try modelContext.fetch(descriptor)
        #expect(savedRestaurants.count == 1)
        #expect(savedRestaurants[0].name == firstRestaurant.name)
        
        // When - Undo swipe
        viewModel.undoLastSwipe()
        
        // Then - Should have 3 restaurants again
        #expect(viewModel.tenders.count == 3)
        #expect(viewModel.tenders[0].name == firstRestaurant.name)
        #expect(viewModel.lastSwipedRestaurant == nil)
        
        // When - Swipe left (skip)
        viewModel.removeTopCard()
        
        // Then - Should have 2 restaurants
        #expect(viewModel.tenders.count == 2)
        #expect(viewModel.tenders[0].name == "Restaurant 2")
    }
    
    @Test("Handle empty restaurant list gracefully")
    func testEmptyRestaurantList() async throws {
        // Given
        let mockLocationManager = MockLocationManager()
        mockLocationManager.mockLocation = CLLocation(latitude: 37.7749, longitude: -122.4194)
        
        let mockYelpService = MockYelpService()
        mockYelpService.mockBusinesses = [] // Empty list
        
        let searchService = RestaurantSearchService(yelpService: mockYelpService)
        let viewModel = TenderDeckViewModel(
            searchService: searchService,
            locationManager: mockLocationManager
        )
        
        // When
        await viewModel.loadRestaurants()
        
        // Then
        #expect(viewModel.tenders.isEmpty)
        #expect(viewModel.errorMessage == "No restaurants found nearby")
        #expect(viewModel.isLoading == false)
        
        // When - Try to remove card from empty deck
        viewModel.removeTopCard()
        
        // Then - Should still be empty
        #expect(viewModel.tenders.isEmpty)
        #expect(viewModel.lastSwipedRestaurant == nil)
    }
    
    @Test("Handle location permission denied")
    func testLocationPermissionDenied() async throws {
        // Given
        let mockLocationManager = MockLocationManager()
        mockLocationManager.mockLocation = nil // No location
        
        let mockYelpService = MockYelpService()
        let searchService = RestaurantSearchService(yelpService: mockYelpService)
        let viewModel = TenderDeckViewModel(
            searchService: searchService,
            locationManager: mockLocationManager
        )
        
        // When
        await viewModel.loadRestaurants()
        
        // Then
        #expect(viewModel.tenders.isEmpty)
        #expect(viewModel.errorMessage == "Unable to get your location")
        #expect(mockYelpService.searchCallCount == 0)
    }
    
    @Test("Handle network error during search")
    func testNetworkError() async throws {
        // Given
        let mockLocationManager = MockLocationManager()
        mockLocationManager.mockLocation = CLLocation(latitude: 37.7749, longitude: -122.4194)
        
        let mockYelpService = MockYelpService()
        mockYelpService.shouldThrowError = true
        
        let searchService = RestaurantSearchService(yelpService: mockYelpService)
        let viewModel = TenderDeckViewModel(
            searchService: searchService,
            locationManager: mockLocationManager
        )
        
        // When
        await viewModel.loadRestaurants()
        
        // Then
        #expect(viewModel.tenders.isEmpty)
        #expect(viewModel.errorMessage?.contains("Failed to load restaurants") == true)
    }
    
    // MARK: - Favorite Management Tests
    
    @Test("Save and retrieve favorites")
    func testSaveAndRetrieveFavorites() async throws {
        // Given
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: FavoriteRestaurant.self, configurations: config)
        let modelContext = container.mainContext
        
        let tender1 = Tender.testTender(name: "Restaurant 1")
        let tender2 = Tender.testTender(name: "Restaurant 2")
        
        // When - Save favorites
        let favorite1 = FavoriteRestaurant(from: tender1)
        let favorite2 = FavoriteRestaurant(from: tender2)
        modelContext.insert(favorite1)
        modelContext.insert(favorite2)
        try modelContext.save()
        
        // Then - Retrieve favorites
        let descriptor = FetchDescriptor<FavoriteRestaurant>()
        let favorites = try modelContext.fetch(descriptor)
        
        #expect(favorites.count == 2)
        #expect(favorites.contains { $0.name == "Restaurant 1" })
        #expect(favorites.contains { $0.name == "Restaurant 2" })
    }
    
    @Test("Remove favorite from list")
    func testRemoveFavorite() async throws {
        // Given
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: FavoriteRestaurant.self, configurations: config)
        let modelContext = container.mainContext
        
        let tender = Tender.testTender(name: "Restaurant To Remove")
        let favorite = FavoriteRestaurant(from: tender)
        modelContext.insert(favorite)
        try modelContext.save()
        
        // When - Remove favorite
        let descriptor = FetchDescriptor<FavoriteRestaurant>(
            predicate: #Predicate { $0.id == tender.id }
        )
        let results = try modelContext.fetch(descriptor)
        if let toRemove = results.first {
            modelContext.delete(toRemove)
            try modelContext.save()
        }
        
        // Then - Should be removed
        let allFavorites = try modelContext.fetch(FetchDescriptor<FavoriteRestaurant>())
        #expect(allFavorites.isEmpty)
    }
    
    @Test("Check if restaurant is favorited")
    func testCheckIfFavorited() async throws {
        // Given
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: FavoriteRestaurant.self, configurations: config)
        let modelContext = container.mainContext
        
        let tender = Tender.testTender(name: "Restaurant")
        let favorite = FavoriteRestaurant(from: tender)
        modelContext.insert(favorite)
        try modelContext.save()
        
        // When - Check if favorited
        let descriptor = FetchDescriptor<FavoriteRestaurant>(
            predicate: #Predicate { $0.id == tender.id }
        )
        let results = try modelContext.fetch(descriptor)
        
        // Then
        #expect(!results.isEmpty, "Restaurant should be in favorites")
    }
    
    // MARK: - Reload and Refresh Tests
    
    @Test("Reload restaurants updates list")
    func testReloadRestaurants() async throws {
        // Given
        let mockLocationManager = MockLocationManager()
        mockLocationManager.mockLocation = CLLocation(latitude: 37.7749, longitude: -122.4194)
        
        let mockYelpService = MockYelpService()
        mockYelpService.mockBusinesses = [
            createMockYelpBusiness(name: "Initial Restaurant")
        ]
        
        let searchService = RestaurantSearchService(yelpService: mockYelpService)
        let viewModel = TenderDeckViewModel(
            searchService: searchService,
            locationManager: mockLocationManager
        )
        
        await viewModel.loadRestaurants()
        #expect(viewModel.tenders.count == 1)
        #expect(viewModel.tenders[0].name == "Initial Restaurant")
        
        // When - Update mock data and reload
        mockYelpService.mockBusinesses = [
            createMockYelpBusiness(name: "New Restaurant 1"),
            createMockYelpBusiness(name: "New Restaurant 2")
        ]
        await viewModel.loadRestaurants()
        
        // Then
        #expect(viewModel.tenders.count == 2)
        #expect(viewModel.tenders[0].name == "New Restaurant 1")
        #expect(viewModel.tenders[1].name == "New Restaurant 2")
    }
    
    // MARK: - Multiple Swipes Tests
    
    @Test("Swipe through entire deck")
    func testSwipeThroughEntireDeck() async throws {
        // Given
        let mockLocationManager = MockLocationManager()
        mockLocationManager.mockLocation = CLLocation(latitude: 37.7749, longitude: -122.4194)
        
        let mockYelpService = MockYelpService()
        mockYelpService.mockBusinesses = [
            createMockYelpBusiness(name: "Restaurant 1"),
            createMockYelpBusiness(name: "Restaurant 2"),
            createMockYelpBusiness(name: "Restaurant 3")
        ]
        
        let searchService = RestaurantSearchService(yelpService: mockYelpService)
        let viewModel = TenderDeckViewModel(
            searchService: searchService,
            locationManager: mockLocationManager
        )
        
        await viewModel.loadRestaurants()
        #expect(viewModel.tenders.count == 3)
        
        // When - Swipe through all cards
        viewModel.removeTopCard()
        #expect(viewModel.tenders.count == 2)
        
        viewModel.removeTopCard()
        #expect(viewModel.tenders.count == 1)
        
        viewModel.removeTopCard()
        
        // Then - Deck should be empty
        #expect(viewModel.tenders.isEmpty)
        #expect(viewModel.lastSwipedRestaurant?.name == "Restaurant 3")
    }
    
    // MARK: - Helper Methods
    
    class MockLocationManager: LocationManager {
        var mockLocation: CLLocation?
        
        override var location: CLLocation? {
            mockLocation
        }
    }
    
    class MockYelpService: YelpService {
        var mockBusinesses: [YelpBusiness] = []
        var shouldThrowError = false
        var searchCallCount = 0
        
        init() {
            super.init(apiKey: "mock")
        }
        
        override func searchBusinesses(near location: CLLocation, term: String, radius: Int, limit: Int) async throws -> [YelpBusiness] {
            searchCallCount += 1
            
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
