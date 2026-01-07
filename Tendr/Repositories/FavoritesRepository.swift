//
//  FavoritesRepository.swift
//  Tendr
//
//  SwiftData-backed persistence for favorite restaurants
//

import Foundation
import SwiftData

// MARK: - SwiftData Model

/// Persistent model for saved/favorite restaurants.
/// Stores enough data to display in list and re-fetch details if needed.
@Model
final class FavoriteRestaurant {
    @Attribute(.unique) var restaurantId: UUID
    var name: String
    var address: String
    var latitude: Double
    var longitude: Double
    var priceLevel: Int
    var phoneNumber: String?
    var websiteURL: URL?
    var savedAt: Date
    
    init(from restaurant: Restaurant) {
        self.restaurantId = restaurant.id
        self.name = restaurant.name
        self.address = restaurant.address
        self.latitude = restaurant.coordinate.latitude
        self.longitude = restaurant.coordinate.longitude
        self.priceLevel = restaurant.priceLevel.rawValue
        self.phoneNumber = restaurant.phoneNumber
        self.websiteURL = restaurant.websiteURL
        self.savedAt = Date()
    }
    
    /// Convert back to domain model
    func toRestaurant() -> Restaurant {
        Restaurant(
            id: restaurantId,
            name: name,
            address: address,
            coordinate: Restaurant.Coordinate(latitude: latitude, longitude: longitude),
            priceLevel: Restaurant.PriceLevel(rawValue: priceLevel) ?? .moderate,
            phoneNumber: phoneNumber,
            websiteURL: websiteURL,
            imageURL: nil
        )
    }
}

// MARK: - Repository

/// Repository for managing favorite restaurants with SwiftData.
@Observable
@MainActor
final class FavoritesRepository {
    
    private let modelContainer: ModelContainer
    private var modelContext: ModelContext
    
    /// All saved favorites, kept in sync with SwiftData
    private(set) var favorites: [Restaurant] = []
    
    // MARK: - Init
    
    init(inMemory: Bool = false) {
        do {
            let configuration = ModelConfiguration(isStoredInMemoryOnly: inMemory)
            self.modelContainer = try ModelContainer(
                for: FavoriteRestaurant.self,
                configurations: configuration
            )
            self.modelContext = modelContainer.mainContext
            loadFavorites()
        } catch {
            fatalError("Failed to initialize SwiftData: \(error)")
        }
    }
    
    // For dependency injection in tests
    init(container: ModelContainer) {
        self.modelContainer = container
        self.modelContext = container.mainContext
        loadFavorites()
    }
    
    // MARK: - Public Methods
    
    /// Add a restaurant to favorites
    func add(_ restaurant: Restaurant) {
        // Check if already exists
        guard !isFavorite(restaurant) else { return }
        
        let favorite = FavoriteRestaurant(from: restaurant)
        modelContext.insert(favorite)
        saveAndReload()
    }
    
    /// Remove a restaurant from favorites
    func remove(_ restaurant: Restaurant) {
        let descriptor = FetchDescriptor<FavoriteRestaurant>(
            predicate: #Predicate { $0.restaurantId == restaurant.id }
        )
        
        do {
            let results = try modelContext.fetch(descriptor)
            for favorite in results {
                modelContext.delete(favorite)
            }
            saveAndReload()
        } catch {
            print("Failed to remove favorite: \(error)")
        }
    }
    
    /// Check if a restaurant is in favorites
    func isFavorite(_ restaurant: Restaurant) -> Bool {
        favorites.contains { $0.id == restaurant.id }
    }
    
    /// Toggle favorite status
    func toggleFavorite(_ restaurant: Restaurant) {
        if isFavorite(restaurant) {
            remove(restaurant)
        } else {
            add(restaurant)
        }
    }
    
    /// Get all favorites sorted by save date (newest first)
    func getFavoritesSortedByDate() -> [Restaurant] {
        favorites.sorted { a, b in
            // Since we don't store savedAt in Restaurant, we need to look it up
            // For simplicity, rely on the order from loadFavorites which sorts by savedAt
            true
        }
    }
    
    // MARK: - Private Methods
    
    private func loadFavorites() {
        let descriptor = FetchDescriptor<FavoriteRestaurant>(
            sortBy: [SortDescriptor(\.savedAt, order: .reverse)]
        )
        
        do {
            let results = try modelContext.fetch(descriptor)
            favorites = results.map { $0.toRestaurant() }
        } catch {
            print("Failed to load favorites: \(error)")
            favorites = []
        }
    }
    
    private func saveAndReload() {
        do {
            try modelContext.save()
            loadFavorites()
        } catch {
            print("Failed to save favorites: \(error)")
        }
    }
}

// MARK: - Preview Support

#if DEBUG
extension FavoritesRepository {
    /// Creates an in-memory repository with sample data for previews
    static var preview: FavoritesRepository {
        let repo = FavoritesRepository(inMemory: true)
        // Add some sample favorites
        repo.add(Restaurant.previewList[0])
        repo.add(Restaurant.previewList[1])
        return repo
    }
    
    /// Creates an empty in-memory repository
    static var empty: FavoritesRepository {
        FavoritesRepository(inMemory: true)
    }
}
#endif
