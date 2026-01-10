//
//  ChatDetailView.swift
//  Cluck
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
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    // Parallax hero image
                    GeometryReader { geometry in
                        let offset = geometry.frame(in: .global).minY
                        
                        ZStack(alignment: .bottomLeading) {
                            if let imageURL = tender.imageURL {
                                AsyncImage(url: imageURL) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .offset(y: offset > 0 ? -offset : 0)
                                            .scaleEffect(offset > 0 ? 1 + offset/500 : 1)
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
                                    .offset(y: offset > 0 ? -offset : 0)
                                    .scaleEffect(offset > 0 ? 1 + offset/500 : 1)
                            } else {
                                gradientFallback
                            }
                            
                            // Gradient overlay
                            LinearGradient(
                                colors: [.clear, .black.opacity(0.6)],
                                startPoint: .center,
                                endPoint: .bottom
                            )
                        }
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                    }
                    .frame(height: 350)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        // Restaurant name prominently displayed
                        Text(tender.name)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)
                        
                        // Star rating display
                        if let rating = tender.rating, let reviewCount = tender.reviewCount {
                            HStack(spacing: 4) {
                                ForEach(1...5, id: \.self) { star in
                                    Image(systemName: star <= Int(rating.rounded()) ? "star.fill" : "star")
                                        .font(.body)
                                        .foregroundStyle(star <= Int(rating.rounded()) ? .yellow : .gray.opacity(0.3))
                                }
                                
                                Text(String(format: "%.1f", rating))
                                    .font(.headline)
                                    .foregroundStyle(.secondary)
                                
                                Text("(\(reviewCount) reviews)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        // Type and price
                        HStack {
                            Label(tender.restaurantType, systemImage: "fork.knife")
                            Spacer()
                            Text(tender.priceRange)
                                .fontWeight(.semibold)
                        }
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        
                        // Open/Closed badge
                        if let isOpenNow = tender.isOpenNow {
                            HStack(spacing: 6) {
                                Image(systemName: "clock.fill")
                                .font(.subheadline)
                                Text(isOpenNow ? "Open Now" : "Closed")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(isOpenNow ? Color.green : Color.red)
                            )
                        }
                        
                        Divider()
                        
                        // Quick action buttons - circular icons
                        HStack(spacing: 20) {
                            // Call button
                            if let phoneNumber = tender.phoneNumber {
                                Button {
                                    if let url = URL(string: "tel:\(phoneNumber)") {
                                        UIApplication.shared.open(url)
                                    }
                                } label: {
                                    VStack(spacing: 8) {
                                        Circle()
                                            .fill(Color.blue.gradient)
                                            .frame(width: 60, height: 60)
                                            .overlay {
                                                Image(systemName: "phone.fill")
                                                    .font(.title3)
                                                    .foregroundStyle(.white)
                                            }
                                        Text("Call")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                            
                            // DoorDash button
                            Button {
                                DeliveryService.openDoorDash(restaurantName: tender.name)
                            } label: {
                                VStack(spacing: 8) {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Color(red: 1.0, green: 0.19, blue: 0.03), // DoorDash red #FF3008
                                                    Color(red: 0.9, green: 0.1, blue: 0.0)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 60, height: 60)
                                        .overlay {
                                            Image(systemName: "bag.fill")
                                                .font(.title3)
                                                .foregroundStyle(.white)
                                        }
                                    Text("Order")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            
                            // Directions button
                            Button {
                                openInMaps()
                            } label: {
                                VStack(spacing: 8) {
                                    Circle()
                                        .fill(Color.green.gradient)
                                        .frame(width: 60, height: 60)
                                        .overlay {
                                            Image(systemName: "arrow.triangle.turn.up.right.circle.fill")
                                                .font(.title3)
                                                .foregroundStyle(.white)
                                        }
                                    Text("Directions")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            
                            // Share button
                            ShareLink(
                                item: "Check out \(tender.name)! \(tender.address ?? "")\n\nFound on Cluck 🍗"
                            ) {
                                VStack(spacing: 8) {
                                    Circle()
                                        .fill(Color.orange.gradient)
                                        .frame(width: 60, height: 60)
                                        .overlay {
                                            Image(systemName: "square.and.arrow.up")
                                                .font(.title3)
                                                .foregroundStyle(.white)
                                        }
                                    Text("Share")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .padding(.vertical, 8)
                        
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
                        
                        // Photo gallery
                        if let additionalPhotos = tender.additionalPhotos, !additionalPhotos.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Photos")
                                    .font(.headline)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(additionalPhotos, id: \.self) { url in
                                            AsyncImage(url: url) { image in
                                                image
                                                    .resizable()
                                                    .scaledToFill()
                                            } placeholder: {
                                                Color.gray.opacity(0.3)
                                            }
                                            .frame(width: 120, height: 120)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Website button
                        if let websiteURL = tender.websiteURL {
                            Divider()
                            
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
                            Divider()
                            
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
                    }
                    .padding()
                }
            }
        }
        .overlay(alignment: .topTrailing) {
            // Done button overlay
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.white, .black.opacity(0.3))
                    .padding()
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
}

