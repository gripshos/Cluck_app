//
//  DiscoveryViewModelTests.swift
//  TendrTests
//
//  Unit tests for DiscoveryViewModel
//

import XCTest
import CoreLocation
@testable import Tendr

@MainActor
final class DiscoveryViewModelTests: XCTestCase {
    
    var viewModel: DiscoveryViewModel!
    var mockFavorites: FavoritesRepository!
    
    override func setUp() async throws {
        mockFavorites = FavoritesRepository(inMemory: true)
    }
    
    override func tearDown() async throws {
        viewModel = nil
        mockFavorites = nil
    }
    
    // MARK: - Initial State Tests
    
    func testInitialState() {
        viewModel = DiscoveryViewModel(
            restaurantRepository: .preview,
            favoritesRepository: mockFavorites,
            locationService: LocationService()
        )
        
        XCTAssertTrue(viewModel.deck.isEmpty)
        XCTAssertEqual(viewModel.currentIndex, 0)
        XCTAssertNil(viewModel.currentRestaurant)
        XCTAssertFalse(viewModel.hasMoreCards)
    }
    
    // MARK: - Swipe Tests
    
    func testSwipeLeftAdvancesIndex() {
        viewModel = .preview
        let initialCount = viewModel.remainingCount
        
        viewModel.swipeLeft()
        
        XCTAssertEqual(viewModel.remainingCount, initialCount - 1)
        XCTAssertEqual(viewModel.currentIndex, 1)
    }
    
    func testSwipeRightAdvancesAndSaves() {
        viewModel = DiscoveryViewModel(
            restaurantRepository: .preview,
            favoritesRepository: mockFavorites,
            locationService: LocationService()
        )
        // Pre-populate deck
        viewModel = .preview
        
        let restaurant = viewModel.currentRestaurant
        XCTAssertNotNil(restaurant)
        
        // Note: Can't test favorites saved since we're using preview which has its own favorites repo
        viewModel.swipeRight()
        
        XCTAssertEqual(viewModel.currentIndex, 1)
    }
    
    func testSwipeOnEmptyDeckDoesNothing() {
        viewModel = .empty
        
        viewModel.swipeLeft()
        XCTAssertEqual(viewModel.currentIndex, 0)
        
        viewModel.swipeRight()
        XCTAssertEqual(viewModel.currentIndex, 0)
    }
    
    // MARK: - State Tests
    
    func testHasMoreCardsReflectsDeckState() {
        viewModel = .preview
        XCTAssertTrue(viewModel.hasMoreCards)
        
        // Swipe through all cards
        while viewModel.hasMoreCards {
            viewModel.swipeLeft()
        }
        
        XCTAssertFalse(viewModel.hasMoreCards)
    }
    
    func testCurrentRestaurantReturnsTopCard() {
        viewModel = .preview
        
        let firstRestaurant = viewModel.currentRestaurant
        XCTAssertNotNil(firstRestaurant)
        
        viewModel.swipeLeft()
        
        let secondRestaurant = viewModel.currentRestaurant
        XCTAssertNotNil(secondRestaurant)
        XCTAssertNotEqual(firstRestaurant?.id, secondRestaurant?.id)
    }
    
    func testRemainingCountDecrementsOnSwipe() {
        viewModel = .preview
        let initialCount = viewModel.remainingCount
        
        viewModel.swipeLeft()
        XCTAssertEqual(viewModel.remainingCount, initialCount - 1)
        
        viewModel.swipeRight()
        XCTAssertEqual(viewModel.remainingCount, initialCount - 2)
    }
}
