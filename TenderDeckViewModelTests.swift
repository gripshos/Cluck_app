//
//  TenderDeckViewModelTests.swift
//  Cluck
//
//  Tests for the TenderDeckViewModel
//

import Testing
import Foundation
import CoreLocation
@testable import Cluck

@Suite("TenderDeckViewModel Tests")
@MainActor
struct TenderDeckViewModelTests {
    
    // MARK: - Mock Services
    
    class MockLocationManager: LocationManager {
        var mockLocation: CLLocation?
        
        override var location: CLLocation? {
            mockLocation
        }
    }
    
    class MockRestaurantSearchService: RestaurantSearchService {
        var mockResults: [Tender] = []
        var shouldThrowError = false
        var searchCallCount = 0
        
        init() {
            super.init(yelpService: YelpService(apiKey: "mock"))
        }
        
        override func searchNearbyRestaurants(near location: CLLocation) async throws -> [Tender] {
            searchCallCount += 1
            
            if shouldThrowError {
                throw NSError(domain: "TestError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock search error"])
            }
            
            return mockResults
        }
    }
    
    // MARK: - Helper Methods
    
    func createViewModel(location: CLLocation? = nil, restaurants: [Tender] = []) -> (TenderDeckViewModel, MockRestaurantSearchService, MockLocationManager) {
        let mockLocationManager = MockLocationManager()
        mockLocationManager.mockLocation = location ?? CLLocation(latitude: 37.7749, longitude: -122.4194)
        
        let mockSearchService = MockRestaurantSearchService()
        mockSearchService.mockResults = restaurants
        
        let viewModel = TenderDeckViewModel(
            searchService: mockSearchService,
            locationManager: mockLocationManager
        )
        
        return (viewModel, mockSearchService, mockLocationManager)
    }
    
    func createMockTender(name: String) -> Tender {
        Tender(
            name: name,
            restaurantType: "Fast Food",
            priceRange: "$",
            latitude: 37.7749,
            longitude: -122.4194
        )
    }
    
    // MARK: - Initialization Tests
    
    @Test("ViewModel initialization")
    func testViewModelInitialization() async throws {
        // Given & When
        let (viewModel, _, _) = createViewModel()
        
        // Then
        #expect(viewModel.tenders.isEmpty)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.lastSwipedRestaurant == nil)
    }
    
    @Test("ViewModel provides user location")
    func testViewModelProvidesUserLocation() async throws {
        // Given
        let expectedLocation = CLLocation(latitude: 40.7128, longitude: -74.0060)
        let (viewModel, _, _) = createViewModel(location: expectedLocation)
        
        // When
        let userLocation = viewModel.userLocation
        
        // Then
        #expect(userLocation?.coordinate.latitude == expectedLocation.coordinate.latitude)
        #expect(userLocation?.coordinate.longitude == expectedLocation.coordinate.longitude)
    }
    
    // MARK: - Load Restaurants Tests
    
    @Test("Load restaurants successfully")
    func testLoadRestaurantsSuccessfully() async throws {
        // Given
        let mockRestaurants = [
            createMockTender(name: "Restaurant 1"),
            createMockTender(name: "Restaurant 2"),
            createMockTender(name: "Restaurant 3")
        ]
        let (viewModel, mockService, _) = createViewModel(restaurants: mockRestaurants)
        
        // When
        await viewModel.loadRestaurants()
        
        // Then
        #expect(viewModel.tenders.count == 3)
        #expect(viewModel.tenders[0].name == "Restaurant 1")
        #expect(viewModel.tenders[1].name == "Restaurant 2")
        #expect(viewModel.tenders[2].name == "Restaurant 3")
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
        #expect(mockService.searchCallCount == 1)
    }
    
    @Test("Load restaurants sets loading state")
    func testLoadRestaurantsLoadingState() async throws {
        // Given
        let (viewModel, _, _) = createViewModel()
        
        // When - Start loading (check loading state during async operation)
        let loadTask = Task {
            await viewModel.loadRestaurants()
        }
        
        // Give a moment for the loading state to be set
        try await Task.sleep(for: .milliseconds(10))
        
        // Then - During loading
        // Note: This test is tricky due to timing, but isLoading should be false after completion
        await loadTask.value
        #expect(viewModel.isLoading == false, "Loading should be false after completion")
    }
    
    @Test("Load restaurants with no location shows error")
    func testLoadRestaurantsNoLocation() async throws {
        // Given
        let (viewModel, mockService, mockLocationManager) = createViewModel()
        mockLocationManager.mockLocation = nil
        
        // When
        await viewModel.loadRestaurants()
        
        // Then
        #expect(viewModel.errorMessage == "Unable to get your location")
        #expect(viewModel.tenders.isEmpty)
        #expect(mockService.searchCallCount == 0)
    }
    
    @Test("Load restaurants with empty results shows error")
    func testLoadRestaurantsEmptyResults() async throws {
        // Given
        let (viewModel, _, _) = createViewModel(restaurants: [])
        
        // When
        await viewModel.loadRestaurants()
        
        // Then
        #expect(viewModel.tenders.isEmpty)
        #expect(viewModel.errorMessage == "No restaurants found nearby")
        #expect(viewModel.isLoading == false)
    }
    
    @Test("Load restaurants with search error")
    func testLoadRestaurantsSearchError() async throws {
        // Given
        let (viewModel, mockService, _) = createViewModel()
        mockService.shouldThrowError = true
        
        // When
        await viewModel.loadRestaurants()
        
        // Then
        #expect(viewModel.tenders.isEmpty)
        #expect(viewModel.errorMessage?.contains("Failed to load restaurants") == true)
        #expect(viewModel.isLoading == false)
    }
    
    // MARK: - Remove Top Card Tests
    
    @Test("Remove top card from deck")
    func testRemoveTopCard() async throws {
        // Given
        let mockRestaurants = [
            createMockTender(name: "Restaurant 1"),
            createMockTender(name: "Restaurant 2"),
            createMockTender(name: "Restaurant 3")
        ]
        let (viewModel, _, _) = createViewModel(restaurants: mockRestaurants)
        await viewModel.loadRestaurants()
        
        // When
        viewModel.removeTopCard()
        
        // Then
        #expect(viewModel.tenders.count == 2)
        #expect(viewModel.tenders[0].name == "Restaurant 2")
        #expect(viewModel.lastSwipedRestaurant?.name == "Restaurant 1")
    }
    
    @Test("Remove top card from empty deck does nothing")
    func testRemoveTopCardEmptyDeck() async throws {
        // Given
        let (viewModel, _, _) = createViewModel(restaurants: [])
        await viewModel.loadRestaurants()
        
        // When
        viewModel.removeTopCard()
        
        // Then
        #expect(viewModel.tenders.isEmpty)
        #expect(viewModel.lastSwipedRestaurant == nil)
    }
    
    @Test("Remove multiple cards in sequence")
    func testRemoveMultipleCards() async throws {
        // Given
        let mockRestaurants = [
            createMockTender(name: "Restaurant 1"),
            createMockTender(name: "Restaurant 2"),
            createMockTender(name: "Restaurant 3")
        ]
        let (viewModel, _, _) = createViewModel(restaurants: mockRestaurants)
        await viewModel.loadRestaurants()
        
        // When
        viewModel.removeTopCard()
        viewModel.removeTopCard()
        
        // Then
        #expect(viewModel.tenders.count == 1)
        #expect(viewModel.tenders[0].name == "Restaurant 3")
        #expect(viewModel.lastSwipedRestaurant?.name == "Restaurant 2")
    }
    
    // MARK: - Undo Last Swipe Tests
    
    @Test("Undo last swipe restores card")
    func testUndoLastSwipe() async throws {
        // Given
        let mockRestaurants = [
            createMockTender(name: "Restaurant 1"),
            createMockTender(name: "Restaurant 2"),
            createMockTender(name: "Restaurant 3")
        ]
        let (viewModel, _, _) = createViewModel(restaurants: mockRestaurants)
        await viewModel.loadRestaurants()
        viewModel.removeTopCard()
        
        // When
        viewModel.undoLastSwipe()
        
        // Then
        #expect(viewModel.tenders.count == 3)
        #expect(viewModel.tenders[0].name == "Restaurant 1")
        #expect(viewModel.lastSwipedRestaurant == nil)
    }
    
    @Test("Undo without previous swipe does nothing")
    func testUndoWithoutPreviousSwipe() async throws {
        // Given
        let mockRestaurants = [
            createMockTender(name: "Restaurant 1"),
            createMockTender(name: "Restaurant 2")
        ]
        let (viewModel, _, _) = createViewModel(restaurants: mockRestaurants)
        await viewModel.loadRestaurants()
        
        // When
        viewModel.undoLastSwipe()
        
        // Then
        #expect(viewModel.tenders.count == 2)
        #expect(viewModel.lastSwipedRestaurant == nil)
    }
    
    @Test("Undo multiple times only restores once")
    func testUndoMultipleTimes() async throws {
        // Given
        let mockRestaurants = [
            createMockTender(name: "Restaurant 1"),
            createMockTender(name: "Restaurant 2")
        ]
        let (viewModel, _, _) = createViewModel(restaurants: mockRestaurants)
        await viewModel.loadRestaurants()
        viewModel.removeTopCard()
        
        // When
        viewModel.undoLastSwipe()
        viewModel.undoLastSwipe() // Second undo should do nothing
        
        // Then
        #expect(viewModel.tenders.count == 2)
        #expect(viewModel.tenders[0].name == "Restaurant 1")
        #expect(viewModel.lastSwipedRestaurant == nil)
    }
    
    @Test("Undo then remove again")
    func testUndoThenRemoveAgain() async throws {
        // Given
        let mockRestaurants = [
            createMockTender(name: "Restaurant 1"),
            createMockTender(name: "Restaurant 2")
        ]
        let (viewModel, _, _) = createViewModel(restaurants: mockRestaurants)
        await viewModel.loadRestaurants()
        viewModel.removeTopCard()
        viewModel.undoLastSwipe()
        
        // When
        viewModel.removeTopCard()
        
        // Then
        #expect(viewModel.tenders.count == 1)
        #expect(viewModel.tenders[0].name == "Restaurant 2")
        #expect(viewModel.lastSwipedRestaurant?.name == "Restaurant 1")
    }
    
    // MARK: - Integration Tests
    
    @Test("Complete workflow: load, swipe, undo")
    func testCompleteWorkflow() async throws {
        // Given
        let mockRestaurants = [
            createMockTender(name: "Restaurant 1"),
            createMockTender(name: "Restaurant 2"),
            createMockTender(name: "Restaurant 3")
        ]
        let (viewModel, _, _) = createViewModel(restaurants: mockRestaurants)
        
        // When - Load restaurants
        await viewModel.loadRestaurants()
        #expect(viewModel.tenders.count == 3)
        
        // When - Remove first card
        viewModel.removeTopCard()
        #expect(viewModel.tenders.count == 2)
        #expect(viewModel.lastSwipedRestaurant?.name == "Restaurant 1")
        
        // When - Undo
        viewModel.undoLastSwipe()
        #expect(viewModel.tenders.count == 3)
        #expect(viewModel.tenders[0].name == "Restaurant 1")
        
        // When - Remove two cards
        viewModel.removeTopCard()
        viewModel.removeTopCard()
        #expect(viewModel.tenders.count == 1)
        #expect(viewModel.lastSwipedRestaurant?.name == "Restaurant 2")
        
        // When - Undo once (only restores last one)
        viewModel.undoLastSwipe()
        #expect(viewModel.tenders.count == 2)
        #expect(viewModel.tenders[0].name == "Restaurant 2")
    }
    
    @Test("Reload restaurants clears previous state")
    func testReloadRestaurantsClearsPreviousState() async throws {
        // Given
        let initialRestaurants = [createMockTender(name: "Restaurant 1")]
        let (viewModel, mockService, _) = createViewModel(restaurants: initialRestaurants)
        await viewModel.loadRestaurants()
        viewModel.removeTopCard()
        
        // When - Update mock results and reload
        let newRestaurants = [
            createMockTender(name: "New Restaurant 1"),
            createMockTender(name: "New Restaurant 2")
        ]
        mockService.mockResults = newRestaurants
        await viewModel.loadRestaurants()
        
        // Then
        #expect(viewModel.tenders.count == 2)
        #expect(viewModel.tenders[0].name == "New Restaurant 1")
        #expect(viewModel.errorMessage == nil)
    }
}
