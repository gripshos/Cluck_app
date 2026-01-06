//
//  ContentView.swift
//  Tendr
//
//  Created by Steven Gripshover on 12/11/20.
//  Copyright © 2020 Steven Gripshover. All rights reserved.
//

import SwiftUI
import CoreLocation
import MapKit
import Observation

// MARK: - Models
struct Tender: Identifiable, Equatable, Hashable {
    static func == (lhs: Tender, rhs: Tender) -> Bool {
        lhs.id == rhs.id
    }

    let id: UUID
    let name: String
    let restaurant: String
    let address: String
    let price: String
    let imageName: String? // using asset names for mock images
    let imageURL: URL? // URL for restaurant photo from MapKit
    let coordinate: CLLocationCoordinate2D
    let phoneNumber: String?
    let url: URL? // Restaurant website

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Location Manager
@Observable
final class LocationManager: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private(set) var userLocation: CLLocation?
    private(set) var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocation() {
        manager.requestWhenInUseAuthorization()
        manager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.first
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }
}

// MARK: - Restaurant Search Service
actor RestaurantSearchService {
    func searchNearbyRestaurants(near location: CLLocation, query: String = "chicken tenders") async throws -> [Tender] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: 5000, // 5km radius
            longitudinalMeters: 5000
        )
        
        // Request point of interest data
        request.resultTypes = [.pointOfInterest]
        
        let search = MKLocalSearch(request: request)
        
        do {
            let response = try await search.start()
            
            // Convert MKMapItems to Tender models with enhanced data
            var tenders: [Tender] = []
            
            for mapItem in response.mapItems {
                guard let name = mapItem.name,
                      let coordinate = mapItem.placemark.location?.coordinate else {
                    continue
                }
                
                // Extract address
                let address = [
                    mapItem.placemark.thoroughfare,
                    mapItem.placemark.locality,
                    mapItem.placemark.administrativeArea
                ]
                .compactMap { $0 }
                .joined(separator: ", ")
                
                // Try to get real price category from MapKit
                let price: String
                if #available(iOS 16.0, *) {
                    // MapKit may provide price range for some POIs
                    // For now, we'll estimate based on category
                    if let category = mapItem.pointOfInterestCategory {
                        price = priceForCategory(category)
                    } else {
                        price = "$$" // Default moderate pricing
                    }
                } else {
                    price = "$$"
                }
                
                // Fetch restaurant image using Look Around if available
                let imageURL = await fetchRestaurantImageURL(for: mapItem)
                
                let tender = Tender(
                    id: UUID(),
                    name: name,
                    restaurant: mapItem.placemark.name ?? name,
                    address: address.isEmpty ? "Address not available" : address,
                    price: price,
                    imageName: nil, // We'll use imageURL or fallback
                    imageURL: imageURL,
                    coordinate: coordinate,
                    phoneNumber: mapItem.phoneNumber,
                    url: mapItem.url
                )
                
                tenders.append(tender)
            }
            
            // If MapKit returns results, use them
            if !tenders.isEmpty {
                return tenders
            }
        } catch {
            print("MapKit search failed: \(error.localizedDescription)")
        }
        
        // Fallback to mock data for testing if MapKit returns nothing or fails
        return generateMockRestaurants(near: location)
    }
    
    // Generate mock restaurants for testing
    private func generateMockRestaurants(near location: CLLocation) -> [Tender] {
        var tenders: [Tender] = []
        
        // Restaurant 1
        let lat1 = location.coordinate.latitude + Double.random(in: -0.02...0.02)
        let lon1 = location.coordinate.longitude + Double.random(in: -0.02...0.02)
        tenders.append(Tender(
            id: UUID(),
            name: "Chicken Tenders",
            restaurant: "The Crispy Chicken Co.",
            address: "123 Main St",
            price: "$",
            imageName: nil,
            imageURL: nil,
            coordinate: CLLocationCoordinate2D(latitude: lat1, longitude: lon1),
            phoneNumber: "555-0100",
            url: URL(string: "https://example.com")
        ))
        
        // Restaurant 2
        let lat2 = location.coordinate.latitude + Double.random(in: -0.02...0.02)
        let lon2 = location.coordinate.longitude + Double.random(in: -0.02...0.02)
        tenders.append(Tender(
            id: UUID(),
            name: "Chicken Tenders",
            restaurant: "Tender Spot",
            address: "456 Oak Ave",
            price: "$$",
            imageName: nil,
            imageURL: nil,
            coordinate: CLLocationCoordinate2D(latitude: lat2, longitude: lon2),
            phoneNumber: "555-0101",
            url: URL(string: "https://example.com")
        ))
        
        // Restaurant 3
        let lat3 = location.coordinate.latitude + Double.random(in: -0.02...0.02)
        let lon3 = location.coordinate.longitude + Double.random(in: -0.02...0.02)
        tenders.append(Tender(
            id: UUID(),
            name: "Chicken Tenders",
            restaurant: "Golden Bites",
            address: "789 Pine St",
            price: "$$$",
            imageName: nil,
            imageURL: nil,
            coordinate: CLLocationCoordinate2D(latitude: lat3, longitude: lon3),
            phoneNumber: "555-0102",
            url: URL(string: "https://example.com")
        ))
        
        // Restaurant 4
        let lat4 = location.coordinate.latitude + Double.random(in: -0.02...0.02)
        let lon4 = location.coordinate.longitude + Double.random(in: -0.02...0.02)
        tenders.append(Tender(
            id: UUID(),
            name: "Chicken Tenders",
            restaurant: "Cluckin' Good",
            address: "321 Elm St",
            price: "$ - $$",
            imageName: nil,
            imageURL: nil,
            coordinate: CLLocationCoordinate2D(latitude: lat4, longitude: lon4),
            phoneNumber: "555-0103",
            url: URL(string: "https://example.com")
        ))
        
        // Restaurant 5
        let lat5 = location.coordinate.latitude + Double.random(in: -0.02...0.02)
        let lon5 = location.coordinate.longitude + Double.random(in: -0.02...0.02)
        tenders.append(Tender(
            id: UUID(),
            name: "Chicken Tenders",
            restaurant: "The Tender House",
            address: "654 Maple Dr",
            price: "$$",
            imageName: nil,
            imageURL: nil,
            coordinate: CLLocationCoordinate2D(latitude: lat5, longitude: lon5),
            phoneNumber: "555-0104",
            url: URL(string: "https://example.com")
        ))
        
        // Restaurant 6
        let lat6 = location.coordinate.latitude + Double.random(in: -0.02...0.02)
        let lon6 = location.coordinate.longitude + Double.random(in: -0.02...0.02)
        tenders.append(Tender(
            id: UUID(),
            name: "Chicken Tenders",
            restaurant: "Crispy Delights",
            address: "987 Cedar Ln",
            price: "$",
            imageName: nil,
            imageURL: nil,
            coordinate: CLLocationCoordinate2D(latitude: lat6, longitude: lon6),
            phoneNumber: "555-0105",
            url: URL(string: "https://example.com")
        ))
        
        return tenders
    }
    
    // Helper to determine price range based on category
    private func priceForCategory(_ category: MKPointOfInterestCategory) -> String {
        switch category {
        case .restaurant:
            return "$$ - $$$"
        case .foodMarket:
            return "$"
        case .cafe, .bakery:
            return "$ - $$"
        default:
            return "$$"
        }
    }
    
    // Attempt to fetch a representative image URL for the restaurant
    // Note: MapKit doesn't directly provide restaurant photos, but we can check
    // if Look Around imagery is available for visual context
    private func fetchRestaurantImageURL(for mapItem: MKMapItem) async -> URL? {
        // Check if Look Around is available at this location
        guard let location = mapItem.placemark.location else { return nil }
        
        let request = MKLookAroundSceneRequest(coordinate: location.coordinate)
        
        do {
            if (try await request.scene) != nil {
                // Look Around is available - we could potentially use this
                // For now, return nil since we can't extract static images easily
                // In a production app, you might integrate with Yelp/Google for photos
                return nil
            }
        } catch {
            // Look Around not available
        }
        
        return nil
    }
}

