//
//  YelpService.swift
//  Cluck
//
//  Service for fetching restaurant data from Yelp Fusion API
//

import Foundation
import CoreLocation

/// Service for interacting with the Yelp Fusion API
@MainActor
class YelpService {
    
    // MARK: - Configuration
    
    private let apiKey: String
    private let baseURL = "https://api.yelp.com/v3"
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    // MARK: - API Methods
    
    /// Search for businesses by phone number to match MapKit results
    func searchByPhone(_ phoneNumber: String) async throws -> YelpBusiness? {
        // Clean phone number (remove formatting)
        let cleanedPhone = phoneNumber.filter { $0.isNumber }
        
        guard let url = URL(string: "\(baseURL)/businesses/search/phone?phone=+1\(cleanedPhone)") else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(YelpPhoneSearchResponse.self, from: data)
        
        return response.businesses.first
    }
    
    /// Search for businesses near a location
    func searchBusinesses(
        near location: CLLocation,
        term: String = "chicken tenders",
        radius: Int = 5000,
        limit: Int = 20
    ) async throws -> [YelpBusiness] {
        var components = URLComponents(string: "\(baseURL)/businesses/search")!
        components.queryItems = [
            URLQueryItem(name: "term", value: term),
            URLQueryItem(name: "latitude", value: "\(location.coordinate.latitude)"),
            URLQueryItem(name: "longitude", value: "\(location.coordinate.longitude)"),
            URLQueryItem(name: "radius", value: "\(radius)"),
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "sort_by", value: "best_match")
        ]
        
        guard let url = components.url else {
            throw YelpError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw YelpError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw YelpError.apiError(statusCode: httpResponse.statusCode)
        }
        
        let searchResponse = try JSONDecoder().decode(YelpSearchResponse.self, from: data)
        return searchResponse.businesses
    }
    
    /// Get detailed business information by Yelp ID
    func getBusinessDetails(id: String) async throws -> YelpBusinessDetails {
        guard let url = URL(string: "\(baseURL)/businesses/\(id)") else {
            throw YelpError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(YelpBusinessDetails.self, from: data)
    }
}

// MARK: - Models

struct YelpSearchResponse: Codable {
    let businesses: [YelpBusiness]
    let total: Int
}

struct YelpPhoneSearchResponse: Codable {
    let businesses: [YelpBusiness]
    let total: Int
}

struct YelpBusiness: Codable {
    let id: String
    let name: String
    let imageUrl: String?
    let url: String?
    let rating: Double?
    let reviewCount: Int?
    let price: String?
    let phone: String?
    let displayPhone: String?
    let categories: [YelpCategory]?
    let coordinates: YelpCoordinates
    let location: YelpLocation
    
    enum CodingKeys: String, CodingKey {
        case id, name, url, rating, price, phone, categories, coordinates, location
        case imageUrl = "image_url"
        case reviewCount = "review_count"
        case displayPhone = "display_phone"
    }
}

struct YelpBusinessDetails: Codable {
    let id: String
    let name: String
    let imageUrl: String?
    let url: String?
    let rating: Double?
    let reviewCount: Int?
    let price: String?
    let phone: String?
    let photos: [String]?
    let categories: [YelpCategory]?
    let coordinates: YelpCoordinates
    let location: YelpLocation
    let hours: [YelpHours]?
    
    enum CodingKeys: String, CodingKey {
        case id, name, url, rating, price, phone, photos, categories, coordinates, location, hours
        case imageUrl = "image_url"
        case reviewCount = "review_count"
    }
}

struct YelpCategory: Codable {
    let alias: String
    let title: String
}

struct YelpCoordinates: Codable {
    let latitude: Double
    let longitude: Double
}

struct YelpLocation: Codable {
    let address1: String?
    let address2: String?
    let address3: String?
    let city: String?
    let zipCode: String?
    let country: String?
    let state: String?
    let displayAddress: [String]?
    
    enum CodingKeys: String, CodingKey {
        case address1, address2, address3, city, country, state
        case zipCode = "zip_code"
        case displayAddress = "display_address"
    }
}

struct YelpHours: Codable {
    let isOpenNow: Bool?
    
    enum CodingKeys: String, CodingKey {
        case isOpenNow = "is_open_now"
    }
}

// MARK: - Errors

enum YelpError: LocalizedError {
    case invalidURL
    case invalidResponse
    case apiError(statusCode: Int)
    case noResults
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .invalidResponse:
            return "Invalid response from Yelp API"
        case .apiError(let statusCode):
            return "Yelp API error: \(statusCode)"
        case .noResults:
            return "No results found"
        }
    }
}
