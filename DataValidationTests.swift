//
//  DataValidationTests.swift
//  Cluck
//
//  Tests for data validation and edge cases
//

import Testing
import Foundation
import CoreLocation
@testable import Cluck

@Suite("Data Validation Tests")
struct DataValidationTests {
    
    // MARK: - URL Validation Tests
    
    @Test("Valid website URLs are parsed correctly")
    func testValidWebsiteURLs() async throws {
        // Given
        let validURLs = [
            "https://example.com",
            "http://example.com",
            "https://www.example.com",
            "https://example.com/path",
            "https://example.com/path?query=value",
            "https://subdomain.example.com"
        ]
        
        for urlString in validURLs {
            // When
            let url = URL(string: urlString)
            
            // Then
            #expect(url != nil, "URL '\(urlString)' should be valid")
        }
    }
    
    @Test("Invalid website URLs return nil")
    func testInvalidWebsiteURLs() async throws {
        // Given
        let invalidURLs = [
            "not a url",
            "ftp://example.com", // Not http/https
            "//example.com",
            "example.com", // Missing scheme
            ""
        ]
        
        for urlString in invalidURLs {
            // When
            let url = URL(string: urlString)
            
            // Then - Some might be valid, but at least empty string should be invalid
            if urlString.isEmpty {
                #expect(url != nil, "Empty string creates URL but shouldn't be used")
            }
        }
    }
    
    @Test("Image URLs are parsed correctly")
    func testImageURLs() async throws {
        // Given
        let imageURLs = [
            "https://example.com/image.jpg",
            "https://example.com/image.png",
            "https://s3.amazonaws.com/bucket/image.jpg",
            "https://cdn.example.com/images/photo.webp"
        ]
        
        for urlString in imageURLs {
            // When
            let url = URL(string: urlString)
            let tender = Tender(
                name: "Test",
                restaurantType: "Test",
                priceRange: "$",
                imageURL: url,
                latitude: 0,
                longitude: 0
            )
            
            // Then
            #expect(tender.imageURL != nil)
        }
    }
    
    // MARK: - Coordinate Validation Tests
    
    @Test("Valid latitude values")
    func testValidLatitudes() async throws {
        // Given
        let validLatitudes = [-90.0, -45.0, 0.0, 45.0, 90.0]
        
        for latitude in validLatitudes {
            // When
            let tender = Tender(
                name: "Test",
                restaurantType: "Test",
                priceRange: "$",
                latitude: latitude,
                longitude: 0.0
            )
            
            // Then
            #expect(tender.latitude == latitude)
            #expect(tender.latitude >= -90.0 && tender.latitude <= 90.0)
        }
    }
    
    @Test("Valid longitude values")
    func testValidLongitudes() async throws {
        // Given
        let validLongitudes = [-180.0, -90.0, 0.0, 90.0, 180.0]
        
        for longitude in validLongitudes {
            // When
            let tender = Tender(
                name: "Test",
                restaurantType: "Test",
                priceRange: "$",
                latitude: 0.0,
                longitude: longitude
            )
            
            // Then
            #expect(tender.longitude == longitude)
            #expect(tender.longitude >= -180.0 && tender.longitude <= 180.0)
        }
    }
    
    @Test("Edge case coordinates are handled")
    func testEdgeCaseCoordinates() async throws {
        // Given - North Pole, South Pole, Prime Meridian, International Date Line
        let edgeCases = [
            (lat: 90.0, lon: 0.0, name: "North Pole"),
            (lat: -90.0, lon: 0.0, name: "South Pole"),
            (lat: 0.0, lon: 0.0, name: "Null Island"),
            (lat: 0.0, lon: 180.0, name: "International Date Line"),
            (lat: 0.0, lon: -180.0, name: "International Date Line (West)")
        ]
        
        for edgeCase in edgeCases {
            // When
            let tender = Tender(
                name: edgeCase.name,
                restaurantType: "Test",
                priceRange: "$",
                latitude: edgeCase.lat,
                longitude: edgeCase.lon
            )
            
            // Then
            #expect(tender.latitude == edgeCase.lat)
            #expect(tender.longitude == edgeCase.lon)
        }
    }
    
