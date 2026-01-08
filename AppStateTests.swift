//
//  AppStateTests.swift
//  Cluck
//
//  Tests for AppState
//

import Testing
import Foundation
import CoreLocation
@testable import Cluck

@Suite("AppState Tests")
@MainActor
struct AppStateTests {
    
    // MARK: - Initialization Tests
    
    @Test("AppState initializes with all dependencies")
    func testInitialization() async throws {
        // When
        let appState = AppState()
        
        // Then
        #expect(appState.locationManager != nil)
        #expect(appState.yelpService != nil)
        #expect(appState.searchService != nil)
    }
    
    @Test("LocationManager is initialized")
    func testLocationManagerInitialized() async throws {
        // Given
        let appState = AppState()
        
        // When
        let locationManager = appState.locationManager
        
        // Then
        #expect(locationManager.location == nil) // Initially nil
        #expect(locationManager.authorizationStatus == .notDetermined)
    }
    
    @Test("YelpService is initialized with API key")
    func testYelpServiceInitialized() async throws {
        // Given
        let appState = AppState()
        
        // When
        let yelpService = appState.yelpService
        
        // Then
        #expect(yelpService.apiKey == Config.yelpAPIKey)
        #expect(!yelpService.apiKey.isEmpty)
    }
    
    @Test("SearchService is initialized with YelpService")
    func testSearchServiceInitialized() async throws {
        // Given
        let appState = AppState()
        
        // When
        let searchService = appState.searchService
        
        // Then
        #expect(searchService != nil)
    }
    
    // MARK: - Observable Tests
    
    @Test("AppState conforms to Observable")
    func testObservableConformance() async throws {
        // Given
        let appState = AppState()
        
        // When & Then - Should be observable
        #expect(appState.locationManager != nil)
        #expect(appState.yelpService != nil)
        #expect(appState.searchService != nil)
    }
    
    // MARK: - Dependency Injection Tests
    
    @Test("AppState provides consistent dependencies")
    func testConsistentDependencies() async throws {
        // Given
        let appState = AppState()
        
        // When
        let locationManager1 = appState.locationManager
        let locationManager2 = appState.locationManager
        let yelpService1 = appState.yelpService
        let yelpService2 = appState.yelpService
        
        // Then - Same instances
        #expect(locationManager1 === locationManager2)
        #expect(yelpService1 === yelpService2)
    }
    
    @Test("Multiple AppState instances are independent")
    func testIndependentInstances() async throws {
        // When
        let appState1 = AppState()
        let appState2 = AppState()
        
        // Then
        #expect(appState1.locationManager !== appState2.locationManager)
        #expect(appState1.yelpService !== appState2.yelpService)
    }
    
    // MARK: - Integration Tests
    
    @Test("AppState can be used with TenderDeckViewModel")
    func testIntegrationWithViewModel() async throws {
        // Given
        let appState = AppState()
        
        // When
        let viewModel = TenderDeckViewModel(
            searchService: appState.searchService,
            locationManager: appState.locationManager
        )
        
        // Then
        #expect(viewModel.tenders.isEmpty)
        #expect(viewModel.isLoading == false)
    }
    
    @Test("AppState location manager can be observed")
    func testLocationManagerObservable() async throws {
        // Given
        let appState = AppState()
        
        // When
        let initialLocation = appState.locationManager.location
        
        // Then
        #expect(initialLocation == nil)
    }
    
    // MARK: - MainActor Tests
    
    @Test("AppState is MainActor isolated")
    func testMainActorIsolation() async throws {
        // Given & When
        let appState = AppState()
        
        // Then - Should be accessible on MainActor
        #expect(appState.locationManager != nil)
    }
    
    // MARK: - Configuration Tests
    
    @Test("AppState uses correct Config values")
    func testConfigUsage() async throws {
        // Given
        let appState = AppState()
        
        // When
        let apiKey = appState.yelpService.apiKey
        
        // Then
        #expect(apiKey == Config.yelpAPIKey)
    }
}
