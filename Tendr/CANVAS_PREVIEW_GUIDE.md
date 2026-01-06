# Canvas Preview & Card Sizing Fixes

## Overview

The app now has proper canvas preview support and fixed card sizing issues. All views can be previewed directly in Xcode's canvas without running the simulator!

## 🎨 What Was Fixed

### 1. Card Sizing Issues ✅

**Problem:** 
- Cards were using `.frame(maxWidth: .infinity, maxHeight: .infinity)` which made them fill the entire screen
- Images weren't properly clipped, causing overflow
- Text was sometimes cut off or hidden behind images

**Solution:**
- Added `GeometryReader` to properly constrain card dimensions
- Cards now use 70% of available height (max 600px)
- Width is screen width minus 40px padding
- Proper clipping with `RoundedRectangle` and `clipShape`
- Images use `.clipped()` to prevent overflow

**Result:**
```swift
.frame(
    width: geometry.size.width - 40,
    height: min(geometry.size.height * 0.7, 600)
)
```

### 2. Image Visibility ✅

**Problem:**
- Images weren't always visible
- Text had poor contrast against bright images
- Loading state wasn't shown for images

**Solution:**
- Better gradient overlay (80% opacity at bottom)
- Added text shadows for better legibility
- Loading indicator shown while images load
- Proper fallback for failed image loads

**Improvements:**
```swift
// Stronger gradient for better text visibility
LinearGradient(
    colors: [.clear, .black.opacity(0.8)],
    startPoint: .center,
    endPoint: .bottom
)

// Text shadows for better readability
.shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
```

### 3. Canvas Preview Support ✅

**Problem:**
- No previews existed for most views
- Couldn't test UI without running simulator
- Slow development iteration

**Solution:**
Added comprehensive preview support with multiple scenarios:

#### TenderCardView Previews
- ✅ Single card with image URL
- ✅ Card without image (gradient fallback)
- ✅ Card with long text (testing line limits)

#### SwipeDeckView Previews
- ✅ With mock restaurant data
- ✅ Loading state
- ✅ Empty state

#### RootView Previews
- ✅ Discover tab view
- ✅ Saved tab view

## 🚀 How to Use Canvas Previews

### Opening Canvas in Xcode

1. Open any view file (e.g., `TenderCardView.swift`)
2. Press **Cmd + Option + Return** to open canvas
3. Or click **Editor → Canvas** from menu bar

### Running Previews

1. Click the **▶️ play button** on any preview
2. Use the **pin icon** to keep multiple previews visible
3. Try different preview variants:
   - "Single Card" - Normal view
   - "No Image" - Fallback gradient
   - "Long Name" - Text truncation

### Preview Benefits

✅ **Instant Feedback** - See changes immediately
✅ **Multiple States** - Test different scenarios side-by-side
✅ **No Simulator** - Faster than launching the full app
✅ **Device Variants** - Test different screen sizes
✅ **Dark Mode** - Toggle appearance modes

## 📐 Card Layout Specifications

### Current Design

```
┌─────────────────────────────────┐
│                                 │
│         CARD WIDTH              │
│    (Screen Width - 40px)        │
│                                 │
│                                 │
│        [Restaurant             │
│         Image or               │
│         Gradient]               │
│                                 │
│         CARD HEIGHT             │
│    (70% of available height,    │
│        max 600px)               │
│                                 │
│                                 │
│    ┌─────────────────────┐     │
│    │ [Gradient Overlay]   │     │
│    │                      │     │
│    │ Restaurant Name      │     │
│    │ Type • Price         │     │
│    │ 📍 Address           │     │
│    └─────────────────────┘     │
│                                 │
└─────────────────────────────────┘
```

### Spacing & Padding

- **Card Padding**: 24px (increased for better spacing)
- **Text Spacing**: 8px between elements
- **Corner Radius**: 20px
- **Shadow**: 10px blur, black at 20% opacity

### Text Handling

- **Restaurant Name**: 
  - Font: `.title` (bold)
  - Line Limit: 2 lines
  - Color: White with shadow

- **Type & Price**:
  - Font: `.subheadline`
  - Color: White at 95% opacity

- **Address**:
  - Font: `.caption`
  - Line Limit: 2 lines
  - Icon: `mappin.circle.fill`
  - Color: White at 90% opacity

