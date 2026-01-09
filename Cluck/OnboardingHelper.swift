//
//  OnboardingHelper.swift
//  Cluck
//
//  Helper utilities for managing onboarding state
//

import Foundation

struct OnboardingHelper {
    private static let hasCompletedKey = "hasCompletedOnboarding"
    
    /// Check if the user has completed onboarding
    static var hasCompletedOnboarding: Bool {
        UserDefaults.standard.bool(forKey: hasCompletedKey)
    }
    
    /// Mark onboarding as completed
    static func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: hasCompletedKey)
    }
    
    /// Reset onboarding (useful for testing or user-requested tutorial replay)
    static func resetOnboarding() {
        UserDefaults.standard.set(false, forKey: hasCompletedKey)
    }
    
    /// Force show onboarding on next app launch (for testing)
    static func showOnNextLaunch() {
        resetOnboarding()
    }
}
