//
//  ChatDetailView.swift
//  Tendr
//
//  Detail view for a restaurant
//

import SwiftUI
import SwiftData
import MapKit

struct ChatDetailView: View {
    let tender: Tender
    let modelContext: ModelContext
    
    @Environment(\.dismiss) private var dismiss
    @State private var isFavorite = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Restaurant image
                    ZStack(alignment: .bottomLeading) {
                        if let imageURL = tender.imageURL {
                            AsyncImage(url: imageURL) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                case .failure, .empty:
                                    gradientFallback
                                @unknown default:
                                    gradientFallback
                                }
                            }
                        } else if let imageName = tender.imageName {
                            Image(imageName)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } else {
                            gradientFallback
                        }
                        
                        // Gradient overlay
                        LinearGradient(
                            colors: [.clear, .black.opacity(0.6)],
                            startPoint: .center,
                            endPoint: .bottom
                        )
                        
                        // Restaurant name
                        Text(tender.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .padding()
                    }
                    .frame(height: 300)
                    .clipped()
                    
                    VStack(alignment: .leading, spacing: 16) {
                        // Type and price
                        HStack {
                            Label(tender.restaurantType, systemImage: "fork.knife")
                            Spacer()
                            Text(tender.priceRange)
                                .fontWeight(.semibold)
                        }
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        
                        Divider()
                        
                        // Address
                        if let address = tender.address {
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Address", systemImage: "mappin.circle.fill")
                                    .font(.headline)
                                
                                Text(address)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        // Phone number
                        if let phoneNumber = tender.phoneNumber {
                            Button {
                                if let url = URL(string: "tel:\(phoneNumber)") {
                                    UIApplication.shared.open(url)
                                }
                            } label: {
                                HStack {
                                    Label(phoneNumber, systemImage: "phone.fill")
                                        .font(.headline)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(.secondary)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                            }
                            .foregroundStyle(.primary)
                        }
                        
                        // Website
                        if let websiteURL = tender.websiteURL {
                            Button {
                                UIApplication.shared.open(websiteURL)
                            } label: {
                                Label("Visit Website", systemImage: "globe")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 1.0, green: 0.3, blue: 0.2),
                                                Color(red: 1.0, green: 0.5, blue: 0.3)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .foregroundStyle(.white)
                                    .cornerRadius(10)
                            }
                        } else {
                            // Fallback to Google search
                            Button {
                                UIApplication.shared.open(googleSearchURL)
                            } label: {
                                Label("Search on Google", systemImage: "magnifyingglass")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 1.0, green: 0.3, blue: 0.2),
                                                Color(red: 1.0, green: 0.5, blue: 0.3)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .foregroundStyle(.white)
                                    .cornerRadius(10)
                            }
                        }
                        
                        Divider()
                        
                        // Actions
                        VStack(spacing: 12) {
                            // Directions button
                            Button {
                                openInMaps()
                            } label: {
                                Label("Get Directions", systemImage: "arrow.triangle.turn.up.right.circle.fill")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        LinearGradient(
                                            colors: [Color.blue, Color.blue.opacity(0.8)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .foregroundStyle(.white)
                                    .cornerRadius(10)
                                    .fontWeight(.semibold)
                            }
                            
                            // Save/Unsave button
                            Button {
                                toggleFavorite()
                            } label: {
                                Label(
                                    isFavorite ? "Remove from Favorites" : "Save to Favorites",
                                    systemImage: isFavorite ? "heart.slash.fill" : "heart.fill"
                                )
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        colors: isFavorite ? 
                                            [Color.red, Color.red.opacity(0.8)] :
                                            [Color(red: 1.0, green: 0.3, blue: 0.2), Color(red: 1.0, green: 0.5, blue: 0.3)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .foregroundStyle(.white)
                                .cornerRadius(10)
                                .fontWeight(.semibold)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                checkIfFavorite()
            }
        }
    }
    
    private var gradientFallback: some View {
        ZStack {
            LinearGradient(
                colors: [.orange, .red],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            Image(systemName: "fork.knife")
                .font(.system(size: 100))
                .foregroundStyle(.white.opacity(0.3))
        }
    }
    
    private var googleSearchURL: URL {
        let query = tender.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return URL(string: "https://www.google.com/search?q=\(query)")!
    }
    
    private func openInMaps() {
        let coordinate = CLLocationCoordinate2D(latitude: tender.latitude, longitude: tender.longitude)
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = tender.name
        mapItem.openInMaps(launchOptions: nil)
    }
    
    private func checkIfFavorite() {
        let descriptor = FetchDescriptor<FavoriteRestaurant>(
            predicate: #Predicate { $0.id == tender.id }
        )
        
        do {
            let results = try modelContext.fetch(descriptor)
            isFavorite = !results.isEmpty
        } catch {
            print("Error checking favorite status: \(error)")
        }
    }
    
    private func toggleFavorite() {
        let descriptor = FetchDescriptor<FavoriteRestaurant>(
            predicate: #Predicate { $0.id == tender.id }
        )
        
        do {
            let results = try modelContext.fetch(descriptor)
            
            if let existing = results.first {
                // Remove from favorites
                modelContext.delete(existing)
                isFavorite = false
            } else {
                // Add to favorites
                let favorite = FavoriteRestaurant(from: tender)
                modelContext.insert(favorite)
                isFavorite = true
            }
            
            try modelContext.save()
        } catch {
            print("Error toggling favorite: \(error)")
        }
    }
}

#Preview {
    ChatDetailView(
        tender: Tender(
            name: "Raising Cane's",
            restaurantType: "Fast Food",
            priceRange: "$",
            address: "123 Main St, San Francisco, CA",
            phoneNumber: "555-1234",
            websiteURL: URL(string: "https://example.com"),
            latitude: 37.7749,
            longitude: -122.4194
        ),
        modelContext: ModelContext(
            try! ModelContainer(for: FavoriteRestaurant.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        )
    )
}
