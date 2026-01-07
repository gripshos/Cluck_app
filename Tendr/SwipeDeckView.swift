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
    @State private var showDetail = false
    @State private var selectedTender: Tender?
    
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
                        VStack(spacing: 20) {
                            ProgressView()
                                .scaleEffect(1.5)
                                .tint(.white)
                            Text("Finding restaurants...")
                                .font(.headline)
                                .foregroundStyle(.white)
                        }
                    } else if let errorMessage = viewModel.errorMessage {
                        ContentUnavailableView(
                            "Unable to Find Restaurants",
                            systemImage: "fork.knife.circle",
                            description: Text(errorMessage)
                        )
                        .foregroundStyle(.white)
                    } else if viewModel.tenders.isEmpty {
                        ContentUnavailableView(
                            "No Restaurants Found",
                            systemImage: "fork.knife.circle",
                            description: Text("Try adjusting your location or search radius")
                        )
                        .foregroundStyle(.white)
                    } else {
                        // Card deck with proper sizing
                        GeometryReader { geometry in
                            ZStack {
                                ForEach(Array(viewModel.tenders.enumerated()), id: \.element.id) { index, tender in
                                    if index == 0 {
                                        // Only show the top card
                                        TenderCardView(tender: tender)
                                            .frame(
                                                width: geometry.size.width - 40,
                                                height: min(geometry.size.height * 0.7, 600)
                                            )
                                            .position(
                                                x: geometry.size.width / 2 + dragAmount.width,
                                                y: geometry.size.height / 2 + dragAmount.height * 0.4
                                            )
                                            .rotationEffect(.degrees(Double(dragAmount.width / 20)))
                                            .gesture(
                                                DragGesture()
                                                    .onChanged { gesture in
                                                        dragAmount = gesture.translation
                                                    }
                                                    .onEnded { gesture in
                                                        handleSwipe(gesture: gesture, tender: tender)
                                                    }
                                            )
                                            .onTapGesture {
                                                selectedTender = tender
                                                showDetail = true
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
            .sheet(isPresented: $showDetail) {
                if let selectedTender {
                    ChatDetailView(tender: selectedTender, modelContext: modelContext)
                }
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
            } else if gesture.translation.width < -threshold {
                // Swipe left - skip
                dragAmount = CGSize(width: -500, height: 0)
            } else {
                // Return to center
                dragAmount = .zero
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
                // App logo
                Image("tenderIcon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
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

