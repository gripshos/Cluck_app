//
//  DeliveryService.swift
//  Cluck
//
//  Service for opening delivery apps with restaurant search
//

import UIKit

enum DeliveryService {
    
    // MARK: - DoorDash
    
    /// Opens DoorDash app or website with restaurant search
    /// - Parameter restaurantName: The name of the restaurant to search for
    static func openDoorDash(restaurantName: String) {
        // URL-encode the restaurant name
        guard let encodedName = restaurantName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("Failed to encode restaurant name")
            openDoorDashWeb(restaurantName: restaurantName)
            return
        }
        
        // Try DoorDash app URL scheme first
        let appURL = URL(string: "doordash://search?query=\(encodedName)")!
        
        if UIApplication.shared.canOpenURL(appURL) {
            // DoorDash app is installed
            UIApplication.shared.open(appURL)
        } else {
            // Fall back to web
            openDoorDashWeb(restaurantName: restaurantName)
        }
    }
    
    /// Opens DoorDash website with restaurant search
    /// - Parameter restaurantName: The name of the restaurant to search for
    private static func openDoorDashWeb(restaurantName: String) {
        // URL-encode for web search
        guard let encodedName = restaurantName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("Failed to encode restaurant name for web")
            return
        }
        
        // DoorDash web search URL
        let webURL = URL(string: "https://www.doordash.com/search/store/\(encodedName)/")!
        UIApplication.shared.open(webURL)
    }
    
    // MARK: - Future: Uber Eats
    
    /// Opens Uber Eats app or website with restaurant search
    /// - Parameter restaurantName: The name of the restaurant to search for
    static func openUberEats(restaurantName: String) {
        guard let encodedName = restaurantName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("Failed to encode restaurant name")
            return
        }
        
        // Uber Eats URL scheme
        let appURL = URL(string: "ubereats://search?query=\(encodedName)")!
        
        if UIApplication.shared.canOpenURL(appURL) {
            UIApplication.shared.open(appURL)
        } else {
            // Fall back to web
            let webURL = URL(string: "https://www.ubereats.com/search?q=\(encodedName)")!
            UIApplication.shared.open(webURL)
        }
    }
    
    // MARK: - Future: Grubhub
    
    /// Opens Grubhub app or website with restaurant search
    /// - Parameter restaurantName: The name of the restaurant to search for
    static func openGrubhub(restaurantName: String) {
        guard let encodedName = restaurantName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("Failed to encode restaurant name")
            return
        }
        
        // Grubhub URL scheme
        let appURL = URL(string: "grubhub://search?query=\(encodedName)")!
        
        if UIApplication.shared.canOpenURL(appURL) {
            UIApplication.shared.open(appURL)
        } else {
            // Fall back to web
            let webURL = URL(string: "https://www.grubhub.com/search/\(encodedName)")!
            UIApplication.shared.open(webURL)
        }
    }
}
