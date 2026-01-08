//
//  TenderTests.swift
//  Cluck
//
//  Tests for the Tender data model
//

import Testing
import Foundation
@testable import Cluck

@Suite("Tender Model Tests")
struct TenderTests {
    
    // MARK: - Initialization Tests
    
    @Test("Initialize with minimal required fields")
    func testMinimalInitialization() async throws {
        // Given & When
        let tender = Tender(
            name: "Test Restaurant",
            restaurantType: "Fast Food",
            priceRange: "$",
            latitude: 37.7749,
            longitude: -122.4194
        )
        
        // Then
        #expect(tender.name == "Test Restaurant")
        #expect(tender.restaurantType == "Fast Food")
        #expect(tender.priceRange == "$")
        #expect(tender.latitude == 37.7749)
        #expect(tender.longitude == -122.4194)
        #expect(tender.address == nil)
        #expect(tender.phoneNumber == nil)
        #expect(tender.websiteURL == nil)
        #expect(tender.imageName == nil)
        #expect(tender.imageURL == nil)
        #expect(tender.rating == nil)
        #expect(tender.reviewCount == nil)
        #expect(tender.isOpenNow == nil)
        #expect(tender.additionalPhotos == nil)
    }
    
    @Test("Initialize with all fields")
    func testFullInitialization() async throws {
        // Given
        let id = UUID()
        let websiteURL = URL(string: "https://example.com")!
        let imageURL = URL(string: "https://example.com/image.jpg")!
        let photo1 = URL(string: "https://example.com/photo1.jpg")!
        let photo2 = URL(string: "https://example.com/photo2.jpg")!
        
        // When
        let tender = Tender(
            id: id,
            name: "Full Restaurant",
            restaurantType: "Fine Dining",
            priceRange: "$$$$",
            address: "123 Main St, San Francisco, CA",
            phoneNumber: "(415) 555-1234",
            websiteURL: websiteURL,
            imageName: "tenders1",
            imageURL: imageURL,
            latitude: 37.7749,
            longitude: -122.4194,
            rating: 4.5,
            reviewCount: 250,
            isOpenNow: true,
            additionalPhotos: [photo1, photo2]
        )
        
        // Then
        #expect(tender.id == id)
        #expect(tender.name == "Full Restaurant")
        #expect(tender.restaurantType == "Fine Dining")
        #expect(tender.priceRange == "$$$$")
        #expect(tender.address == "123 Main St, San Francisco, CA")
        #expect(tender.phoneNumber == "(415) 555-1234")
        #expect(tender.websiteURL == websiteURL)
        #expect(tender.imageName == "tenders1")
        #expect(tender.imageURL == imageURL)
        #expect(tender.latitude == 37.7749)
        #expect(tender.longitude == -122.4194)
        #expect(tender.rating == 4.5)
        #expect(tender.reviewCount == 250)
        #expect(tender.isOpenNow == true)
        #expect(tender.additionalPhotos?.count == 2)
    }
    
    @Test("Default ID is generated when not provided")
    func testDefaultIDGeneration() async throws {
        // When
        let tender1 = Tender(
            name: "Restaurant 1",
            restaurantType: "Fast Food",
            priceRange: "$",
            latitude: 37.7749,
            longitude: -122.4194
        )
        let tender2 = Tender(
            name: "Restaurant 2",
            restaurantType: "Fast Food",
            priceRange: "$",
            latitude: 37.7749,
            longitude: -122.4194
        )
        
        // Then - IDs should be different
        #expect(tender1.id != tender2.id)
    }
    
    // MARK: - Identifiable Protocol Tests
    
    @Test("Tender conforms to Identifiable")
    func testIdentifiableConformance() async throws {
        // Given
        let id = UUID()
        let tender = Tender(
            id: id,
            name: "Test",
            restaurantType: "Restaurant",
            priceRange: "$",
            latitude: 0,
            longitude: 0
        )
        
        // Then
        #expect(tender.id == id)
    }
    
    // MARK: - Codable Tests
    
