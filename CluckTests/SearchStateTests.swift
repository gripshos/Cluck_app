//
//  SearchStateTests.swift
//  TendrTests
//
//  Unit tests for SearchState enum
//

import XCTest
@testable import Tendr

final class SearchStateTests: XCTestCase {
    
    // MARK: - State Properties
    
    func testIdleState() {
        let state: SearchState<[String]> = .idle
        
        XCTAssertFalse(state.isLoading)
        XCTAssertNil(state.data)
        XCTAssertNil(state.error)
    }
    
    func testLoadingState() {
        let state: SearchState<[String]> = .loading
        
        XCTAssertTrue(state.isLoading)
        XCTAssertNil(state.data)
        XCTAssertNil(state.error)
    }
    
    func testSuccessState() {
        let data = ["item1", "item2"]
        let state: SearchState<[String]> = .success(data)
        
        XCTAssertFalse(state.isLoading)
        XCTAssertEqual(state.data, data)
        XCTAssertNil(state.error)
    }
    
    func testEmptyState() {
        let state: SearchState<[String]> = .empty
        
        XCTAssertFalse(state.isLoading)
        XCTAssertNil(state.data)
        XCTAssertNil(state.error)
    }
    
    func testFailureState() {
        let error = SearchError.networkError(underlying: "Connection failed")
        let state: SearchState<[String]> = .failure(error)
        
        XCTAssertFalse(state.isLoading)
        XCTAssertNil(state.data)
        XCTAssertNotNil(state.error)
    }
    
    // MARK: - Error Properties
    
    func testErrorDescriptions() {
        XCTAssertNotNil(SearchError.locationUnavailable.errorDescription)
        XCTAssertNotNil(SearchError.locationPermissionDenied.errorDescription)
        XCTAssertNotNil(SearchError.networkError(underlying: "test").errorDescription)
        XCTAssertNotNil(SearchError.noResults.errorDescription)
        XCTAssertNotNil(SearchError.unknown(underlying: "test").errorDescription)
    }
    
    func testErrorRecoverySuggestions() {
        XCTAssertNotNil(SearchError.locationUnavailable.recoverySuggestion)
        XCTAssertNotNil(SearchError.locationPermissionDenied.recoverySuggestion)
        XCTAssertNotNil(SearchError.networkError(underlying: "test").recoverySuggestion)
        XCTAssertNotNil(SearchError.noResults.recoverySuggestion)
        XCTAssertNotNil(SearchError.unknown(underlying: "test").recoverySuggestion)
    }
    
    func testErrorIconNames() {
        XCTAssertEqual(SearchError.locationUnavailable.iconName, "location.slash")
        XCTAssertEqual(SearchError.locationPermissionDenied.iconName, "location.slash")
        XCTAssertEqual(SearchError.networkError(underlying: "test").iconName, "wifi.slash")
        XCTAssertEqual(SearchError.noResults.iconName, "fork.knife.circle")
        XCTAssertEqual(SearchError.unknown(underlying: "test").iconName, "exclamationmark.triangle")
    }
}
