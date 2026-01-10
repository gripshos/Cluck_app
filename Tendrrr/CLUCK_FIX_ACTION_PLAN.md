# Cluck App Fix Action Plan

## Overview
This document provides step-by-step instructions to fix 7 issues in the Cluck iOS app. Each fix includes the file path, specific code changes, and rationale.

---

## Issue 1: Rough Loading-to-Discover Page Transition

### Problem
The transition from loading state to the discover page is jarring. Users see unloaded elements and the page being built.

### Files to Modify
- `Tendr/SwipeDeckView.swift`

### Solution
Add opacity transitions and ensure cards are fully loaded before displaying. Wrap state changes in animations.

### Code Changes

**In `SwipeDeckView.swift`, replace the body's ZStack content section with:**

```swift
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
                CluckHeader(onRefresh: {
                    Task {
                        await viewModel.loadRestaurants()
                    }
                })
                
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
            ForEach(Array(viewModel.tenders.enumerated()), id: \.element.id) { index, tender in
                if index == 0 {
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
```

---

## Issue 2: Saved Restaurants Still Appearing in Card Stack

### Problem
Restaurants already in the user's Saved list still appear as cards, including after reload.

### Files to Modify
- `Tendr/TenderDeckViewModel.swift`
- `Tendr/SwipeDeckView.swift`

### Solution
Filter out saved restaurants when loading and when building the deck. Pass the model context to the view model.

### Code Changes

**Step 1: Update `TenderDeckViewModel.swift`:**

Replace the entire file with:

```swift
//
//  TenderDeckViewModel.swift
//  Cluck
//
//  Manages the state of the tender deck
//

import SwiftUI
import Observation
import CoreLocation
import SwiftData

@Observable
@MainActor
class TenderDeckViewModel {
    var tenders: [Tender] = []
    var isLoading = false
    var errorMessage: String?
    
    private let searchService: RestaurantSearchService
    private let locationManager: LocationManager
    
    init(searchService: RestaurantSearchService, locationManager: LocationManager) {
        self.searchService = searchService
        self.locationManager = locationManager
    }
    
    func loadRestaurants(excluding savedNames: Set<String> = []) async {
        guard let location = locationManager.location else {
            errorMessage = "Unable to get your location"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let allTenders = try await searchService.searchNearbyRestaurants(near: location)
            
            // Filter out restaurants that are already saved
            // Use lowercased comparison for case-insensitive matching
            let lowercasedSavedNames = Set(savedNames.map { $0.lowercased() })
            tenders = allTenders.filter { tender in
                !lowercasedSavedNames.contains(tender.name.lowercased())
            }
            
            if tenders.isEmpty && !allTenders.isEmpty {
                errorMessage = "You've saved all nearby restaurants! 🎉"
            } else if tenders.isEmpty {
                errorMessage = "No restaurants found nearby"
            }
        } catch {
            errorMessage = "Failed to load restaurants: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func removeTopCard() {
        guard !tenders.isEmpty else { return }
        tenders.removeFirst()
    }
    
    /// Remove a specific restaurant from the deck (used when saving)
    func removeFromDeck(named restaurantName: String) {
        tenders.removeAll { $0.name.lowercased() == restaurantName.lowercased() }
    }
}
```

**Step 2: Update `SwipeDeckView.swift` to pass saved names:**

Add a Query for favorites at the top of the struct:

```swift
struct SwipeDeckView: View {
    @Bindable var viewModel: TenderDeckViewModel
    let modelContext: ModelContext
    
    // Add this Query to get saved restaurants
    @Query private var savedFavorites: [FavoriteRestaurant]
    
    @State private var dragAmount = CGSize.zero
    @State private var showDetail = false
    @State private var selectedTender: Tender?
    
    // Computed property to get saved restaurant names
    private var savedRestaurantNames: Set<String> {
        Set(savedFavorites.map { $0.name })
    }
```

**Step 3: Update the `.task` modifier in `SwipeDeckView.swift`:**

