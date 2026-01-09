//
//  CardDeckView.swift
//  Tendr
//
//  Manages the swipeable card deck with gesture handling
//

import SwiftUI

/// The swipeable card deck that displays restaurants.
struct CardDeckView: View {
    @Bindable var viewModel: DiscoveryViewModel
    
    // MARK: - Gesture State
    
    @State private var dragOffset: CGSize = .zero
    @State private var dragRotation: Double = 0
    
    private let swipeThreshold: CGFloat = 120
    private let rotationFactor: Double = 35 // Degrees per screen width
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if let restaurant = viewModel.currentRestaurant {
                    // Single card (no stack visible for cleaner look)
                    cardView(for: restaurant, geometry: geometry)
                }
            }
        }
    }
    
    // MARK: - Card View
    
    @ViewBuilder
    private func cardView(for restaurant: Restaurant, geometry: GeometryProxy) -> some View {
        ZStack {
            SwipeCardView(restaurant: restaurant)
                .frame(width: geometry.size.width, height: geometry.size.height)
            
            // Swipe direction indicator overlay
            SwipeOverlayView(offset: dragOffset.width, threshold: swipeThreshold)
        }
        .offset(dragOffset)
        .rotationEffect(.degrees(dragRotation))
        .gesture(swipeGesture(screenWidth: geometry.size.width))
        .animation(.interactiveSpring(response: 0.4, dampingFraction: 0.7), value: dragOffset)
    }
    
    // MARK: - Gesture
    
    private func swipeGesture(screenWidth: CGFloat) -> some Gesture {
        DragGesture()
            .onChanged { value in
                dragOffset = value.translation
                // Rotate based on horizontal drag
                dragRotation = Double(value.translation.width / screenWidth) * rotationFactor
            }
            .onEnded { value in
                handleSwipeEnd(
                    translation: value.translation,
                    velocity: value.predictedEndTranslation,
                    screenWidth: screenWidth
                )
            }
    }
    
    private func handleSwipeEnd(translation: CGSize, velocity: CGSize, screenWidth: CGFloat) {
        let horizontalMovement = translation.width
        let horizontalVelocity = velocity.width
        
        // Determine if swipe should complete based on position or velocity
        let shouldCompleteSwipe = abs(horizontalMovement) > swipeThreshold ||
                                   abs(horizontalVelocity) > swipeThreshold * 2
        
        if shouldCompleteSwipe {
            let isRightSwipe = horizontalMovement > 0 || horizontalVelocity > 0
            completeSwipe(direction: isRightSwipe ? .right : .left, screenWidth: screenWidth)
        } else {
            // Snap back to center
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                dragOffset = .zero
                dragRotation = 0
            }
        }
    }
    
    private func completeSwipe(direction: SwipeDirection, screenWidth: CGFloat) {
        // Animate card off screen
        let offscreenX = direction == .right ? screenWidth * 1.5 : -screenWidth * 1.5
        let finalRotation = direction == .right ? 15.0 : -15.0
        
        withAnimation(.easeOut(duration: 0.3)) {
            dragOffset = CGSize(width: offscreenX, height: 0)
            dragRotation = finalRotation
        }
        
        // After animation completes, update view model and reset
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            // Update view model
            if direction == .right {
                viewModel.swipeRight()
            } else {
                viewModel.swipeLeft()
            }
            
            // Reset for next card (no animation needed since card is off-screen)
            dragOffset = .zero
            dragRotation = 0
        }
    }
    
    private enum SwipeDirection {
        case left, right
    }
}

// MARK: - Preview

#Preview("Card Deck") {
    CardDeckView(viewModel: .preview)
        .padding()
}
