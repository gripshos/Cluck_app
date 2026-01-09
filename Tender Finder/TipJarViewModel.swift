//
//  TipJarViewModel.swift
//  Cluck
//
//  ViewModel for the tip jar screen
//

import Foundation
import StoreKit
import Observation

@MainActor
@Observable
final class TipJarViewModel {
    
    // MARK: - Dependencies
    
    private let storeKitService: StoreKitService
    
    // MARK: - State
    
    /// Whether a purchase is currently in progress
    private(set) var purchaseInProgress = false
    
    /// Whether to show the thank you state
    private(set) var showThankYou = false
    
    // MARK: - Initialization
    
    init(storeKitService: StoreKitService) {
        self.storeKitService = storeKitService
    }
    
    // MARK: - Computed Properties
    
    /// Products sorted by price (exposed from service)
    var products: [Product] {
        storeKitService.products
    }
    
    /// Whether products are loading
    var isLoading: Bool {
        storeKitService.isLoading
    }
    
    /// Error message from service
    var errorMessage: String? {
        storeKitService.errorMessage
    }
    
    /// Whether a purchase is in progress (from service or local state)
    var isPurchasing: Bool {
        storeKitService.isPurchasing || purchaseInProgress
    }
    
    // MARK: - Actions
    
    /// Handle a tip purchase
    /// - Parameter product: The product to purchase
    func purchaseTip(_ product: Product) async {
        guard !isPurchasing else { return }
        
        purchaseInProgress = true
        
        // Attempt the purchase
        let success = await storeKitService.purchase(product)
        
        purchaseInProgress = false
        
        // Show thank you message on success
        if success {
            showThankYou = true
            
            // Auto-dismiss thank you after 2.5 seconds
            try? await Task.sleep(nanoseconds: 2_500_000_000)
            showThankYou = false
        }
    }
    
    /// Reload products from the App Store
    func reloadProducts() async {
        await storeKitService.loadProducts()
    }
}
