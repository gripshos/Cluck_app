//
//  Tender.swift
//  Cluck
//
//  Data model for restaurants
//

import Foundation

struct Tender: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let restaurantType: String
    let priceRange: String
    let address: String?
    let phoneNumber: String?
    let websiteURL: URL?
    let imageName: String?
    let imageURL: URL?
    let latitude: Double
    let longitude: Double
    let rating: Double?
    let reviewCount: Int?
    let isOpenNow: Bool?
    let additionalPhotos: [URL]?
    
    init(
        id: UUID = UUID(),
        name: String,
        restaurantType: String,
        priceRange: String,
        address: String? = nil,
        phoneNumber: String? = nil,
        websiteURL: URL? = nil,
        imageName: String? = nil,
        imageURL: URL? = nil,
        latitude: Double,
        longitude: Double,
        rating: Double? = nil,
        reviewCount: Int? = nil,
        isOpenNow: Bool? = nil,
        additionalPhotos: [URL]? = nil
    ) {
        self.id = id
        self.name = name
        self.restaurantType = restaurantType
        self.priceRange = priceRange
        self.address = address
        self.phoneNumber = phoneNumber
        self.websiteURL = websiteURL
        self.imageName = imageName
        self.imageURL = imageURL
        self.latitude = latitude
        self.longitude = longitude
        self.rating = rating
        self.reviewCount = reviewCount
        self.isOpenNow = isOpenNow
        self.additionalPhotos = additionalPhotos
    }
}
