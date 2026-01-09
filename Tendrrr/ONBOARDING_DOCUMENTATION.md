# Onboarding Tutorial System

## Overview
The Cluck app now includes a comprehensive onboarding tutorial system that guides new users through the app's features. The tutorial only shows on the first app launch, with an option to replay it from the Saved screen.

## Features

### 🎯 Tutorial Content
The onboarding covers 6 key screens:

1. **Welcome** - Introduction to Cluck
2. **Swipe to Decide** - Shows how to swipe right (like) or left (skip) with animated gesture hints
3. **Save Your Favorites** - Explains that right swipes save restaurants
4. **Get Directions** - Shows how to tap cards for details, directions, and delivery
5. **Made a Mistake?** - Explains the Undo button
6. **Ready to Cluck?** - Final encouragement screen with "Get Started" button

### ✨ User Experience Features

- **Dynamic gradient backgrounds** that change color for each page
- **Animated emojis** with scale effects and glow
- **Gesture hints** with animated thumbs up/down icons on the swipe page
- **Custom page indicators** with smooth transitions
- **Skip button** on all pages except the last
- **Smooth animations** throughout the experience

### 🎨 Visual Design

- Full-screen presentation with no distractions
- Gradient backgrounds matching the app's color scheme
- Large, friendly emojis (100pt size)
- Clear, bold titles (32pt rounded font)
- Easy-to-read descriptions with proper spacing
- Professional shadows and effects

## Implementation

### Files Created

1. **OnboardingView.swift** - Main onboarding UI component
   - `OnboardingView` - Container view with page navigation
   - `OnboardingPage` - Data model for each tutorial page
   - `OnboardingPageView` - Individual page view with animations

2. **OnboardingHelper.swift** - State management utilities
   - `hasCompletedOnboarding` - Check completion status
   - `completeOnboarding()` - Mark as completed
   - `resetOnboarding()` - Reset for testing or replay

### Files Modified

1. **ContentView.swift**
   - Added state to check onboarding completion
   - Shows onboarding as full-screen cover on first launch
   - Uses UserDefaults key: `"hasCompletedOnboarding"`

2. **SavedListView.swift**
   - Added help button (❓) to header
   - Confirmation dialog before replaying tutorial
   - Can show tutorial at any time via help button

3. **SavedHeader.swift** (within SavedListView.swift)
   - Added `onHelpTapped` callback parameter
   - Help button always visible in header

## Usage

### For Users

**First Launch:**
- Tutorial automatically appears on first app open
- Users can skip at any time or go through all pages
- Tapping "Get Started" on final page dismisses tutorial

**Replaying Tutorial:**
1. Navigate to the "Saved" tab
2. Tap the question mark (❓) button in the top right
3. Confirm "Show Tutorial" in the dialog
4. Tutorial replays from the beginning

### For Developers

**Testing the Tutorial:**

```swift
// Force show tutorial on next app launch
OnboardingHelper.resetOnboarding()

// Check if user has completed onboarding
if OnboardingHelper.hasCompletedOnboarding {
    print("User has seen the tutorial")
}

// Manually trigger onboarding (in any view)
@State private var showOnboarding = false

Button("Show Tutorial") {
    showOnboarding = true
}
.fullScreenCover(isPresented: $showOnboarding) {
    OnboardingView(isPresented: $showOnboarding)
}
```

**Resetting for Testing:**
- Delete the app and reinstall
- OR: Call `OnboardingHelper.resetOnboarding()` in code
- OR: Use Xcode's "Reset Content and Settings" in simulator

## Technical Details

### State Management
- Uses `UserDefaults` with key `"hasCompletedOnboarding"`
- Boolean value: `false` = needs onboarding, `true` = completed
- Persists across app launches

### Animations
- Spring animations for smooth, natural feel
- Page transitions use SwiftUI's TabView with gesture support
- Emoji scale animations with glow effects
- Gesture hints use repeating animations

### Navigation
- Full-screen cover presentation style
- Non-dismissible by default (must complete or skip)
- Smooth transitions between pages
- Custom page indicators

## Customization

### Adding New Pages

Edit the `pages` array in `OnboardingView`:

```swift
OnboardingPage(
    emoji: "🎉",
    title: "Your Title",
    description: "Your description text",
    accentColor: Color(red: 1.0, green: 0.3, blue: 0.2),
    gestureHint: .tap // Optional: .swipe or .tap
)
```

### Changing Colors

Modify the `accentColor` property for each page to match your desired gradient.

### Modifying Content

All tutorial text is in the `pages` array initialization. Simply edit the `title` and `description` strings.

## Best Practices

1. **Keep it short** - Currently 6 pages, users can skip
2. **Visual first** - Large emojis and gestures over text
3. **Allow skipping** - Skip button on all pages except last
4. **Easy replay** - Help button always accessible
5. **Smooth animations** - Professional feel throughout

## Future Enhancements

Potential improvements:
- [ ] Analytics to track completion rate
- [ ] A/B testing different tutorial content
- [ ] Interactive tutorial overlays on actual app screens
- [ ] Video demonstrations instead of static images
- [ ] Localization for multiple languages
- [ ] Tutorial completion badges or rewards

## Accessibility

Current accessibility features:
- Large text and emojis
- High contrast white text on colored backgrounds
- VoiceOver compatible (SwiftUI default)
- Simple, clear language

Future accessibility improvements:
- [ ] Reduced motion alternative for animations
- [ ] Screen reader optimized descriptions
- [ ] Larger text size options
- [ ] High contrast mode support

---

**Version:** 1.0  
**Last Updated:** January 9, 2026  
**Developer:** Cluck Team