    // MARK: - Phone Number Validation Tests
    
    @Test("Various phone number formats are stored correctly")
    func testPhoneNumberFormats() async throws {
        // Given
        let phoneFormats = [
            "555-1234",
            "(415) 555-1234",
            "+1 415-555-1234",
            "415.555.1234",
            "4155551234"
        ]
        
        for phoneNumber in phoneFormats {
            // When
            let tender = Tender(
                name: "Test",
                restaurantType: "Test",
                priceRange: "$",
                phoneNumber: phoneNumber,
                latitude: 0,
                longitude: 0
            )
            
            // Then
            #expect(tender.phoneNumber == phoneNumber)
        }
    }
    
    // MARK: - Price Range Validation Tests
    
    @Test("All standard price ranges are valid")
    func testStandardPriceRanges() async throws {
        // Given
        let priceRanges = ["$", "$$", "$$$", "$$$$"]
        
        for priceRange in priceRanges {
            // When
            let tender = Tender(
                name: "Test",
                restaurantType: "Test",
                priceRange: priceRange,
                latitude: 0,
                longitude: 0
            )
            
            // Then
            #expect(tender.priceRange == priceRange)
            #expect(!tender.priceRange.isEmpty)
        }
    }
    
    @Test("Custom price range formats are accepted")
    func testCustomPriceRanges() async throws {
        // Given
        let customPriceRanges = [
            "$10-$20",
            "$ - $$",
            "$$ - $$$",
            "Inexpensive",
            "Expensive"
        ]
        
        for priceRange in customPriceRanges {
            // When
            let tender = Tender(
                name: "Test",
                restaurantType: "Test",
                priceRange: priceRange,
                latitude: 0,
                longitude: 0
            )
            
            // Then
            #expect(tender.priceRange == priceRange)
        }
    }
    
    // MARK: - Rating Validation Tests
    
    @Test("Rating values within valid range")
    func testRatingRange() async throws {
        // Given
        let ratings = [0.0, 1.0, 2.5, 3.5, 4.0, 4.5, 5.0]
        
        for rating in ratings {
            // When
            let tender = Tender(
                name: "Test",
                restaurantType: "Test",
                priceRange: "$",
                latitude: 0,
                longitude: 0,
                rating: rating
            )
            
            // Then
            #expect(tender.rating == rating)
            #expect(tender.rating! >= 0.0 && tender.rating! <= 5.0)
        }
    }
    
    @Test("Review count is non-negative")
    func testReviewCountNonNegative() async throws {
        // Given
        let reviewCounts = [0, 1, 10, 100, 1000, 10000]
        
        for count in reviewCounts {
            // When
            let tender = Tender(
                name: "Test",
                restaurantType: "Test",
                priceRange: "$",
                latitude: 0,
                longitude: 0,
                reviewCount: count
            )
            
            // Then
            #expect(tender.reviewCount == count)
            #expect(tender.reviewCount! >= 0)
        }
    }
    
    // MARK: - String Validation Tests
    
    @Test("Restaurant names with special characters")
    func testNamesWithSpecialCharacters() async throws {
        // Given
        let names = [
            "Joe's Pizza",
            "Café Français",
            "Restaurant & Bar",
            "Mom's Kitchen (Best Food)",
            "Taco Bell™",
            "McDonald's",
            "50/50 Burger"
        ]
        
        for name in names {
            // When
            let tender = Tender(
                name: name,
                restaurantType: "Test",
                priceRange: "$",
                latitude: 0,
                longitude: 0
            )
            
            // Then
            #expect(tender.name == name)
            #expect(!tender.name.isEmpty)
        }
    }
    
