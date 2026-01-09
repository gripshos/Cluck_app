//
//  SettingsView.swift
//  Cluck
//
//  Settings and about screen
//

import SwiftUI
import StoreKit

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    let storeKitService: StoreKitService
    
    @State private var showTipJar = false
    
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
                
                List {
                    // Support Section
                    Section {
                        Button(action: { showTipJar = true }) {
                            HStack {
                                Image(systemName: "heart.fill")
                                    .foregroundColor(.pink)
                                    .font(.title3)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Support Cluck")
                                        .font(.body.weight(.medium))
                                        .foregroundColor(.primary)
                                    
                                    Text("Leave a tip to support development")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                                    .font(.caption.weight(.semibold))
                            }
                            .padding(.vertical, 8)
                        }
                        .buttonStyle(PlainButtonStyle())
                    } header: {
                        Text("Support")
                    }
                    .listRowBackground(Color.white.opacity(0.8))
                    
                    // App Section
                    Section {
                        // Version
                        HStack {
                            Text("Version")
                                .foregroundColor(.primary)
                            Spacer()
                            Text(appVersion)
                                .foregroundColor(.secondary)
                        }
                        
                        // Rate App
                        Button(action: rateApp) {
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.orange)
                                    .font(.body)
                                
                                Text("Rate Cluck")
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Image(systemName: "arrow.up.right")
                                    .foregroundColor(.secondary)
                                    .font(.caption.weight(.semibold))
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Share App
                        ShareLink(
                            item: URL(string: "https://apps.apple.com/app/cluck")!,
                            subject: Text("Cluck App"),
                            message: Text("Check out Cluck - discover great restaurants!")
                        ) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                    .foregroundColor(.blue)
                                    .font(.body)
                                
                                Text("Share Cluck")
                                    .foregroundColor(.primary)
                                
                                Spacer()
                            }
                        }
                    } header: {
                        Text("About")
                    }
                    .listRowBackground(Color.white.opacity(0.8))
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color(red: 1.0, green: 0.3, blue: 0.2))
                }
            }
            .sheet(isPresented: $showTipJar) {
                TipJarView(storeKitService: storeKitService)
            }
        }
    }
    
    // MARK: - Helpers
    
    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
    
    private func rateApp() {
        // Request review from the user
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}

// MARK: - Preview

#Preview {
    SettingsView(storeKitService: StoreKitService())
}
