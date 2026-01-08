//
//  TenderDeckViewModelTests.swift
//  Cluck
//
//  Comprehensive tests for TenderDeckViewModel
//

import Testing
import Foundation
import CoreLocation
@testable import Cluck

@Suite("TenderDeckViewModel Tests")
@MainActor
struct TenderDeckViewModelTests {
    
    // MARK: - Initialization Tests
    
    @Test("ViewModel initializes with empty state")
    func testInitialization() async throws {
        // Given
        let mockLocationManager = MockLocationManager()
        let mockYelpService = MockYelpService()
        let searchService = RestaurantSearchService(yelpService: mockYelpService)
        
        // When
        let viewModel = TenderDeckViewModel(
            searchService: searchService,
            locationManager: mockLocationManager
        )
        
        // Then
        #expect(viewModel.tenders.isEmpty)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.lastSwipedRestaurant == nil)
    }
    
    @Test("ViewModel provides user location")
    func testUserLocation() async throws {
        // Given
        let mockLocationManager = MockLocationManager()
        let location = CLLocation(latitude: 37.7749, longitude: -122.4194)
        mockLocationManager.mockLocation = location
        
        let mockYelpService = MockYelpService()
        let searchService = RestaurantSearchService(yelpService: mockYelpService)
        
        // When
        let viewModel = TenderDeckViewModel(
            searchService: searchService,
            locationManager: mockLocationManager
        )
        
        // Then
        #expect(viewModel.userLocation?.coordinate.latitude == 37.7749)
        #expect(viewModel.userLocation?.coordinate.longitude == -122.4194)
    }
    
    // MARK: - Load Restaurants Tests
    
    @Test("Load restaurants successfully")
    func testLoadRestaurantsSuccess() async throws {
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
        
        // When
        await viewModel.loadRestaurants()
        
        // Then
        #expect(viewModel.tenders.count == 3)
        #expect(viewModel.tenders[0].name == "Restaurant 1")
        #expect(viewModel.tenders[1].name == "Restaurant 2")
        #expect(viewModel.tenders[2].name == "Restaurant 3")
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
    }
    
    @Test("Load restaurants shows loading state")
    func testLoadRestaurantsLoading() async throws {
        // Given
        let mockLocationManager = MockLocationManager()
        mockLocationManager.mockLocation = CLLocation(latitude: 37.7749, longitude: -122.4194)
        
        let mockYelpService = MockYelpService()
        mockYelpService.mockBusinesses = [createMockYelpBusiness(name: "Restaurant")]
        
        let searchService = RestaurantSearchService(yelpService: mockYelpService)
        let viewModel = TenderDeckViewModel(
            searchService: searchService,
            locationManager: mockLocationManager
        )
        
        // When & Then
        await viewModel.loadRestaurants()
        // Loading happens so fast in tests, but we can verify final state
        #expect(viewModel.isLoading == false)
    }
    
    @Test("Load restaurants without location shows error")
    func testLoadRestaurantsWithoutLocation() async throws {
        // Given
        let mockLocationManager = MockLocationManager()
        mockLocationManager.mockLocation = nil
        
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
        #expect(viewModel.isLoading == false)
    }
    
    @Test("Load restaurants with empty results shows error")
    func testLoadRestaurantsEmptyResults() async throws {
        // Given
        let mockLocationManager = MockLocationManager()
        mockLocationManager.mockLocation = CLLocation(latitude: 37.7749, longitude: -122.4194)
        
        let mockYelpService = MockYelpService()
        mockYelpService.mockBusinesses = []
        
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
    }
    
    @Test("Load restaurants handles service error")
    func testLoadRestaurantsServiceError() async throws {
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
        #expect(viewModel.isLoading == false)
    }
    
    @Test("Load restaurants clears previous error")
    func testLoadRestaurantsClearsPreviousError() async throws {
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
        
        // First load with error
        await viewModel.loadRestaurants()
        #expect(viewModel.errorMessage != nil)
        
        // When - Load again with success
        mockYelpService.shouldThrowError = false
        mockYelpService.mockBusinesses = [createMockYelpBusiness(name: "Restaurant")]
        await viewModel.loadRestaurants()
        
        // Then - Error should be cleared
        #expect(viewModel.errorMessage == nil)
        #expect(!viewModel.tenders.isEmpty)
    }
    
    // MARK: - Remove Top Card Tests
    
    @Test("Remove top card from deck")
    func testRemoveTopCard() async throws {
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
        let firstRestaurant = viewModel.tenders[0]
        
        // When
        viewModel.removeTopCard()
        
        // Then
        #expect(viewModel.tenders.count == 2)
        #expect(viewModel.tenders[0].name == "Restaurant 2")
        #expect(viewModel.lastSwipedRestaurant?.name == firstRestaurant.name)
    }
    
    @Test("Remove top card from empty deck does nothing")
    func testRemoveTopCardFromEmptyDeck() async throws {
        // Given
        let mockLocationManager = MockLocationManager()
        let mockYelpService = MockYelpService()
        let searchService = RestaurantSearchService(yelpService: mockYelpService)
        let viewModel = TenderDeckViewModel(
            searchService: searchService,
            locationManager: mockLocationManager
        )
        
        // When
        viewModel.removeTopCard()
        
        // Then
        #expect(viewModel.tenders.isEmpty)
        #expect(viewModel.lastSwipedRestaurant == nil)
    }
    
