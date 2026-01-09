//
//  FavoritesHelper.swift
//  Cluck
//
//  Helper utilities for managing favorites and preventing duplicates
//

import Foundation
import SwiftData

@MainActor
enum FavoritesHelper {
    
    /// Checks if a restaurant is already saved to favorites
    /// - Parameters:
    ///   - tenderId: The UUID of the restaurant to check
    ///   - modelContext: The SwiftData model context
    /// - Returns: True if the restaurant is already in favorites
    static func isFavorite(tenderId: UUID, in modelContext: ModelContext) -> Bool {
        let descriptor = FetchDescriptor<FavoriteRestaurant>(
            predicate: #Predicate { $0.id == tenderId }
        )
        
        do {
            let results = try modelContext.fetch(descriptor)
            return !results.isEmpty
        } catch {
            print("❌ Error checking favorite status: \(error)")
            return false
        }
    }
    
    /// Safely adds a restaurant to favorites, preventing duplicates
    /// - Parameters:
    ///   - tender: The restaurant to add
    ///   - modelContext: The SwiftData model context
    /// - Returns: True if successfully added, false if already exists or error occurred
    @discardableResult
    static func addToFavorites(tender: Tender, in modelContext: ModelContext) -> Bool {
        let descriptor = FetchDescriptor<FavoriteRestaurant>(
            predicate: #Predicate { $0.id == tender.id }
        )
        
        do {
            let existing = try modelContext.fetch(descriptor)
            
            if existing.isEmpty {
                // Safe to add - no duplicates
                let favorite = FavoriteRestaurant(from: tender)
                modelContext.insert(favorite)
                try modelContext.save()
                print("✅ Added to favorites: \(tender.name)")
                return true
            } else {
                // Already exists
                print("ℹ️ Already in favorites: \(tender.name)")
                return false
            }
        } catch {
            print("❌ Error adding to favorites: \(error)")
            return false
        }
    }
    
    /// Removes a restaurant from favorites
    /// - Parameters:
    ///   - tenderId: The UUID of the restaurant to remove
    ///   - modelContext: The SwiftData model context
    /// - Returns: True if successfully removed, false if not found or error occurred
    @discardableResult
    static func removeFromFavorites(tenderId: UUID, in modelContext: ModelContext) -> Bool {
        let descriptor = FetchDescriptor<FavoriteRestaurant>(
            predicate: #Predicate { $0.id == tenderId }
        )
        
        do {
            let results = try modelContext.fetch(descriptor)
            
            if let favorite = results.first {
                modelContext.delete(favorite)
                try modelContext.save()
                print("🗑️ Removed from favorites")
                return true
            } else {
                print("ℹ️ Restaurant not found in favorites")
                return false
            }
        } catch {
            print("❌ Error removing from favorites: \(error)")
            return false
        }
    }
    
    /// Removes duplicate entries from favorites database
    /// This is useful for cleaning up data if duplicates were created in previous versions
    /// - Parameter modelContext: The SwiftData model context
    /// - Returns: Number of duplicates removed
    @discardableResult
    static func removeDuplicates(in modelContext: ModelContext) -> Int {
        let descriptor = FetchDescriptor<FavoriteRestaurant>(
            sortBy: [SortDescriptor(\.savedDate, order: .forward)]
        )
        
        do {
            let allFavorites = try modelContext.fetch(descriptor)
            var seenIds = Set<UUID>()
            var duplicatesRemoved = 0
            
            for favorite in allFavorites {
                if seenIds.contains(favorite.id) {
                    // This is a duplicate - remove it
                    modelContext.delete(favorite)
                    duplicatesRemoved += 1
                    print("🗑️ Removed duplicate: \(favorite.name)")
                } else {
                    // First occurrence - keep it
                    seenIds.insert(favorite.id)
                }
            }
            
            if duplicatesRemoved > 0 {
                try modelContext.save()
                print("✅ Removed \(duplicatesRemoved) duplicate(s) from favorites")
            } else {
                print("ℹ️ No duplicates found")
            }
            
            return duplicatesRemoved
        } catch {
            print("❌ Error removing duplicates: \(error)")
            return 0
        }
    }
    
    /// Gets count of all favorites
    /// - Parameter modelContext: The SwiftData model context
    /// - Returns: Number of saved favorites
    static func getFavoritesCount(in modelContext: ModelContext) -> Int {
        let descriptor = FetchDescriptor<FavoriteRestaurant>()
        
        do {
            let results = try modelContext.fetch(descriptor)
            return results.count
        } catch {
            print("❌ Error counting favorites: \(error)")
            return 0
        }
    }
    
    /// Gets all favorites sorted by saved date (newest first)
    /// - Parameter modelContext: The SwiftData model context
    /// - Returns: Array of favorite restaurants
    static func getAllFavorites(in modelContext: ModelContext) -> [FavoriteRestaurant] {
        let descriptor = FetchDescriptor<FavoriteRestaurant>(
            sortBy: [SortDescriptor(\.savedDate, order: .reverse)]
        )
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("❌ Error fetching favorites: \(error)")
            return []
        }
    }
}
