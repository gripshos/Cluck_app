//
//  TenderTests.swift
//  Cluck
//
//  Tests for the Tender model
//

import Testing
import Foundation
@testable import Cluck

@Suite("Tender Model Tests")
struct TenderTests {
    
    @Test("Tender initialization with all parameters")
    func testTenderInitializationWithAllParameters() async throws {
        // Given
        let id = UUID()
        let name = "Test Restaurant"
        let restaurantType = "Fast Food"
        let priceRange = "$"
        let address = "123 Main St"
        let phoneNumber = "555-1234"
        let websiteURL = URL(string: "https://example.com")
        let imageName = "test_image"
        let imageURL = URL(string: "https://example.com/image.jpg")
        let latitude = 37.7749
        let longitude = -122.4194
        let rating = 4.5
        let reviewCount = 100
        let isOpenNow = true
        let additionalPhotos = [URL(string: "https://example.com/photo1.jpg")!]
        
        // When
        let tender = Tender(
            id: id,
            name: name,
            restaurantType: restaurantType,
            priceRange: priceRange,
            address: address,
            phoneNumber: phoneNumber,
            websiteURL: websiteURL,
            imageName: imageName,
            imageURL: imageURL,
            latitude: latitude,
            longitude: longitude,
            rating: rating,
            reviewCount: reviewCount,
            isOpenNow: isOpenNow,
            additionalPhotos: additionalPhotos
        )
        
        // Then
        #expect(tender.id == id)
        #expect(tender.name == name)
        #expect(tender.restaurantType == restaurantType)
        #expect(tender.priceRange == priceRange)
        #expect(tender.address == address)
        #expect(tender.phoneNumber == phoneNumber)
        #expect(tender.websiteURL == websiteURL)
        #expect(tender.imageName == imageName)
        #expect(tender.imageURL == imageURL)
        #expect(tender.latitude == latitude)
        #expect(tender.longitude == longitude)
        #expect(tender.rating == rating)
        #expect(tender.reviewCount == reviewCount)
        #expect(tender.isOpenNow == isOpenNow)
        #expect(tender.additionalPhotos == additionalPhotos)
    }
    
    @Test("Tender initialization with minimal parameters")
    func testTenderInitializationWithMinimalParameters() async throws {
        // Given
        let name = "Minimal Restaurant"
        let restaurantType = "Fast Food"
        let priceRange = "$$"
        let latitude = 34.0522
        let longitude = -118.2437
        
        // When
        let tender = Tender(
            name: name,
            restaurantType: restaurantType,
            priceRange: priceRange,
            latitude: latitude,
            longitude: longitude
        )
        
        // Then
        #expect(tender.name == name)
        #expect(tender.restaurantType == restaurantType)
        #expect(tender.priceRange == priceRange)
        #expect(tender.latitude == latitude)
        #expect(tender.longitude == longitude)
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
    
    @Test("Tender is Identifiable")
    func testTenderIsIdentifiable() async throws {
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
            restaurantType: "Casual Dining",
            priceRange: "$$",
            latitude: 34.0522,
            longitude: -118.2437
        )
        
        // Then
        #expect(tender1.id != tender2.id, "Each tender should have a unique ID")
    }
    
    @Test("Tender is Codable")
    func testTenderCodable() async throws {
        // Given
        let originalTender = Tender(
            name: "Test Restaurant",
            restaurantType: "Fast Food",
            priceRange: "$$$",
            address: "123 Test St",
            phoneNumber: "555-1234",
            websiteURL: URL(string: "https://test.com"),
            imageURL: URL(string: "https://test.com/image.jpg"),
            latitude: 40.7128,
            longitude: -74.0060,
            rating: 4.5,
            reviewCount: 250,
            isOpenNow: true
        )
        
        // When
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        let jsonData = try encoder.encode(originalTender)
        let decodedTender = try decoder.decode(Tender.self, from: jsonData)
        
        // Then
        #expect(decodedTender.id == originalTender.id)
        #expect(decodedTender.name == originalTender.name)
        #expect(decodedTender.restaurantType == originalTender.restaurantType)
        #expect(decodedTender.priceRange == originalTender.priceRange)
        #expect(decodedTender.latitude == originalTender.latitude)
        #expect(decodedTender.longitude == originalTender.longitude)
        #expect(decodedTender.rating == originalTender.rating)
        #expect(decodedTender.reviewCount == originalTender.reviewCount)
    }
    
