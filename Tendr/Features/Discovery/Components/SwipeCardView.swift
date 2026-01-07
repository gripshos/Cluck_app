//
//  SwipeCardView.swift
//  Tendr
//
//  Individual restaurant card for the swipe deck
//

import SwiftUI

/// A single restaurant card displayed in the swipe deck.
struct SwipeCardView: View {
    let restaurant: Restaurant
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomLeading) {
                // Background
                backgroundView
                    .frame(width: geometry.size.width, height: geometry.size.height)
                
                // Gradient overlay for text legibility
                LinearGradient(
                    stops: [
                        .init(color: .clear, location: 0.5),
                        .init(color: .black.opacity(0.6), location: 0.8),
                        .init(color: .black.opacity(0.95), location: 1.0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                // Restaurant info
                VStack(alignment: .leading, spacing: 8) {
                    Text(restaurant.name)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                    
                    HStack(spacing: 8) {
                        Text(restaurant.priceLevel.displayString)
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.orange)
                        
                        if restaurant.address != "Address unavailable" {
                            Text("•")
                                .foregroundStyle(.white.opacity(0.7))
                            
                            Text(restaurant.address)
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.85))
                                .lineLimit(1)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 140) // Space for action buttons
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
    
    // MARK: - Background
    
    @ViewBuilder
    private var backgroundView: some View {
        if let imageURL = restaurant.imageURL {
            // Remote image
            AsyncImage(url: imageURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    placeholderBackground
                case .empty:
                    placeholderBackground
                        .overlay {
                            ProgressView()
                                .tint(.white)
                        }
                @unknown default:
                    placeholderBackground
                }
            }
        } else {
            placeholderBackground
        }
    }
    
    private var placeholderBackground: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [
                    Color.orange.opacity(0.4),
                    Color.red.opacity(0.3)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Food icon
            Image(systemName: "fork.knife")
                .font(.system(size: 120, weight: .ultraLight))
                .foregroundStyle(.white.opacity(0.25))
        }
    }
}

// MARK: - Swipe Overlay Indicators

/// Visual feedback shown when card is being dragged
struct SwipeOverlayView: View {
    let offset: CGFloat
    let threshold: CGFloat
    
    private var progress: CGFloat {
        min(abs(offset) / threshold, 1.0)
    }
    
    private var isLike: Bool {
        offset > 0
    }
    
    var body: some View {
        ZStack {
            if abs(offset) > 20 {
                // Show indicator based on direction
                if isLike {
                    likeIndicator
                        .opacity(Double(progress))
                } else {
                    nopeIndicator
                        .opacity(Double(progress))
                }
            }
        }
    }
    
    private var likeIndicator: some View {
        VStack {
            HStack {
                Spacer()
                Text("LIKE")
                    .font(.system(size: 48, weight: .black))
                    .foregroundStyle(.green)
                    .padding(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.green, lineWidth: 4)
                    )
                    .rotationEffect(.degrees(15))
                    .padding(40)
            }
            Spacer()
        }
    }
    
    private var nopeIndicator: some View {
        VStack {
            HStack {
                Text("NOPE")
                    .font(.system(size: 48, weight: .black))
                    .foregroundStyle(.red)
                    .padding(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.red, lineWidth: 4)
                    )
                    .rotationEffect(.degrees(-15))
                    .padding(40)
                Spacer()
            }
            Spacer()
        }
    }
}

// MARK: - Preview

#Preview("Card") {
    SwipeCardView(restaurant: .preview)
        .frame(height: 500)
        .padding()
}

#Preview("Card with Overlay") {
    ZStack {
        SwipeCardView(restaurant: .preview)
        SwipeOverlayView(offset: 150, threshold: 100)
    }
    .frame(height: 500)
    .padding()
}
