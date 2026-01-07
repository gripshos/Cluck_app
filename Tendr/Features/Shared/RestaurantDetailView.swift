//
//  RestaurantDetailView.swift
//  Tendr
//
//  Detailed view for a single restaurant
//

import SwiftUI
import MapKit

/// Full detail view for a restaurant with actions.
struct RestaurantDetailView: View {
    let restaurant: Restaurant
    @Bindable var viewModel: SavedViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Hero image
                heroImage
                    .frame(height: 250)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                
                // Restaurant info
                VStack(alignment: .leading, spacing: 12) {
                    Text(restaurant.name)
                        .font(.title.bold())
                    
                    // Price and address
                    VStack(alignment: .leading, spacing: 6) {
                        Label(restaurant.priceLevel.displayString, systemImage: "dollarsign.circle")
                            .font(.subheadline)
                            .foregroundStyle(.orange)
                        
                        if restaurant.address != "Address unavailable" {
                            Label(restaurant.address, systemImage: "mappin.and.ellipse")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        if let phone = restaurant.phoneNumber {
                            Link(destination: URL(string: "tel:\(phone.filter { $0.isNumber })")!) {
                                Label(phone, systemImage: "phone.fill")
                                    .font(.subheadline)
                            }
                        }
                    }
                }
                
                Divider()
                
                // Action buttons
                VStack(spacing: 12) {
                    // Directions button
                    Link(destination: directionsURL) {
                        Label("Get Directions", systemImage: "map.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .foregroundStyle(.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    HStack(spacing: 12) {
                        // Website or search
                        if let websiteURL = restaurant.websiteURL {
                            Link(destination: websiteURL) {
                                Label("Website", systemImage: "safari")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.orange.opacity(0.1))
                                    .foregroundStyle(.orange)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        } else {
                            Link(destination: googleSearchURL) {
                                Label("Search", systemImage: "magnifyingglass")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.orange.opacity(0.1))
                                    .foregroundStyle(.orange)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                        
                        // Share button
                        ShareLink(item: shareText) {
                            Label("Share", systemImage: "square.and.arrow.up")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .foregroundStyle(.primary)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
                
                // Mini map
                Map(initialPosition: mapPosition) {
                    Marker(restaurant.name, coordinate: restaurant.coordinate.clCoordinate)
                        .tint(.orange)
                }
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .disabled(true) // Static map, tap opens directions
                .onTapGesture {
                    UIApplication.shared.open(directionsURL)
                }
            }
            .padding()
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.remove(restaurant)
                } label: {
                    Image(systemName: viewModel.isSaved(restaurant) ? "bookmark.fill" : "bookmark")
                        .foregroundStyle(.orange)
                }
            }
        }
    }
    
    // MARK: - Views
    
    @ViewBuilder
    private var heroImage: some View {
        if let imageURL = restaurant.imageURL {
            AsyncImage(url: imageURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure, .empty:
                    placeholderImage
                @unknown default:
                    placeholderImage
                }
            }
        } else {
            placeholderImage
        }
    }
    
    private var placeholderImage: some View {
        ZStack {
            LinearGradient(
                colors: [Color.orange.opacity(0.3), Color.red.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Image(systemName: "fork.knife")
                .font(.system(size: 80))
                .foregroundStyle(.white.opacity(0.4))
        }
    }
    
    // MARK: - Computed Properties
    
    private var mapPosition: MapCameraPosition {
        .region(MKCoordinateRegion(
            center: restaurant.coordinate.clCoordinate,
            latitudinalMeters: 500,
            longitudinalMeters: 500
        ))
    }
    
    private var directionsURL: URL {
        let lat = restaurant.coordinate.latitude
        let lon = restaurant.coordinate.longitude
        return URL(string: "http://maps.apple.com/?daddr=\(lat),\(lon)")!
    }
    
    private var googleSearchURL: URL {
        let query = restaurant.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return URL(string: "https://www.google.com/search?q=\(query)")!
    }
    
    private var shareText: String {
        var text = "Check out \(restaurant.name)!"
        if restaurant.address != "Address unavailable" {
            text += "\n📍 \(restaurant.address)"
        }
        text += "\n\nFound on Tendr 🍗"
        return text
    }
}

// MARK: - Preview

#Preview("Detail") {
    NavigationStack {
        RestaurantDetailView(
            restaurant: .preview,
            viewModel: .preview
        )
    }
}