    @Test("Tender is Hashable")
    func testTenderHashable() async throws {
        // Given
        let tender1 = Tender(
            name: "Restaurant",
            restaurantType: "Fast Food",
            priceRange: "$",
            latitude: 37.7749,
            longitude: -122.4194
        )
        let tender2 = tender1
        let tender3 = Tender(
            name: "Different Restaurant",
            restaurantType: "Casual Dining",
            priceRange: "$$",
            latitude: 34.0522,
            longitude: -118.2437
        )
        
        // When
        var set = Set<Tender>()
        set.insert(tender1)
        set.insert(tender2)
        set.insert(tender3)
        
        // Then
        #expect(set.count == 2, "Duplicate tenders should not be added to set")
    }
    
    @Test("Tender with negative coordinates")
    func testTenderWithNegativeCoordinates() async throws {
        // Given
        let latitude = -33.8688
        let longitude = 151.2093
        
        // When
        let tender = Tender(
            name: "Sydney Restaurant",
            restaurantType: "Restaurant",
            priceRange: "$$",
            latitude: latitude,
            longitude: longitude
        )
        
        // Then
        #expect(tender.latitude == latitude)
        #expect(tender.longitude == longitude)
    }
    
    @Test("Tender with zero rating")
    func testTenderWithZeroRating() async throws {
        // Given
        let rating = 0.0
        
        // When
        let tender = Tender(
            name: "New Restaurant",
            restaurantType: "Restaurant",
            priceRange: "$$",
            latitude: 37.7749,
            longitude: -122.4194,
            rating: rating,
            reviewCount: 0
        )
        
        // Then
        #expect(tender.rating == 0.0)
        #expect(tender.reviewCount == 0)
    }
    
    @Test("Tender with maximum rating")
    func testTenderWithMaximumRating() async throws {
        // Given
        let rating = 5.0
        
        // When
        let tender = Tender(
            name: "Perfect Restaurant",
            restaurantType: "Fine Dining",
            priceRange: "$$$$",
            latitude: 37.7749,
            longitude: -122.4194,
            rating: rating,
            reviewCount: 1000
        )
        
        // Then
        #expect(tender.rating == 5.0)
        #expect(tender.reviewCount == 1000)
    }
    
    @Test("Tender with multiple additional photos")
    func testTenderWithMultipleAdditionalPhotos() async throws {
        // Given
        let photos = [
            URL(string: "https://example.com/photo1.jpg")!,
            URL(string: "https://example.com/photo2.jpg")!,
            URL(string: "https://example.com/photo3.jpg")!
        ]
        
        // When
        let tender = Tender(
            name: "Photo Gallery Restaurant",
            restaurantType: "Restaurant",
            priceRange: "$$",
            latitude: 37.7749,
            longitude: -122.4194,
            additionalPhotos: photos
        )
        
        // Then
        #expect(tender.additionalPhotos?.count == 3)
        #expect(tender.additionalPhotos == photos)
    }
    
    @Test("Tender with empty additional photos array")
    func testTenderWithEmptyAdditionalPhotos() async throws {
        // Given
        let photos: [URL] = []
        
        // When
        let tender = Tender(
            name: "No Photos Restaurant",
            restaurantType: "Restaurant",
            priceRange: "$$",
            latitude: 37.7749,
            longitude: -122.4194,
            additionalPhotos: photos
        )
        
        // Then
        #expect(tender.additionalPhotos?.isEmpty == true)
    }
    
    @Test("Tender with various price ranges")
    func testTenderWithVariousPriceRanges() async throws {
        // Given
        let priceRanges = ["$", "$$", "$$$", "$$$$"]
        
        for priceRange in priceRanges {
            // When
            let tender = Tender(
                name: "Restaurant",
                restaurantType: "Restaurant",
                priceRange: priceRange,
                latitude: 37.7749,
                longitude: -122.4194
            )
            
            // Then
            #expect(tender.priceRange == priceRange)
        }
    }
}
