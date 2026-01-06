//
//  SavedListView.swift
//  Tendr
//
//  List of saved favorite restaurants
//

import SwiftUI
import SwiftData

struct SavedListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FavoriteRestaurant.savedDate, order: .reverse) private var favorites: [FavoriteRestaurant]
    
    @State private var showDetail = false
    @State private var selectedTender: Tender?
    
    var body: some View {
        NavigationStack {
            Group {
                if favorites.isEmpty {
                    ContentUnavailableView(
                        "No Saved Restaurants",
                        systemImage: "heart.slash",
                        description: Text("Swipe right on restaurants to save them here")
                    )
                } else {
                    List {
                        ForEach(favorites) { favorite in
                            Button {
                                selectedTender = favorite.asTender
                                showDetail = true
                            } label: {
                                SavedRestaurantRow(favorite: favorite)
                            }
                        }
                        .onDelete(perform: deleteRestaurants)
                    }
                }
            }
            .navigationTitle("Saved Restaurants")
            .toolbar {
                if !favorites.isEmpty {
                    EditButton()
                }
            }
            .sheet(isPresented: $showDetail) {
                if let selectedTender {
                    ChatDetailView(tender: selectedTender, modelContext: modelContext)
                }
            }
        }
    }
    
    private func deleteRestaurants(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(favorites[index])
        }
        try? modelContext.save()
    }
}

struct SavedRestaurantRow: View {
    let favorite: FavoriteRestaurant
    
    var body: some View {
        HStack(spacing: 12) {
            // Image or icon
            ZStack {
                if let imageURL = favorite.imageURL, let url = URL(string: imageURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure, .empty:
                            iconFallback
                        @unknown default:
                            iconFallback
                        }
                    }
                } else if let imageName = favorite.imageName {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    iconFallback
                }
            }
            .frame(width: 60, height: 60)
            .cornerRadius(8)
            
            // Restaurant info
            VStack(alignment: .leading, spacing: 4) {
                Text(favorite.name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                HStack {
                    Text(favorite.restaurantType)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Text("•")
                        .foregroundStyle(.secondary)
                    
                    Text(favorite.priceRange)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                if let address = favorite.address {
                    Text(address)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
        }
    }
    
    private var iconFallback: some View {
        ZStack {
            LinearGradient(
                colors: [.orange, .red],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            Image(systemName: "fork.knife")
                .font(.title2)
                .foregroundStyle(.white)
        }
    }
}

#Preview {
    SavedListView()
        .modelContainer(for: FavoriteRestaurant.self, inMemory: true)
}
