//
//  EmptyStateView.swift
//  Cluck
//
//  Custom empty state views with personality
//

import SwiftUI

struct EmptyStateView: View {
    let title: String
    let emoji: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    init(
        title: String,
        emoji: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.emoji = emoji
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // Animated emoji
            Text(emoji)
                .font(.system(size: 80))
                .scaleEffect(emojiScale)
                .onAppear {
                    withAnimation(
                        .spring(response: 0.6, dampingFraction: 0.6)
                        .repeatForever(autoreverses: true)
                    ) {
                        emojiScale = 1.1
                    }
                }
            
            VStack(spacing: 12) {
                // Title
                Text(title)
                    .font(.title.bold())
                    .foregroundStyle(.white)
                
                // Message
                Text(message)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.9))
                    .padding(.horizontal, 40)
            }
            
            // Optional action button
            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 16)
                        .background(
                            Capsule()
                                .fill(.white.opacity(0.25))
                        )
                }
                .padding(.top, 8)
            }
        }
    }
    
    @State private var emojiScale: CGFloat = 1.0
}

// MARK: - Predefined Empty States

extension EmptyStateView {
    /// Empty state for when no restaurants are found
    static func noRestaurantsFound(onRetry: @escaping () -> Void) -> EmptyStateView {
        EmptyStateView(
            title: "All Clucked Out!",
            emoji: "🍗",
            message: "You've seen every chicken tender spot nearby. Check back later for new additions!",
            actionTitle: "Search Again",
            action: onRetry
        )
    }
    
    /// Empty state for location permission denied
    static var locationDenied: EmptyStateView {
        EmptyStateView(
            title: "Location Needed",
            emoji: "📍",
            message: "We need your location to find the best tender spots nearby. Please enable location access in Settings."
        )
    }
    
    /// Empty state for network error
    static func networkError(onRetry: @escaping () -> Void) -> EmptyStateView {
        EmptyStateView(
            title: "Connection Lost",
            emoji: "📡",
            message: "Looks like we lost our connection. Check your internet and try again.",
            actionTitle: "Try Again",
            action: onRetry
        )
    }
    
    /// Empty state for saved restaurants (when empty)
    static var noSavedRestaurants: EmptyStateView {
        EmptyStateView(
            title: "No Favorites Yet",
            emoji: "💛",
            message: "Swipe right on restaurants in the Discover tab to save them here!"
        )
    }
    
    /// Empty state for loading/searching
    static var searching: EmptyStateView {
        EmptyStateView(
            title: "Finding steaming hot tenders near you",
            emoji: "🐔",
            message: ""
        )
    }
}

// MARK: - Preview Support

#Preview("No Restaurants") {
    ZStack {
        LinearGradient(
            colors: [
                Color(red: 1.0, green: 0.3, blue: 0.2),
                Color(red: 1.0, green: 0.6, blue: 0.4)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        
        EmptyStateView.noRestaurantsFound(onRetry: {})
    }
}

#Preview("Location Denied") {
    ZStack {
        LinearGradient(
            colors: [
                Color(red: 1.0, green: 0.3, blue: 0.2),
                Color(red: 1.0, green: 0.6, blue: 0.4)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        
        EmptyStateView.locationDenied
    }
}

#Preview("Network Error") {
    ZStack {
        LinearGradient(
            colors: [
                Color(red: 1.0, green: 0.3, blue: 0.2),
                Color(red: 1.0, green: 0.6, blue: 0.4)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        
        EmptyStateView.networkError(onRetry: {})
    }
}

#Preview("No Saved") {
    ZStack {
        LinearGradient(
            colors: [
                Color(red: 1.0, green: 0.2, blue: 0.4),
                Color(red: 1.0, green: 0.6, blue: 0.6)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        
        EmptyStateView.noSavedRestaurants
    }
}

#Preview("Searching") {
    ZStack {
        LinearGradient(
            colors: [
                Color(red: 1.0, green: 0.3, blue: 0.2),
                Color(red: 1.0, green: 0.6, blue: 0.4)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        
        EmptyStateView.searching
    }
}
