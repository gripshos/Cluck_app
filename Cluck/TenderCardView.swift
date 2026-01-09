//
//  TenderCardView.swift
//  Cluck
//
//  Individual swipeable card for a restaurant
//

import SwiftUI
import CoreLocation

struct TenderCardView: View {
    let tender: Tender
    var userLocation: CLLocation?
    
    private var distanceText: String? {
        guard let userLocation = userLocation else { return nil }
        let restaurantLocation = CLLocation(latitude: tender.latitude, longitude: tender.longitude)
        let distanceInMeters = userLocation.distance(from: restaurantLocation)
        let distanceInMiles = distanceInMeters / 1609.34
        return String(format: "%.1f mi", distanceInMiles)
    }
    
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
                
                // "Open Now" / "Closed" badge in top-right corner
                if let isOpenNow = tender.isOpenNow {
                    VStack {
                        HStack {
                            Spacer()
                            HStack(spacing: 4) {
                                Image(systemName: "clock.fill")
                                    .font(.caption2)
                                Text(isOpenNow ? "Open" : "Closed")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(isOpenNow ? Color.green.opacity(0.9) : Color.red.opacity(0.9))
                            )
                            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                            .padding([.top, .trailing], 16)
                        }
                        Spacer()
                    }
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
                    
                    // Star rating and review count
                    if let rating = tender.rating, let reviewCount = tender.reviewCount {
                        HStack(spacing: 4) {
                            ForEach(1...5, id: \.self) { star in
                                Image(systemName: star <= Int(rating.rounded()) ? "star.fill" : "star")
                                    .font(.caption)
                                    .foregroundStyle(star <= Int(rating.rounded()) ? .yellow : .gray.opacity(0.5))
                            }
                            
                            Text("(\(reviewCount))")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.9))
                        }
                        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                    }
                    
                    HStack {
                        Text(tender.restaurantType)
                            .foregroundStyle(.white.opacity(0.95))
                        
                        Text("•")
                            .foregroundStyle(.white.opacity(0.7))
                        
                        Text(tender.priceRange)
                            .foregroundStyle(.white.opacity(0.95))
                        
                        if let distanceText = distanceText {
                            Text("•")
                                .foregroundStyle(.white.opacity(0.7))
                            
                            Label(distanceText, systemImage: "location.fill")
                                .foregroundStyle(.white.opacity(0.95))
                        }
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
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
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


