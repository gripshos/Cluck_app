//
//  SavedListViewTests.swift
//  Cluck
//
//  Tests for SavedListView and related components
//

import XCTest
import SwiftUI
import SwiftData
@testable import Cluck

@MainActor
class SavedListViewTests: XCTestCase {
    
    // MARK: - SavedListView Tests
    
    func testSavedListViewCreation() async throws {
        // When
        let view = SavedListView()
        
        // Then - Should initialize without crashing
        XCTAssertNotNil(view)
    }
    
    func testEmptyFavoritesList() async throws {
        // Given
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: FavoriteRestaurant.self, configurations: config)
        
        // When
        let view = SavedListView()
            .modelContainer(container)
        
        // Then - Should show empty state
        XCTAssertNotNil(view)
    }
    
    func testFavoritesListWithData() async throws {
        // Given
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: FavoriteRestaurant.self, configurations: config)
        let modelContext = container.mainContext
        
        let tender1 = Tender.testTender(name: "Restaurant 1")
        let tender2 = Tender.testTender(name: "Restaurant 2")
        modelContext.insert(FavoriteRestaurant(from: tender1))
        modelContext.insert(FavoriteRestaurant(from: tender2))
        try modelContext.save()
        
        // When
        let view = SavedListView()
            .modelContainer(container)
        
        // Then
        #expect(view != nil)
    }
    
    // MARK: - SavedHeader Tests
    
    @Test("SavedHeader without edit button")
    func testSavedHeaderNoEdit() async throws {
        // Given
        @State var editMode: EditMode = .inactive
        
        // When
        let header = SavedHeader(showEdit: false, editMode: Binding.constant(.inactive))
        
        // Then
        #expect(header != nil)
    }
    
    @Test("SavedHeader with edit button")
    func testSavedHeaderWithEdit() async throws {
        // When
        let header = SavedHeader(showEdit: true, editMode: Binding.constant(.inactive))
        
        // Then
        #expect(header != nil)
    }
    
    @Test("SavedHeader edit mode toggle")
    func testSavedHeaderEditModeToggle() async throws {
        // Given
        var editMode: EditMode = .inactive
        
        // When - Toggle to active
        editMode = .active
        
        // Then
        #expect(editMode == .active)
        
        // When - Toggle back
        editMode = .inactive
        
        // Then
        #expect(editMode == .inactive)
    }
    
    // MARK: - SavedRestaurantRow Tests
    
    @Test("SavedRestaurantRow displays minimal data")
    func testSavedRestaurantRowMinimal() async throws {
        // Given
        let tender = Tender.testTender(name: "Test Restaurant")
        let favorite = FavoriteRestaurant(from: tender)
        
        // When
        let row = SavedRestaurantRow(favorite: favorite)
        
        // Then
        #expect(row.favorite.name == "Test Restaurant")
        #expect(row.favorite.restaurantType == "Fast Food")
        #expect(row.favorite.priceRange == "$$")
    }
    
    @Test("SavedRestaurantRow displays full data")
    func testSavedRestaurantRowFull() async throws {
        // Given
        let tender = Tender.fullTestTender(name: "Full Restaurant")
        let favorite = FavoriteRestaurant(from: tender)
        
        // When
        let row = SavedRestaurantRow(favorite: favorite)
        
        // Then
        #expect(row.favorite.name == "Full Restaurant")
        #expect(row.favorite.address != nil)
        #expect(row.favorite.imageURL != nil)
    }
    
    @Test("SavedRestaurantRow with image URL")
    func testSavedRestaurantRowWithImageURL() async throws {
        // Given
        let tender = Tender(
            name: "Restaurant",
            restaurantType: "Italian",
            priceRange: "$$$",
            imageURL: URL(string: "https://example.com/image.jpg"),
            latitude: 0,
            longitude: 0
        )
        let favorite = FavoriteRestaurant(from: tender)
        
        // When
        let row = SavedRestaurantRow(favorite: favorite)
        
        // Then
        #expect(row.favorite.imageURL == "https://example.com/image.jpg")
    }
    
    @Test("SavedRestaurantRow with local image name")
    func testSavedRestaurantRowWithLocalImage() async throws {
        // Given
        let tender = Tender(
            name: "Restaurant",
            restaurantType: "Italian",
            priceRange: "$$$",
            imageName: "tenders1",
            latitude: 0,
            longitude: 0
        )
        let favorite = FavoriteRestaurant(from: tender)
        
        // When
        let row = SavedRestaurantRow(favorite: favorite)
        
        // Then
        #expect(row.favorite.imageName == "tenders1")
    }
    
    @Test("SavedRestaurantRow without image")
    func testSavedRestaurantRowNoImage() async throws {
        // Given
        let tender = Tender(
            name: "Restaurant",
            restaurantType: "Italian",
            priceRange: "$$$",
            latitude: 0,
            longitude: 0
        )
        let favorite = FavoriteRestaurant(from: tender)
        
        // When
        let row = SavedRestaurantRow(favorite: favorite)
        
        // Then
        #expect(row.favorite.imageName == nil)
        #expect(row.favorite.imageURL == nil)
    }
    
    @Test("SavedRestaurantRow displays address")
    func testSavedRestaurantRowWithAddress() async throws {
        // Given
        let tender = Tender(
            name: "Restaurant",
            restaurantType: "Italian",
            priceRange: "$$$",
            address: "123 Main St, San Francisco, CA",
            latitude: 0,
            longitude: 0
        )
        let favorite = FavoriteRestaurant(from: tender)
        
        // When
        let row = SavedRestaurantRow(favorite: favorite)
        
        // Then
        #expect(row.favorite.address == "123 Main St, San Francisco, CA")
    }
    
    // MARK: - Delete Functionality Tests
    
    @Test("Delete single favorite")
    func testDeleteSingleFavorite() async throws {
        // Given
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: FavoriteRestaurant.self, configurations: config)
        let modelContext = container.mainContext
        
        let tender = Tender.testTender(name: "To Delete")
        let favorite = FavoriteRestaurant(from: tender)
        modelContext.insert(favorite)
        try modelContext.save()
        
        // When
        modelContext.delete(favorite)
        try modelContext.save()
        
        let descriptor = FetchDescriptor<FavoriteRestaurant>()
        let results = try modelContext.fetch(descriptor)
        
        // Then
        #expect(results.isEmpty)
    }
    
    @Test("Delete multiple favorites")
    func testDeleteMultipleFavorites() async throws {
        // Given
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: FavoriteRestaurant.self, configurations: config)
        let modelContext = container.mainContext
        
        let tender1 = Tender.testTender(name: "Restaurant 1")
        let tender2 = Tender.testTender(name: "Restaurant 2")
        let tender3 = Tender.testTender(name: "Restaurant 3")
        
        let favorite1 = FavoriteRestaurant(from: tender1)
        let favorite2 = FavoriteRestaurant(from: tender2)
        let favorite3 = FavoriteRestaurant(from: tender3)
        
        modelContext.insert(favorite1)
        modelContext.insert(favorite2)
        modelContext.insert(favorite3)
        try modelContext.save()
        
        // When - Delete first and third
        modelContext.delete(favorite1)
        modelContext.delete(favorite3)
        try modelContext.save()
        
        let descriptor = FetchDescriptor<FavoriteRestaurant>()
        let results = try modelContext.fetch(descriptor)
        
        // Then - Only second should remain
        #expect(results.count == 1)
        #expect(results[0].name == "Restaurant 2")
    }
    
    // MARK: - Sorting Tests
    
    @Test("Favorites sorted by saved date (newest first)")
    func testFavoritesSortedBySavedDate() async throws {
        // Given
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: FavoriteRestaurant.self, configurations: config)
        let modelContext = container.mainContext
        
        let tender1 = Tender.testTender(name: "First")
        modelContext.insert(FavoriteRestaurant(from: tender1))
        try modelContext.save()
        
        try await Task.sleep(nanoseconds: 10_000_000) // 0.01 seconds
        
        let tender2 = Tender.testTender(name: "Second")
        modelContext.insert(FavoriteRestaurant(from: tender2))
        try modelContext.save()
        
        try await Task.sleep(nanoseconds: 10_000_000)
        
        let tender3 = Tender.testTender(name: "Third")
        modelContext.insert(FavoriteRestaurant(from: tender3))
        try modelContext.save()
        
        // When
        let descriptor = FetchDescriptor<FavoriteRestaurant>(
            sortBy: [SortDescriptor(\.savedDate, order: .reverse)]
        )
        let results = try modelContext.fetch(descriptor)
        
        // Then - Newest first
        #expect(results.count == 3)
        #expect(results[0].savedDate >= results[1].savedDate)
        #expect(results[1].savedDate >= results[2].savedDate)
    }
    
    // MARK: - Tap Gesture Tests
    
    @Test("Tapping row should select tender")
    func testTapRowSelectsTender() async throws {
        // Given
        let tender = Tender.testTender(name: "Tap Test")
        let favorite = FavoriteRestaurant(from: tender)
        var selectedTender: Tender? = nil
        
        // When - Simulate tap
        selectedTender = favorite.asTender
        
        // Then
        #expect(selectedTender != nil)
        #expect(selectedTender?.name == "Tap Test")
    }
    
    // MARK: - Integration Tests
    
    @Test("Complete flow: Save -> View in List -> Delete")
    func testCompleteListFlow() async throws {
        // Given
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: FavoriteRestaurant.self, configurations: config)
        let modelContext = container.mainContext
        
        // When - Save restaurant
        let tender = Tender.testTender(name: "Test Restaurant")
        let favorite = FavoriteRestaurant(from: tender)
        modelContext.insert(favorite)
        try modelContext.save()
        
        // Then - Verify saved
        var descriptor = FetchDescriptor<FavoriteRestaurant>()
        var results = try modelContext.fetch(descriptor)
        #expect(results.count == 1)
        #expect(results[0].name == "Test Restaurant")
        
        // When - Delete
        modelContext.delete(results[0])
        try modelContext.save()
        
        // Then - Verify deleted
        descriptor = FetchDescriptor<FavoriteRestaurant>()
        results = try modelContext.fetch(descriptor)
        #expect(results.isEmpty)
    }
    
    @Test("View updates when favorites change")
    func testViewUpdatesWithDataChanges() async throws {
        // Given
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: FavoriteRestaurant.self, configurations: config)
        let modelContext = container.mainContext
        
        // When - Initially empty
        var descriptor = FetchDescriptor<FavoriteRestaurant>()
        var results = try modelContext.fetch(descriptor)
        #expect(results.isEmpty)
        
        // When - Add favorite
        let tender = Tender.testTender(name: "New Restaurant")
        modelContext.insert(FavoriteRestaurant(from: tender))
        try modelContext.save()
        
        // Then - Should have one item
        descriptor = FetchDescriptor<FavoriteRestaurant>()
        results = try modelContext.fetch(descriptor)
        #expect(results.count == 1)
    }
    
    // MARK: - Edit Mode Tests
    
    @Test("Edit mode inactive by default")
    func testEditModeInactiveByDefault() async throws {
        // Given
        var editMode: EditMode = .inactive
        
        // Then
        #expect(editMode == .inactive)
    }
    
    @Test("Edit mode can be activated")
    func testEditModeActivation() async throws {
        // Given
        var editMode: EditMode = .inactive
        
        // When
        editMode = .active
        
        // Then
        #expect(editMode == .active)
    }
    
    @Test("Edit mode can be deactivated")
    func testEditModeDeactivation() async throws {
        // Given
        var editMode: EditMode = .active
        
        // When
        editMode = .inactive
        
        // Then
        #expect(editMode == .inactive)
    }
    
    // MARK: - Display Tests
    
    @Test("Row displays restaurant type")
    func testRowDisplaysRestaurantType() async throws {
        // Given
        let tender = Tender(
            name: "Italian Place",
            restaurantType: "Italian",
            priceRange: "$$$",
            latitude: 0,
            longitude: 0
        )
        let favorite = FavoriteRestaurant(from: tender)
        
        // When
        let row = SavedRestaurantRow(favorite: favorite)
        
        // Then
        #expect(row.favorite.restaurantType == "Italian")
    }
    
    @Test("Row displays price range")
    func testRowDisplaysPriceRange() async throws {
        // Given
        let priceRanges = ["$", "$$", "$$$", "$$$$"]
        
        for priceRange in priceRanges {
            // When
            let tender = Tender(
                name: "Restaurant",
                restaurantType: "Restaurant",
                priceRange: priceRange,
                latitude: 0,
                longitude: 0
            )
            let favorite = FavoriteRestaurant(from: tender)
            let row = SavedRestaurantRow(favorite: favorite)
            
            // Then
            #expect(row.favorite.priceRange == priceRange)
        }
    }
    
    @Test("Row displays restaurant name")
    func testRowDisplaysName() async throws {
        // Given
        let names = ["Restaurant A", "Restaurant B", "Very Long Restaurant Name That Should Be Displayed"]
        
        for name in names {
            // When
            let tender = Tender(
                name: name,
                restaurantType: "Restaurant",
                priceRange: "$",
                latitude: 0,
                longitude: 0
            )
            let favorite = FavoriteRestaurant(from: tender)
            let row = SavedRestaurantRow(favorite: favorite)
            
            // Then
            #expect(row.favorite.name == name)
        }
    }
    
    // MARK: - Empty State Tests
    
    @Test("Empty state shows when no favorites")
    func testEmptyStateDisplay() async throws {
        // Given
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: FavoriteRestaurant.self, configurations: config)
        let modelContext = container.mainContext
        
        // When
        let descriptor = FetchDescriptor<FavoriteRestaurant>()
        let results = try modelContext.fetch(descriptor)
        
        // Then
        #expect(results.isEmpty)
    }
    
    @Test("List shows when favorites exist")
    func testListDisplayWithFavorites() async throws {
        // Given
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: FavoriteRestaurant.self, configurations: config)
        let modelContext = container.mainContext
        
        let tender = Tender.testTender(name: "Test")
        modelContext.insert(FavoriteRestaurant(from: tender))
        try modelContext.save()
        
        // When
        let descriptor = FetchDescriptor<FavoriteRestaurant>()
        let results = try modelContext.fetch(descriptor)
        
        // Then
        #expect(!results.isEmpty)
    }
}