// MARK: - ViewModel
@Observable
final class TenderDeckViewModel {
    private(set) var deck: [Tender] = []
    private(set) var saved: [Tender] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    
    private let searchService = RestaurantSearchService()
    
    func loadRestaurants(near location: CLLocation) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let restaurants = try await searchService.searchNearbyRestaurants(near: location)
            deck = restaurants.isEmpty ? [] : restaurants
            
            if restaurants.isEmpty {
                errorMessage = "No restaurants found nearby"
            }
        } catch {
            errorMessage = "Failed to load restaurants: \(error.localizedDescription)"
            print("Search error: \(error)")
        }
        
        isLoading = false
    }

    func swipeLeft() {
        guard !deck.isEmpty else { return }
        deck.removeFirst()
    }

    func swipeRight() {
        guard !deck.isEmpty else { return }
        let liked = deck.removeFirst()
        if !saved.contains(liked) {
            saved.append(liked)
        }
    }

    func reset(location: CLLocation) async {
        await loadRestaurants(near: location)
    }
}

// MARK: - Swipe Card
struct TenderCardView: View {
    let tender: Tender
    @State private var loadedImage: UIImage?
    @State private var isLoadingImage = false

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomLeading) {
                // Background Image - full bleed
                Group {
                    if let loadedImage = loadedImage {
                        // Display loaded remote image
                        Image(uiImage: loadedImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .clipped()
                    } else if let imageName = tender.imageName {
                        // Display local asset image
                        Image(imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .clipped()
                    } else {
                        // Fallback: elegant gradient with food icon
                        ZStack {
                            LinearGradient(
                                colors: [
                                    Color.orange.opacity(0.3),
                                    Color.red.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            
                            Image(systemName: "fork.knife")
                                .font(.system(size: 120))
                                .foregroundStyle(.white.opacity(0.3))
                        }
                        .frame(width: geometry.size.width, height: geometry.size.height)
                    }
                }
                
                // Gradient for text legibility
                LinearGradient(
                    stops: [
                        .init(color: .clear, location: 0.5),
                        .init(color: .black.opacity(0.6), location: 0.8),
                        .init(color: .black.opacity(0.95), location: 1.0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                // Restaurant info at bottom
                VStack(alignment: .leading, spacing: 6) {
                    Text(tender.name)
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.leading)
                    
                    Text("\(tender.restaurant) • \(tender.price)")
                        .font(.title3.weight(.medium))
                        .foregroundStyle(.white.opacity(0.95))
                    
                    if !tender.address.isEmpty && tender.address != "Address not available" {
                        Label(tender.address, systemImage: "mappin.circle.fill")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.85))
                            .lineLimit(1)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 140) // Space for floating buttons
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .task {
            // Load image from URL if available
            if let imageURL = tender.imageURL, loadedImage == nil {
                await loadImage(from: imageURL)
            }
        }
    }
    
    private func loadImage(from url: URL) async {
        isLoadingImage = true
        defer { isLoadingImage = false }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                await MainActor.run {
                    loadedImage = image
                }
            }
        } catch {
            print("Failed to load image: \(error)")
        }
    }
}

// MARK: - Deck with gestures
struct SwipeDeckView: View {
    @Bindable var viewModel: TenderDeckViewModel
    let locationManager: LocationManager
    @State private var dragOffset: CGSize = .zero
    private let swipeThreshold: CGFloat = 100

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if viewModel.isLoading {
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Finding restaurants nearby...")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = viewModel.errorMessage {
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 64))
                            .foregroundStyle(.orange)
                        Text(error)
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        if let location = locationManager.userLocation {
                            Button("Try Again") {
                                Task {
                                    await viewModel.reset(location: location)
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.orange)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.deck.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "fork.knife.circle")
                            .font(.system(size: 64))
                            .foregroundStyle(.secondary)
                        Text("No more restaurants nearby")
                            .font(.headline)
                        
                        if let location = locationManager.userLocation {
                            Button("Search Again") {
                                Task {
                                    await viewModel.reset(location: location)
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.orange)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Only show the top card - no stacking visible
                    ForEach(Array(viewModel.deck.prefix(1).enumerated()), id: \.element.id) { _, tender in
                        TenderCardView(tender: tender)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .offset(dragOffset)
                            .rotationEffect(.degrees(Double(dragOffset.width / 20)))
                            .gesture(dragGesture())
                    }
                }
            }
        }
    }

    private func dragGesture() -> some Gesture {
        DragGesture()
            .onChanged { value in
                dragOffset = value.translation
            }
            .onEnded { value in
                let dx = value.translation.width
                let velocity = value.predictedEndTranslation.width
                
                if dx > swipeThreshold || velocity > swipeThreshold * 2 {
                    swipe(to: .right)
                } else if dx < -swipeThreshold || velocity < -swipeThreshold * 2 {
                    swipe(to: .left)
                } else {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                        dragOffset = .zero
                    }
                }
            }
    }
    
    private func swipe(to direction: SwipeDirection) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            // Push card way off screen
            dragOffset = CGSize(width: direction == .right ? 1000 : -1000, height: 0)
        } completion: {
            if direction == .right {
                viewModel.swipeRight()
            } else {
                viewModel.swipeLeft()
            }
            dragOffset = .zero
        }
    }
    
    enum SwipeDirection { case left, right }
}

