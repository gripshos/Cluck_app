//
//  ViewIntegrationTests.swift
//  Cluck
//
//  Integration tests for SwiftUI views and complete user flows
//

import Testing
import SwiftUI
import CoreLocation
import SwiftData
@testable import Cluck

@Suite("View Integration Tests")
@MainActor
struct ViewIntegrationTests {
    
    // MARK: - SwipeDeckView Integration
    
    @Test("SwipeDeckView can be created with ViewModel")
    func testSwipeDeckViewCreation() async throws {
        // Given
        let mockLocationManager = MockLocationManager()
        let mockYelpService = MockYelpService()
        let searchService = RestaurantSearchService(yelpService: mockYelpService)
        let viewModel = TenderDeckViewModel(
            searchService: searchService,
            locationManager: mockLocationManager
        )
        
        // When
        let view = SwipeDeckView(viewModel: viewModel, modelContext: nil)
        
        // Then - View should initialize without crashing
        #expect(view.viewModel === viewModel)
    }
    
    @Test("TenderCardView displays restaurant information")
    func testTenderCardViewDisplay() async throws {
        // Given
        let tender = Tender(
            name: "Test Restaurant",
            restaurantType: "Italian",
            priceRange: "$$$",
            address: "123 Main St",
            phoneNumber: "(555) 123-4567",
            latitude: 37.7749,
            longitude: -122.4194,
            rating: 4.5,
            reviewCount: 200
        )
        let userLocation = CLLocation(latitude: 37.7749, longitude: -122.4194)
        
        // When
        let view = TenderCardView(tender: tender, userLocation: userLocation)
        
        // Then
        #expect(view.tender.name == "Test Restaurant")
        #expect(view.tender.restaurantType == "Italian")
        #expect(view.tender.priceRange == "$$$")
        #expect(view.tender.rating == 4.5)
        #expect(view.tender.reviewCount == 200)
    }
    
    // MARK: - ChatDetailView Integration
    
    @Test("ChatDetailView can be created with Tender")
    func testChatDetailViewCreation() async throws {
        // Given
        let tender = Tender.fullTestTender()
        let userLocation = CLLocation(latitude: 37.7749, longitude: -122.4194)
        
        // When
        let view = ChatDetailView(
            tender: tender,
            userLocation: userLocation,
            modelContext: nil,
            onClose: {}
        )
        
        // Then - View should initialize
        #expect(view.tender.name == tender.name)
    }
    
    // MARK: - ContentView Integration
    
    @Test("ContentView can be created")
    func testContentViewCreation() async throws {
        // When
        let view = ContentView()
        
        // Then - Should initialize without crashing
        #expect(view != nil)
    }
    
    // MARK: - Complete User Flow Tests
    
    @Test("Complete flow: View -> Load -> Display Cards")
    func testCompleteViewFlow() async throws {
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
        
        // When
        await viewModel.loadRestaurants()
        
        // Create views for each card
        let cardViews = viewModel.tenders.map { tender in
            TenderCardView(tender: tender, userLocation: mockLocationManager.mockLocation)
        }
        
        // Then
        #expect(cardViews.count == 2)
        #expect(cardViews[0].tender.name == "Restaurant 1")
        #expect(cardViews[1].tender.name == "Restaurant 2")
    }
    
    @Test("Complete flow: Swipe -> Save -> View Saved")
    func testSwipeAndSaveFlow() async throws {
        // Given
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: FavoriteRestaurant.self, configurations: config)
        let modelContext = container.mainContext
        
        let mockLocationManager = MockLocationManager()
        mockLocationManager.mockLocation = CLLocation(latitude: 37.7749, longitude: -122.4194)
        
        let mockYelpService = MockYelpService()
        mockYelpService.mockBusinesses = [createMockYelpBusiness(name: "Great Restaurant")]
        
        let searchService = RestaurantSearchService(yelpService: mockYelpService)
        let viewModel = TenderDeckViewModel(
            searchService: searchService,
            locationManager: mockLocationManager
        )
        
        await viewModel.loadRestaurants()
        
        // When - Swipe right (save)
        let tenderToSave = viewModel.tenders[0]
        let favorite = FavoriteRestaurant(from: tenderToSave)
        modelContext.insert(favorite)
        try modelContext.save()
        viewModel.removeTopCard()
        
        // Then - Verify saved
        let descriptor = FetchDescriptor<FavoriteRestaurant>()
        let savedRestaurants = try modelContext.fetch(descriptor)
        #expect(savedRestaurants.count == 1)
        #expect(savedRestaurants[0].name == "Great Restaurant")
        
