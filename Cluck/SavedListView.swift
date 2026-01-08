//
//  SavedListView.swift
//  Cluck
//
//  List of saved favorite restaurants
//

import SwiftUI
import SwiftData

struct SavedListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FavoriteRestaurant.savedDate, order: .reverse) private var favorites: [FavoriteRestaurant]
    
    @State private var selectedTender: Tender?
    @State private var editMode: EditMode = .inactive
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Vibrant gradient background
                LinearGradient(
                    colors: [
                        Color(red: 1.0, green: 0.2, blue: 0.4),
                        Color(red: 1.0, green: 0.4, blue: 0.5),
                        Color(red: 1.0, green: 0.6, blue: 0.6)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Custom Header with Edit Button
                    SavedHeader(showEdit: !favorites.isEmpty, editMode: $editMode)
                    
                    // Main Content
                    if favorites.isEmpty {
                        Spacer()
                        ContentUnavailableView(
                            "No Saved Restaurants",
                            systemImage: "heart.slash",
                            description: Text("Swipe right on restaurants to save them here")
                        )
                        .foregroundStyle(.white)
                        Spacer()
                    } else {
                        List {
                            ForEach(favorites) { favorite in
                                SavedRestaurantRow(favorite: favorite)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        selectedTender = favorite.asTender
                                    }
                                    .listRowBackground(Color.white.opacity(0.9))
                            }
                            .onDelete(perform: deleteRestaurants)
                        }
                        .scrollContentBackground(.hidden)
                        .environment(\.editMode, $editMode)
                    }
                }
            }
            .sheet(item: $selectedTender) { tender in
                ChatDetailView(tender: tender, modelContext: modelContext)
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

// MARK: - Custom Header Component

struct SavedHeader: View {
    let showEdit: Bool
    @Binding var editMode: EditMode
    
    var body: some View {
        ZStack {
            // Vibrant gradient background matching the Saved tab theme
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.2, blue: 0.4),
                    Color(red: 1.0, green: 0.3, blue: 0.45)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            
            HStack(spacing: 12) {
                // Heart icon
                Image(systemName: "heart.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                
                // Styled tab title
                Text("Saved")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .white.opacity(0.9)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
                
                Spacer()
                
                // Edit button (only show when there are favorites)
                if showEdit {
                    Button(action: {
                        withAnimation {
                            if editMode == .active {
                                editMode = .inactive
                            } else {
                                editMode = .active
                            }
                        }
                    }) {
                        Text(editMode == .active ? "Done" : "Edit")
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(.white.opacity(0.2))
                            )
                    }
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .frame(height: 70)
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
                    .foregroundStyle(.black)
                
                HStack {
                    Text(favorite.restaurantType)
                        .font(.subheadline)
                        .foregroundStyle(.black.opacity(0.7))
                    
                    Text("•")
                        .foregroundStyle(.black.opacity(0.7))
                    
                    Text(favorite.priceRange)
                        .font(.subheadline)
                        .foregroundStyle(.black.opacity(0.7))
                }
                
                if let address = favorite.address {
                    Text(address)
                        .font(.caption)
                        .foregroundStyle(.black.opacity(0.5))
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
