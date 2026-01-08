//
//  SwipeDeckView.swift
//  Cluck
//
//  Main swipeable card deck interface
//

import SwiftUI
import SwiftData

struct SwipeDeckView: View {
    @Bindable var viewModel: TenderDeckViewModel
    let modelContext: ModelContext
    
    @State private var dragAmount = CGSize.zero
    @State private var selectedTender: Tender?
    @State private var hasTriggeredHaptic = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient that extends to the top safe area
                LinearGradient(
                    colors: [
                        Color(red: 1.0, green: 0.3, blue: 0.2), // #FF4C33
                        Color(red: 1.0, green: 0.4, blue: 0.3),
                        Color(red: 1.0, green: 0.6, blue: 0.4),
                        Color(red: 1.0, green: 0.8, blue: 0.5)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Custom Header with Logo and Title
                    CluckHeader(onRefresh: {
                        Task {
                            await viewModel.loadRestaurants()
                        }
                    })
                    
                    // Main Content
                    ZStack {
                    
                    if viewModel.isLoading {
                        EmptyStateView.searching
                    } else if let errorMessage = viewModel.errorMessage {
                        if errorMessage.contains("location") {
                            EmptyStateView.locationDenied
                        } else {
                            EmptyStateView.networkError(onRetry: {
                                Task {
                                    await viewModel.loadRestaurants()
                                }
                            })
                        }
                    } else if viewModel.tenders.isEmpty {
                        EmptyStateView.noRestaurantsFound(onRetry: {
                            Task {
                                await viewModel.loadRestaurants()
                            }
                        })
                    } else {
                        VStack {
                            // Undo button (only visible when there's a last swiped restaurant)
                            if viewModel.lastSwipedRestaurant != nil {
                                HStack {
                                    Spacer()
                                    Button {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            viewModel.undoLastSwipe()
                                        }
                                    } label: {
                                        HStack(spacing: 6) {
                                            Image(systemName: "arrow.uturn.backward")
                                                .font(.subheadline)
                                            Text("Undo")
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                        }
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            Capsule()
                                                .fill(.white.opacity(0.25))
                                        )
                                    }
                                    .padding(.trailing)
                                    .transition(.move(edge: .trailing).combined(with: .opacity))
                                }
                                .padding(.top, 8)
                            }
                            
                            Spacer()
                        }
                        .zIndex(10)
                        
                        // Card deck with proper sizing
                        GeometryReader { geometry in
                            ZStack {
                                // Render up to 3 cards with stacking effect
                                ForEach(Array(viewModel.tenders.prefix(3).enumerated().reversed()), id: \.element.id) { index, tender in
                                    ZStack {
                                        TenderCardView(tender: tender, userLocation: viewModel.userLocation)
                                        
                                        // Like/Nope overlay (only on top card)
                                        if index == 0 {
                                            SwipeOverlayView(dragAmount: dragAmount)
                                        }
                                    }
                                    .frame(
                                        width: geometry.size.width - 40,
                                        height: min(geometry.size.height * 0.7, 600)
                                    )
                                    .scaleEffect(1.0 - (Double(index) * 0.05))
                                    .offset(y: CGFloat(index) * 8)
                                    .position(
                                        x: geometry.size.width / 2 + (index == 0 ? dragAmount.width : 0),
                                        y: geometry.size.height / 2 + (index == 0 ? dragAmount.height * 0.4 : 0)
                                    )
                                    .rotationEffect(.degrees(index == 0 ? Double(dragAmount.width / 20) : 0))
                                    .zIndex(Double(3 - index))
                                    .allowsHitTesting(index == 0)
                                        .gesture(
                                            index == 0 ? DragGesture()
                                                .onChanged { gesture in
                                                    dragAmount = gesture.translation
                                                    
                                                    // Trigger haptic feedback when crossing threshold
                                                    let threshold: CGFloat = 100
                                                    if abs(gesture.translation.width) > threshold && !hasTriggeredHaptic {
                                                        let impact = UIImpactFeedbackGenerator(style: .medium)
                                                        impact.impactOccurred()
                                                        hasTriggeredHaptic = true
                                                    } else if abs(gesture.translation.width) <= threshold {
                                                        hasTriggeredHaptic = false
                                                    }
                                                }
                                                .onEnded { gesture in
                                                    handleSwipe(gesture: gesture, tender: tender)
                                                    hasTriggeredHaptic = false
                                                } : nil
                                        )
                                        .onTapGesture {
                                            if index == 0 {
                                                selectedTender = tender
                                            }
                                        }
                                }
                            }
                        }
                    }
                }
            }
            // Close the VStack
            }
            .navigationBarHidden(true)
            .task {
                if viewModel.tenders.isEmpty && !viewModel.isLoading {
                    await viewModel.loadRestaurants()
                }
            }
            .sheet(item: $selectedTender) { tender in
                ChatDetailView(tender: tender, modelContext: modelContext)
            }
        }
    }
    
    private func handleSwipe(gesture: DragGesture.Value, tender: Tender) {
        let threshold: CGFloat = 100
        
        withAnimation {
            if gesture.translation.width > threshold {
                // Swipe right - save
                saveTender(tender)
                dragAmount = CGSize(width: 500, height: 0)
                
                // Success haptic feedback
                let notification = UINotificationFeedbackGenerator()
                notification.notificationOccurred(.success)
            } else if gesture.translation.width < -threshold {
                // Swipe left - skip
                dragAmount = CGSize(width: -500, height: 0)
                
                // Success haptic feedback
                let notification = UINotificationFeedbackGenerator()
                notification.notificationOccurred(.success)
            } else {
                // Return to center
                dragAmount = .zero
                
                // Light haptic feedback for snap back
                let light = UIImpactFeedbackGenerator(style: .light)
                light.impactOccurred()
            }
        }
        
        // Remove card after animation
        if abs(gesture.translation.width) > threshold {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation {
                    viewModel.removeTopCard()
                    dragAmount = .zero
                }
            }
        } else {
            withAnimation {
                dragAmount = .zero
            }
        }
    }
    
    private func saveTender(_ tender: Tender) {
        let favorite = FavoriteRestaurant(from: tender)
        modelContext.insert(favorite)
        try? modelContext.save()
    }
}

