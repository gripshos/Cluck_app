//
//  SavedViewModel.swift
//  Tendr
//
//  ViewModel for the saved/favorites feature
//

import Foundation
import Observation

/// Manages state for the saved restaurants list.
@Observable
@MainActor
final class SavedViewModel {
    
    // MARK: - Dependencies
    
    private let favoritesRepository: FavoritesRepository
    
    // MARK: - Computed Properties
    
    /// All saved restaurants
    var favorites: [Restaurant] {
        favoritesRepository.favorites
    }
    
    /// Whether the favorites list is empty
    var isEmpty: Bool {
        favorites.isEmpty
    }
    
    /// Count of saved restaurants
    var count: Int {
        favorites.count
    }
    
    // MARK: - Init
    
    init(favoritesRepository: FavoritesRepository) {
        self.favoritesRepository = favoritesRepository
    }
    
    // MARK: - Actions
    
    /// Remove a restaurant from favorites
    func remove(_ restaurant: Restaurant) {
        favoritesRepository.remove(restaurant)
    }
    
    /// Remove restaurants at specific indices (for swipe-to-delete in List)
    func remove(at offsets: IndexSet) {
        for index in offsets {
            guard index < favorites.count else { continue }
            favoritesRepository.remove(favorites[index])
        }
    }
    
    /// Check if a restaurant is saved
    func isSaved(_ restaurant: Restaurant) -> Bool {
        favoritesRepository.isFavorite(restaurant)
    }
}

// MARK: - Preview Support

#if DEBUG
extension SavedViewModel {
    /// Creates a view model with sample data for previews
    static var preview: SavedViewModel {
        SavedViewModel(favoritesRepository: .preview)
    }
    
    /// Creates a view model with empty favorites
    static var empty: SavedViewModel {
        SavedViewModel(favoritesRepository: .empty)
    }
}
#endif