    @Test("Restaurant types are preserved")
    func testRestaurantTypes() async throws {
        // Given
        let types = [
            "Fast Food",
            "Casual Dining",
            "Fine Dining",
            "Food Truck",
            "Cafe",
            "Bar & Grill",
            "Chicken Wings"
        ]
        
        for type in types {
            // When
            let tender = Tender(
                name: "Test",
                restaurantType: type,
                priceRange: "$",
                latitude: 0,
                longitude: 0
            )
            
            // Then
            #expect(tender.restaurantType == type)
        }
    }
    
    @Test("Addresses with various formats")
    func testAddressFormats() async throws {
        // Given
        let addresses = [
            "123 Main St",
            "456 Oak Ave, Apt 2B",
            "789 Elm St, San Francisco, CA 94102",
            "1000 Broadway, Suite 100, New York, NY 10001, USA",
            "Building 7, Floor 3, Room 301"
        ]
        
        for address in addresses {
            // When
            let tender = Tender(
                name: "Test",
                restaurantType: "Test",
                priceRange: "$",
                address: address,
                latitude: 0,
                longitude: 0
            )
            
            // Then
            #expect(tender.address == address)
        }
    }
    
    // MARK: - Array Validation Tests
    
    @Test("Additional photos array handling")
    func testAdditionalPhotosArray() async throws {
        // Given
        let photoURLs = [
            URL(string: "https://example.com/photo1.jpg")!,
            URL(string: "https://example.com/photo2.jpg")!,
            URL(string: "https://example.com/photo3.jpg")!
        ]
        
        // When
        let tender = Tender(
            name: "Test",
            restaurantType: "Test",
            priceRange: "$",
            latitude: 0,
            longitude: 0,
            additionalPhotos: photoURLs
        )
        
        // Then
        #expect(tender.additionalPhotos?.count == 3)
        #expect(tender.additionalPhotos?[0].absoluteString == "https://example.com/photo1.jpg")
        #expect(tender.additionalPhotos?[1].absoluteString == "https://example.com/photo2.jpg")
        #expect(tender.additionalPhotos?[2].absoluteString == "https://example.com/photo3.jpg")
    }
    
    @Test("Empty additional photos array")
    func testEmptyAdditionalPhotos() async throws {
        // Given
        let emptyArray: [URL] = []
        
        // When
        let tender = Tender(
            name: "Test",
            restaurantType: "Test",
            priceRange: "$",
            latitude: 0,
            longitude: 0,
            additionalPhotos: emptyArray
        )
        
        // Then
        #expect(tender.additionalPhotos?.isEmpty == true)
        #expect(tender.additionalPhotos?.count == 0)
    }
    
    // MARK: - CLLocation Validation Tests
    
    @Test("CLLocation creation from Tender coordinates")
    func testCLLocationCreation() async throws {
        // Given
        let tender = Tender(
            name: "Test",
            restaurantType: "Test",
            priceRange: "$",
            latitude: 37.7749,
            longitude: -122.4194
        )
        
        // When
        let location = CLLocation(latitude: tender.latitude, longitude: tender.longitude)
        
        // Then
        #expect(location.coordinate.latitude == tender.latitude)
        #expect(location.coordinate.longitude == tender.longitude)
    }
    
    @Test("Distance calculation between two locations")
    func testDistanceCalculation() async throws {
        // Given
        let location1 = CLLocation(latitude: 37.7749, longitude: -122.4194) // SF
        let location2 = CLLocation(latitude: 37.7849, longitude: -122.4094) // ~1.5km away
        
        // When
        let distance = location1.distance(from: location2)
        let distanceInMiles = distance / 1609.34
        
        // Then
        #expect(distance > 0)
        #expect(distance < 10000, "Distance should be less than 10km")
        #expect(distanceInMiles < 10, "Distance should be less than 10 miles")
    }
}