    @Test("Tender can be encoded to JSON")
    func testEncodable() async throws {
        // Given
        let tender = Tender(
            name: "Test Restaurant",
            restaurantType: "Fast Food",
            priceRange: "$$",
            latitude: 37.7749,
            longitude: -122.4194,
            rating: 4.5,
            reviewCount: 100
        )
        
        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(tender)
        
        // Then
        #expect(!data.isEmpty)
    }
    
    @Test("Tender can be decoded from JSON")
    func testDecodable() async throws {
        // Given
        let originalTender = Tender(
            name: "Test Restaurant",
            restaurantType: "Fast Food",
            priceRange: "$$",
            address: "123 Main St",
            phoneNumber: "(555) 123-4567",
            websiteURL: URL(string: "https://example.com"),
            latitude: 37.7749,
            longitude: -122.4194,
            rating: 4.5,
            reviewCount: 100,
            isOpenNow: true
        )
        
        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalTender)
        
        let decoder = JSONDecoder()
        let decodedTender = try decoder.decode(Tender.self, from: data)
        
        // Then
        #expect(decodedTender.id == originalTender.id)
        #expect(decodedTender.name == originalTender.name)
        #expect(decodedTender.restaurantType == originalTender.restaurantType)
        #expect(decodedTender.priceRange == originalTender.priceRange)
        #expect(decodedTender.address == originalTender.address)
        #expect(decodedTender.phoneNumber == originalTender.phoneNumber)
        #expect(decodedTender.websiteURL == originalTender.websiteURL)
        #expect(decodedTender.latitude == originalTender.latitude)
        #expect(decodedTender.longitude == originalTender.longitude)
        #expect(decodedTender.rating == originalTender.rating)
        #expect(decodedTender.reviewCount == originalTender.reviewCount)
        #expect(decodedTender.isOpenNow == originalTender.isOpenNow)
    }
    
    @Test("Tender with URLs can be encoded and decoded")
    func testCodableWithURLs() async throws {
        // Given
        let tender = Tender(
            name: "Test",
            restaurantType: "Restaurant",
            priceRange: "$",
            websiteURL: URL(string: "https://example.com"),
            imageURL: URL(string: "https://example.com/image.jpg"),
            latitude: 0,
            longitude: 0,
            additionalPhotos: [
                URL(string: "https://example.com/photo1.jpg")!,
                URL(string: "https://example.com/photo2.jpg")!
            ]
        )
        
        // When
        let data = try JSONEncoder().encode(tender)
        let decoded = try JSONDecoder().decode(Tender.self, from: data)
        
        // Then
        #expect(decoded.websiteURL == tender.websiteURL)
        #expect(decoded.imageURL == tender.imageURL)
        #expect(decoded.additionalPhotos?.count == 2)
    }
    
    // MARK: - Hashable Tests
    
    @Test("Tender conforms to Hashable")
    func testHashableConformance() async throws {
        // Given
        let id = UUID()
        let tender1 = Tender(
            id: id,
            name: "Test",
            restaurantType: "Restaurant",
            priceRange: "$",
            latitude: 0,
            longitude: 0
        )
        let tender2 = Tender(
            id: id,
            name: "Test",
            restaurantType: "Restaurant",
            priceRange: "$",
            latitude: 0,
            longitude: 0
        )
        
        // Then
        #expect(tender1 == tender2)
        #expect(tender1.hashValue == tender2.hashValue)
    }
    
    @Test("Different tenders have different hashes")
    func testDifferentTendersHaveDifferentHashes() async throws {
        // Given
        let tender1 = Tender(
            name: "Restaurant 1",
            restaurantType: "Fast Food",
            priceRange: "$",
            latitude: 37.7749,
            longitude: -122.4194
        )
        let tender2 = Tender(
            name: "Restaurant 2",
            restaurantType: "Fast Food",
            priceRange: "$",
            latitude: 37.7749,
            longitude: -122.4194
        )
        
        // Then
        #expect(tender1 != tender2)
    }
    
    @Test("Tenders can be added to Set")
    func testTendersInSet() async throws {
        // Given
        let tender1 = Tender.testTender(name: "Restaurant 1")
        let tender2 = Tender.testTender(name: "Restaurant 2")
        let tender3 = tender1 // Same instance
        
        // When
        var tenderSet = Set<Tender>()
        tenderSet.insert(tender1)
        tenderSet.insert(tender2)
        tenderSet.insert(tender3)
        
        // Then
        #expect(tenderSet.count == 2) // tender1 and tender3 are the same
    }
    
    // MARK: - Price Range Tests
    
    @Test("Various price ranges are stored correctly")
    func testPriceRanges() async throws {
        let priceRanges = ["$", "$$", "$$$", "$$$$", "$ - $$", "$$ - $$$"]
        
        for priceRange in priceRanges {
            // When
            let tender = Tender(
                name: "Test",
                restaurantType: "Restaurant",
                priceRange: priceRange,
                latitude: 0,
                longitude: 0
            )
            
            // Then
            #expect(tender.priceRange == priceRange)
        }
    }
    
    // MARK: - Rating Tests
    
    @Test("Rating range is valid")
    func testRatingRange() async throws {
        let ratings = [0.0, 1.0, 2.5, 3.0, 4.5, 5.0]
        
        for rating in ratings {
            // When
            let tender = Tender(
                name: "Test",
                restaurantType: "Restaurant",
                priceRange: "$",
                latitude: 0,
                longitude: 0,
                rating: rating
            )
            
            // Then
            #expect(tender.rating == rating)
            #expect(tender.rating! >= 0.0)
            #expect(tender.rating! <= 5.0)
        }
    }
    
    // MARK: - Coordinate Tests
    
    @Test("Valid latitude range")
    func testValidLatitude() async throws {
        let latitudes = [-90.0, -45.0, 0.0, 45.0, 90.0]
        
        for lat in latitudes {
            // When
            let tender = Tender(
                name: "Test",
                restaurantType: "Restaurant",
                priceRange: "$",
                latitude: lat,
                longitude: 0
            )
            
            // Then
            #expect(tender.latitude == lat)
            #expect(tender.latitude >= -90.0)
            #expect(tender.latitude <= 90.0)
        }
    }
    
    @Test("Valid longitude range")
    func testValidLongitude() async throws {
        let longitudes = [-180.0, -90.0, 0.0, 90.0, 180.0]
        
        for lon in longitudes {
            // When
            let tender = Tender(
                name: "Test",
                restaurantType: "Restaurant",
                priceRange: "$",
                latitude: 0,
                longitude: lon
            )
            
            // Then
            #expect(tender.longitude == lon)
            #expect(tender.longitude >= -180.0)
            #expect(tender.longitude <= 180.0)
        }
    }
    
    // MARK: - Test Helper Tests
    
    @Test("testTender helper creates valid tender")
    func testTestTenderHelper() async throws {
        // When
        let tender = Tender.testTender()
        
        // Then
        #expect(tender.name == "Test Restaurant")
        #expect(tender.restaurantType == "Fast Food")
        #expect(tender.priceRange == "$$")
        #expect(tender.latitude == 37.7749)
        #expect(tender.longitude == -122.4194)
    }
    
    @Test("testTender helper accepts custom parameters")
    func testTestTenderHelperWithCustomParams() async throws {
        // When
        let tender = Tender.testTender(
            name: "Custom Restaurant",
            restaurantType: "Fine Dining",
            priceRange: "$$$$",
            latitude: 40.7128,
            longitude: -74.0060
        )
        
        // Then
        #expect(tender.name == "Custom Restaurant")
        #expect(tender.restaurantType == "Fine Dining")
        #expect(tender.priceRange == "$$$$")
        #expect(tender.latitude == 40.7128)
        #expect(tender.longitude == -74.0060)
    }
    
    @Test("fullTestTender helper creates complete tender")
    func testFullTestTenderHelper() async throws {
        // When
        let tender = Tender.fullTestTender()
        
        // Then
        #expect(tender.name == "Full Test Restaurant")
        #expect(tender.address != nil)
        #expect(tender.phoneNumber != nil)
        #expect(tender.websiteURL != nil)
        #expect(tender.imageURL != nil)
        #expect(tender.rating != nil)
        #expect(tender.reviewCount != nil)
        #expect(tender.isOpenNow != nil)
        #expect(tender.additionalPhotos != nil)
        #expect(tender.additionalPhotos?.count == 2)
    }
    
    // MARK: - Optional Field Tests
    
    @Test("Optional fields can be nil")
    func testOptionalFieldsNil() async throws {
        // When
        let tender = Tender(
            name: "Test",
            restaurantType: "Restaurant",
            priceRange: "$",
            latitude: 0,
            longitude: 0
        )
        
        // Then
        #expect(tender.address == nil)
        #expect(tender.phoneNumber == nil)
        #expect(tender.websiteURL == nil)
        #expect(tender.imageName == nil)
        #expect(tender.imageURL == nil)
        #expect(tender.rating == nil)
        #expect(tender.reviewCount == nil)
        #expect(tender.isOpenNow == nil)
        #expect(tender.additionalPhotos == nil)
    }
    
    @Test("Optional fields can have values")
    func testOptionalFieldsWithValues() async throws {
        // When
        let tender = Tender(
            name: "Test",
            restaurantType: "Restaurant",
            priceRange: "$",
            address: "123 Main St",
            phoneNumber: "(555) 123-4567",
            websiteURL: URL(string: "https://example.com"),
            imageName: "image",
            imageURL: URL(string: "https://example.com/image.jpg"),
            latitude: 0,
            longitude: 0,
            rating: 4.5,
            reviewCount: 100,
            isOpenNow: true,
            additionalPhotos: [URL(string: "https://example.com/photo.jpg")!]
        )
        
        // Then
        #expect(tender.address != nil)
        #expect(tender.phoneNumber != nil)
        #expect(tender.websiteURL != nil)
        #expect(tender.imageName != nil)
        #expect(tender.imageURL != nil)
        #expect(tender.rating != nil)
        #expect(tender.reviewCount != nil)
        #expect(tender.isOpenNow != nil)
        #expect(tender.additionalPhotos != nil)
    }
    
    // MARK: - Edge Case Tests
    
    @Test("Empty string values are handled")
    func testEmptyStrings() async throws {
        // When
        let tender = Tender(
            name: "",
            restaurantType: "",
            priceRange: "",
            address: "",
            phoneNumber: "",
            latitude: 0,
            longitude: 0
        )
        
        // Then
        #expect(tender.name == "")
        #expect(tender.restaurantType == "")
        #expect(tender.priceRange == "")
        #expect(tender.address == "")
        #expect(tender.phoneNumber == "")
    }
    
    @Test("Very large review count is handled")
    func testLargeReviewCount() async throws {
        // When
        let tender = Tender(
            name: "Popular Restaurant",
            restaurantType: "Restaurant",
            priceRange: "$",
            latitude: 0,
            longitude: 0,
            reviewCount: 999999
        )
        
        // Then
        #expect(tender.reviewCount == 999999)
    }
    
    @Test("Zero coordinates are valid")
    func testZeroCoordinates() async throws {
        // When
        let tender = Tender(
            name: "Test",
            restaurantType: "Restaurant",
            priceRange: "$",
            latitude: 0.0,
            longitude: 0.0
        )
        
        // Then
        #expect(tender.latitude == 0.0)
        #expect(tender.longitude == 0.0)
    }
    
    @Test("Multiple additional photos are stored")
    func testMultipleAdditionalPhotos() async throws {
        // Given
        let photos = (1...10).map { URL(string: "https://example.com/photo\($0).jpg")! }
        
        // When
        let tender = Tender(
            name: "Test",
            restaurantType: "Restaurant",
            priceRange: "$",
            latitude: 0,
            longitude: 0,
            additionalPhotos: photos
        )
        
        // Then
        #expect(tender.additionalPhotos?.count == 10)
        #expect(tender.additionalPhotos?[0].absoluteString == "https://example.com/photo1.jpg")
        #expect(tender.additionalPhotos?[9].absoluteString == "https://example.com/photo10.jpg")
    }
    
    @Test("Empty additional photos array")
    func testEmptyAdditionalPhotos() async throws {
        // When
        let tender = Tender(
            name: "Test",
            restaurantType: "Restaurant",
            priceRange: "$",
            latitude: 0,
            longitude: 0,
            additionalPhotos: []
        )
        
        // Then
        #expect(tender.additionalPhotos?.isEmpty == true)
    }
}
