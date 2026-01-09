//
//  OnboardingView.swift
//  Cluck
//
//  First-time user onboarding tutorial
//

import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var currentPage = 0
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            emoji: "👋",
            title: "Welcome to Cluck!",
            description: "Your personal guide to finding the best chicken tenders near you.",
            accentColor: Color(red: 1.0, green: 0.3, blue: 0.2)
        ),
        OnboardingPage(
            emoji: "👆",
            title: "Swipe to Decide",
            description: "Swipe right on restaurants you want to save, or swipe left to skip them.",
            accentColor: Color(red: 1.0, green: 0.4, blue: 0.2),
            gestureHint: .swipe
        ),
        OnboardingPage(
            emoji: "❤️",
            title: "Save Your Favorites",
            description: "Restaurants you swipe right on are saved to your Favorites list for easy access.",
            accentColor: Color(red: 1.0, green: 0.3, blue: 0.4)
        ),
        OnboardingPage(
            emoji: "📍",
            title: "Get Directions",
            description: "Tap on any card to see details, get directions, and order delivery.",
            accentColor: Color(red: 1.0, green: 0.5, blue: 0.2)
        ),
        OnboardingPage(
            emoji: "🔄",
            title: "Made a Mistake?",
            description: "Use the Undo button to bring back the last restaurant you swiped.",
            accentColor: Color(red: 1.0, green: 0.4, blue: 0.3)
        ),
        OnboardingPage(
            emoji: "🍗",
            title: "Ready to Cluck?",
            description: "Let's find you some amazing chicken tenders!",
            accentColor: Color(red: 1.0, green: 0.3, blue: 0.2)
        )
    ]
    
    var body: some View {
        ZStack {
            // Dynamic background gradient based on current page
            LinearGradient(
                colors: [
                    pages[currentPage].accentColor,
                    pages[currentPage].accentColor.opacity(0.7)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.5), value: currentPage)
            
            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    if currentPage < pages.count - 1 {
                        Button {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                completeOnboarding()
                            }
                        } label: {
                            Text("Skip")
                                .font(.headline)
                                .foregroundStyle(.white.opacity(0.9))
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                        }
                    }
                }
                .padding()
                
                Spacer()
                
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                Spacer()
                
                // Custom page indicator
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(currentPage == index ? Color.white : Color.white.opacity(0.3))
                            .frame(width: currentPage == index ? 10 : 8, height: currentPage == index ? 10 : 8)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
                    }
                }
                .padding(.bottom, 20)
                
                // Next/Get Started button
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        if currentPage < pages.count - 1 {
                            currentPage += 1
                        } else {
                            completeOnboarding()
                        }
                    }
                } label: {
                    Text(currentPage < pages.count - 1 ? "Next" : "Get Started")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(pages[currentPage].accentColor)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.white)
                        )
                        .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
    }
    
    private func completeOnboarding() {
        // Mark onboarding as completed
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        isPresented = false
    }
}

// MARK: - Onboarding Page Model

struct OnboardingPage {
    let emoji: String
    let title: String
    let description: String
    let accentColor: Color
    var gestureHint: GestureHint?
    
    init(emoji: String, title: String, description: String, accentColor: Color, gestureHint: GestureHint? = nil) {
        self.emoji = emoji
        self.title = title
        self.description = description
        self.accentColor = accentColor
        self.gestureHint = gestureHint
    }
    
    enum GestureHint {
        case swipe
        case tap
    }
}

// MARK: - Onboarding Page View

struct OnboardingPageView: View {
    let page: OnboardingPage
    @State private var emojiScale: CGFloat = 0.5
    @State private var contentOpacity: Double = 0
    @State private var gestureOffset: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 32) {
            // Animated emoji
            ZStack {
                // Glow effect
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.white.opacity(0.3), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 100
                        )
                    )
                    .frame(width: 200, height: 200)
                    .scaleEffect(emojiScale)
                
                Text(page.emoji)
                    .font(.system(size: 100))
                    .scaleEffect(emojiScale)
            }
            .frame(height: 200)
            
            VStack(spacing: 16) {
                // Title
                Text(page.title)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                
                // Description
                Text(page.description)
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .opacity(contentOpacity)
            
            // Gesture hint animation
            if let hint = page.gestureHint {
                gestureHintView(for: hint)
                    .opacity(contentOpacity)
                    .padding(.top, 20)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                emojiScale = 1.0
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
                contentOpacity = 1.0
            }
            
            // Start gesture animation
            if page.gestureHint != nil {
                startGestureAnimation()
            }
        }
    }
    
    @ViewBuilder
    private func gestureHintView(for hint: OnboardingPage.GestureHint) -> some View {
        switch hint {
        case .swipe:
            HStack(spacing: 40) {
                VStack(spacing: 8) {
                    Image(systemName: "hand.thumbsdown.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(.white.opacity(0.8))
                        .rotationEffect(.degrees(-20))
                        .offset(x: gestureOffset * -0.5)
                    Text("Nope")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white.opacity(0.7))
                }
                
                VStack(spacing: 8) {
                    Image(systemName: "hand.thumbsup.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(.white.opacity(0.8))
                        .rotationEffect(.degrees(20))
                        .offset(x: gestureOffset * 0.5)
                    Text("Like")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
            
        case .tap:
            VStack(spacing: 12) {
                Image(systemName: "hand.tap.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(.white.opacity(0.8))
                Text("Tap for details")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
    }
    
    private func startGestureAnimation() {
        withAnimation(
            .easeInOut(duration: 1.5)
            .repeatForever(autoreverses: true)
            .delay(0.5)
        ) {
            gestureOffset = 20
        }
    }
}

