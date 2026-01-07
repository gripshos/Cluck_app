//
//  LocationService.swift
//  Tendr
//
//  Location service with protocol for testability
//

import Foundation
import CoreLocation
import Observation

// MARK: - Protocol

/// Protocol for location services, enabling mock implementations for testing
protocol LocationServiceProtocol: AnyObject, Sendable {
    var currentLocation: CLLocation? { get }
    var authorizationStatus: CLAuthorizationStatus { get }
    
    func requestAuthorization()
    func requestLocation()
}

// MARK: - Implementation

/// Production location service wrapping CLLocationManager
@Observable
final class LocationService: NSObject, LocationServiceProtocol, CLLocationManagerDelegate {
    
    // MARK: - Published State
    
    private(set) var currentLocation: CLLocation?
    private(set) var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    // MARK: - Private
    
    private let manager: CLLocationManager
    private var locationContinuation: CheckedContinuation<CLLocation, Error>?
    
    // MARK: - Init
    
    override init() {
        self.manager = CLLocationManager()
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters // Good enough for restaurant search
        authorizationStatus = manager.authorizationStatus
    }
    
    // MARK: - LocationServiceProtocol
    
    func requestAuthorization() {
        manager.requestWhenInUseAuthorization()
    }
    
    func requestLocation() {
        // Only request if we have authorization
        guard authorizationStatus == .authorizedWhenInUse || 
              authorizationStatus == .authorizedAlways else {
            requestAuthorization()
            return
        }
        manager.requestLocation()
    }
    
    // MARK: - Async Location Request
    
    /// Async wrapper for getting location - useful for one-shot requests
    func getCurrentLocation() async throws -> CLLocation {
        // Return cached if fresh (within 60 seconds)
        if let location = currentLocation,
           Date().timeIntervalSince(location.timestamp) < 60 {
            return location
        }
        
        // Check authorization first
        guard authorizationStatus == .authorizedWhenInUse ||
              authorizationStatus == .authorizedAlways else {
            throw SearchError.locationPermissionDenied
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            self.locationContinuation = continuation
            manager.requestLocation()
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        currentLocation = location
        
        // Resume continuation if waiting
        locationContinuation?.resume(returning: location)
        locationContinuation = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
        
        // Resume continuation with error if waiting
        locationContinuation?.resume(throwing: SearchError.locationUnavailable)
        locationContinuation = nil
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        // Auto-request location when authorized
        if authorizationStatus == .authorizedWhenInUse || 
           authorizationStatus == .authorizedAlways {
            manager.requestLocation()
        }
    }
}

// MARK: - Mock for Testing/Previews

#if DEBUG
@Observable
final class MockLocationService: LocationServiceProtocol {
    var currentLocation: CLLocation?
    var authorizationStatus: CLAuthorizationStatus = .authorizedWhenInUse
    
    init(location: CLLocation? = CLLocation(latitude: 39.9612, longitude: -82.9988)) {
        self.currentLocation = location
    }
    
    func requestAuthorization() {
        authorizationStatus = .authorizedWhenInUse
    }
    
    func requestLocation() {
        // Already set in init for mock
    }
}
#endif