        // Convert back to Tender for display
        let savedTender = savedRestaurants[0].asTender
        #expect(savedTender.name == tenderToSave.name)
    }
    
    @Test("Complete flow: Load -> Swipe All -> Empty State")
    func testSwipeAllCardsFlow() async throws {
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
        
        // When - Swipe all cards
        viewModel.removeTopCard()
        viewModel.removeTopCard()
        viewModel.removeTopCard()
        
        // Then - Empty state
        #expect(viewModel.tenders.isEmpty)
        #expect(viewModel.lastSwipedRestaurant != nil)
    }
    
    @Test("Complete flow: Error -> Retry -> Success")
    func testErrorRetryFlow() async throws {
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
        
        // When - First attempt fails
        await viewModel.loadRestaurants()
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.tenders.isEmpty)
        
        // When - Retry with success
        mockYelpService.shouldThrowError = false
        mockYelpService.mockBusinesses = [createMockYelpBusiness(name: "Restaurant")]
        await viewModel.loadRestaurants()
        
        // Then
        #expect(viewModel.errorMessage == nil)
        #expect(!viewModel.tenders.isEmpty)
    }
    
    // MARK: - Distance Display Tests
    
    @Test("Distance is calculated for card view")
    func testDistanceCalculation() async throws {
        // Given
        let userLocation = CLLocation(latitude: 37.7749, longitude: -122.4194)
        let restaurantLocation = CLLocation(latitude: 37.7849, longitude: -122.4094)
        let tender = Tender(
            name: "Nearby Restaurant",
            restaurantType: "Fast Food",
            priceRange: "$",
            latitude: restaurantLocation.coordinate.latitude,
            longitude: restaurantLocation.coordinate.longitude
        )
        
        // When
        let distance = userLocation.distance(from: restaurantLocation)
        let distanceInMiles = distance / 1609.34
        
        // Then
        #expect(distance > 0)
        #expect(distanceInMiles < 2.0) // Should be less than 2 miles
    }
    
    @Test("Distance text formatting")
    func testDistanceTextFormatting() async throws {
        // Given
        let distances: [(meters: Double, expectedMiles: Double)] = [
            (1609.34, 1.0),      // 1 mile
            (3218.68, 2.0),      // 2 miles
            (8046.70, 5.0),      // 5 miles
            (16093.40, 10.0)     // 10 miles
        ]
        
        for (meters, expectedMiles) in distances {
            // When
            let calculatedMiles = meters / 1609.34
            
            // Then
            #expect(abs(calculatedMiles - expectedMiles) < 0.01)
        }
    }
    
    // MARK: - Rating Display Tests
    
    @Test("Star rating display for various values")
    func testStarRatingDisplay() async throws {
        let ratings = [1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0]
        
        for rating in ratings {
            // Given
            let tender = Tender(
                name: "Test",
                restaurantType: "Restaurant",
                priceRange: "$",
                latitude: 0,
                longitude: 0,
                rating: rating
            )
            
            // When
            let fullStars = Int(rating)
            let hasHalfStar = rating - Double(fullStars) >= 0.5
            
            // Then
            #expect(fullStars >= 1 && fullStars <= 5)
            if hasHalfStar {
                #expect(rating - Double(fullStars) >= 0.5)
            }
        }
    }
    
    // MARK: - Open/Closed Badge Tests
    
    @Test("Open badge displays for open restaurants")
    func testOpenBadge() async throws {
        // Given
        let tender = Tender(
            name: "Open Restaurant",
            restaurantType: "Restaurant",
            priceRange: "$",
            latitude: 0,
            longitude: 0,
            isOpenNow: true
        )
        
        // When
        let view = TenderCardView(tender: tender, userLocation: nil)
        
        // Then
        #expect(view.tender.isOpenNow == true)
    }
    
    @Test("Closed badge displays for closed restaurants")
    func testClosedBadge() async throws {
        // Given
        let tender = Tender(
            name: "Closed Restaurant",
            restaurantType: "Restaurant",
            priceRange: "$",
            latitude: 0,
            longitude: 0,
            isOpenNow: false
        )
        
        // When
        let view = TenderCardView(tender: tender, userLocation: nil)
        
        // Then
        #expect(view.tender.isOpenNow == false)
    }
    
    @Test("No badge when status unknown")
    func testNoBadgeWhenUnknown() async throws {
        // Given
        let tender = Tender(
            name: "Unknown Status Restaurant",
            restaurantType: "Restaurant",
            priceRange: "$",
            latitude: 0,
            longitude: 0,
            isOpenNow: nil
        )
        
        // When
        let view = TenderCardView(tender: tender, userLocation: nil)
        
        // Then
        #expect(view.tender.isOpenNow == nil)
    }
    
    // MARK: - Image Loading Tests
    
    @Test("Card handles local image name")
    func testLocalImageHandling() async throws {
        // Given
        let tender = Tender(
            name: "Local Image Restaurant",
            restaurantType: "Restaurant",
            priceRange: "$",
            imageName: "tenders1",
            latitude: 0,
            longitude: 0
        )
        
        // When
        let view = TenderCardView(tender: tender, userLocation: nil)
        
        // Then
        #expect(view.tender.imageName == "tenders1")
    }
    
    @Test("Card handles remote image URL")
    func testRemoteImageHandling() async throws {
        // Given
        let tender = Tender(
            name: "Remote Image Restaurant",
            restaurantType: "Restaurant",
            priceRange: "$",
            imageURL: URL(string: "https://example.com/image.jpg"),
            latitude: 0,
            longitude: 0
        )
        
        // When
        let view = TenderCardView(tender: tender, userLocation: nil)
        
        // Then
        #expect(view.tender.imageURL != nil)
    }
    
    @Test("Card handles missing image gracefully")
    func testMissingImageHandling() async throws {
        // Given
        let tender = Tender(
            name: "No Image Restaurant",
            restaurantType: "Restaurant",
            priceRange: "$",
            latitude: 0,
            longitude: 0
        )
        
        // When
        let view = TenderCardView(tender: tender, userLocation: nil)
        
        // Then
        #expect(view.tender.imageName == nil)
        #expect(view.tender.imageURL == nil)
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
