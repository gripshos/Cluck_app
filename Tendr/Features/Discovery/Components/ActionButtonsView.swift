//
//  ActionButtonsView.swift
//  Tendr
//
//  Floating action buttons for swipe actions
//

import SwiftUI

/// Floating action buttons for like/nope actions.
struct ActionButtonsView: View {
    let onNope: () -> Void
    let onLike: () -> Void
    let disabled: Bool
    
    var body: some View {
        HStack(spacing: 44) {
            // Nope button
            ActionButton(
                systemImage: "xmark",
                color: .red,
                size: 72,
                action: onNope
            )
            .disabled(disabled)
            
            // Like button
            ActionButton(
                systemImage: "heart.fill",
                color: .green,
                size: 72,
                action: onLike
            )
            .disabled(disabled)
        }
    }
}

/// Individual action button with consistent styling.
struct ActionButton: View {
    let systemImage: String
    let color: Color
    let size: CGFloat
    let action: () -> Void
    
    @Environment(\.isEnabled) private var isEnabled
    
    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: size * 0.38, weight: .bold))
                .foregroundStyle(isEnabled ? color : .gray)
                .frame(width: size, height: size)
                .background(.white, in: Circle())
                .shadow(color: .black.opacity(0.12), radius: 12, y: 6)
        }
        .buttonStyle(.plain)
        .scaleEffect(isEnabled ? 1.0 : 0.9)
        .animation(.spring(response: 0.3), value: isEnabled)
    }
}

// MARK: - Preview

#Preview("Action Buttons") {
    VStack(spacing: 40) {
        ActionButtonsView(
            onNope: { print("Nope") },
            onLike: { print("Like") },
            disabled: false
        )
        
        ActionButtonsView(
            onNope: { print("Nope") },
            onLike: { print("Like") },
            disabled: true
        )
    }
    .padding()
    .background(Color.gray.opacity(0.2))
}
