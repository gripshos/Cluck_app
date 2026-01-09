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
    
    @State private var dragAmount = CGSize.zero
    @State private var selectedTender: Tender?
    @State private var hasTriggeredHaptic = false
    @State private var showSettings = false
    
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
                    // Custom Header with Logo and Title (hide when loading)
                    if !viewModel.isLoading {
                        CluckHeader(
                            onRefresh: {
                                Task {
                                    await viewModel.loadRestaurants()
                                }
                            },
                            onSettings: {
                                showSettings = true
                            }
                        )
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    // Main Content
                    ZStack {
                    
                    if viewModel.isLoading {
                        EmptyStateView.searching
                    } else if let errorMessage = viewModel.errorMessage {
                        if errorMessage.contains("location") {
                            EmptyStateView.locationDenied
                        } else if errorMessage.contains("already in your saved list") {
                            // All restaurants are already saved
                            VStack(spacing: 20) {
                                Text("🎉")
                                    .font(.system(size: 80))
                                Text("All Done!")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                                Text("You've saved all nearby restaurants.\nCheck your Saved list or try again later!")
                                    .font(.body)
                                    .foregroundStyle(.white.opacity(0.9))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)
                                
                                Button {
                                    Task {
                                        await viewModel.loadRestaurants()
                                    }
                                } label: {
                                    Text("Refresh")
                                        .font(.headline)
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 30)
                                        .padding(.vertical, 12)
                                        .background(
                                            Capsule()
                                                .fill(.white.opacity(0.25))
                                        )
                                }
                            }
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
                                    cardView(for: tender, at: index, in: geometry)
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
            .sheet(isPresented: $showSettings) {
                SettingsView(storeKitService: storeKitService)
            }
        }
    }
    
    @ViewBuilder
    private func cardView(for tender: Tender, at index: Int, in geometry: GeometryProxy) -> some View {
        let cardContent = ZStack {
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
        .onTapGesture {
            if index == 0 {
                selectedTender = tender
            }
        }
        
        if index == 0 {
            cardContent
                .gesture(
                    DragGesture()
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
                        }
                )
        } else {
            cardContent
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
        // Check if already saved to prevent duplicates
        let descriptor = FetchDescriptor<FavoriteRestaurant>(
            predicate: #Predicate { $0.id == tender.id }
        )
        
        do {
            let existing = try modelContext.fetch(descriptor)
            
            if existing.isEmpty {
                // Only save if not already in favorites
                let favorite = FavoriteRestaurant(from: tender)
                modelContext.insert(favorite)
                try modelContext.save()
                print("✅ Saved: \(tender.name)")
            } else {
                // Already exists, skip saving
                print("ℹ️ Already saved: \(tender.name)")
            }
        } catch {
            print("❌ Error checking/saving favorite: \(error)")
        }
    }
}

// MARK: - Custom Header Component

struct CluckHeader: View {
    let onRefresh: () -> Void
    let onSettings: () -> Void
    
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
                
                // Settings button
                Button(action: onSettings) {
                    Image(systemName: "gearshape.fill")
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




