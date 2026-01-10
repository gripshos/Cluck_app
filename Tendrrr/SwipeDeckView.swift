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
    let storeKitService: StoreKitService
    
    // Query for saved favorites
    @Query private var savedFavorites: [FavoriteRestaurant]
    
    @State private var dragAmount = CGSize.zero
    @State private var showDetail = false
    @State private var showSettings = false
    @State private var selectedTender: Tender?
    
    // Computed property to get saved restaurant names
    private var savedRestaurantNames: Set<String> {
        Set(savedFavorites.map { $0.name })
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient that extends to the top safe area
                LinearGradient(
                    colors: [
                        Color(red: 1.0, green: 0.3, blue: 0.2),
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
                    CluckHeader(
                        onRefresh: {
                            Task {
                                await viewModel.loadRestaurants(excluding: savedRestaurantNames)
                            }
                        },
                        onSettings: {
                            showSettings = true
                        }
                    )
                    
                    // Main Content with smooth transitions
                    ZStack {
                        // Loading State
                        if viewModel.isLoading {
                            loadingView
                                .transition(.opacity)
                        }
                        
                        // Error State
                        if let errorMessage = viewModel.errorMessage, !viewModel.isLoading {
                            errorView(message: errorMessage)
                                .transition(.opacity)
                        }
                        
                        // Empty State
                        if viewModel.tenders.isEmpty && !viewModel.isLoading && viewModel.errorMessage == nil {
                            emptyView
                                .transition(.opacity)
                        }
                        
                        // Cards - only show when we have data and not loading
                        if !viewModel.tenders.isEmpty && !viewModel.isLoading {
                            cardDeckView
                                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        }
                    }
                    .animation(.easeInOut(duration: 0.3), value: viewModel.isLoading)
                    .animation(.easeInOut(duration: 0.3), value: viewModel.tenders.isEmpty)
                    .animation(.easeInOut(duration: 0.3), value: viewModel.errorMessage != nil)
                }
            }
            .navigationBarHidden(true)
            .task {
                if viewModel.tenders.isEmpty && !viewModel.isLoading {
                    await viewModel.loadRestaurants(excluding: savedRestaurantNames)
                }
            }
            .sheet(isPresented: $showDetail) {
                if let selectedTender {
                    ChatDetailView(tender: selectedTender, modelContext: modelContext)
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(storeKitService: storeKitService)
            }
        }
    }
    
    // MARK: - Extracted Views for Clean Transitions
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.white)
            Text("Finding restaurants...")
                .font(.headline)
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func errorView(message: String) -> some View {
        ContentUnavailableView(
            "Unable to Find Restaurants",
            systemImage: "fork.knife.circle",
            description: Text(message)
        )
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyView: some View {
        ContentUnavailableView(
            "No Restaurants Found",
            systemImage: "fork.knife.circle",
            description: Text("Try adjusting your location or search radius")
        )
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var cardDeckView: some View {
        GeometryReader { geometry in
            ZStack {
                // Show up to 2 cards - the next card sits behind, pre-rendered but scaled down
                // Using prefix(2) and reversed() to stack them correctly (last one at bottom)
                ForEach(Array(viewModel.tenders.prefix(2).enumerated().reversed()), id: \.element.id) { index, tender in
                    let isTopCard = index == 0
                    
                    ZStack {
                        TenderCardView(tender: tender)
                        if isTopCard {
                            SwipeOverlayView(dragAmount: dragAmount)
                        }
                    }
                    .frame(
                        width: geometry.size.width - 40,
                        height: min(geometry.size.height * 0.7, 600)
                    )
                    .position(
                        x: geometry.size.width / 2 + (isTopCard ? dragAmount.width : 0),
                        y: geometry.size.height / 2 + (isTopCard ? dragAmount.height * 0.4 : 0)
                    )
                    .rotationEffect(.degrees(isTopCard ? Double(dragAmount.width / 20) : 0))
                    .scaleEffect(isTopCard ? 1.0 : 0.95)
                    .opacity(isTopCard ? 1.0 : 0.5)
                    .allowsHitTesting(isTopCard) // Only top card responds to gestures
                    .zIndex(isTopCard ? 1 : 0)
                    .id(tender.id) // Stable identity to prevent re-renders
                    .gesture(isTopCard ?
                        DragGesture()
                            .onChanged { gesture in
                                dragAmount = gesture.translation
                            }
                            .onEnded { gesture in
                                handleSwipe(gesture: gesture, tender: tender)
                            }
                        : nil
                    )
                    .onTapGesture {
                        if isTopCard {
                            selectedTender = tender
                            showDetail = true
                        }
                    }
                }
            }
        }
    }
    
    private func handleSwipe(gesture: DragGesture.Value, tender: Tender) {
        let threshold: CGFloat = 100
        
        if gesture.translation.width > threshold {
            // Swipe right - save
            withAnimation(.easeOut(duration: 0.3)) {
                dragAmount = CGSize(width: 500, height: 0)
            }
            
            // Delay the save and removal to let animation complete
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                saveTender(tender)
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    viewModel.removeTopCard()
                    dragAmount = .zero
                }
            }
        } else if gesture.translation.width < -threshold {
            // Swipe left - skip
            withAnimation(.easeOut(duration: 0.3)) {
                dragAmount = CGSize(width: -500, height: 0)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    viewModel.removeTopCard()
                    dragAmount = .zero
                }
            }
        } else {
            // Return to center
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                dragAmount = .zero
            }
        }
    }
    
    private func saveTender(_ tender: Tender) {
        let favorite = FavoriteRestaurant(from: tender)
        modelContext.insert(favorite)
        try? modelContext.save()
        
        // Remove from deck to prevent showing again
        viewModel.removeFromDeck(named: tender.name)
    }
}

// MARK: - CluckHeader

struct CluckHeader: View {
    let onRefresh: () -> Void
    let onSettings: () -> Void
    @State private var showTutorial = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Chicken emoji icon
            Text("🍗")
                .font(.system(size: 36))
                .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 1)
            
            // Styled app title
            Text("Cluck")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
            
            Spacer()
            
            // Settings button
            HeaderIconButton(systemImage: "gearshape.fill") {
                onSettings()
            }
            
            // Refresh button
            HeaderIconButton(systemImage: "arrow.clockwise") {
                onRefresh()
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .padding(.top, 8)
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

// MARK: - Component Definitions
// Moved here to ensure they are available in scope without project file modifications

struct HeaderIconButton: View {
    let systemImage: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white.opacity(0.9))
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(.white.opacity(0.15))
                )
        }
    }
}

struct HeaderTextButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(.white.opacity(0.15))
                )
        }
    }
}

