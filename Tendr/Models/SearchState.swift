//
//  SearchState.swift
//  Tendr
//
//  Generic state management for async operations
//

import Foundation

/// Represents the state of an async search/fetch operation.
/// Generic over the success type for reusability.
enum SearchState<T: Sendable>: Sendable {
    case idle
    case loading
    case success(T)
    case empty
    case failure(SearchError)
    
    /// Convenience check for loading state
    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
    
    /// Extract data if in success state
    var data: T? {
        if case .success(let data) = self { return data }
        return nil
    }
    
    /// Extract error if in failure state
    var error: SearchError? {
        if case .failure(let error) = self { return error }
        return nil
    }
}

/// Domain-specific search errors with user-friendly messages
enum SearchError: Error, Sendable, LocalizedError {
    case locationUnavailable
    case locationPermissionDenied
    case networkError(underlying: String)
    case noResults
    case unknown(underlying: String)
    
    var errorDescription: String? {
        switch self {
        case .locationUnavailable:
            return "Unable to determine your location"
        case .locationPermissionDenied:
            return "Location access is required to find restaurants nearby"
        case .networkError(let underlying):
            return "Network error: \(underlying)"
        case .noResults:
            return "No chicken tender spots found nearby"
        case .unknown(let underlying):
            return "Something went wrong: \(underlying)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .locationUnavailable:
            return "Make sure Location Services are enabled in Settings"
        case .locationPermissionDenied:
            return "Go to Settings > Tendr > Location and select 'While Using'"
        case .networkError:
            return "Check your internet connection and try again"
        case .noResults:
            return "Try expanding your search area"
        case .unknown:
            return "Please try again"
        }
    }
    
    /// System image name for error display
    var iconName: String {
        switch self {
        case .locationUnavailable, .locationPermissionDenied:
            return "location.slash"
        case .networkError:
            return "wifi.slash"
        case .noResults:
            return "fork.knife.circle"
        case .unknown:
            return "exclamationmark.triangle"
        }
    }
}
