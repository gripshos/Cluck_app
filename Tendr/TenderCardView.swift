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
        ZStack(alignment: .bottomLeading) {
            // Background image or gradient fallback
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
            
            // Gradient overlay for text legibility
            LinearGradient(
                colors: [.clear, .black.opacity(0.7)],
                startPoint: .center,
                endPoint: .bottom
            )
            
            // Restaurant information
            VStack(alignment: .leading, spacing: 8) {
                Text(tender.name)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                
                HStack {
                    Text(tender.restaurantType)
                        .foregroundStyle(.white.opacity(0.9))
                    
                    Text("•")
                        .foregroundStyle(.white.opacity(0.6))
                    
                    Text(tender.priceRange)
                        .foregroundStyle(.white.opacity(0.9))
                }
                .font(.subheadline)
                
                if let address = tender.address {
                    Label(address, systemImage: "mappin.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.8))
                        .lineLimit(2)
                }
            }
            .padding(20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(radius: 10)
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

#Preview {
    TenderCardView(
        tender: Tender(
            name: "Raising Cane's",
            restaurantType: "Fast Food",
            priceRange: "$",
            address: "123 Main St, San Francisco, CA",
            phoneNumber: "555-1234",
            websiteURL: URL(string: "https://example.com"),
            latitude: 37.7749,
            longitude: -122.4194
        )
    )
    .frame(height: 600)
    .padding()
}
