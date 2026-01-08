//
//  ConfigTests.swift
//  Cluck
//
//  Tests for the Config enum
//

import Testing
import Foundation
@testable import Cluck

@Suite("Config Tests")
struct ConfigTests {
    
    @Test("Yelp API key is not empty")
    func testYelpAPIKeyNotEmpty() async throws {
        // When
        let apiKey = Config.yelpAPIKey
        
        // Then
        #expect(!apiKey.isEmpty, "Yelp API key should not be empty")
    }
    
    @Test("Search radius is positive")
    func testSearchRadiusPositive() async throws {
        // When
        let radius = Config.searchRadius
        
        // Then
        #expect(radius > 0, "Search radius should be positive")
    }
    
    @Test("Search radius is reasonable (between 100m and 50km)")
    func testSearchRadiusReasonable() async throws {
        // When
        let radius = Config.searchRadius
        
        // Then
        #expect(radius >= 100, "Search radius should be at least 100 meters")
        #expect(radius <= 50000, "Search radius should be at most 50km")
    }
    
    @Test("Max results is positive")
    func testMaxResultsPositive() async throws {
        // When
        let maxResults = Config.maxResults
        
        // Then
        #expect(maxResults > 0, "Max results should be positive")
    }
    
    @Test("Max results is reasonable (between 1 and 50)")
    func testMaxResultsReasonable() async throws {
        // When
        let maxResults = Config.maxResults
        
        // Then
        #expect(maxResults >= 1, "Max results should be at least 1")
        #expect(maxResults <= 50, "Max results should be at most 50")
    }
    
    @Test("Default search radius is 5000 meters")
    func testDefaultSearchRadius() async throws {
        // When
        let radius = Config.searchRadius
        
        // Then
        #expect(radius == 5000, "Default search radius should be 5000 meters (5km)")
    }
    
    @Test("Default max results is 20")
    func testDefaultMaxResults() async throws {
        // When
        let maxResults = Config.maxResults
        
        // Then
        #expect(maxResults == 20, "Default max results should be 20")
    }
    
    @Test("Yelp API key has correct format")
    func testYelpAPIKeyFormat() async throws {
        // When
        let apiKey = Config.yelpAPIKey
        
        // Then
        // Yelp API keys are typically long alphanumeric strings
        #expect(apiKey.count > 20, "Yelp API key should be longer than 20 characters")
        #expect(!apiKey.contains(" "), "Yelp API key should not contain spaces")
    }
}
