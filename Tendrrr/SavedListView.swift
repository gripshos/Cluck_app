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
                    SavedHeader(
                        showEdit: !favorites.isEmpty,
                        editMode: $editMode
                    )
                    
                    // Main Content
                    if favorites.isEmpty {
                        Spacer()
                        EmptyStateView.noSavedRestaurants
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
    @State private var showTutorialAlert = false
    @State private var showTutorial = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Heart icon
            Image(systemName: "heart.fill")
                .font(.system(size: 28))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 1)
            
            // Styled tab title
            Text("Saved")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
            
            Spacer()
            
            // Tutorial button
            HeaderIconButton(systemImage: "questionmark.circle.fill") {
                showTutorialAlert = true
            }
            
            // Edit button (only show when there are favorites)
            if showEdit {
                HeaderTextButton(title: editMode == .active ? "Done" : "Edit") {
                    withAnimation {
                        editMode = editMode == .active ? .inactive : .active
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .padding(.top, 8)
        .confirmationDialog("Tutorial", isPresented: $showTutorialAlert, titleVisibility: .hidden) {
            Button("Show Tutorial") {
                showTutorial = true
            }
            Button("Cancel", role: .cancel) { }
        }
        .sheet(isPresented: $showTutorial) {
            Text("Tutorial")
        }
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