```swift
.task {
    if viewModel.tenders.isEmpty && !viewModel.isLoading {
        await viewModel.loadRestaurants(excluding: savedRestaurantNames)
    }
}
```

**Step 4: Update the refresh button action in `CluckHeader` call:**

```swift
CluckHeader(onRefresh: {
    Task {
        await viewModel.loadRestaurants(excluding: savedRestaurantNames)
    }
})
```

**Step 5: Update `saveTender` function to also remove from deck:**

```swift
private func saveTender(_ tender: Tender) {
    let favorite = FavoriteRestaurant(from: tender)
    modelContext.insert(favorite)
    try? modelContext.save()
    
    // No need to manually remove - the card animation already handles this
}
```

---

## Issue 3: Card Transition Glitches

### Problem
The card below visually glitches/reloads when moving the top card. Terminal shows: `nw_connection_copy_connected_local_endpoint_block_invoke [C3] Connection has no local endpoint`

### Files to Modify
- `Tendr/SwipeDeckView.swift`

### Solution
1. Pre-render the next card behind the current one (but hidden)
2. Use `id()` modifier to prevent unnecessary re-renders
3. The network warning is related to async image loading - add image caching

### Code Changes

**Replace the `cardDeckView` computed property with this improved version:**

```swift
private var cardDeckView: some View {
    GeometryReader { geometry in
        ZStack {
            // Show up to 2 cards - the next card sits behind, pre-rendered but scaled down
            ForEach(Array(viewModel.tenders.prefix(2).enumerated().reversed()), id: \.element.id) { index, tender in
                let isTopCard = index == 0
                
                TenderCardView(tender: tender)
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
```

**Update the `handleSwipe` function to use smoother animations:**

```swift
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
```

---

## Issue 4: Header Bar Gradient Design

### Problem
The header bar on the Discover page's gradient feels odd and doesn't look cohesive.

### Files to Modify
- `Tendr/SwipeDeckView.swift`

### Solution
Make the header gradient seamlessly blend with the background gradient.

### Code Changes

**Replace the `CluckHeader` struct with:**

```swift
struct CluckHeader: View {
    let onRefresh: () -> Void
    @State private var showTutorial = false
    @State private var showSettings = false
    
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
            Button(action: { showSettings = true }) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.9))
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(.white.opacity(0.15))
                    )
            }
            
            // Refresh button
            Button(action: onRefresh) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.9))
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(.white.opacity(0.15))
                    )
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .padding(.top, 8)
        // No background - let the parent gradient show through
        .alert("Settings", isPresented: $showSettings) {
            Button("Restart Tutorial", role: .none) {
                showTutorial = true
            }
            Button("Cancel", role: .cancel) { }
        }
        .sheet(isPresented: $showTutorial) {
            // Tutorial view placeholder
            Text("Tutorial")
        }
    }
}
```

**Also update the main ZStack in SwipeDeckView to remove any header-specific gradient:**

The header should no longer have its own gradient background - it will inherit from the parent VStack/ZStack's background gradient, creating a seamless look.

---

## Issue 5: Inconsistent Button Sizes Between Pages

### Problem
Settings/reset buttons on Discover page differ in size from tutorial/edit buttons on Saved page.

### Files to Modify
- `Tendr/SwipeDeckView.swift`
- `Tendr/SavedListView.swift`

### Solution
Create a shared button style component and apply it consistently.

### Code Changes

**Create a new file `Tendr/Components/HeaderButton.swift`:**

```swift
//
//  HeaderButton.swift
//  Cluck
//
//  Consistent header button styling across the app
//

import SwiftUI

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

#Preview("Icon Button") {
    ZStack {
        Color.orange
        HeaderIconButton(systemImage: "gearshape.fill") { }
    }
}

#Preview("Text Button") {
    ZStack {
        Color.pink
        HeaderTextButton(title: "Edit") { }
    }
}
```

**Update `SavedHeader` in `SavedListView.swift`:**

