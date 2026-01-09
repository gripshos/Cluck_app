//
//  TipJarView.swift
//  Cluck
//
//  Tip jar interface for optional donations
//

import SwiftUI
import StoreKit

struct TipJarView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: TipJarViewModel
    
    init(storeKitService: StoreKitService) {
        self._viewModel = State(initialValue: TipJarViewModel(storeKitService: storeKitService))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient matching app style
                LinearGradient(
                    colors: [
                        Color(red: 1.0, green: 0.95, blue: 0.9),
                        Color.white
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 12) {
                            Text("🐔")
                                .font(.system(size: 64))
                            
                            Text("Support Cluck")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(Color(red: 1.0, green: 0.3, blue: 0.2))
                            
                            Text("If Cluck made it easier for you to find hot, fresh tenders in your area, consider a tip!")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding(.top, 32)
                        
                        // Thank you overlay
                        if viewModel.showThankYou {
                            thankYouCard
                                .transition(.scale.combined(with: .opacity))
                        }
                        
                        // Content states
                        if viewModel.isLoading {
                            loadingView
                        } else if !viewModel.products.isEmpty {
                            tipsSection
                        } else if let error = viewModel.errorMessage {
                            errorView(message: error)
                        } else {
                            emptyView
                        }
                        
                        // Bottom spacing
                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color(red: 1.0, green: 0.3, blue: 0.2))
                }
            }
        }
    }
    
    // MARK: - Tips Section
    
    private var tipsSection: some View {
        VStack(spacing: 16) {
            ForEach(viewModel.products, id: \.id) { product in
                TipButton(
                    product: product,
                    isPurchasing: viewModel.isPurchasing
                ) {
                    Task {
                        await viewModel.purchaseTip(product)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .disabled(viewModel.isPurchasing)
    }
    
    // MARK: - Thank You Card
    
    private var thankYouCard: some View {
        VStack(spacing: 16) {
            Text("🎉")
                .font(.system(size: 48))
            
            Text("Thank You!")
                .font(.title.bold())
                .foregroundColor(Color(red: 1.0, green: 0.3, blue: 0.2))
            
            Text("Your support means the world!")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 20, y: 10)
        )
        .padding(.horizontal, 20)
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Loading...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
    
    // MARK: - Error View
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Try Again") {
                Task {
                    await viewModel.reloadProducts()
                }
            }
            .buttonStyle(SecondaryButtonStyle())
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    // MARK: - Empty View
    
    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "cart")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("No tips available")
                .font(.body)
                .foregroundColor(.secondary)
            
            Button("Reload") {
                Task {
                    await viewModel.reloadProducts()
                }
            }
            .buttonStyle(SecondaryButtonStyle())
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

// MARK: - Tip Button Component

struct TipButton: View {
    let product: Product
    let isPurchasing: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Emoji
                Text(emoji(for: product))
                    .font(.system(size: 32))
                
                // Product info
                VStack(alignment: .leading, spacing: 4) {
                    Text(tierName(for: product))
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(product.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Price
                if isPurchasing {
                    ProgressView()
                        .scaleEffect(0.9)
                } else {
                    Text(product.displayPrice)
                        .font(.title3.bold())
                        .foregroundColor(Color(red: 1.0, green: 0.3, blue: 0.2))
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.08), radius: 12, y: 6)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isPurchasing)
        .opacity(isPurchasing ? 0.6 : 1.0)
    }
    
    // MARK: - Helpers
    
    private func emoji(for product: Product) -> String {
        // Match product ID to emoji
        if let tipProduct = TipProduct(rawValue: product.id) {
            return tipProduct.emoji
        }
        return "🍗"
    }
    
    private func tierName(for product: Product) -> String {
        // Derive tier name from product ID
        if product.id.contains("small") {
            return "Small Tip"
        } else if product.id.contains("medium") {
            return "Medium Tip"
        } else if product.id.contains("large") {
            return "Large Tip"
        }
        return "Tip"
    }
}

// MARK: - Secondary Button Style

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.weight(.medium))
            .foregroundColor(Color(red: 1.0, green: 0.3, blue: 0.2))
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 1.0, green: 0.3, blue: 0.2).opacity(0.1))
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview {
    TipJarView(storeKitService: StoreKitService())
}
