//
//  RestaurantTests.swift
//  TendrTests
//
//  Unit tests for Restaurant model
//

import XCTest
@testable import Tendr

final class RestaurantTests: XCTestCase {
    
    // MARK: - Model Tests
    
    func testRestaurantEquality() {
        let id = UUID()
        let restaurant1 = Restaurant(
            id: id,
            name: "Test Restaurant",
            address: "123 Main St",
            coordinate: .init(latitude: 0, longitude: 0),
            priceLevel: .moderate,
            phoneNumber: nil,
            websiteURL: nil,
            imageURL: nil
        )
        let restaurant2 = Restaurant(
            id: id,
            name: "Different Name", // Same ID, different data
            address: "456 Other St",
            coordinate: .init(latitude: 1, longitude: 1),
            priceLevel: .expensive,
            phoneNumber: nil,
            websiteURL: nil,
            imageURL: nil
        )
        
        // Equality based on ID only
        XCTAssertEqual(restaurant1, restaurant2)
    }
    
    func testRestaurantHashability() {
        let restaurant1 = Restaurant.preview
        let restaurant2 = Restaurant.previewList[0]
        
        var set = Set<Restaurant>()
        set.insert(restaurant1)
        set.insert(restaurant2)
        
        // Both should be in set (different IDs)
        XCTAssertEqual(set.count, 2)
        
        // Inserting same restaurant again shouldn't change count
        set.insert(restaurant1)
        XCTAssertEqual(set.count, 2)
    }
    
    // MARK: - Price Level Tests
    
    func testPriceLevelDisplayStrings() {
        XCTAssertEqual(Restaurant.PriceLevel.unknown.displayString, "Price N/A")
        XCTAssertEqual(Restaurant.PriceLevel.cheap.displayString, "$")
        XCTAssertEqual(Restaurant.PriceLevel.moderate.displayString, "$$")
        XCTAssertEqual(Restaurant.PriceLevel.expensive.displayString, "$$$")
        XCTAssertEqual(Restaurant.PriceLevel.veryExpensive.displayString, "$$$$")
    }
    
    func testPriceLevelCodable() throws {
        let original = Restaurant.PriceLevel.expensive
        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Restaurant.PriceLevel.self, from: encoded)
        
        XCTAssertEqual(original, decoded)
    }
    
    // MARK: - Coordinate Tests
    
    func testCoordinateCLConversion() {
        let coordinate = Restaurant.Coordinate(latitude: 39.9612, longitude: -82.9988)
        let clCoord = coordinate.clCoordinate
        
        XCTAssertEqual(clCoord.latitude, 39.9612, accuracy: 0.0001)
        XCTAssertEqual(clCoord.longitude, -82.9988, accuracy: 0.0001)
    }
    
    func testCoordinateCodable() throws {
        let original = Restaurant.Coordinate(latitude: 39.9612, longitude: -82.9988)
        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Restaurant.Coordinate.self, from: encoded)
        
        XCTAssertEqual(original, decoded)
    }
    
    // MARK: - Restaurant Codable Tests
    
    func testRestaurantCodable() throws {
        let original = Restaurant.preview
        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Restaurant.self, from: encoded)
        
        XCTAssertEqual(original.id, decoded.id)
        XCTAssertEqual(original.name, decoded.name)
        XCTAssertEqual(original.address, decoded.address)
        XCTAssertEqual(original.priceLevel, decoded.priceLevel)
    }
}