// MARK: - Saved List and Chat Detail
struct SavedListView: View {
    @Bindable var viewModel: TenderDeckViewModel

    var body: some View {
        Group {
            if viewModel.saved.isEmpty {
                ContentUnavailableView(
                    "No Saved Restaurants",
                    systemImage: "bookmark.slash",
                    description: Text("Restaurants you like will appear here")
                )
            } else {
                List(viewModel.saved) { tender in
                    NavigationLink(value: tender) {
                        HStack(spacing: 16) {
                            // Use the same image loading logic
                            Group {
                                if let imageName = tender.imageName {
                                    Image(imageName)
                                        .resizable()
                                        .scaledToFill()
                                } else {
                                    // Fallback with icon
                                    ZStack {
                                        Color.orange.opacity(0.2)
                                        Image(systemName: "fork.knife")
                                            .foregroundStyle(.orange.opacity(0.5))
                                    }
                                }
                            }
                            .frame(width: 70, height: 70)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(tender.name).font(.headline)
                                Text(tender.restaurant)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Text(tender.price)
                                    .font(.caption.bold())
                                    .foregroundStyle(.orange)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .navigationDestination(for: Tender.self) { tender in
            ChatDetailView(tender: tender)
        }
        .navigationTitle("Saved")
    }
}

struct ChatDetailView: View {
    let tender: Tender
    @State private var loadedImage: UIImage?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Restaurant image with better fallback
                Group {
                    if let loadedImage = loadedImage {
                        Image(uiImage: loadedImage)
                            .resizable()
                            .scaledToFill()
                    } else if let imageName = tender.imageName {
                        Image(imageName)
                            .resizable()
                            .scaledToFill()
                    } else {
                        ZStack {
                            LinearGradient(
                                colors: [Color.orange.opacity(0.3), Color.red.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            Image(systemName: "fork.knife")
                                .font(.system(size: 80))
                                .foregroundStyle(.white.opacity(0.4))
                        }
                    }
                }
                .frame(height: 250)
                .clipShape(RoundedRectangle(cornerRadius: 20))

                VStack(alignment: .leading, spacing: 8) {
                    Text(tender.name)
                        .font(.title.bold())
                    Text(tender.restaurant)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                    
                    if !tender.address.isEmpty && tender.address != "Address not available" {
                        Label(tender.address, systemImage: "mappin.and.ellipse")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    if let phone = tender.phoneNumber {
                        Link(destination: URL(string: "tel:\(phone)")!) {
                            Label(phone, systemImage: "phone.fill")
                                .font(.subheadline)
                        }
                    }
                }

                Divider()

                VStack(alignment: .leading, spacing: 12) {
                    Text("Details")
                        .font(.headline)
                    HStack {
                        Text("Price range")
                        Spacer()
                        Text(tender.price).bold()
                    }
                    
                    HStack(spacing: 12) {
                        Link(destination: URL(string: "http://maps.apple.com/?daddr=\(tender.coordinate.latitude),\(tender.coordinate.longitude)")!) {
                            Label("Directions", systemImage: "map")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        if let url = tender.url {
                            Link(destination: url) {
                                Label("Website", systemImage: "safari")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.orange.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .foregroundStyle(.orange)
                            }
                        } else {
                            Link(destination: URL(string: "https://www.google.com/search?q=\(tender.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")!) {
                                Label("Search", systemImage: "magnifyingglass")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.orange.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .foregroundStyle(.orange)
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Restaurant Details")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if let imageURL = tender.imageURL, loadedImage == nil {
                await loadImage(from: imageURL)
            }
        }
    }
    
    private func loadImage(from url: URL) async {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                await MainActor.run {
                    loadedImage = image
                }
            }
        } catch {
            print("Failed to load image: \(error)")
        }
    }
}

// MARK: - Root
struct ContentView: View {
    @State private var vm = TenderDeckViewModel()
    @State private var locationManager = LocationManager()

    var body: some View {
        TabView {
            NavigationStack {
                ZStack(alignment: .bottom) {
                    // Full screen card deck
                    SwipeDeckView(viewModel: vm, locationManager: locationManager)
                        .ignoresSafeArea(edges: .top)
                    
                    // Floating action buttons
                    HStack(spacing: 44) {
                        Button {
                            withAnimation(.spring()) { vm.swipeLeft() }
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 26, weight: .bold))
                                .foregroundStyle(.red)
                                .frame(width: 72, height: 72)
                                .background(.white, in: Circle())
                                .shadow(color: .black.opacity(0.12), radius: 12, y: 6)
                        }
                        .disabled(vm.deck.isEmpty || vm.isLoading)
                        
                        Button {
                            withAnimation(.spring()) { vm.swipeRight() }
                        } label: {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundStyle(.green)
                                .frame(width: 72, height: 72)
                                .background(.white, in: Circle())
                                .shadow(color: .black.opacity(0.12), radius: 12, y: 6)
                        }
                        .disabled(vm.deck.isEmpty || vm.isLoading)
                    }
                    .padding(.bottom, 44)
                }
                .navigationTitle("Tendr")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .task {
                    // Request location and load restaurants on appear
                    locationManager.requestLocation()
                    
                    // Wait a moment for location to be fetched
                    try? await Task.sleep(for: .seconds(1))
                    
                    if let location = locationManager.userLocation {
                        await vm.loadRestaurants(near: location)
                    }
                }
            }
            .tabItem {
                Label("Discover", systemImage: "flame.fill")
            }

            NavigationStack {
                SavedListView(viewModel: vm)
            }
            .tabItem {
                Label("Saved", systemImage: "bookmark.fill")
            }
        }
        .tint(.orange)
    }
}

#Preview("Main View") {
    ContentView()
}
