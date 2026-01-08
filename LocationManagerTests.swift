//
//  LocationManagerTests.swift
//  Cluck
//
//  Tests for LocationManager
//

import Testing
import Foundation
import CoreLocation
@testable import Cluck

@Suite("LocationManager Tests")
struct LocationManagerTests {
    
    // MARK: - Initialization Tests
    
    @Test("LocationManager initializes with nil location")
    func testInitialization() async throws {
        // When
        let locationManager = LocationManager()
        
        // Then
        #expect(locationManager.location == nil)
        #expect(locationManager.authorizationStatus == .notDetermined)
        #expect(locationManager.error == nil)
    }
    
    // MARK: - Authorization Tests
    
    @Test("LocationManager tracks authorization status")
    func testAuthorizationStatus() async throws {
        // Given
        let locationManager = LocationManager()
        
        // When
        let initialStatus = locationManager.authorizationStatus
        
        // Then
        #expect(initialStatus == .notDetermined)
    }
    
    // MARK: - Request Location Tests
    
    @Test("requestLocation can be called without crashing")
    func testRequestLocation() async throws {
        // Given
        let locationManager = LocationManager()
        
        // When & Then - Should not crash
        locationManager.requestLocation()
        
        // Note: In a real test environment, this would trigger authorization
        // For unit tests, we just verify the method doesn't crash
    }
    
    // MARK: - Mock Location Tests
    
    @Test("Mock location manager provides location")
    func testMockLocationManager() async throws {
        // Given
        let mockLocationManager = MockLocationManager()
        let testLocation = CLLocation(latitude: 37.7749, longitude: -122.4194)
        mockLocationManager.mockLocation = testLocation
        
        // When
        let location = mockLocationManager.location
        
        // Then
        #expect(location != nil)
        #expect(location?.coordinate.latitude == 37.7749)
        #expect(location?.coordinate.longitude == -122.4194)
    }
    
    @Test("Mock location manager can return nil")
    func testMockLocationManagerNil() async throws {
        // Given
        let mockLocationManager = MockLocationManager()
        mockLocationManager.mockLocation = nil
        
        // When
        let location = mockLocationManager.location
        
        // Then
        #expect(location == nil)
    }
    
    @Test("Mock location manager can change location")
    func testMockLocationManagerChangeLocation() async throws {
        // Given
        let mockLocationManager = MockLocationManager()
        let location1 = CLLocation(latitude: 37.7749, longitude: -122.4194)
        let location2 = CLLocation(latitude: 40.7128, longitude: -74.0060)
        
        // When
        mockLocationManager.mockLocation = location1
        let firstLocation = mockLocationManager.location
        
        mockLocationManager.mockLocation = location2
        let secondLocation = mockLocationManager.location
        
        // Then
        #expect(firstLocation?.coordinate.latitude == 37.7749)
        #expect(secondLocation?.coordinate.latitude == 40.7128)
    }
    
    // MARK: - Error Handling Tests
    
    @Test("LocationManager can store error")
    func testErrorHandling() async throws {
        // Given
        let locationManager = LocationManager()
        let testError = NSError(domain: "TestError", code: -1, userInfo: nil)
        
        // When
        locationManager.error = testError
        
        // Then
        #expect(locationManager.error != nil)
        #expect((locationManager.error as? NSError)?.domain == "TestError")
    }
    
    // MARK: - Observable Tests
    
    @Test("LocationManager conforms to Observable")
    func testObservableConformance() async throws {
        // Given & When
        let locationManager = LocationManager()
        
        // Then - Should compile and work as @Observable
        #expect(locationManager.location == nil)
        #expect(locationManager.error == nil)
    }
    
    // MARK: - CLLocation Tests
    
    @Test("CLLocation stores coordinates correctly")
    func testCLLocationCoordinates() async throws {
        // When
        let location = CLLocation(latitude: 37.7749, longitude: -122.4194)
        
        // Then
        #expect(location.coordinate.latitude == 37.7749)
        #expect(location.coordinate.longitude == -122.4194)
    }
    
    @Test("CLLocation can calculate distance")
    func testCLLocationDistance() async throws {
        // Given
        let location1 = CLLocation(latitude: 37.7749, longitude: -122.4194) // SF
        let location2 = CLLocation(latitude: 37.7849, longitude: -122.4094) // ~1.5km away
        
        // When
        let distance = location1.distance(from: location2)
        
        // Then
        #expect(distance > 0)
        #expect(distance < 2000) // Should be less than 2km
    }
    
    @Test("CLLocation distance is zero for same coordinates")
    func testCLLocationSameDistance() async throws {
        // Given
        let location1 = CLLocation(latitude: 37.7749, longitude: -122.4194)
        let location2 = CLLocation(latitude: 37.7749, longitude: -122.4194)
        
        // When
        let distance = location1.distance(from: location2)
        
        // Then
        #expect(distance < 1.0) // Should be essentially 0
    }
    
    @Test("CLLocation validates latitude range")
    func testCLLocationLatitudeRange() async throws {
        // Given - Valid latitudes
        let validLatitudes = [-90.0, -45.0, 0.0, 45.0, 90.0]
        
        for lat in validLatitudes {
            // When
            let location = CLLocation(latitude: lat, longitude: 0)
            
            // Then
            #expect(location.coordinate.latitude == lat)
        }
    }
    
    @Test("CLLocation validates longitude range")
    func testCLLocationLongitudeRange() async throws {
        // Given - Valid longitudes
        let validLongitudes = [-180.0, -90.0, 0.0, 90.0, 180.0]
        
        for lon in validLongitudes {
            // When
            let location = CLLocation(latitude: 0, longitude: lon)
            
            // Then
            #expect(location.coordinate.longitude == lon)
        }
    }
    
    @Test("CLLocation has timestamp")
    func testCLLocationTimestamp() async throws {
        // When
        let location = CLLocation(latitude: 37.7749, longitude: -122.4194)
        
        // Then
        #expect(location.timestamp != nil)
    }
    
    @Test("CLLocation can have altitude")
    func testCLLocationWithAltitude() async throws {
        // When
        let coordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let location = CLLocation(
            coordinate: coordinate,
            altitude: 100.0,
            horizontalAccuracy: 10.0,
            verticalAccuracy: 10.0,
            timestamp: Date()
        )
        
        // Then
        #expect(location.altitude == 100.0)
        #expect(location.horizontalAccuracy == 10.0)
        #expect(location.verticalAccuracy == 10.0)
    }
    
    // MARK: - Helper Classes
    
    class MockLocationManager: LocationManager {
        var mockLocation: CLLocation?
        
        override var location: CLLocation? {
            mockLocation
        }
    }
}
