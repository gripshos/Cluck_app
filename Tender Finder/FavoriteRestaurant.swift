//
//  FavoriteRestaurant.swift
//  Cluck
//
//  SwiftData model for saved favorites
//

import Foundation
import SwiftData

@Model
class FavoriteRestaurant {
    @Attribute(.unique) var id: UUID
    var name: String
    var restaurantType: String
    var priceRange: String
    var address: String?
    var phoneNumber: String?
    var websiteURL: String?
    var imageName: String?
    var imageURL: String?
    var latitude: Double
    var longitude: Double
    var savedDate: Date
    var rating: Double?
    var reviewCount: Int?
    var isOpenNow: Bool?
    var additionalPhotosData: Data? // Store as JSON data
    
    init(from tender: Tender) {
        self.id = tender.id
        self.name = tender.name
        self.restaurantType = tender.restaurantType
        self.priceRange = tender.priceRange
        self.address = tender.address
        self.phoneNumber = tender.phoneNumber
        self.websiteURL = tender.websiteURL?.absoluteString
        self.imageName = tender.imageName
        self.imageURL = tender.imageURL?.absoluteString
        self.latitude = tender.latitude
        self.longitude = tender.longitude
        self.savedDate = Date()
        self.rating = tender.rating
        self.reviewCount = tender.reviewCount
        self.isOpenNow = tender.isOpenNow
        
        // Encode additional photos to Data
        if let photos = tender.additionalPhotos {
            let urls = photos.map { $0.absoluteString }
            self.additionalPhotosData = try? JSONEncoder().encode(urls)
        }
    }
    
    // Convert back to Tender for display
    var asTender: Tender {
        // Decode additional photos
        var additionalPhotos: [URL]?
        if let data = additionalPhotosData,
           let urls = try? JSONDecoder().decode([String].self, from: data) {
            additionalPhotos = urls.compactMap { URL(string: $0) }
        }
        
        return Tender(
            id: id,
            name: name,
            restaurantType: restaurantType,
            priceRange: priceRange,
            address: address,
            phoneNumber: phoneNumber,
            websiteURL: websiteURL.flatMap { URL(string: $0) },
            imageName: imageName,
            imageURL: imageURL.flatMap { URL(string: $0) },
            latitude: latitude,
            longitude: longitude,
            rating: rating,
            reviewCount: reviewCount,
            isOpenNow: isOpenNow,
            additionalPhotos: additionalPhotos
        )
    }
}