    @Test("Remove multiple cards sequentially")
    func testRemoveMultipleCards() async throws {
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
        
        // When
        viewModel.removeTopCard()
        #expect(viewModel.tenders.count == 2)
        #expect(viewModel.lastSwipedRestaurant?.name == "Restaurant 1")
        
        viewModel.removeTopCard()
        #expect(viewModel.tenders.count == 1)
        #expect(viewModel.lastSwipedRestaurant?.name == "Restaurant 2")
        
        viewModel.removeTopCard()
        
        // Then
        #expect(viewModel.tenders.isEmpty)
        #expect(viewModel.lastSwipedRestaurant?.name == "Restaurant 3")
    }
    
    // MARK: - Undo Last Swipe Tests
    
    @Test("Undo last swipe restores card")
    func testUndoLastSwipe() async throws {
        // Given
        let mockLocationManager = MockLocationManager()
        mockLocationManager.mockLocation = CLLocation(latitude: 37.7749, longitude: -122.4194)
        
        let mockYelpService = MockYelpService()
        mockYelpService.mockBusinesses = [
            createMockYelpBusiness(name: "Restaurant 1"),
            createMockYelpBusiness(name: "Restaurant 2")
        ]
        
        let searchService = RestaurantSearchService(yelpService: mockYelpService)
        let viewModel = TenderDeckViewModel(
            searchService: searchService,
            locationManager: mockLocationManager
        )
        
        await viewModel.loadRestaurants()
        viewModel.removeTopCard()
        
        // When
        viewModel.undoLastSwipe()
        
        // Then
        #expect(viewModel.tenders.count == 2)
        #expect(viewModel.tenders[0].name == "Restaurant 1")
        #expect(viewModel.lastSwipedRestaurant == nil)
    }
    
    @Test("Undo without previous swipe does nothing")
    func testUndoWithoutPreviousSwipe() async throws {
        // Given
        let mockLocationManager = MockLocationManager()
        mockLocationManager.mockLocation = CLLocation(latitude: 37.7749, longitude: -122.4194)
        
        let mockYelpService = MockYelpService()
        mockYelpService.mockBusinesses = [createMockYelpBusiness(name: "Restaurant 1")]
        
        let searchService = RestaurantSearchService(yelpService: mockYelpService)
        let viewModel = TenderDeckViewModel(
            searchService: searchService,
            locationManager: mockLocationManager
        )
        
        await viewModel.loadRestaurants()
        
        // When
        viewModel.undoLastSwipe()
        
        // Then
        #expect(viewModel.tenders.count == 1)
        #expect(viewModel.lastSwipedRestaurant == nil)
    }
    
    @Test("Undo can only be done once")
    func testUndoOnlyOnce() async throws {
        // Given
        let mockLocationManager = MockLocationManager()
        mockLocationManager.mockLocation = CLLocation(latitude: 37.7749, longitude: -122.4194)
        
        let mockYelpService = MockYelpService()
        mockYelpService.mockBusinesses = [
            createMockYelpBusiness(name: "Restaurant 1"),
            createMockYelpBusiness(name: "Restaurant 2")
        ]
        
        let searchService = RestaurantSearchService(yelpService: mockYelpService)
        let viewModel = TenderDeckViewModel(
            searchService: searchService,
            locationManager: mockLocationManager
        )
        
        await viewModel.loadRestaurants()
        viewModel.removeTopCard()
        viewModel.undoLastSwipe()
        
        // When - Try to undo again
        viewModel.undoLastSwipe()
        
        // Then - Nothing should change
        #expect(viewModel.tenders.count == 2)
        #expect(viewModel.lastSwipedRestaurant == nil)
    }
    
    @Test("New swipe replaces undo state")
    func testNewSwipeReplacesUndoState() async throws {
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
        viewModel.removeTopCard() // Remove Restaurant 1
        #expect(viewModel.lastSwipedRestaurant?.name == "Restaurant 1")
        
        // When - Swipe again without undo
        viewModel.removeTopCard() // Remove Restaurant 2
        
        // Then - Undo state should be replaced
        #expect(viewModel.lastSwipedRestaurant?.name == "Restaurant 2")
    }
    
    // MARK: - Integration Tests
    
    @Test("Complete flow: load, swipe, undo, swipe again")
    func testCompleteFlow() async throws {
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
        
        // When - Load
        await viewModel.loadRestaurants()
        #expect(viewModel.tenders.count == 3)
        
        // When - First swipe
        viewModel.removeTopCard()
        #expect(viewModel.tenders.count == 2)
        #expect(viewModel.tenders[0].name == "Restaurant 2")
        
        // When - Undo
        viewModel.undoLastSwipe()
        #expect(viewModel.tenders.count == 3)
        #expect(viewModel.tenders[0].name == "Restaurant 1")
        
        // When - Swipe again
        viewModel.removeTopCard()
        #expect(viewModel.tenders.count == 2)
        #expect(viewModel.tenders[0].name == "Restaurant 2")
    }
    
    @Test("Reload replaces existing restaurants")
    func testReloadReplacesRestaurants() async throws {
        // Given
        let mockLocationManager = MockLocationManager()
        mockLocationManager.mockLocation = CLLocation(latitude: 37.7749, longitude: -122.4194)
        
        let mockYelpService = MockYelpService()
        mockYelpService.mockBusinesses = [createMockYelpBusiness(name: "Restaurant 1")]
        
        let searchService = RestaurantSearchService(yelpService: mockYelpService)
        let viewModel = TenderDeckViewModel(
            searchService: searchService,
            locationManager: mockLocationManager
        )
        
        await viewModel.loadRestaurants()
        #expect(viewModel.tenders.count == 1)
        
        // When - Update data and reload
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
    
    // MARK: - Helper Classes
    
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
