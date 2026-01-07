//
//  StateViews.swift
//  Tendr
//
//  Reusable views for loading, empty, and error states
//

import SwiftUI

// MARK: - Loading View

/// Full-screen loading indicator for search operations.
struct LoadingStateView: View {
    var message: String = "Finding restaurants nearby..."
    
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.orange)
            
            Text(message)
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Empty View

/// Shown when no restaurants are found or deck is exhausted.
struct EmptyStateView: View {
    var title: String = "No more restaurants"
    var message: String = "We've run out of chicken tender spots nearby"
    var actionTitle: String = "Search Again"
    var onAction: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "fork.knife.circle")
                .font(.system(size: 72))
                .foregroundStyle(.secondary)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.title2.bold())
                
                Text(message)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            if let onAction {
                Button(action: onAction) {
                    Text(actionTitle)
                        .font(.headline)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
                .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Error View

/// Shown when search fails with actionable recovery options.
struct ErrorStateView: View {
    let error: SearchError
    var onRetry: (() -> Void)?
    var onOpenSettings: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: error.iconName)
                .font(.system(size: 72))
                .foregroundStyle(.orange)
            
            VStack(spacing: 8) {
                Text("Something went wrong")
                    .font(.title2.bold())
                
                Text(error.localizedDescription)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                if let suggestion = error.recoverySuggestion {
                    Text(suggestion)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .padding(.top, 4)
                }
            }
            
            HStack(spacing: 16) {
                if let onRetry {
                    Button(action: onRetry) {
                        Label("Try Again", systemImage: "arrow.clockwise")
                            .font(.headline)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                }
                
                if case .locationPermissionDenied = error, let onOpenSettings {
                    Button(action: onOpenSettings) {
                        Label("Settings", systemImage: "gear")
                            .font(.headline)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Location Permission View

/// Prompts user to grant location permission.
struct LocationPermissionView: View {
    var onRequestPermission: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "location.circle")
                .font(.system(size: 72))
                .foregroundStyle(.orange)
            
            VStack(spacing: 8) {
                Text("Enable Location")
                    .font(.title2.bold())
                
                Text("Tendr needs your location to find chicken tenders nearby")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Button(action: onRequestPermission) {
                Label("Enable Location", systemImage: "location.fill")
                    .font(.headline)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Previews

#Preview("Loading") {
    LoadingStateView()
}

#Preview("Empty") {
    EmptyStateView(onAction: { print("Search again") })
}

#Preview("Error - Network") {
    ErrorStateView(
        error: .networkError(underlying: "Connection timed out"),
        onRetry: { print("Retry") }
    )
}

#Preview("Error - Location Denied") {
    ErrorStateView(
        error: .locationPermissionDenied,
        onRetry: { print("Retry") },
        onOpenSettings: { print("Open settings") }
    )
}

#Preview("Location Permission") {
    LocationPermissionView(onRequestPermission: { print("Request permission") })
}
