//
//  TenderCardView.swift
//  Tendr
//
//  Individual swipeable card for a restaurant
//

import SwiftUI

struct TenderCardView: View {
    let tender: Tender
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomLeading) {
                // Background image or gradient fallback
                if let imageURL = tender.imageURL {
                    AsyncImage(url: imageURL) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .clipped()
                        case .failure:
                            gradientFallback
                        case .empty:
                            ZStack {
                                gradientFallback
                                ProgressView()
                                    .tint(.white)
                            }
                        @unknown default:
                            gradientFallback
                        }
                    }
                } else if let imageName = tender.imageName {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                } else {
                    gradientFallback
                }
                
                // Gradient overlay for text legibility
                LinearGradient(
                    colors: [.clear, .black.opacity(0.8)],
                    startPoint: .center,
                    endPoint: .bottom
                )
                
                // Restaurant information
                VStack(alignment: .leading, spacing: 8) {
                    Text(tender.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                    
                    HStack {
                        Text(tender.restaurantType)
                            .foregroundStyle(.white.opacity(0.95))
                        
                        Text("•")
                            .foregroundStyle(.white.opacity(0.7))
                        
                        Text(tender.priceRange)
                            .foregroundStyle(.white.opacity(0.95))
                    }
                    .font(.subheadline)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                    
                    if let address = tender.address {
                        Label(address, systemImage: "mappin.circle.fill")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.9))
                            .lineLimit(2)
                            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                    }
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
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
}

#Preview("Single Card") {
    TenderCardView(
        tender: Tender(
            name: "Raising Cane's Chicken Fingers",
            restaurantType: "Fast Food",
            priceRange: "$",
            address: "123 Main St, San Francisco, CA",
            phoneNumber: "555-1234",
            websiteURL: URL(string: "https://example.com"),
            imageURL: URL(string: "https://s3-media0.fl.yelpcdn.com/bphoto/example.jpg"),
            latitude: 37.7749,
            longitude: -122.4194
        )
    )
    .frame(height: 500)
    .padding()
}
#Preview("No Image") {
    TenderCardView(
        tender: Tender(
            name: "Popeyes Louisiana Kitchen",
            restaurantType: "Fast Food",
            priceRange: "$$",
            address: "456 Oak Ave, Los Angeles, CA",
            phoneNumber: "555-5678",
            websiteURL: URL(string: "https://example.com"),
            latitude: 34.0522,
            longitude: -118.2437
        )
    )
    .frame(height: 500)
    .padding()
}

#Preview("Long Name") {
    TenderCardView(
        tender: Tender(
            name: "The Best Chicken Tenders Restaurant and Grill House",
            restaurantType: "Casual Dining",
            priceRange: "$$$",
            address: "789 Very Long Street Name That Goes On, New York, NY",
            phoneNumber: "555-9999",
            websiteURL: URL(string: "https://example.com"),
            latitude: 40.7128,
            longitude: -74.0060
        )
    )
    .frame(height: 500)
    .padding()
}

