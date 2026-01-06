//
//  SwipeDeckView.swift
//  Tendr
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
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if viewModel.isLoading {
                    ProgressView("Finding restaurants...")
                } else if let errorMessage = viewModel.errorMessage {
                    ContentUnavailableView(
                        "Unable to Find Restaurants",
                        systemImage: "fork.knife.circle",
                        description: Text(errorMessage)
                    )
                } else if viewModel.tenders.isEmpty {
                    ContentUnavailableView(
                        "No Restaurants Found",
                        systemImage: "fork.knife.circle",
                        description: Text("Try adjusting your location or search radius")
                    )
                } else {
                    // Card deck
                    ZStack {
                        ForEach(Array(viewModel.tenders.enumerated()), id: \.element.id) { index, tender in
                            if index == 0 {
                                // Only show the top card
                                TenderCardView(tender: tender)
                                    .offset(x: dragAmount.width, y: dragAmount.height * 0.4)
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
                    .padding()
                }
            }
            .navigationTitle("Tendr")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            await viewModel.loadRestaurants()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
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