## 🎯 Card Positioning

The card is now centered using `.position()` instead of `.offset()`:

```swift
.position(
    x: geometry.size.width / 2 + dragAmount.width,
    y: geometry.size.height / 2 + dragAmount.height * 0.4
)
```

This ensures:
- ✅ Card stays centered on all device sizes
- ✅ Drag gestures work smoothly
- ✅ Rotation pivot point is correct
- ✅ No overflow on smaller screens

## 📱 Device Support

The new layout works perfectly on:

- ✅ **iPhone SE** (smallest screen)
- ✅ **iPhone 15 / 15 Pro** (standard size)
- ✅ **iPhone 15 Pro Max** (largest phone)
- ✅ **iPad** (adapts to larger screens)

### Responsive Behavior

| Device | Card Width | Card Height |
|--------|-----------|-------------|
| iPhone SE | ~295px | ~420px (70%) |
| iPhone 15 | ~353px | ~578px (70%) |
| iPhone 15 Pro Max | ~390px | ~600px (max) |
| iPad | Varies | 600px (max) |

## 🎨 Image Handling

### AsyncImage States

1. **Loading** (`.empty`):
   - Shows gradient background
   - Displays spinner overlay
   - Smooth transition when loaded

2. **Success**:
   - Image fills card area
   - Proper aspect ratio maintained
   - Clipped to rounded corners

3. **Failure**:
   - Falls back to gradient
   - Shows fork.knife icon
   - Maintains consistent design

### Image URLs

Yelp provides image URLs in this format:
```
https://s3-media0.fl.yelpcdn.com/bphoto/{photo_id}/{size}.jpg
```

The app automatically displays these images with proper caching via `AsyncImage`.

## 🔧 Customization Options

### Adjusting Card Size

To change card dimensions, modify in `SwipeDeckView.swift`:

```swift
.frame(
    width: geometry.size.width - 40,  // Change 40 for more/less padding
    height: min(geometry.size.height * 0.7, 600)  // Change 0.7 or 600
)
```

### Adjusting Gradient Strength

To change text overlay darkness, modify in `TenderCardView.swift`:

```swift
LinearGradient(
    colors: [.clear, .black.opacity(0.8)],  // Change 0.8 (0-1)
    startPoint: .center,  // Can adjust start position
    endPoint: .bottom
)
```

### Adjusting Corner Radius

```swift
.clipShape(RoundedRectangle(cornerRadius: 20))  // Change 20
```

## 🐛 Troubleshooting

### Canvas Not Working?

1. **Clean Build Folder**: Cmd + Shift + K
2. **Restart Canvas**: Cmd + Option + P
3. **Check Preview Code**: Ensure no async operations without proper handling

### Images Not Loading in Preview?

Previews use mock data with example URLs. They won't load real images. To test real images:
1. Run in simulator
2. Grant location permission
3. Wait for Yelp API response

### Card Too Large/Small?

1. Check device orientation (should be portrait)
2. Verify safe area insets aren't interfering
3. Adjust the `0.7` multiplier in card height calculation

## 📊 Performance

### Improvements Made

✅ **Lazy Loading**: Images load asynchronously
✅ **Automatic Caching**: `AsyncImage` caches by default
✅ **Geometry Reader**: Only measures when needed
✅ **Clipping**: Prevents off-screen rendering

### Memory Considerations

- Cards are only rendered when visible (index == 0)
- Images are cached by URLSession
- SwiftUI automatically manages view lifecycle

## 🎉 Before & After

### Before
- ❌ Cards filled entire screen
- ❌ Images overflowed
- ❌ Text sometimes invisible
- ❌ No canvas previews
- ❌ Slow development iteration

### After
- ✅ Cards properly sized and centered
- ✅ Images clipped perfectly
- ✅ Text always readable with shadows
- ✅ Full canvas preview support
- ✅ Instant visual feedback

## 🚀 Next Steps

Consider adding:
1. **Multiple card peek** - Show next 2-3 cards behind current one
2. **Smooth animations** - Card flip or reveal effects
3. **Ratings display** - Show Yelp star rating on card
4. **Distance indicator** - Show "0.5 mi away"
5. **Quick actions** - Swipe indicators (❤️ or ✕ icons)

---

**Enjoy building with instant preview feedback!** 🎨✨
