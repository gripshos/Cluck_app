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
    }
    
    // Convert back to Tender for display
    var asTender: Tender {
        Tender(
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
            longitude: longitude
        )
    }
}