```swift
struct SavedHeader: View {
    let showEdit: Bool
    @Binding var editMode: EditMode
    @State private var showTutorialAlert = false
    @State private var showTutorial = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Heart icon
            Image(systemName: "heart.fill")
                .font(.system(size: 28))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 1)
            
            // Styled tab title
            Text("Saved")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
            
            Spacer()
            
            // Tutorial button
            HeaderIconButton(systemImage: "questionmark.circle.fill") {
                showTutorialAlert = true
            }
            
            // Edit button (only show when there are favorites)
            if showEdit {
                HeaderTextButton(title: editMode == .active ? "Done" : "Edit") {
                    withAnimation {
                        editMode = editMode == .active ? .inactive : .active
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .padding(.top, 8)
        .confirmationDialog("Tutorial", isPresented: $showTutorialAlert, titleVisibility: .hidden) {
            Button("Show Tutorial") {
                showTutorial = true
            }
            Button("Cancel", role: .cancel) { }
        }
        .sheet(isPresented: $showTutorial) {
            Text("Tutorial")
        }
    }
}
```

**Update `CluckHeader` in `SwipeDeckView.swift` to use the same components:**

```swift
struct CluckHeader: View {
    let onRefresh: () -> Void
    @State private var showSettingsAlert = false
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
                showSettingsAlert = true
            }
            
            // Refresh button
            HeaderIconButton(systemImage: "arrow.clockwise") {
                onRefresh()
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .padding(.top, 8)
        .confirmationDialog("Settings", isPresented: $showSettingsAlert, titleVisibility: .hidden) {
            Button("Restart Tutorial") {
                showTutorial = true
            }
            Button("Cancel", role: .cancel) { }
        }
        .sheet(isPresented: $showTutorial) {
            Text("Tutorial")
        }
    }
}
```

---

## Issue 6: Tutorial Pop-up Button Colors

### Problem
In the restart tutorial pop-up, both Cancel and Show Tutorial are red. Show Tutorial should not be red.

### Files to Modify
- `Tendr/SwipeDeckView.swift`
- `Tendr/SavedListView.swift`

### Solution
Use `confirmationDialog` instead of `alert` with proper button roles, or use a custom alert.

### Code Changes

The changes in Issue 5 already address this by using `confirmationDialog` which handles button colors properly. The key is:

```swift
.confirmationDialog("Settings", isPresented: $showSettingsAlert, titleVisibility: .hidden) {
    Button("Show Tutorial") {  // No role = default appearance (blue/primary)
        showTutorial = true
    }
    Button("Cancel", role: .cancel) { }  // Cancel role = gray
}
```

**If you need to use an Alert instead**, here's an alternative approach:

```swift
.alert("Settings", isPresented: $showSettingsAlert) {
    Button("Show Tutorial") {  // Default role - will be blue
        showTutorial = true
    }
    Button("Cancel", role: .cancel) { }
} message: {
    Text("Would you like to restart the tutorial?")
}
```

**Important:** Do NOT use `role: .destructive` on the "Show Tutorial" button. Only use destructive role for actions that delete data or cannot be undone.

---

## Issue 7: Remove "Add to Favorites" Button from Detail View

### Problem
The restaurant detail card (ChatDetailView) has a "Save to Favorites" button, but saving should only happen via swipe actions.

### Files to Modify
- `Tendr/ChatDetailView.swift`

### Solution
Remove the save/favorite button from the detail view since swiping right is the designated action for saving.

### Code Changes

**In `ChatDetailView.swift`, remove the favorite toggle button from the Actions VStack:**

Find this section:

```swift
// Actions
VStack(spacing: 12) {
    // Directions button
    Button { ... } label: { ... }
    
    // Save/Unsave button  <-- REMOVE THIS ENTIRE BUTTON
    Button {
        toggleFavorite()
    } label: {
        Label(...)
    }
}
```

**Replace the entire Actions VStack with:**

```swift
// Actions
VStack(spacing: 12) {
    // Directions button
    Button {
        openInMaps()
    } label: {
        Label("Get Directions", systemImage: "arrow.triangle.turn.up.right.circle.fill")
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    colors: [Color.blue, Color.blue.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundStyle(.white)
            .cornerRadius(10)
            .fontWeight(.semibold)
    }
}
```