// MARK: - Custom Header Component

struct CluckHeader: View {
    let onRefresh: () -> Void
    
    var body: some View {
        ZStack {
            // Vibrant gradient background - using #FF4C33 as base
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.3, blue: 0.2), // #FF4C33
                    Color(red: 1.0, green: 0.4, blue: 0.3)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            
            HStack(spacing: 12) {
                // Chicken emoji icon
                Text("🍗")
                    .font(.system(size: 40))
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                
                // Styled app title
                Text("Cluck")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .white.opacity(0.9)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
                
                Spacer()
                
                // Refresh button
                Button(action: onRefresh) {
                    Image(systemName: "arrow.clockwise")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(.white.opacity(0.2))
                        )
                }
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .frame(height: 70)
    }
}

// MARK: - Swipe Overlay Component

struct SwipeOverlayView: View {
    let dragAmount: CGSize
    
    private var likeOpacity: Double {
        guard dragAmount.width > 0 else { return 0 }
        return min(Double(dragAmount.width / 100), 1.0)
    }
    
    private var nopeOpacity: Double {
        guard dragAmount.width < 0 else { return 0 }
        return min(Double(abs(dragAmount.width) / 100), 1.0)
    }
    
    private var likeScale: CGFloat {
        0.5 + (likeOpacity * 0.5) // Scale from 0.5 to 1.0
    }
    
    private var nopeScale: CGFloat {
        0.5 + (nopeOpacity * 0.5) // Scale from 0.5 to 1.0
    }
    
    var body: some View {
        ZStack {
            // LIKE overlay (right swipe)
            VStack {
                HStack {
                    Text("LIKE")
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .foregroundStyle(.green)
                        .overlay(
                            Text("LIKE")
                                .font(.system(size: 48, weight: .black, design: .rounded))
                                .foregroundStyle(.white)
                                .opacity(0.5)
                                .blur(radius: 4)
                        )
                        .rotationEffect(.degrees(-15))
                        .scaleEffect(likeScale)
                        .opacity(likeOpacity)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: likeOpacity)
                        .padding(.leading, 40)
                        .padding(.top, 40)
                    Spacer()
                }
                Spacer()
            }
            
            // NOPE overlay (left swipe)
            VStack {
                HStack {
                    Spacer()
                    Text("NOPE")
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .foregroundStyle(.red)
                        .overlay(
                            Text("NOPE")
                                .font(.system(size: 48, weight: .black, design: .rounded))
                                .foregroundStyle(.white)
                                .opacity(0.5)
                                .blur(radius: 4)
                        )
                        .rotationEffect(.degrees(15))
                        .scaleEffect(nopeScale)
                        .opacity(nopeOpacity)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: nopeOpacity)
                        .padding(.trailing, 40)
                        .padding(.top, 40)
                }
                Spacer()
            }
        }
    }
}

// MARK: - Preview Support

#Preview("With Restaurants") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: FavoriteRestaurant.self, configurations: config)
    let context = container.mainContext
    
    // Create mock data
    let mockViewModel = TenderDeckViewModel(
        searchService: RestaurantSearchService(yelpService: YelpService(apiKey: "mock")),
        locationManager: LocationManager()
    )
    
    // Add mock tenders
    mockViewModel.tenders = [
        Tender(
            name: "Raising Cane's Chicken Fingers",
            restaurantType: "Fast Food",
            priceRange: "$",
            address: "123 Main St, San Francisco, CA",
            phoneNumber: "(555) 123-4567",
            websiteURL: URL(string: "https://example.com"),
            imageURL: URL(string: "https://s3-media0.fl.yelpcdn.com/bphoto/example1.jpg"),
            latitude: 37.7749,
            longitude: -122.4194
        ),
        Tender(
            name: "Popeyes Louisiana Kitchen",
            restaurantType: "Fast Food",
            priceRange: "$$",
            address: "456 Oak Ave, Los Angeles, CA",
            phoneNumber: "(555) 987-6543",
            websiteURL: URL(string: "https://example.com"),
            imageURL: URL(string: "https://s3-media0.fl.yelpcdn.com/bphoto/example2.jpg"),
            latitude: 34.0522,
            longitude: -118.2437
        )
    ]
    
    return SwipeDeckView(viewModel: mockViewModel, modelContext: context)
}

#Preview("Loading") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: FavoriteRestaurant.self, configurations: config)
    let context = container.mainContext
    
    let mockViewModel = TenderDeckViewModel(
        searchService: RestaurantSearchService(yelpService: YelpService(apiKey: "mock")),
        locationManager: LocationManager()
    )
    mockViewModel.isLoading = true
    
    return SwipeDeckView(viewModel: mockViewModel, modelContext: context)
}

#Preview("Empty State") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: FavoriteRestaurant.self, configurations: config)
    let context = container.mainContext
    
    let mockViewModel = TenderDeckViewModel(
        searchService: RestaurantSearchService(yelpService: YelpService(apiKey: "mock")),
        locationManager: LocationManager()
    )
    mockViewModel.tenders = []
    
    return SwipeDeckView(viewModel: mockViewModel, modelContext: context)
}

