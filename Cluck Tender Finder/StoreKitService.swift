//
//  StoreKitService.swift
//  Cluck
//
//  StoreKit 2 service for handling in-app purchases (tip jar)
//

import StoreKit
import Foundation

/// Product identifiers for tip jar consumables
enum TipProduct: String, CaseIterable {
    case small = "com.sag.cluck.tip.small"
    case medium = "com.sag.cluck.tip.medium"
    case large = "com.sag.cluck.tip.large"
    
    var emoji: String {
        switch self {
        case .small: return "🍗"
        case .medium: return "🍗🍗"
        case .large: return "🍗🍗🍗"
        }
    }
}

/// Service managing all StoreKit 2 interactions for the tip jar
@MainActor
@Observable
final class StoreKitService {
    
    // MARK: - Observable State
    
    /// Loaded products from the App Store
    private(set) var products: [Product] = []
    
    /// Whether products are currently loading
    private(set) var isLoading = false
    
    /// Error message if product loading or purchase fails
    private(set) var errorMessage: String?
    
    /// Whether a purchase is currently in progress
    private(set) var isPurchasing = false
    
    // MARK: - Initialization
    
    init() {
        // Load products on initialization
        Task {
            await loadProducts()
        }
    }
    
    // MARK: - Product Loading
    
    /// Load products from the App Store
    func loadProducts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Get all product IDs
            let productIDs = TipProduct.allCases.map { $0.rawValue }
            
            // Request products from StoreKit
            let loadedProducts = try await Product.products(for: productIDs)
            
            // Sort by price (low to high)
            products = loadedProducts.sorted { $0.price < $1.price }
            
            isLoading = false
        } catch {
            errorMessage = "Failed to load products. Please try again later."
            isLoading = false
            print("❌ StoreKit error loading products: \(error)")
        }
    }
    
    // MARK: - Purchase Handling
    
    /// Purchase a tip product
    /// - Parameter product: The product to purchase
    /// - Returns: True if purchase was successful, false otherwise
    @discardableResult
    func purchase(_ product: Product) async -> Bool {
        isPurchasing = true
        errorMessage = nil
        
        do {
            // Attempt the purchase
            let result = try await product.purchase()
            
            // Handle the purchase result
            switch result {
            case .success(let verificationResult):
                // Verify the transaction
                let transaction = try checkVerified(verificationResult)
                
                // Transaction verified successfully
                print("✅ Purchase successful: \(product.displayName)")
                
                // Finish the transaction (consumables don't persist)
                await transaction.finish()
                
                isPurchasing = false
                return true
                
            case .userCancelled:
                // User cancelled - this is normal, no error message needed
                print("ℹ️ User cancelled purchase")
                isPurchasing = false
                return false
                
            case .pending:
                // Purchase is pending (e.g., requires parental approval)
                errorMessage = "Purchase is pending approval."
                isPurchasing = false
                return false
                
            @unknown default:
                errorMessage = "An unknown error occurred."
                isPurchasing = false
                return false
            }
            
        } catch StoreKitError.networkError {
            errorMessage = "Network error. Please check your connection and try again."
            isPurchasing = false
            print("❌ Network error during purchase")
            return false
            
        } catch StoreKitError.notAvailableInStorefront {
            errorMessage = "This purchase is not available in your region."
            isPurchasing = false
            print("❌ Product not available in storefront")
            return false
            
        } catch {
            errorMessage = "Purchase failed. Please try again."
            isPurchasing = false
            print("❌ Purchase error: \(error)")
            return false
        }
    }
    
    // MARK: - Transaction Verification
    
    /// Verify a transaction to ensure it's valid
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            // Transaction failed verification
            throw error
        case .verified(let safe):
            // Transaction is verified
            return safe
        }
    }
}