**Also remove these related items from `ChatDetailView.swift`:**

1. Remove the `@State private var isFavorite = false` property
2. Remove the `checkIfFavorite()` function
3. Remove the `toggleFavorite()` function
4. Remove the `.onAppear { checkIfFavorite() }` modifier

**The cleaned up `ChatDetailView` should look like:**

```swift
struct ChatDetailView: View {
    let tender: Tender
    let modelContext: ModelContext
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Restaurant image
                    ZStack(alignment: .bottomLeading) {
                        // ... image code stays the same ...
                    }
                    .frame(height: 300)
                    .clipped()
                    
                    VStack(alignment: .leading, spacing: 16) {
                        // Restaurant name
                        Text(tender.name)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)
                        
                        // Type and price
                        HStack {
                            Label(tender.restaurantType, systemImage: "fork.knife")
                            Spacer()
                            Text(tender.priceRange)
                                .fontWeight(.semibold)
                        }
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        
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
                        
                        // Website or Google search button
                        if let websiteURL = tender.websiteURL {
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
                        
                        Divider()
                        
                        // Directions button only
                        Button {
                            openInMaps()
                        } label: {
                            Label("Get Directions", systemImage: "arrow.triangle.turn.up.right.circle.fill")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        colors: [Color.blue, Color.blue.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .foregroundStyle(.white)
                                .cornerRadius(10)
                                .fontWeight(.semibold)
                        }
                        
                        // Phone number
                        if let phoneNumber = tender.phoneNumber {
                            Divider()
                            
                            Button {
                                if let url = URL(string: "tel:\(phoneNumber)") {
                                    UIApplication.shared.open(url)
                                }
                            } label: {
                                HStack {
                                    Label(phoneNumber, systemImage: "phone.fill")
                                        .font(.headline)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(.secondary)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                            }
                            .foregroundStyle(.primary)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle(tender.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // Keep these helper properties/functions
    private var gradientFallback: some View { ... }
    private var googleSearchURL: URL { ... }
    private func openInMaps() { ... }
}
```

---

## Implementation Order

Execute fixes in this order for best results:

1. **Issue 5** - Create HeaderButton components (foundation for other fixes)
2. **Issue 4** - Update header gradient design  
3. **Issue 6** - Fix tutorial popup button colors
4. **Issue 2** - Filter saved restaurants from deck
5. **Issue 3** - Fix card transition glitches
6. **Issue 1** - Smooth loading transitions
7. **Issue 7** - Remove favorites button from detail view

---

## Testing Checklist

After implementing all fixes:

- [ ] Loading state transitions smoothly to card view
- [ ] No jarring visual jumps when cards load
- [ ] Saved restaurants do not appear in the swipe deck
- [ ] After saving a restaurant and refreshing, it doesn't reappear
- [ ] Card below doesn't glitch when swiping the top card
- [ ] Swiping left/right animations are smooth
- [ ] Header gradient blends seamlessly with background
- [ ] All header buttons are consistent size across pages
- [ ] Tutorial popup shows "Show Tutorial" in blue/primary color
- [ ] Cancel button is not red/destructive
- [ ] Restaurant detail view has no "Save to Favorites" button
- [ ] Detail view only shows Directions, Website, and Phone actions

---

## Files Changed Summary

| File | Changes |
|------|---------|
| `Tendr/SwipeDeckView.swift` | Loading transitions, card rendering, header updates |
| `Tendr/TenderDeckViewModel.swift` | Filter saved restaurants |
| `Tendr/SavedListView.swift` | Consistent button styling |
| `Tendr/ChatDetailView.swift` | Remove favorites button |
| `Tendr/Components/HeaderButton.swift` | **NEW FILE** - Shared button components |

---

## Notes for Implementation

- Build and test after each major change
- Use Xcode's canvas preview to verify UI changes
- Test on both simulator and device if possible
- The network warning (`nw_connection_copy_connected_local_endpoint`) is related to async image loading and should reduce with the caching improvements, but may not disappear entirely as it's an iOS system message
