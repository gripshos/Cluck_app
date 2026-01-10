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
            List {
                // Support Section
                Section {
                    Button(action: { showTipJar = true }) {
                        HStack {
                            Image(systemName: "heart.fill")
                                .foregroundStyle(.pink)
                                .font(.title3)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Support Cluck")
                                    .font(.body.weight(.medium))
                                    .foregroundStyle(.primary)
                                
                                Text("Leave a tip to support development")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.tertiary)
                                .font(.caption.weight(.semibold))
                        }
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(PlainButtonStyle())
                } header: {
                    Text("Support")
                }
                
                // App Section
                Section {
                    // Version
                    HStack {
                        Text("Version")
                            .foregroundStyle(.primary)
                        Spacer()
                        Text(appVersion)
                            .foregroundStyle(.secondary)
                    }
                    
                    // Rate App
                    Button(action: rateApp) {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundStyle(.orange)
                                .font(.body)
                            
                            Text("Rate Cluck")
                                .foregroundStyle(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "arrow.up.right")
                                .foregroundStyle(.tertiary)
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
                                .foregroundStyle(.blue)
                                .font(.body)
                            
                            Text("Share Cluck")
                                .foregroundStyle(.primary)
                            
                            Spacer()
                        }
                    }
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .tint(Color(red: 1.0, green: 0.3, blue: 0.2))
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
