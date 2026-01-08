//
//  SavedListView.swift
//  Tendr
//
//  List view for saved/favorite restaurants
//

import SwiftUI

/// List of saved favorite restaurants.
struct SavedListView: View {
    @Bindable var viewModel: SavedViewModel
    
    var body: some View {
        Group {
            if viewModel.isEmpty {
                emptyView
            } else {
                listView
            }
        }
        .navigationTitle("Saved")
        .navigationDestination(for: Restaurant.self) { restaurant in
            RestaurantDetailView(restaurant: restaurant, viewModel: viewModel)
        }
    }
    
    // MARK: - Views
    
    private var emptyView: some View {
        ContentUnavailableView(
            "No Saved Restaurants",
            systemImage: "bookmark.slash",
            description: Text("Restaurants you like will appear here.\nSwipe right on a restaurant to save it!")
        )
    }
    
    private var listView: some View {
        List {
            ForEach(viewModel.favorites) { restaurant in
                NavigationLink(value: restaurant) {
                    RestaurantRowView(restaurant: restaurant)
                }
            }
            .onDelete(perform: viewModel.remove)
        }
        .listStyle(.plain)
    }
}

// MARK: - Row View

/// Single row in the saved restaurants list.
struct RestaurantRowView: View {
    let restaurant: Restaurant
    
    var body: some View {
        HStack(spacing: 16) {
            // Thumbnail
            thumbnailView
                .frame(width: 70, height: 70)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(restaurant.name)
                    .font(.headline)
                    .lineLimit(1)
                
                if restaurant.address != "Address unavailable" {
                    Text(restaurant.address)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                
                Text(restaurant.priceLevel.displayString)
                    .font(.caption.bold())
                    .foregroundStyle(.orange)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
    
    @ViewBuilder
    private var thumbnailView: some View {
        if let imageURL = restaurant.imageURL {
            AsyncImage(url: imageURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure, .empty:
                    placeholderThumbnail
                @unknown default:
                    placeholderThumbnail
                }
            }
        } else {
            placeholderThumbnail
        }
    }
    
    private var placeholderThumbnail: some View {
        ZStack {
            Color.orange.opacity(0.2)
            Image(systemName: "fork.knife")
                .foregroundStyle(.orange.opacity(0.5))
        }
    }
}

// MARK: - Preview

#Preview("With Items") {
    NavigationStack {
        SavedListView(viewModel: .preview)
    }
}

#Preview("Empty") {
    NavigationStack {
        SavedListView(viewModel: .empty)
    }
}
